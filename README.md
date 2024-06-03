1 - Create vagrant's box for dnf VM \n
2 - VM reboot one time and then shutdown. \n
3 - Commands for create box: \n
  vagrant package --base "name vm in VirtualBox" \n
  vagrant box add "your box name which you want" package.box \n
4 - Commands for test: \n
  vagrant init "your box name which you want" \n
  vagrant up \n