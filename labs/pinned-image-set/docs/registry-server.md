# Local registry server
The registry server has been installed in a different VM for an easier monitoring and control.  
The testing could be done using Quay but the requirements for this registry are lower.  

## VM settings
* vCPUs: 2
* Memory: 4096 MB
* Disk: 100 GB
* OS: Fedora Linux 39

## Software setup

### nginx
```shell
dnf install nginx -y
```
Create self-signed certificates:
```
$ mkdir /etc/pki/nginx/
$ openssl req -newkey rsa:4096 -nodes -sha256 -keyout /etc/pki/nginx/registry.key \
    -subj "/C=US/ST=North Carolina/L=Raleigh/O=Red Hat/CN=pinnedis-registry.pinnedis.local.lab" \
    -addext "subjectAltName=DNS:pinnedis-registry.pinnedis.local.lab,DNS:quay.io" \
    -x509 -days 730 -out /etc/pki/nginx/registry.pem
```
Add reverse proxy configuration:
```
    server {
        listen       443 ssl;
        listen       [::]:443 ssl;
        http2        on;
        server_name  _;

        access_log /var/log/nginx/registry-access.log;
        error_log /var/log/nginx/registry-error.log;

        ssl_certificate "/etc/pki/nginx/registry.pem";
        ssl_certificate_key "/etc/pki/nginx/registry.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers PROFILE=SYSTEM;
        ssl_prefer_server_ciphers on;

        client_max_body_size 0;
        chunked_transfer_encoding on;

        location /v2/ {
            proxy_pass                          http://localhost:5000;
            proxy_set_header  Host              $http_host;
            proxy_set_header  X-Real-IP         $remote_addr;
            proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
            proxy_set_header  X-Forwarded-Proto $scheme;
            proxy_read_timeout                  900;
        }
    }
```
Enable `nginx` service:
```shell
systemctl enable nginx.service --now
```
Enable the service in `firewalld`:
```shell
$ firewall-cmd --zone FedoraServer --add-service=https --permanent
$ firewall-cmd --reload
```
Enable `SELinux` access to port 5000:
```shell
ausearch -c 'nginx' --raw | audit2allow -M my-nginx
semodule -X 300 -i my-nginx.pp
```

### podman
```shell
dnf install podman -y
```

## Set up the registry
### Prepare the filesystem
```shell
$ mkdir /var/lib/registry
$ lvcreate -L 50G -n registry fedora_pinnedis-registry
$ mkfs.xfs -L registry /dev/fedora_pinnedis-registry/registry
$ echo "LABEL=registry                            /var/lib/registry       xfs     defaults        0 0" >> /etc/fstab
$ systemctl daemon-reload
$ mount /var/lib/registry/
```

### Start the registry
```shell
$ podman pull quay.io/mlorenzofr/registry:latest
$ podman run -d -p 5000:5000 --restart always --name registry -v /var/lib/registry:/var/lib/registry:Z registry:latest
```

## Validate
On an external host, copy the self-signed certificate to `/etc/containers/certs.d/`.
```shell
$ mkdir /etc/containers/certs.d/pinnedis-registry.pinnedis.local.lab
$ cp ca.crt /etc/containers/certs.d/pinnedis-registry.pinnedis.local.lab/
```
Tag an image and upload it to the registry:
```shell
$ podman tag 95ad8395795e pinnedis-registry.pinnedis.local.lab/ubi8/ubi
$ podman push pinnedis-registry.pinnedis.local.lab/ubi8/ubi --remove-signatures
```

## Links
* [Deploy a registry server](https://distribution.github.io/distribution/about/deploying/)
* [CNCF Distribution nginx recipes](https://distribution.github.io/distribution/recipes/nginx/)
* [containers-certs.d](https://github.com/containers/image/blob/main/docs/containers-certs.d.5.md)