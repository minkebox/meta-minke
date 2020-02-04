FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://0_resize-rootfs.sh \
  file://1_swap-file.sh \
  file://2_fix-boot-disk.sh \
  file://3_fix-network.sh"


do_install_append() {
  install -d ${D}${sysconfdir}/rpm-postinsts
  install -m 0755 ${WORKDIR}/0_resize-rootfs.sh ${D}${sysconfdir}/rpm-postinsts
  install -m 0755 ${WORKDIR}/1_swap-file.sh ${D}${sysconfdir}/rpm-postinsts
  install -m 0755 ${WORKDIR}/2_fix-boot-disk.sh ${D}${sysconfdir}/rpm-postinsts
  install -m 0755 ${WORKDIR}/3_fix-network.sh ${D}${sysconfdir}/rpm-postinsts
}
