FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dropbear.socket"

do_install_append() {
  install -d ${D}${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/dropbear.socket ${D}${systemd_unitdir}/system
}
