#!/bin/bash
#create folder
mkdir /virtbox 
wget https://download.virtualbox.org/virtualbox/7.0.18/VBoxGuestAdditions_7.0.18.iso && mount ./VBoxGuestAdditions_7.0.18.iso /virtbox 
sh /virtbox/VBoxLinuxAdditions.run && umount /virtbox && rm -rf /virtbox
rm -rf ./VBoxGuestAdditions_7.0.18.iso 
rm -rf /etc/rc.local
rm -ff /root/part2.sh
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
shutdown -h +0