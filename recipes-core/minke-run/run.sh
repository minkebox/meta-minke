#! /bin/sh

# Handle in-place upgrades of this script by copying it to a safe instance and running that instead
if [ "$(basename $0)" = "run.sh" ]; then
  SCRIPTPATH="$(cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
  cp "${SCRIPTPATH}/run.sh" "${SCRIPTPATH}/run.current.sh"
  chmod 777 "${SCRIPTPATH}/run.current.sh"
  exec "${SCRIPTPATH}/run.current.sh"
fi

# Install base images. Remove as we go so we don't do it again
if [ ! -f /usr/share/minke/docker-image-install-done ]; then
  for image in /usr/share/minke/*.tar.gz; do
    if [ "${image}" != "/usr/share/minke/*.tar.gz" ]; then
      zcat ${image} | docker image load -q
      rm -f ${image}
    fi
  done
  touch /usr/share/minke/docker-image-install-done
fi

# Make sure various bind points exist
mkdir -p /minke /minke/apps /minke/db /minke/skeletons/local /minke/skeletons/internal
touch /etc/timezone /etc/hostname /minke/minkebox.config /lib/systemd/network/70-bridge.network /lib/systemd/network/80-wifi.network /lib/systemd/network/80-wired.network /etc/wpa_supplicant/wpa_supplicant-wlan0.conf

# If the home nework exists, we remove it and reboot.
# The home network should be destroyed when rebooting, but if the machine crashed it may still exist.
# We must remove it because docker will reset the ip address of the machine to the address stored
# in the home network when docker starts up (ie. at this point it's already happened!). As the address
# may be different, this will cause problems. The only solution is to remove it and reboot so this
# wont happen next time.
if [ "$(docker network inspect home > /dev/null 2>&1 && echo 'exists')" = "exists" ]; then
  docker network rm home
  reboot
fi

# If WLAN is active, we setup the proxy services to copy traffic from wlan to the bridge.
# WiFi doesn't support bridging natively :-(
if [ -f /tmp/pre-docker-wlan-active ]; then
  NWIP=$(ip addr show dev wlan0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}\b" | head -n1)
  # The bridge needs to have the same IP/MASK as the WLAN otherwise the DHCP proxy doesn't work correctly.
  # We also need to put this back by hand because adding devices to the bridge can make it disappear
  bridge_fix() {
    while true; do
      /sbin/ip addr add ${NWIP} dev br0
      sleep 5
    done
  }
  bridge_fix &
  # Give the WLAN our *exact* address so multicast picks the correct interface
  WIP=$(ip addr show dev wlan0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
  ip addr add ${WIP}/32 dev wlan0
  # Raspberry Pi requires promisc for proxy_arp to work on wifi
  ip link set wlan0 promisc on
  # Proxy ARP
  echo 1 > /proc/sys/net/ipv4/conf/wlan0/proxy_arp
  echo 1 > /proc/sys/net/ipv4/conf/br0/proxy_arp
  # Proxy DHCP
  /usr/sbin/dhcp-helper -b wlan0 -i br0
fi

# Use the local nameserver
rm -rf /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# Find root disk
ROOTDISK=$(mount | grep ' / ' | cut -d' ' -f 1 | sed "s:/dev/\(.*\)[0-9]$:\1:" | sed "s:p$::")

RESTART_REASON=/tmp/minke-restart-reason
echo "exit" > ${RESTART_REASON}
TRACER_OUT=/tmp/tracer.out
cp /dev/null ${TRACER_OUT}

while true; do
  docker container rm minke
  REASON=$(cat ${RESTART_REASON})
  echo "exit" > ${RESTART_REASON}
  docker run --name minke \
    --privileged \
    --env RESTART_REASON="${REASON}" \
    --env ROOTDISK="${ROOTDISK}" \
    --mount type=bind,source=/etc/timezone,target=/etc/timezone,bind-propagation=rshared \
    --mount type=bind,source=/etc/hostname,target=/etc/hostname,bind-propagation=rshared \
    --mount type=bind,source=/etc/fstab,target=/etc/fstab,bind-propagation=rshared \
    --mount type=bind,source=/lib/systemd/network/70-bridge.network,target=/etc/systemd/network/bridge.network,bind-propagation=rshared \
    --mount type=bind,source=/lib/systemd/network/80-wifi.network,target=/etc/systemd/network/wlan.network,bind-propagation=rshared \
    --mount type=bind,source=/lib/systemd/network/80-wired.network,target=/etc/systemd/network/wired.network,bind-propagation=rshared \
    --mount type=bind,source=/etc/wpa_supplicant/wpa_supplicant-wlan0.conf,target=/etc/wpa_supplicant.conf,bind-propagation=rshared \
    --mount type=bind,source=${RESTART_REASON},target=${RESTART_REASON},bind-propagation=rshared \
    --mount type=bind,source=${TRACER_OUT},target=${TRACER_OUT},bind-propagation=rshared \
    --mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock,bind-propagation=rshared \
    --mount type=bind,source=/minke/apps,target=/minke/apps,bind-propagation=rshared \
    --mount type=bind,source=/minke/db,target=/minke/db,bind-propagation=rshared \
    --mount type=bind,source=/minke/minkebox.config,target=/minke/minkebox.config,bind-propagation=rshared \
    --mount type=bind,source=/minke/skeletons/local,target=/app/skeletons/local,bind-propagation=rshared \
    --mount type=bind,source=/minke/skeletons/internal,target=/app/skeletons/internal,bind-propagation=rshared \
    --mount type=bind,source=/mnt,target=/mnt,bind-propagation=rshared \
    --network=host \
    --log-driver json-file --log-opt max-size=10k --log-opt max-file=1 \
    registry.minkebox.net/minkebox/minke
  case "$(cat ${RESTART_REASON})" in
    update-native) cp /dev/null ${TRACER_OUT} ; systemctl start dnf-automatic-restart ;;
    halt|reboot|exit) break ;;
    *) ;;
  esac
done

# Remove the network so we can recreate it each time. We *must* do this because the network
# will override the ip address of the machine, and this may be incorrect. This happens as soon
# as docker starts up so we have to remove it during shutdown as it's too late once we start up.
docker network rm home

rm -f /etc/resolv.conf
ln -s /etc/resolv-conf.systemd /etc/resolv.conf

case "$(cat ${RESTART_REASON})" in
  halt) systemctl poweroff ;;
  reboot) systemctl reboot ;;
  *) ;;
esac
