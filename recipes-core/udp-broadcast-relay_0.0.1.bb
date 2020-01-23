DESCRIPTION = "udp-broadcast-relay"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=18810669f13b87348459e611d31ab760"

PR = "r1"
SRC_URI = "file://COPYING file://main.c file://Makefile"

S = "${WORKDIR}"

TARGET_CC_ARCH += "${LDFLAGS}"
INSANE_SKIP_${PN}-dev += "dev-elf"

PACKAGES = "${PN} ${PN}-dev ${PN}-dbg"
FILES_${PN} = "${sbindir}/*"

PROVIDES += " udp-broadcast-relay "
RPROVIDES_${PN} += " udp-broadcast-relay "

do_configure() {
}

do_compile() {
  oe_runmake STRIP=true CC="${CC}"
}

do_install() {
  install -m 0755 -d ${D}/${sbindir}
  install -m 0755 udp-broadcast-relay ${D}/${sbindir}
}
