# QEMU + KVM + libvirt

A collection of commands to use QEMU and KVM and libvirt to manage kernel based virtual machines in linux.

## Links to tools discussed here

[QEMU](https://www.qemu.org/)  
[KVM](https://www.linux-kvm.org)  
[libvirt](https://libvirt.org/)  


## Install
```bash
sudo apt install qemu qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager
```

## Bidirectional Host-Guest Copy-Paste
```bash
# In the guest enter
sudo apt install spice-vdagent
```

## Create VM Disk Image
```bash
# qemu-img create -f qcow2 <vm-img-name>.qcow2 <disk-size>G

qemu-img create -f qcow2 vm_disk_img_name.qcow2 20G
```

## Start Existing VM
```bash
# qemu-system-x86_64 <vm-img-name>.qcow2 -m <mem-size>G -enable-kvm

qemu-system-x86_64 vm_disk_img_name.qcow2 -m 8G -enable-kvm
```

## Modify Existing VM
```bash
# qemu-system-x86_64 <vm-img-name>.qcow2 -m <new-mem-size>G -enable-kvm

qemu-system-x86_64 vm_disk_img_name.qcow2 -m 4G -net none -vga qxl -enable-kvm
```

## Create VM with libvirt
```bash
# virt-install --name <vm_name> --os-variant <os_name> --memory <MiB> --disk size=<GB>,format=qcow2,path=<path_to_storage>.qcow2 --cdrom <path_to_iso_file>

virt-install --name deb11_001 --os-variant debian10 --memory 8192 --disk size=20,format=qcow2,path=./deb_11_001.qcow2 --cdrom ~/Downloads/debian-11.6.0-amd64-netinst.iso
```
## Using virsh

### Listing VMS
```bash
virsh list
```

### Start VM
```bash
# virsh start <vm_name>
virsh start deb11_001
```
### Connect to VM UI After Starting
```bash
# virt-viewer <vm_name>
virt-viewer deb_11_001
```

### Shutdown VM
```bash
# virsh shutdown <vm_name>
virsh shutdown deb11_001
```

### Force Shutdown VM
```bash
# virsh destroy <vm_name>
virsh destroy deb11_001
```

### Delete VM
```bash
# virsh undefine <vm_name>
virsh undefine deb11_001
```

### Use domdisplay to get VM Display Info
```bash
# virsh domdisplay <vm_name>
virsh domdisplay deb11_001
```
### Use dominfo to get vm info
```bash
# virsh dominfo <vm_name>
virsh dominfo deb11_001
```

### Temporarily Set Used Memory of a VM
```bash
# virsh setmem <vm_name> <mem_size>M
# virsh setmem <vm_name> <mem_size>G
virsh setmem deb11_001 2048M
```

### Permanently Set Used Memory of a VM
!Shutdown the guest first
```bash
# virsh setmem <vm_name> <mem_size>M --config
# virsh setmem <vm_name> <mem_size>G --config
virsh setmem deb11_001 8G --config
```
### Permanently Change Max Memory of a VM
!Shutdown the guest first
```bash
# virsh setmaxmem <vm_name> <mem_size>M --config
# virsh setmaxmem <vm_name> <mem_size>G --config
virsh setmaxmem deb11_001 8G --config
```

### Set VM to Autostart when host reboots
```bash
# virsh autostart <vm_name>
virsh autostart deb11_001
```



