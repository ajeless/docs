# docs

A collection of scripts, documents and recipes to simplify developement and dev related setup.

## QEMU + KVM

[QEMU](https://www.qemu.org/)  
[KVM](https://www.linux-kvm.org)  
[libvirt](https://libvirt.org/)  


### Install
```bash
sudo apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager
```

### Bidirectional Host-Guest Copy-Paste
```bash
# In the guest enter
sudo apt install spice-vdagent
```

### Create VM Disk Image

```bash
# qemu-img create -f qcow2 <vm-img-name>.qcow2 <disk-size>G

qemu-img create -f qcow2 vm_disk_img_name.qcow2 20G
```

### Start Existing VM
```bash
# qemu-system-x86_64 <vm-img-name>.qcow2 -m <mem-size>G -enable-kvm

qemu-system-x86_64 vm_disk_img_name.qcow2 -m 8G -enable-kvm
```

### Modify Existing VM
```bash
# qemu-system-x86_64 <vm-img-name>.qcow2 -m <new-mem-size>G -enable-kvm

qemu-system-x86_64 vm_disk_img_name.qcow2 -m 4G -net none -vga qxl -enable-kvm
```

### Create VM with libvirt
```bash
# virt-install --name <vm_name> --os-variant <os_name> --memory <MiB> --disk size=<GB>,format=qcow2,path=<path_to_storage>.qcow2 --cdrom <path_to_iso_file>

virt-install --name deb11_001 --os-variant debian10 --memory 8192 --disk size=20,format=qcow2,path=./deb_11_001.qcow2 --cdrom ~/Downloads/debian-11.6.0-amd64-netinst.iso
```
### Use virsh to manage a VM
```bash
# list vms
virsh list

# start a vm
# virsh start <vm_name>
virsh start deb11_001

# connect to vm ui after starting
# virt-viewer <vm_name>
virt-viewer deb_11_001

# shutdown a vm
# virsh shutdown <vm_name>
virsh shutdown deb11_001

# force shutdown/stp a vm
# virsh destroy <vm_name>
virsh destroy deb11_001

# delete vm
# virsh undefine <vm_name>
virsh undefine deb11_001

# managing domain state: 


```

