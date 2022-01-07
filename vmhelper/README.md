# vmhelper
Scripts and process documentation to partially automate the setup and provisioning of VMs for development work.

## Dependencies (Host OS Linux)
The host operating system should be/have the following:
* [.ajeless](https://github.com/ajeless/docs)
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## Setup the developer sandbox VM
```bash
$ cd developer_sandbox
```


## Step 3: Run vmprovision.sh
```bash
$ ./vmprovision.sh
```
Wait for the vagrant provisioning to end and the VM to shutdown.

## Step 4: Run postinstall.sh
On the Host machine, in the terminal, run:  

```bash
$ ./postinstall.sh
```

This does a number of things:
1. Removes vagrant default shared folders so their absence doesn't become a problem later.
1. This creates an IDE controller in the VM and attaches the VirtualBox Guest Additons to it.  It starts the machine.
1. Turns on bidirectional clipboard and drag and drop so we can more easily share things between our VM and Host machine.

## Step 5: Run secure.sh as root (inside VM)
Wait for the VM to start and log in as the root user.

```bash
password: vagrant
```  

In the VM, as root, at a terminal, run:  
```bash
$ /home/vagrant/secure.sh
```  

This script Does a few things:  
1. Secures the VM by deleting the vagrant user
1. Secures the VM by changing the default root user password which is set by vagrant to "vagrant".  The new root user password is is whatever the non-priviledged user password is.  That is it is set to whatever is specified in the userconfig on the host OS in userconfig.sh.  It's on the line:
``` bash
VM_PASSWORD="password"
```
3. Installs virtualbox guest additions in the VM.

## Step 6: Run cleanup.sh
This deletes this repository (the local repository) from the host machine.  It's simply not needed anymore.  It's only purpose was to use vagrant and the scripts herein to help setup the VM.  Going forward we start the VM from VirtualBox.  We don't need Vagrant anymore.  The VM is ready to use as a development environment.  Install whatever developer tools and languages you need on it.

The VM is ready for login as our non-priviledged, regular user.

In the host machine, at the terminal, run:
```bash
$ ./cleanup.sh
```