#! /bin/sh

SWAPSIZE=512M
SWAPFILE=/swapfile

fallocate --length ${SWAPSIZE} ${SWAPFILE}
chmod 600 ${SWAPFILE}
mkswap ${SWAPFILE}
swapon ${SWAPFILE}

echo "${SWAPFILE} swap swap defaults 0 0" >> /etc/fstab
