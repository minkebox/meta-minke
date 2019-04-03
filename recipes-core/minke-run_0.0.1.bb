SUMMARY = "Install and Run Minke"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit systemd

PROVIDES = "minke-run"
RPROVIDES_${PN} = "minke-run"

SRCREV = "master"
PR = "r1"
SRC_URI += "file://minke.service file://predocker.service file://run.sh file://prerun.sh"

SYSTEMD_SERVICE_${PN} = "minke.service predocker.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

IMAGENAMES = "minke minke-helper"
IMAGEVERSION = "latest"

do_install() {
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/minke.service ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/predocker.service ${D}${systemd_system_unitdir}

  install -d ${D}${datadir}/minke
  install -m 0755 ${WORKDIR}/run.sh ${D}${datadir}/minke
  install -m 0755 ${WORKDIR}/prerun.sh ${D}${datadir}/minke
  for imagename in ${IMAGENAMES}; do
    /usr/bin/docker image save registry.minkebox.net/minkebox/${imagename}:${IMAGEVERSION} -o ${D}${datadir}/minke/${imagename}.tar
    gzip ${D}${datadir}/minke/${imagename}.tar
  done
  chown root:root -R ${D}${datadir}/minke
}

FILES_${PN} += "${datadir}/minke ${systemd_system_unitdir} /minke"
