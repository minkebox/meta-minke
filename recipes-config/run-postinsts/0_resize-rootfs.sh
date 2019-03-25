#! /bin/sh

ROOT=$(mount | grep ' / ' | cut -d' ' -f 1 | sed s/[0-9]$//)
PARTITION=2

(echo "ok" ; echo "f") | script -qfc "parted ${ROOT} -l" /dev/null
parted ${ROOT} "resizepart ${PARTITION} -1"
resize2fs ${ROOT}${PARTITION}
