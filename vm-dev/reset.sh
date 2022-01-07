#/usr/bin/env bash

# This file is for testing purposes
vagrant destroy
rm -rf $HOME/.$USER
rm -rf ~/.vagrant.d/boxes/*
rm -rf ./.vagrant