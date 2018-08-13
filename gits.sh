# download smithxyz LARBS
git clone git://github.com/LukeSmithxyz/LARBS.git ~/Documents/git

# download st from smithxyz
git clone https://github.com/LukeSmithxyz/st.git ~/Documents/git
cd st
make
make install 
cd..

# downloada yay
git clone https://aur.archlinux.org/yay.git ~/Documents/git
cd yay
makepkg -si
cd ..

# downloada pipes
git clone https://github.com/pipeseroni/pipes.sh.git  ~/Documents/git
cd pipes.sh
make
make install
cd ..

git clone https://github.com/xorg62/tty-clock.git  ~/Documents/git
cd tty-clock
make
make install
cd .. 
