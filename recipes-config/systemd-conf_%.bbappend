FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://bridge.netdev"

do_install_append() {
  install -m 0755 -d ${D}/lib/systemd/network
  install -m 0644 ${WORKDIR}/bridge.netdev ${D}/lib/systemd/network/70-bridge.netdev
}
