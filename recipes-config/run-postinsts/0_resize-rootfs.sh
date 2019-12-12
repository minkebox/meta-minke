#! /bin/sh
echo "Resizing root partition"

ROOT=$(mount | grep ' / ' | cut -d' ' -f 1 | sed s/[0-9]$// | sed s/p$//)
PARTITION=2

(echo "ok" ; echo "f") | script -qfc "parted ${ROOT} -l" /dev/null
parted ${ROOT} "resizepart ${PARTITION} -1"
if [ -b "${ROOT}${PARTITION}" ]; then
  resize2fs -p ${ROOT}${PARTITION}
elif [ -b "${ROOT}p${PARTITION}" ]; then
  resize2fs -p ${ROOT}p${PARTITION}
else
  echo "No partition found"
fi
