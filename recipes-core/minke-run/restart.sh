#! /bin/sh

RESTART_REASON=/minke/minke-restart-reason

echo -n 'restart' > ${RESTART_REASON}
docker kill minke
