FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://systemd-networkd-wait-online.service"

do_install_append() {
  install -m 0644 ${WORKDIR}/systemd-networkd-wait-online.service ${D}/lib/systemd/system/systemd-networkd-wait-online.service
}

PACKAGECONFIG_remove = "timesyncd"
