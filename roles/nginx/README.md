# nginx

Install and configure nginx on the lab server so iPXE clients can
download scripts over HTTP.

## Requirements

RHEL 9, with the `nginx` package available from AppStream.

SELinux on RHEL 9 labels TCP 8080 as `http_cache_port_t`. The role
changes that label to `http_port_t` so nginx can bind the port, and
labels the document root as `httpd_sys_content_t`.

The lab host playbook disables firewalld. This role opens TCP `8080`
only when firewalld is already running.

## Role Variables

* `nginx_listen_address`. _String_. Bind address. Default: `'192.168.125.1'`
* `nginx_listen_port`. _Number_. Bind port. Default: `8080`
* `nginx_root`. _String_. iPXE document root. Default: `'/var/www/ipxe'`

## Example Playbook

```yaml

- hosts: lab
  roles:
    - nginx
```

## License

MIT / BSD

## Author Information

* **Manuel Lorenzo** (<mlorenzofr@redhat.com>) (2026-)
