1 - Create vagrant's box for dnf VM.

2 - VM reboot one time and then shutdown.
3 - Commands for create box:
  vagrant package --base "name vm in VirtualBox"
  vagrant box add "your box name which you want" package.box
4 - Commands for test:
  vagrant init "your box name which you want"
  vagrant up
