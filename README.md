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


