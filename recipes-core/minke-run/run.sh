#! /bin/sh

SWAPSIZE=100M

# Install base images. Remove as we go so we don't do it again
for image in /usr/share/minke/*.tar.gz; do
  if [ "${image}" != "/usr/share/minke/*.tar.gz" ]; then
    zcat ${image} | docker image load -q
    rm -f ${image}
  fi
done

# Create some swap space
SWAPFILE=/swapfile
fallocate --length ${SWAPSIZE} ${SWAPFILE}
chmod 600 ${SWAPFILE}
mkswap ${SWAPFILE}
swapon ${SWAPFILE}

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
