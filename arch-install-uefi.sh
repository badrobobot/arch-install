# confirm you can access the internet
if [[ ! $(curl -Is http://www.google.com/ | head -n 1) =~ "200 OK" ]]; then
  echo "Your Internet seems broken. Press Ctrl-C to abort or enter to continue."
  read
fi

# update system clock
timedatectl set-ntp true

# make a new GUID partition table 
parted -s /dev/sda mklabel gpt

# make a EFI Sys partition, a 40GiB root, 4 GiB swap, remaining space for home  
parted -s /dev/sda mkpart ESP fat32 1MiB 551MiB
parted -s /dev/sda set 1 esp on
parted -s /dev/sda mkpart primary ext4 551MiB 40.5GiB
parted -s /dev/sda mkpart primary linux-swap 40.5GiB 44.5GiB
parted -s /dev/sda mkpart primary ext4 44.5GiB 100.5GiB
parted -s /dev/sda mkpart primary NTFS 100.5GiB 100%

# make filesystems
# swap
mkswap /dev/sda3
swapon /dev/sda3
# /boot/EFI
mkfs.fat -F32 /dev/sda1
# /
mkfs.ext4 /dev/sda2
# /home
mkfs.ext4 /dev/sda4

# mount 
# set up /mnt
mount /dev/sda2 /mnt
# set up /mnt/boot/efi
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
# set up /mnt/home
mkdir /mnt/home
mount /dev/sda4 /mnt/home

# rankmirrors to make this faster (though it takes a while)
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
rankmirrors -n 6 /etc/pacman.d/mirrorlist.orig >/etc/pacman.d/mirrorlist
pacman -Syy

# install base packages (take a coffee break if you have slow internet)
pacstrap /mnt base base-devel vim 

# install grub2 efibootmgr networkmaner
arch-chroot /mnt pacman -S grub efibootmgr networkmanager --noconfirm

# copy ranked mirrorlist over
cp /etc/pacman.d/mirrorlist* /mnt/etc/pacman.d

# generate fstab
genfstab -p /mnt >>/mnt/etc/fstab

# chroot
arch-chroot /mnt /bin/bash <<EOF
# enable networkmanger
systemctl enable NetworkManager
# set initial hostname
# echo "archlinux-$(date -I)" >/etc/hostname
echo "pavilon" >/etc/hostname
# set initial timezone to America/Mexico_City
ln -s /usr/share/zoneinfo/America/Mexico_City /etc/localtime
# generate /etc/adjtime
hwclock --systohc
# set initial locale
# locale >/etc/locale.conf
echo "LANG=en-US.UTF-8" > /etc/locale.conf
locale-gen
# (initramfs) no modifications to mkinitcpio.conf should be needed
mkinitcpio -p linux

# install grub2 bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
# Use the grub-mkconfig tool to generate grub.cfg
grub-mkconfig -o /boot/grub/grub.cfg

# set root password to "root"
echo root:root | chpasswd
# end section sent to chroot
EOF

# unmount
umount -R /mnt
swapoff -a

echo "Done! Unmount the CD image from the VM, then type 'reboot'."
