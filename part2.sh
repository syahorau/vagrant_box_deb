#!/bin/bash
#create folder
mkdir /virtbox
#Vars
conf_folder='//192.168.100.100/docs/itm/'
#mount conf_folder
mount -t cifs "$conf_folder" /mnt -o guest && \
mount /mnt/confs/VBoxGuestAdditions.iso /virtbox && \
sh /virtbox/VBoxLinuxAdditions.run && \
umount /virtbox && \
rm -rf /virtbox && \
rm -rf /etc/rc.local
rm -ff /root/part2.sh
echo '#!/bin/bash
/root/part3.sh' >> /etc/rc.local
chmod +x /etc/rc.local
shutdown -r +0