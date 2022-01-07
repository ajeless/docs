#!/usr/bin/env bash

VM_TYPE=$1

cp ./vm_types/$1 ./Vagrantfile

chmod 755 *.sh
mkdir -p $HOME/.$USER
cp -R -u -p ./userconfig_template.sh $HOME/.$USER/userconfig.sh
