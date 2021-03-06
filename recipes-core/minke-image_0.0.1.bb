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
  kernel-modules linux-firmware \
  \
  wpa-supplicant iw iproute2 dhcp-helper tcpdump \
  \
  wireguard-tools \
  \
  extra-sysctl \
  rng-tools \
  \
  parted e2fsprogs-resize2fs e2fsprogs-mke2fs \
  \
  minke-run dnf-automatic-restart tracer tzdata \
  \
  ${MACHINE_EXTRA_RRECOMMENDS} \
  ${CORE_IMAGE_EXTRA_INSTALL}"

IMAGE_FEATURES += "package-management"

inherit core-image

IMAGE_ROOTFS_SIZE ?= "12288"
PACKAGE_EXCLUDE_pn-minke-image = "dnsmasq"

include ${THISDIR}/machine/${MACHINE}.conf
