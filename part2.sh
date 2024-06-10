#!/bin/bash
#create folder
sleep 10s
wget https://download.virtualbox.org/virtualbox/7.0.18/VBoxGuestAdditions_7.0.18.iso && mount ./VBoxGuestAdditions_7.0.18.iso /mnt
sh /virtbox/VBoxLinuxAdditions.run 
sleep 10s
umount /mnt
rm -rf ./VBoxGuestAdditions_7.0.18.iso 
umount /virtbox && \
rm -rf /virtbox && \
rm -rf /etc/rc.local
rm -ff /root/part2.sh
echo '#!/bin/bash
/root/part3.sh' >> /etc/rc.local
chmod +x /etc/rc.local
shutdown -r +0