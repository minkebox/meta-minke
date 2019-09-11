FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://bind.network file://bridge.network file://bridge.netdev"

PACKAGECONFIG_remove = "timesyncd"

do_install_append() {
  install -m 0644 ${WORKDIR}/bind.network ${D}/etc/systemd/network
  install -m 0644 ${WORKDIR}/bridge.network ${D}/etc/systemd/network
  install -m 0644 ${WORKDIR}/bridge.netdev ${D}/etc/systemd/network
}
