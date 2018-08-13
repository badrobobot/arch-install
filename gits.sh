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


