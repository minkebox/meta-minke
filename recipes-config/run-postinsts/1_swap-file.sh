#! /bin/sh
echo "Creating swap"

SWAPSIZE=2048M
SWAPFILE=/swapfile

if [ ! -e ${SWAPFILE} ]; then
  fallocate --posix --length ${SWAPSIZE} ${SWAPFILE}
  chmod 600 ${SWAPFILE}
  mkswap ${SWAPFILE}
  swapon ${SWAPFILE}
  echo "${SWAPFILE} swap swap defaults 0 0" >> /etc/fstab
fi
