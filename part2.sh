#!/bin/bash
#create folder
mkdir /virtbox 
wget https://download.virtualbox.org/virtualbox/7.0.18/VBoxGuestAdditions_7.0.18.iso
mount ./VBoxGuestAdditions_7.0.18.iso /virtbox 
sh /virtbox/VBoxLinuxAdditions.run && umount /virtbox 
rm -r /virtbox
rm -r ./VBoxGuestAdditions_7.0.18.iso 
sed -i "/\/root\/part2\.sh/d" /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
rm -f /root/part2.sh
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
shutdown -h +0