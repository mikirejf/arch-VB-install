#!/bin/bash

echo 'Starting custom Arch installation.'
echo 'Updating package list.'
refreshPackageList
echo 'Setting keyboard and updating system clock.'
setKeyboard
echo 'Making BIOS/MBT partition table and partition.'
createPartition

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
	(echo; echo; echo;) | pacstrap -i /mnt base base-devel
	genfstab -U /mnt > /mnt/etc/fstab
}