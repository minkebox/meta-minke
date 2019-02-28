#! /bin/sh

DEVICE=/dev/sda
PARTITION=2

echo "f" | script -qfc "parted ${DEVICE} -l" /dev/null
parted ${DEVICE} "resizepart ${PARTITION} -1"
resize2fs ${DEVICE}${PARTITION}
