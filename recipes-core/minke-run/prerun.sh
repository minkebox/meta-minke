#! /bin/sh

# Capture our network address before Docker starts (which might change it)
IFACE=br0
IP=$(ip addr show dev ${IFACE} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
GW=$(ip route show | grep default | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")
echo "${IP}:${GW}" > /tmp/pre-docker-network
