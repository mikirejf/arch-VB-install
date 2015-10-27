#!/bin/bash

arch_chroot () {
	arch-chroot /mnt /bin/bash -c "${1}"
}

refreshPackageList () {
	pacman -Syy
}

setKeyboard () {
	loadkeys slovene
	setfont lat2-16 -m 8859-2
	# update the system clock
	timedatectl set-ntp true
}

createPartition () {
	(echo o; echo n; echo p; echo 1; echo; echo; echo a; echo w) | fdisk /dev/sda
	mkfs.ext4 /dev/sda1
	mount /dev/sda1 /mnt
}

updateAndRankMirrorlist () {
	pacman -S --noconfirm reflector
	reflector --verbose -p http -l 5 --sort rate --save /etc/pacman.d/mirrorlist
}

installation () {
	(echo; echo; echo) | pacstrap -i /mnt base base-devel
	genfstab -U /mnt > /mnt/etc/fstab
	#arch-chroot /mnt /bin/bash
	arch_chroot "sed 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen"
	arch_chroot "sed 's/#sl_SI.UTF-8/sl_SI.UTF-8/g' /etc/locale.gen"
	arch_chroot "locale-gen"
	arch_chroot "echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
	arch_chroot "echo 'KEYMAP=slovene\nFONT=lat2-16' > /etc/vconsole.conf"
	arch_chroot "(echo 8; echo 42; echo 1) | tzselect"
	arch_chroot "ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime"
	arch_chroot "hwclock --systohc --utc"
}

installBootloader () {
	arch_chroot "pacman -S --noconfirm intel-ucode grub os-prober"
	arch_chroot "grub-install --recheck /dev/sda"
	arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
}

hostnameAndUnmount () {
	arch_chroot "echo 'podgancar' > /etc/hostname"
	arch_chroot "sed -i '6s/$/ podgancar/' /etc/hosts"
	arch_chroot "sed -i '7s/$/ podgancar/' /etc/hosts"
	arch_chroot "(echo slovenija; echo slovenija) | passwd"
	arch_chroot "umount -R /mnt"
	arch_chroot "reboot"
}

echo -e '\e[42mStarting custom Arch installation.\e[49m'
echo -e '\e[42mUpdating package list.\e[49m'
refreshPackageList
echo -e '\e[42mSetting keyboard and updating system clock.\e[49m'
setKeyboard
echo -e '\e[42mMaking BIOS/MBT partition table and partition.\e[49m'
createPartition
echo -e '\e[42mUpdating and ranking mirrorlist.\e[49m'
updateAndRankMirrorlist
echo -e '\e[42mGeneral installation and configuration.\e[49m'
installation
echo -e '\e[42mInstalling bootloader.\e[49m'
installBootloader
echo -e '\e[42mSetting hostname, unmounting and rebooting.\e[49m'
hostnameAndUnmount