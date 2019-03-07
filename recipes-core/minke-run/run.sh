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
mkdir -p /minke /minke/fs /minke/db /minke/skeletons/local
touch /etc/timezone /etc/hostname /etc/systemd/network/bridge.network

# Use the local nameserver
OLDRESOLV=$(cat /etc/resolv.conf)
echo "nameserver 127.0.0.1" > /etc/resolv.conf

# Check that the Docker home network is still consistent with our IP and default route. If not, we delete the
# Docker network and reboot (to force the network to setup again)
DOCKERIPNET=$(docker network inspect home -f '{{(index .IPAM.Config 0).Gateway}}:{{(index .IPAM.Config 0).AuxiliaryAddresses.DefaultGatewayIPv4}}')
ORIGINALIPNET=$(cat /tmp/pre-docker-network)
if [ "${DOCKERIPNET}" != "${ORIGINALIPNET}" ]; then
  if docker network rm home ; then
    reboot
  fi
fi

RESTART_REASON=/tmp/minke-restart-reason
echo "exit" > ${RESTART_REASON}
TRACER_OUT=/tmp/tracer.out
touch ${TRACER_OUT}

while true; do 
  docker container rm minke
  docker run --name minke \
    --privileged \
    -e RESTART_REASON="$(cat ${RESTART_REASON})" \
    -v /etc/timezone:/etc/timezone \
    -v /etc/hostname:/etc/hostname \
    -v /etc/systemd/network/bridge.network:/etc/systemd/network/bridge.network \
    -v ${RESTART_REASON}:${RESTART_REASON} \
    -v ${TRACER_OUT}:${TRACER_OUT} \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --mount type=bind,source=/minke/fs,target=/minke/fs,bind-propagation=rshared \
    --mount type=bind,source=/minke/db,target=/minke/db,bind-propagation=rshared \
    --mount type=bind,source=/minke/skeletons/local,target=/app/skeletons/local,bind-propagation=rshared \
    --network=host \
    registry.gitlab.com/minkebox/minke
  case "$(cat ${RESTART_REASON})" in
    halt)   systemctl poweroff ;;
    reboot) systemctl reboot ;;
    update) systemctl start dnf-automatic-restart ;;
    exit)   exit ;;
    *) ;;
  esac
done

# Put back the old resolv
echo ${OLDRESOLV} > /etc/resolv.conf
