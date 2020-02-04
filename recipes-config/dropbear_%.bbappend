FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://dropbear.socket file://dropbear.default"

do_install_append() {
  install -d ${D}${systemd_unitdir}/system ${D}/etc/default
  install -m 0644 ${WORKDIR}/dropbear.socket ${D}${systemd_unitdir}/system
  install -m 0644 ${WORKDIR}/dropbear.default ${D}/etc/default/dropbear
}
