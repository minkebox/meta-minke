#! /bin/sh

#IFACE=br0

# Install base images. Remove as we go so we don't do it again
for image in /usr/share/minke/*.tar.gz; do
  if [ "${image}" != "/usr/share/minke/*.tar.gz" ]; then
    zcat ${image} | docker image load -q
    rm -f ${image}
  fi
done

# Create home network
#IP=$(ip addr show dev ${IFACE} | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
#NET=$(echo ${IP} | sed "s/^\([0-9]\+.[0-9]\+.[0-9]\+\).*$/\1/")

#docker network rm home
#docker network create --driver=bridge \
#  --subnet=${NET}.0/24 \
#  --gateway=${NET}.1 \
#  -o "com.docker.network.bridge.name=${IFACE}" \
#  home

# Deallocate local adddress so we can re-use it in Minke
#ifconfig ${IFACE} 0.0.0.0

mkdir -p /minke /minke/fs /minke/db /minke/skeletons/local
touch /etc/timezone 

docker container rm minke
docker run --name minke \
  -d --privileged \
  -v /etc/timezone:/etc/timezone \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --mount type=bind,source=/minke/fs,target=/minke/fs,bind-propagation=rshared \
  --mount type=bind,source=/minke/db,target=/minke/db,bind-propagation=rshared \
  --mount type=bind,source=/minke/skeletons/local,target=/app/skeletons/local,bind-propagation=rshared \
  --network=host \
  registry.gitlab.com/minkebox/minke
