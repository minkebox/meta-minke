#! /bin/sh

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
touch /etc/timezone /etc/hostname /lib/systemd/network/70-bridge.network /lib/systemd/network/80-wifi.network /lib/systemd/network/80-wired.network /etc/wpa_supplicant/wpa_supplicant-wlan0.conf

# Check that the Docker home network is still consistent with our IP and default route. If not, we delete the
# Docker network and reboot (to force the network to setup again)
#DOCKERIPNET=$(docker network inspect home -f '{{(index .IPAM.Config 0).Gateway}}:{{(index .IPAM.Config 0).AuxiliaryAddresses.DefaultGatewayIPv4}}')
#ORIGINALIPNET=$(cat /tmp/pre-docker-network)
#if [ "${DOCKERIPNET}" != "${ORIGINALIPNET}" ]; then
#  if docker network rm home ; then
#    reboot
#  fi
#fi

# If WLAN is active, we setup the proxy services to copy traffic from wlan to the bridge.
# WiFi doesn't support bridging natively :-(
if [ -f /tmp/pre-docker-wlan-active ]; then
  NWIP=$(ip addr show dev wlan0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}\b" | head -n1)
  WIP=$(ip addr show dev wlan0 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
  # The bridge needs to be on the same network as the wlan (despite it not being really bridged) otherwise
  # things don't work properly when traffic is being proxied.
  bridge_fix() {
    while true; do
      /sbin/ip addr add ${NWIP} dev br0
      sleep 5
    done
  }
  bridge_fix &
  # Give the WLAN our *exact* address to multicast picks the correct interface
  /sbin/ip addr add ${WIP}/32 dev wlan0
  # Proxy ARP
  /usr/sbin/parprouted -p wlan0 br0
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
    --mount type=bind,source=/minke/skeletons/local,target=/app/skeletons/local,bind-propagation=rshared \
    --mount type=bind,source=/minke/skeletons/internal,target=/app/skeletons/internal,bind-propagation=rshared \
    --mount type=bind,source=/mnt,target=/mnt,bind-propagation=rshared \
    --network=host \
    --log-driver json-file --log-opt max-size=10k --log-opt max-file=1 \
    registry.minkebox.net/minkebox/minke
  case "$(cat ${RESTART_REASON})" in
    halt) systemctl poweroff ;;
    reboot) systemctl reboot ;;
    update-native) cp /dev/null ${TRACER_OUT} ; systemctl start dnf-automatic-restart ;;
    exit) exit ;;
    *) ;;
  esac
done

rm -f /etc/resolv.conf
ln -s /etc/resolv-conf.systemd /etc/resolv.conf
