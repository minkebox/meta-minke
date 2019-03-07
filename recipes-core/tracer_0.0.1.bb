SUMMARY = "Tracer"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PROVIDES = "tracer"
RPROVIDES_${PN} = "tracer"

SRCREV = "master"
PR = "r1"
SRC_URI = "git://github.com/FrostyX/tracer.git;protocol=https"

RDEPENDS_${PN} += " \
  python3 \
  python3-setuptools \
  python3-psutil \
  python3-dbus \
  python3-beautifulsoup4 \
"

do_install() {
  install -d ${D}${datadir}/tracer
  cp -R ${WORKDIR}/git/* ${D}${datadir}/tracer
  chown root:root -R ${D}${datadir}/tracer

  (cd ${D}${datadir}/tracer ; patch -p1 < ${THISDIR}/${PN}/py2topy3.patch)
  (cd ${D}${datadir}/tracer ; patch -p1 < ${THISDIR}/${PN}/metaclass.patch)

  install -d ${D}${bindir}
  ln -s ${datadir}/tracer/bin/tracer.py ${D}${bindir}/tracer
}

FILES_${PN} += "${datadir}/tracer ${bindir}/tracer"
