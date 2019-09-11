SUMMARY = "Install extra sysctls"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PROVIDES = "extra-sysctl"
RPROVIDES_${PN} = "extra-sysctl"

SRCREV = "master"
PR = "r1"

do_install() {
  install -d ${D}/etc/sysctl.d
  echo "kernel.panic = 20" > ${D}/etc/sysctl.d/reboot.conf
}

FILES_${PN} += "/etc/sysctl.d"
