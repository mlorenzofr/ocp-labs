# iSCSI setup for the iscsi lab

This document describes how to configure the iSCSI target, iPXE network boot, and iBFT initiator
parameters for the spoke cluster in the **iscsi** lab. The VM installs OpenShift on an
iSCSI LUN as its unique storage target.

The spoke VM must establish the iSCSI session **before** the assisted-service discovery ISO
starts. In this lab that is done with **iPXE** (which simulates **iBFT**) and only then the
discovery ISO image is attached and booted.

## Architecture

```text
┌──────────────────────────────────────────────────────────────────┐
│  Hub (SNO + MCE)                                                 │
│  assisted-service ──► InfraEnv + discovery ISO for spoke         │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  Spoke BMH VM (iscsi-sno-1)                                      │
│  1. PXE boot → iPXE                                              │
│  2. iPXE sets initiator IQN and logs in to iSCSI (iBFT)          │
│  3. sanboot fails (empty LUN) → fallback to discovery ISO        │
│  4. Agent discovers iSCSI disk and installs OpenShift on it      │
└──────────────────────────────────────────────────────────────────┘
                              │ iSCSI session (TCP/3260)
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  iSCSI target VM (iscsi)                                         │
│  192.168.125.150                                                 │
│  IQN: iqn.2023-01.com.example:target01                           │
│  LUN backed by /dev/vdb (120 GB)                                 │
└──────────────────────────────────────────────────────────────────┘
```

## Boot sequence

OpenShift on iSCSI requires the initiator to be logged in to the target **before** hardware
discovery runs on the discovery ISO. The spoke VM follows this sequence:

1. **Network boot (iPXE)**. The VM boots from Ethernet using iPXE served by dnsmasq on beaker.
2. **iBFT via iPXE**. The iPXE script sets the initiator IQN and connects to the iSCSI target.
   This populates `/sys/firmware/ibft` in the running system, simulating firmware iBFT tables.
3. **sanboot attempt**. iPXE tries to boot from the iSCSI LUN. The LUN is empty, so boot fails.
4. **Discovery ISO**. With the boot order set to network first and CD-ROM present (but not first
   in order), the VM falls back to the discovery ISO attached through Redfish virtual media.
5. **Agent discovery**. The assisted installer agent starts, finds the iSCSI disk already connected
   via iBFT, and uses it as the installation target.

QEMU UEFI firmware can configure an iSCSI target in the firmware menu, but the RHCOS kernel does
**not** read that configuration. **To simulate iBFT you must boot through iPXE.**

## iSCSI target server

Deploy a dedicated VM for the iSCSI target. [Fedora Server](https://download.fedoraproject.org/pub/fedora/linux/releases/) is sufficient.

### Target VM resources

| Resource | Value |
| --- | --- |
| vCPUs | 2 |
| Memory | 1.5 GB |
| OS disk | 20 GB |
| Data disk (`/dev/vdb`) | 120 GB (OpenShift installation LUN) |
| Hostname | `iscsi` |
| IP address | `192.168.125.150` |

### Install and configure targetcli

On the iSCSI target VM:

```shell
dnf install -y targetcli
```

Create the backing store and expose it through a target:

```shell
targetcli backstores/fileio create name=disk0 file_or_dev=/dev/vdb
targetcli /iscsi create iqn.2023-01.com.example:target01
targetcli /iscsi/iqn.2023-01.com.example:target01/tpg1/luns create /backstores/fileio/disk0
targetcli /iscsi/iqn.2023-01.com.example:target01/tpg1/acls create iqn.1994-05.com.redhat:e1c30923a3a
targetcli /iscsi/iqn.2023-01.com.example:target01/tpg1/acls create iqn.1994-05.com.redhat:c1c2623386e8
targetcli / saveconfig
```

The ACL initiator IQNs correspond to RHCOS 8 and RHCOS 9 default initiator names. The iPXE script
must use an IQN that matches one of the configured ACLs.

Review the configuration:

```shell
targetcli ls
```

### Firewall

Allow iSCSI target traffic:

```shell
firewall-cmd --permanent --add-service=iscsi-target
firewall-cmd --reload
```

### ACL troubleshooting

ACL permissions are a common source of failures. If the initiator cannot log in, check the target
logs and add the initiator IQN reported by the client:

```shell
journalctl -xg iscsi
```

## iPXE on beaker

The beaker host already enables PXE boot for the lab network in `inventory/host_vars/beaker.yaml`:

```yaml
dnsmasq_pxe: true
dnsmasq_pxe_boot_file: 'ipxe.efi'
dnsmasq_pxe_boot_url: 'http://192.168.125.1:8080/boot.ipxe'
dnsmasq_pxe_iscsi_address: '192.168.125.150'
dnsmasq_pxe_iscsi_lun: 0
dnsmasq_pxe_iscsi_target_name: 'iqn.2023-01.com.example:target01'
dnsmasq_pxe_root_path: true
```

This generates a dnsmasq snippet equivalent to:

```text
dhcp-boot=ipxe.efi
dhcp-match=set:ipxe,175
dhcp-boot=tag:ipxe,http://192.168.125.1:8080/boot.ipxe
dhcp-option=option:root-path,iscsi:192.168.125.150:::0:iqn.2023-01.com.example:target01
enable-tftp
tftp-root=/var/lib/tftp
```

### Install iPXE boot loaders

On beaker:

```shell
mkdir -p /var/lib/tftp

# BIOS
wget https://boot.ipxe.org/undionly.kpxe -O /var/lib/tftp/undionly.kpxe

# UEFI
wget https://boot.ipxe.org/ipxe.efi -O /var/lib/tftp/ipxe.efi
```

### UEFI prerequisites

When using UEFI boot (the default for lab BMH VMs):

1. **SELinux**. Allow dnsmasq to read the TFTP directory if needed:

```shell
ausearch -c 'dnsmasq' --raw | audit2allow -M my-dnsmasq
semodule -X 300 -i my-dnsmasq.pp
```

2. **Secure Boot**. Disable Secure Boot on the spoke VM:
   1. Press `Esc` at UEFI startup
   2. Device Manager → Secure Boot Configuration
   3. Uncheck **Attempt Secure Boot**
   4. Press `F10` to save
   5. Reset the VM

### boot.ipxe script

Create `/var/lib/tftp/boot.ipxe` on beaker. The initiator IQN must match an ACL on the target.
The target address is the iSCSI server IP on the lab network:

```ipxe
#!ipxe
set initiator-iqn iqn.1994-05.com.redhat:e1c30923a3a
sanboot iscsi:192.168.125.150::::iqn.2023-01.com.example:target01
```

For **multipath** installations, the iSCSI server and the client must share two networks. In that
case, list both target portal addresses in the `sanboot` command:

```ipxe
#!ipxe
set initiator-iqn iqn.1994-05.com.redhat:e1c30923a3a
sanboot iscsi:192.168.125.150::::iqn.2023-01.com.example:target01 \
        iscsi:192.168.100.157::::iqn.2023-01.com.example:target01
```

Serve the script over HTTP so iPXE can chain-load it after the initial DHCP boot:

```shell
cd /var/lib/tftp/
python -m http.server 8080
```

Keep the HTTP server running while testing spoke VM boots.

A copy of the single-path script for this lab is available at
`labs/iscsi/files/boot.ipxe`.

## iBFT configuration

### Why iPXE is required

QEMU UEFI firmware exposes an iSCSI Configuration menu, but the Linux kernel used by RHCOS does not
consume that firmware configuration. The UEFI iSCSI settings are therefore **not** sufficient for
OpenShift discovery.

To simulate iBFT tables that the agent and RHCOS can read, boot the spoke VM through iPXE.

### Create the Spoke VM

We can create the VM using `kcli`:

```shell
kcli create vm -P start=False \
   -P uefi_legacy=true \
   -P plan=iscsi \
   -P memory=22528 \
   -P numcpus=16 \
   -P nets=['{"name": "lab-network", "mac": "52:54:00:00:00:af"}'] \
   -P name=iscsi-spoke
```

### Spoke VM boot order

Configure the spoke BMH VM before attaching the discovery ISO:

| Setting | Value |
| --- | --- |
| First boot device | Ethernet (PXE / iPXE) |
| CD-ROM | Attached, but **not** first in boot order |

Expected behaviour:

1. The VM boots from the network and runs the iPXE script.
2. iPXE logs in to the iSCSI target and attempts `sanboot`.
3. Boot from the empty iSCSI LUN fails.
4. The VM falls back to the next boot device.

After iPXE has run, attach the discovery ISO through Redfish virtual media (ksushy) and reboot.
When the discovery environment starts, verify that iSCSI is already configured:

```shell
lsblk -o NAME,TYPE,SIZE,TRAN,MOUNTPOINT
ls /sys/firmware/ibft/
```

The iSCSI disk must be visible **before** approving the agent in assisted-service.

## Discovery ISO

In this lab the discovery ISO is generated by **assisted-service** on the MCE hub. After deploying the spoke InfraEnv, download the discovery ISO from the
InfraEnv and attach it to the spoke VM.

### Download the discovery ISO

From the hub cluster:

```shell
export KUBECONFIG=/root/labs/iscsi/deploy/auth/kubeconfig

oc get infraenv -n spoke-iscsi
oc get infraenv spoke-iscsi -n spoke-iscsi -o jsonpath='{.status.bootArtifacts.discoveryImageUrl}'
```