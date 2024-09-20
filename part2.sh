#!/bin/bash
#Vars
conf_folder='//192.168.100.100/docs/itm/'
#create folder
sleep 10s
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
mount -t cifs "$conf_folder" /itm -o guest

# Set oh-my-zsh
chsh -s $(which zsh)
export PATH=$HOME/bin:/usr/local/bin:$PATH
sh -c "$(wget --no-check-certificate https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" <<EOF
y
EOF

# Download features for oh-my-zsh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "/tempare/.zsh-syntax-highlighting" --depth 1 && \
git clone https://github.com/zsh-users/zsh-autosuggestions "/tempare/zsh-autosuggestions"
# Download base config files for users
git clone https://github.com/syahorau/accounts.git "/tempare/accounts"
# Download ssh keys
git clone https://github.com/hashicorp/vagrant.git "/tempare/vagrant"

# Copy files
sudo cp -r "/tempare/.zsh-syntax-highlighting" "/root/.zsh-syntax-highlighting"
sudo cp -r "/tempare/zsh-autosuggestions" "/root/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
sudo cp -r "/tempare/accounts/base_user/." "/root/"


users=$(ls -1 /home)
IFS=$'\n'
for i in $(echo "$users"); do
    if [ "$i" != "lost+found" ]; then
      /usr/bin/sudo chsh -s /bin/zsh "$i"
      /usr/bin/sudo -u "$i" sh -c "$(wget --no-check-certificate https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" <<EOF
y
EOF
      sudo cp -r "/tempare/.zsh-syntax-highlighting" "/home/${i}/.zsh-syntax-highlighting"
      sudo cp -r "/tempare/zsh-autosuggestions" "/home/${i}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
      sudo cp -r "/tempare/accounts/base_user/." "/home/${i}/"
      chown -R ${i}:${i} "/home/${i}"
    fi
done


# Copy come config for users and new users
cp -r "/tempare/accounts/base_user/." /etc/skel/
cp -rf /root/.oh-my-zsh /etc/skel/
cp -rf /root/.zsh-syntax-highlighting /etc/skel/

#Copy SSH keys
cp -rf "/itm/confs/ssh/ssh-etc/." /etc/ssh/
cp -rf "/itm/confs/ssh/ssh-win-personal/." /home/siarhei/.ssh/

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
cat /tempare/vagrant/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
cp -r /tempare/vagrant/keys/. /home/vagrant/.ssh/
chmod 0600 /home/vagrant/.ssh/authorized_keys && \
chown -R vagrant /home/vagrant/.ssh

cd /home/vagrant/.ssh
files=$(ls -1)
IFS=$'\n'
for i in $(echo "$files"); do
    if [ "$i" != "lost+found" ]; then
      /usr/bin/sudo chsh -s /bin/zsh "$i"
      /usr/bin/sudo -u "$i" sh -c "$(wget --no-check-certificate https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)" <<EOF
y
EOF
      sudo cp -r "/tempare/.zsh-syntax-highlighting" "/home/${i}/.zsh-syntax-highlighting"
      sudo cp -r "/tempare/zsh-autosuggestions" "/home/${i}/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
      sudo cp -r "/tempare/accounts/base_user/." "/home/${i}/"
      chown -R ${i}:${i} "/home/${i}"
    fi
done

chmod -R 600 /home/vagrant/.ssh/vagrant*
chmod -R 644 /home/vagrant/.ssh/vagrant.pub*

chmod -R 600 /home/siarhei/.ssh/id*
chmod -R 644 /home/siarhei/.ssh/id_rsa*

rm -rf /home/accounts

sleep 10s
umount /itm && rm -rf /itm
sleep 10s
rm -rf ./VBoxGuestAdditions_7.0.18.iso 
rm -rf /etc/rc.local
echo '#!/bin/bash
/tempare/part3.sh' >> /etc/rc.local
chmod +x /etc/rc.local
shutdown -r +0