FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

inherit systemd
SYSTEMD_SERVICE_${PN} += "wpa_supplicant@wlan0.service"
SYSTEMD_AUTO_ENABLE_${PN} = "enable"

do_install_append() {
  install -m 0755 -d ${D}/etc/wpa_supplicant
}

FILES_${PN} += "/lib/systemd/system /etc/wpa_supplicant"
