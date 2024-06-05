#!/bin/bash
#Vars
conf_folder='//192.168.100.100/docs/itm/'
# Create the second task
a=$(/bin/find / -name part2.sh)
cp "$a" /root
echo '#!/bin/bash
/root/part2.sh' >> /etc/rc.local
chmod +x /etc/rc.local

#Dell folder with scrs
a=$(/bin/find / -name vagrant_box_deb)
rm -rf "$a"

#Install apps
apt update

apt install -y mc zsh ssh sudo tree ntp bash-completion git tmux vim-gtk3 curl cifs-utils ntfs-3g firewalld

# Change config's files for useradd and adduser
sed -i \
-e 's/^.SKEL=.*/SKEL=\/etc\/skel/g' \
-e 's/^SKEL=.*/SKEL=\/etc\/skel/g' \
-e 's/^.DSHELL=.*/DSHELL=\/bin\/zsh/g' \
-e 's/^DSHELL=.*/DSHELL=\/bin\/zsh/g' /etc/adduser.conf

sed -i \
-e 's/^ .SKEL=.*/SKEL=\/etc\/skel/g' \
-e 's/^SKEL=.*/SKEL=\/etc\/skel/g' \
-e 's/^ .SHELL=.*/SHELLL=\/bin\/zsh/g' \
-e 's/^SHELL=.*/SHELL=\/bin\/zsh/g' /etc/default/useradd

#mount conf_folder
mount -t cifs "$conf_folder" /mnt -o guest

# Set oh-my-zsh
chsh -s $(which zsh)
export PATH=$HOME/bin:/usr/local/bin:$PATH
sh -c "$(wget --no-check-certificate https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" <<EOF
y
EOF
export PATH=$HOME/bin:/usr/local/bin:$PATH
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1
git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

users=$(ls -1 /home)
IFS=$'\n'
for i in $(echo "$users"); do
    if [ "$i" != "lost+found" ]; then
      /usr/bin/sudo chsh -s /bin/zsh "$i"
      /usr/bin/sudo -u "$i" sh -c "$(wget --no-check-certificate https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" <<EOF
y
EOF
      /usr/bin/sudo -u "$i" git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1
      /usr/bin/sudo -u "$i" git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    fi
done


# Copy come config for users and new users
tar -xf /mnt/confs/linux_users/base_user.tar.gz -C /home/siarhei/
tar -xf /mnt/confs/linux_users/base_user.tar.gz -C /etc/skel/
tar -xf /mnt/confs/linux_users/base_user.tar.gz -C /root/
cp -rf /root/.oh-my-zsh /etc/skel/
cp -rf /root/.zsh-syntax-highlighting /etc/skel/

#Copy SSH keys
cp -rf /mnt/confs/ssh/ssh-etc/. /etc/ssh/
cp -rf /mnt/confs/ssh/ssh-siarhei/. /home/siarhei/.ssh/

chown -R siarhei:siarhei /home/siarhei
chown -R root:root /root

#Add user vagrant
/usr/sbin/useradd -m vagrant
echo "vagrant:vagrant" | chpasswd
echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
echo "siarhei ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/siarhei

sed -i \
-e 's/^.AuthorizedKeysFile.*/AuthorizedKeysFile \.ssh\/authorized_keys \.ssh\/authorized_keys2/g' /etc/ssh/sshd_config \
-e 's/^AuthorizedKeysFile.*/AuthorizedKeysFile \.ssh\/authorized_keys \.ssh\/authorized_keys2/g' /etc/ssh/sshd_config

mkdir -p /home/vagrant/.ssh
chmod 0700 /home/vagrant/.ssh

# Set vagrant's ssh keys
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys

chmod 0600 /home/vagrant/.ssh/authorized_keys && \
chown -R vagrant /home/vagrant/.ssh

# Set firewalld
firewall-cmd --permanent --new-zone=my-zone
firewall-cmd --reload
firewall-cmd --permanent --zone=my-zone --add-service={ssh,dhcp,dns}
firewall-cmd --permanent --zone=my-zone --add-interface=enp0s8
firewall-cmd --permanent --zone=my-zone --add-icmp-block-inversion
firewall-cmd --permanent --zone=my-zone --add-icmp-block={echo-reply,echo-request,destination-unreachable,time-exceeded}

# Set hostname 
hostnamectl set-hostname d12base
echo '127.0.0.1 d12base
::1 d12base' > /etc/hosts

# Create task for update omz
echo "#!/bin/zsh
/bin/zsh -i -c 'omz update'
users=$(ls -1 /home)
IFS=$'\n'
for i in $(echo \"$users\"); do
    if [ \"$i\" != \"lost+found\" ]; then
      su \"$i\" -c \"/bin/zsh -i -c 'omz update'\"
    fi
done" > /bin/update-omz.sh
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
apt install -y build-essential dkms linux-headers-$(uname -r) gpm gpg



# Reboot VM
systemctl reboot
