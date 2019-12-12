FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://wired.network file://bridge.network file://bridge.netdev"

do_install_append() {
  install -m 0644 ${WORKDIR}/wired.network ${D}/lib/systemd/network/80-wired.network
  install -m 0644 ${WORKDIR}/bridge.network ${D}/lib/systemd/network/70-bridge.network
  install -m 0644 ${WORKDIR}/bridge.netdev ${D}/lib/systemd/network/70-bridge.netdev
}
