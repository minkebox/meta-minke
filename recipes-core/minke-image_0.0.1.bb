SUMMARY = "A small image to boot the Minke Docker container."

LICENSE = "MIT"

IMAGE_INSTALL = "\
  packagegroup-core-boot \
  \
  os-release \
  \
  docker \
  ca-certificates \
  \
  kernel-module-br-netfilter kernel-module-xt-conntrack kernel-module-nf-conntrack-netlink kernel-module-xfrm-user kernel-module-xt-addrtype \
  kernel-module-ipvlan kernel-module-xt-ipvs kernel-module-vxlan kernel-module-ip-vs kernel-module-ip-vs-rr \
  \
  kernel-module-tun \
  \
  parted e2fsprogs-resize2fs \
  \
  minke-run dnf-automatic-restart tracer \
  \
  ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_FEATURES += "package-management"

inherit core-image

WKS_FILE = "minkex86.wks"
IMAGE_ROOTFS_SIZE ?= "12288"
