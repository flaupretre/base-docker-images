#
# This script is executed by root before building the root image
#============================================================================
set -euo pipefail

id="$(docker run -d --rm \
  -e ROOT_DEBIAN_VERSION="$ROOT_DEBIAN_VERSION" \
  -e SYSFUNC_VERSION=$SYSFUNC_VERSION \
  -e FS=/rootfs \
  "$ROOT_BASE_IMAGE" sh -c 'while true ; do sleep 3600 ; done')"

for i in build_bootstrap cleanup_image ; do
  docker cp $BASE_DIR/docker/root/$i.sh $id:/
  docker exec $id bash -x /$i.sh
done

docker exec $id tar -C /rootfs -cf - . | docker import - root-root:local

docker kill $id



