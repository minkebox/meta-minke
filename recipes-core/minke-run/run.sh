#! /bin/sh

# Install base images. Remove as we go so we don't do it again
for image in /usr/share/minke/*.tar.gz; do
  if [ "${image}" != "/usr/share/minke/*.tar.gz" ]; then
    zcat ${image} | docker image load -q
    rm -f ${image}
  fi
done

mkdir -p /minke /minke/fs /minke/db /minke/skeletons/local
touch /etc/timezone /etc/hostname

docker container rm minke
docker run --name minke \
  -d --privileged \
  -v /etc/timezone:/etc/timezone \
  -v /etc/hostname:/etc/hostname \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --mount type=bind,source=/minke/fs,target=/minke/fs,bind-propagation=rshared \
  --mount type=bind,source=/minke/db,target=/minke/db,bind-propagation=rshared \
  --mount type=bind,source=/minke/skeletons/local,target=/app/skeletons/local,bind-propagation=rshared \
  --network=host \
  registry.gitlab.com/minkebox/minke
