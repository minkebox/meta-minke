SUMMARY = "Install and Run Minke"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit systemd

PROVIDES = "minke-run"
RPROVIDES_${PN} = "minke-run"

SRCREV = "master"
PR = "r1"
SRC_URI += "file://minke.service file://predocker.service file://run.sh file://prerun.sh file://restart.sh file://minke-tmpfiles.conf"

SYSTEMD_SERVICE_${PN} = "minke.service predocker.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

IMAGENAMES = "minke minke-helper"
IMAGE_VERSION ?= "latest"
IMAGE_REGISTRY ?= "registry.minkebox.net"


do_install() {
  install -d ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/minke.service ${D}${systemd_system_unitdir}
  install -m 0644 ${WORKDIR}/predocker.service ${D}${systemd_system_unitdir}

  install -d ${D}${datadir}/minke
  install -m 0755 ${WORKDIR}/run.sh ${D}${datadir}/minke
  install -m 0755 ${WORKDIR}/prerun.sh ${D}${datadir}/minke
  install -m 0755 ${WORKDIR}/restart.sh ${D}${datadir}/minke

  install -d ${D}${nonarch_libdir}/tmpfiles.d
  install -m 0644 ${WORKDIR}/minke-tmpfiles.conf ${D}${nonarch_libdir}/tmpfiles.d/minke.conf

  case "${MACHINE}" in
    raspberrypi*-64)  IMAGEPLATFORM="linux/arm64" ;;
    *x86-64)          IMAGEPLATFORM="linux/amd64" ;;
    *)                echo "${MACHINE} not supported"; exit 1 ;;
  esac
  for imagename in ${IMAGENAMES}; do
    /usr/bin/docker pull --platform ${IMAGEPLATFORM} ${IMAGE_REGISTRY}/minkebox/${imagename}:${IMAGE_VERSION}
    /usr/bin/docker image save ${IMAGE_REGISTRY}/minkebox/${imagename}:${IMAGE_VERSION} -o ${D}${datadir}/minke/${imagename}.tar
    gzip ${D}${datadir}/minke/${imagename}.tar
  done
  chown root:root -R ${D}${datadir}/minke
}

FILES_${PN} += "${datadir}/minke ${systemd_system_unitdir} /minke ${nonarch_libdir}/tmpfiles.d"
