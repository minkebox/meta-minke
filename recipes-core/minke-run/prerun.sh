#! /bin/sh

# Capture our network address before Docker starts (which might change it)
IFACE=wlan0
IP=$(ip addr show dev ${IFACE} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
if [ "${IP}" = "" ]; then
  IFACE=br0
  IP=$(ip addr show dev ${IFACE} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
else
  touch /tmp/pre-docker-wlan-active
fi

# Note first run
FIRSTRUN=$(test -f /usr/share/minke/prerun-done || echo 'yes')
touch /usr/share/minke/prerun-done

# If network failed to start the first time, we assign a default address and reboot
if [ "${FIRSTRUN}" = "yes" -a "${IP}" = "" -a "${IFACE}" = "br0" ]; then
  cat > /lib/systemd/network/70-bridge.network <<__EOF__
[Match]
Name=br0

[Network]
Address=192.168.1.200/24
Gateway=192.168.1.1

[DHCP]
UseDNS=false
__EOF__
  reboot
fi
