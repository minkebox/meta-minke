#! /bin/sh

echo "/dev/sdb1 /mnt/store ext4 defaults,nofail 0 0" >> /etc/fstab
mount /mnt/store
