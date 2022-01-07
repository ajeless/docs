#!/usr/bin/env bash

source $HOME/.$USER/userconfig.sh
VMNAME="$VM_USERNAME-dev-vm"
VBoxManage sharedfolder remove $VMNAME --name "vagrant"
VBoxManage storagectl $VMNAME --name "IDE Controller" --add ide
VBoxManage storageattach $VMNAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium /usr/share/virtualbox/VBoxGuestAdditions.iso
VBoxManage modifyvm $VMNAME --clipboard bidirectional
VBoxManage modifyvm $VMNAME --draganddrop bidirectional
VBoxManage startvm $VMNAME