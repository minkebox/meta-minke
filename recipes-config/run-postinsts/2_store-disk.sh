#! /bin/sh

echo "/dev/sdb1 /mnt/store ext4 defaults 0 0" >> /etc/fstab
mount /mnt/store
