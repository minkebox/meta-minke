SUMMARY = "Multicast Relay"
LICENSE = "GPL-3.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d32239bcb673463ab874e80d47fae504"

PROVIDES = "multicast-relay"
RPROVIDES_${PN} = "multicast-relay"

SRCREV = "master"
PR = "r1"
SRC_URI = "git://github.com/aanon4/multicast-relay.git;protocol=http"

S = "${WORKDIR}/git/"

RDEPENDS_${PN} += " \
  python3-core \
  python3 \
  py-netifaces \
"

do_install() {
  install -m 0755 -d ${D}${sbindir}
  install -m 0755 multicast-relay.py ${D}${sbindir}/multicast-relay
}

FILES_${PN} += "${sbindir}/*"
