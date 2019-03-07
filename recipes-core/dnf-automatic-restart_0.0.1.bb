SUMMARY = "System restart and reboot service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit systemd

PROVIDES = "dnf-automatic-restart"
RPROVIDES_${PN} = "dnf-automatic-restart"

SRCREV = "master"
PR = "r1"
SRC_URI += "file://dnf-automatic-restart file://dnf-automatic-restart.service"

SYSTEMD_SERVICE_${PN} = "dnf-automatic-restart.service"
SYSTEMD_AUTO_ENABLE_${PN} = "disable"


do_install_append() {
  install -d ${D}${bindir}
  install -m 0755 ${WORKDIR}/dnf-automatic-restart ${D}${bindir}

  install -d ${D}${base_libdir}/systemd/system
  install -m 0644 ${WORKDIR}/dnf-automatic-restart.service ${D}${base_libdir}/systemd/system
}

FILES_${PN} += "${bindir} ${base_libdir}/systemd/system"
