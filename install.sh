#!/bin/bash

echo 'Starting custom Arch installation.'
echo 'Updating package list.'
refreshPackageList
echo 'Setting keyboard and updating system clock.'
setKeyboard
echo 'Making BIOS/MBT partition table and partition.'
createPartition
echo 'Updating and ranking mirrorlist.'
updateAndRankMirrorlist
echo 'General installation and configuration.'
installation
echo 'Installing bootloader.'
installBootloader

function refreshPackageList {
	pacman -Syy
}

function setKeyboard {
	loadkeys slovene
	setfont lat2-16 -m 8859-2
	# update the system clock
	timedatectl set-ntp true
}

function createPartition {
	(echo o; echo n; echo p; echo 1; echo; echo; echo a; echo w) | fdisk /dev/sda
	mkfs.ext4 /dev/sda1
	mount /dev/sda1 /mnt
}

function updateAndRankMirrorlist {
	pacman -S --noconfirm reflector
	reflector --verbose -p http -l 5 --sort rate --save /etc/pacman.d/mirrorlist
}

function installation {
	(echo; echo; echo) | pacstrap -i /mnt base base-devel
	genfstab -U /mnt > /mnt/etc/fstab
	arch-chroot /mnt /bin/bash
	sed 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/loacle.gen
	sed 's/#sl_SI.UTF-8/sl_SI.UTF-8/g' /etc/loacle.gen
	locale-gen
	echo 'LANG=en_US.UTF-8' > /etc/locale.conf
	echo 'KEYMAP=slovene\nFONT=lat2-16' > /etc/vconsole.conf
	(echo 8; echo 43; echo 1) | tzselect
	ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime
	hwclock --systohc --utc
}

function installBootloader {

}