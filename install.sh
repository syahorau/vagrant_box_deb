#!/bin/bash
read -p "enter hostname: " vm_name

a=$(. /etc/os-release && echo "$VERSION_CODENAME")

if [ "$a" = 'bullseye' ]; then
echo "deb http://deb.debian.org/debian bullseye main contrib non-free
deb-src http://deb.debian.org/debian bullseye main contrib non-free

deb http://deb.debian.org/debian bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free

deb http://deb.debian.org/debian bullseye-backports main contrib non-free
deb-src http://deb.debian.org/debian bullseye-backports main contrib non-free

deb http://security.debian.org/debian-security/ bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security/ bullseye-security main contrib non-free" > /etc/apt/sources.list
fi

apt update && \
apt install -y debconf-utils && \
echo 'libc6 libraries/restart-without-asking boolean true' |  debconf-set-selections

mkdir /tempare
mkdir /itm
# Create the second task
a=$(/bin/find / -name part2.sh)
cp "$a" /tempare
a=$(/bin/find / -name part3.sh)
cp "$a" /tempare
echo '#!/bin/bash
/tempare/part2.sh' >> /etc/rc.local
chmod +x /etc/rc.local
chmod +x /tempare/part2.sh
chmod +x /tempare/part3.sh

#Dell folder with scrs
a=$(/bin/find / -name vagrant_box_deb)
rm -rf "$a"

#Install apps
apt update && apt upgrade -y && \
apt install -y mc zsh ssh sudo tree ntp bash-completion git tmux vim curl cifs-utils ntfs-3g nano &> /dev/null

# Set firewalld
#firewall-cmd --permanent --new-zone=my-zone
#firewall-cmd --reload
#firewall-cmd --permanent --zone=my-zone --add-service=ssh
#firewall-cmd --permanent --zone=my-zone --add-service=dhcp
#firewall-cmd --permanent --zone=my-zone --add-service=dns
#firewall-cmd --permanent --zone=my-zone --add-interface=enp0s8
#firewall-cmd --permanent --zone=my-zone --add-icmp-block-inversion
#firewall-cmd --permanent --zone=my-zone --add-icmp-block=echo-request
#firewall-cmd --permanent --zone=my-zone --add-icmp-block=echo-reply
#firewall-cmd --permanent --zone=my-zone --add-icmp-block=destination-unreachable
#firewall-cmd --permanent --zone=my-zone --add-icmp-block=time-exceeded

# Set hostname 
hostnamectl set-hostname "$vm_name"
echo "127.0.0.1 $vm_name
::1 $vm_name" > /etc/hosts

# Create task for update omz
echo "#!/bin/bash
/bin/zsh -i -c 'omz update'
users=$(ls -1 /home)
for i in $(echo \"$users\"); do
    if [ \"$i\" != \"lost+found\" ]; then
      su \"$i\" -c \"/bin/zsh -i -c 'omz update'\"
    fi
done
su \"root\" -c \"/bin/zsh -i -c 'omz update'\"" > /bin/update-omz.sh
chmod +x /bin/update-omz.sh

echo "[Unit]
Description=update omz

[Service]
Type=oneshot
ExecStart=/bin/update-omz.sh

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/update-omz.service

echo "[Unit]
Description=Run update-omz 
[Timer]
OnBootSec=5
OnUnitActiveSec=1w
Unit=update-omz.service
[Install]
WantedBy=multi-user.target" > /etc/systemd/system/update-omz.timer

systemctl daemon-reload
systemctl enable update-omz.timer

apt upgrade -y
apt install -y build-essential dkms linux-headers-$(uname -r) gpm gpg &> /dev/null && \
apt autoremove -y &> /dev/null



# Reboot VM
systemctl reboot

