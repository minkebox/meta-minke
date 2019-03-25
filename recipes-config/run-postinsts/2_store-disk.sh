#! /bin/sh

ROOT=$(mount | grep ' / ' | cut -d' ' -f 1 | sed s/[0-9]$//)
if [ "${ROOT}" = "/dev/sda" ]; then 
  echo "/dev/sdb1 /mnt/store ext4 defaults,nofail 0 0" >> /etc/fstab
elif [ "${ROOT}" = "/dev/sdb" ]; then
  echo "/dev/sda1 /mnt/store ext4 defaults,nofail 0 0" >> /etc/fstab
fi
mkdir -p /mnt/store
mount /mnt/store
