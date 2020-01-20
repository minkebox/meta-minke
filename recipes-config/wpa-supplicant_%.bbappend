FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://wpa_supplicant-wlan0.conf"

inherit systemd
SYSTEMD_SERVICE_${PN} += "wpa_supplicant@wlan0.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

do_install_append() {
  install -m 0755 -d ${D}/etc/wpa_supplicant
  install -m 0644 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}/etc/wpa_supplicant/wpa_supplicant-wlan0.conf
}

FILES_${PN} += "/lib/systemd/system /etc/wpa_supplicant"
