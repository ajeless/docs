#!/usr/bin/env bash

echo "Password to secure your VM?: "
read vm_passwd
echo $vm_passwd


echo "#!/usr/bin/env bash" > ./secure.sh
echo "deluser --remove-all-files vagrant" >> ./secure.sh
echo "echo -e \"$vm_passwd\\n$vm_passwd\" | passwd" >> ./secure.sh
echo "rm -rf /home/vagrant" >> ./secure.sh
echo "mkdir /media/cdrom" >> ./secure.sh
echo "mount /dev/sr0 /media/cdrom" >> ./secure.sh
echo "cp /media/cdrom/VBoxLinuxAdditions.run ." >> ./secure.sh
echo "chmod 755 ./VBoxLinuxAdditions.run" >> ./secure.sh
echo "./VBoxLinuxAdditions.run" >> ./secure.sh
chmod 755 ./secure.sh
echo "shutdown -r now" >> ./secure.sh
vagrant up
rm ./secure.sh