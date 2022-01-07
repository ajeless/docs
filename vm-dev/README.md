# vm-dev
Semi-automated developer VM setup.

## Purpose
Setup a base, Debian Linux, VM for work and experimentation.  The intent is to automate some steps of the repetitive, error-prone, process involved in downloading a linux .iso file, and creating a VirtualBox VM for development.  We use vagrant and bash scripts to accomplish this goal.  At the end of the process there should be a secured, base VM running debian, ready for the installation of developer tools.

## Dependencies (Host OS Linux)
The host operating system should be/have the following:
* Linux - recommend [Debian](https://www.debian.org/)
* [VirtualBox](https://www.virtualbox.org/)
* [Vagrant](https://www.vagrantup.com/)

## Setup
```bash
# clone this repo
$ git clone git@github.com:ajeless/vm-dev.git

# cd into it
$ cd vm-dev
```

## Step 1: Run init.sh
```bash
$ ./init.sh <vm_type>
```

where [`<vm_type>`](./vm_types) is the type of VM we wish to setup.  For example, to setup the developer sandbox VM we would run:

```bash
./init.sh vm_dev
```

This creates a hidden folder in the home directory with the name of the current user.  If the current user is foo, there will be a folder called .foo under the user's home directory.

```bash
# to see the hidden directory
foo@foo:~$ ls -la ~
drwxr-xr-x 27 foo  foo  4096 Dec 23 22:16  .
drwxr-xr-x  3 root root 4096 Sep 30 10:44  ..
drwxr-xr-x  2 foo  foo  4096 Dec 23 22:16  .foo

# list its contents
foo@foo:~$ ls ~/.foo/
userconfig.sh
```

## Step 2: Update userconfig.sh
Edit [userconfig.sh](./userconfig_template.sh) in the hidden directory created in step 1.  Add values inside the quotes to each of the variables and save.

```bash
#!/usr/bin/env bash

# The github username to be used in the guest VM
GH_USERNAME=""

# The github password to be used in the guest VM
GH_PASSWORD=""

# Path to VirtualBox shared folders on the host
SF_HOST=""

# Path to VirtualBox shared folders on the guest VM
SF_GUEST=""

# Login username to be created on the guest VM
VM_USERNAME=""

# Login password to be used for guest VM
VM_PASSWORD=""
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