
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://automatic.conf file://dnf-automatic-install.service"

do_install_append() {
  install -d ${D}${sysconfdir}/dnf
  install -m 0755 ${WORKDIR}/automatic.conf ${D}${sysconfdir}/dnf

  install -d ${D}${base_libdir}/systemd/system
  install -m 0644 ${WORKDIR}/dnf-automatic-install.service ${D}${base_libdir}/systemd/system
}

SYSTEMD_AUTO_ENABLE = "enable"
