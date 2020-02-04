#! /bin/sh
# Create default network setup
cat > /lib/systemd/network/70-bridge.network <<__EOF__
[Match]
Name=br0

[Network]
DHCP=ipv4

[DHCP]
UseDNS=false
__EOF__
cat > /lib/systemd/network/80-wifi.network <<__EOF__
[Match]
Name=wlan0

[Network]
DHCP=ipv4

[DHCP]
UseDNS=false
__EOF__
cat > /lib/systemd/network/80-wired.network <<__EOF__
[Match]
Name=en* eth*

[Network]
Bridge=br0
__EOF__
