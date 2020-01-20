DESCRIPTION = "Netifaces"
HOMEPAGE = "https://github.com/al45tair/netifaces"
SECTION = "devel/python"
LICENSE = "MIT"
LIC_FILES_CHKSUM="file://LICENSE;md5=e4677613c25bf3673bfee98c0cc52202"

#DEPENDS = "python-core"
RDEPENDS_${PN} = "python3"
PR = "r0"

SRC_URI = "https://github.com/al45tair/netifaces/archive/release_0_10_9.tar.gz"
SRC_URI[md5sum] = "67468890eb744dd3cc7f4683a1d426a7"

S = "${WORKDIR}/netifaces-release_0_10_9/"

RDEPENDS_${PN} += " \
  python3-core \
  python3 \
  python3-setuptools \
"

inherit setuptools3

# need to export these variables for python-config to work
#export BUILD_SYS
#export HOST_SYS
#export STAGING_INCDIR
#export STAGING_LIBDIR
#
#BBCLASSEXTEND = "native"
#
#do_install_append() {
#  rm -f ${D}${libdir}/python*/site-packages/site.py*
#}
