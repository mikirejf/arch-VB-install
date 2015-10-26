 #!/bin/bash

 echo 'Starting custom Arch installation.'
 echo 'Setting keyboard and updating system clock.'
 setKeyboard
 echo 'Making BIOS/MBT partition table and partition.'
 createPartition


 function setKeyboard {
 	loadkeys slovene
 	setfont lat2-16 -m 8859-2
 	# update the system clock
 	timedatectl set-ntp true
 }

 function createPartition {
 	(echo o; echo n; echo p; echo 1; echo; echo; echo a; echo w) | fdisk /dev/sda
 	mkfs.ext4 /dev/sda1
 }