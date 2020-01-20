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
GW=$(ip route show | grep default | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)

# If network failed to start, we assign a default address
if [ "${IP}" = "" ]; then
  IP=192.168.1.200
  GW=192.168.1.1
  BCAST=192.168.1.255
  ip addr add ${IP}/24 broadcast ${BCAST} dev ${IFACE}
  ip link set ${IFACE} up
  ip route add default via ${GW}
fi

echo "${IP}:${GW}" > /tmp/pre-docker-network
