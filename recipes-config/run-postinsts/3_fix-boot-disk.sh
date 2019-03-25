#! /bin/sh

ROOT=$(mount | grep ' / ' | cut -d' ' -f 1 | sed s/[0-9]$//)
echo "${ROOT}1 /boot vfat defaults,nofail 0 0" >> /etc/fstab
mount /boot
