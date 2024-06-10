#!/bin/bash
rm -rf /etc/rc.local
rm -ff /root/part3.sh
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
shutdown -h +0