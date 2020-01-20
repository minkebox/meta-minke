DESCRIPTION = "parprouted"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=0636e73ff0215e8d672dc4c32c317bb3"

PR = "r1"
SRC_URI = "http://deb.debian.org/debian/pool/main/p/parprouted/parprouted_0.70.orig.tar.gz"
SRC_URI[md5sum] = "570f5deaf09600df8f80f589de79ecdb"

S = "${WORKDIR}/parprouted-0.7"

TARGET_CC_ARCH += "${LDFLAGS}"
INSANE_SKIP_${PN}-dev += "dev-elf"

PACKAGES = "${PN} ${PN}-dev ${PN}-dbg"
FILES_${PN} = "${sbindir}/*"

PROVIDES += " parprouted "
RPROVIDES_${PN} += " parprouted "

do_configure() {
}

do_compile() {
  oe_runmake STRIP=true CC="${CC}"
}

do_install() {
  install -m 0755 -d ${D}/${sbindir}
  install -m 0755 parprouted ${D}/${sbindir}
}