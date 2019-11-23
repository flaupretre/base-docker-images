#---

DW_LAYERS_FILE='/etc/dwrap.layers'
DW_FINAL_DIR='/docker'

GOSS=/usr/bin/goss

[[ ${GOSS_OPTS+x} ]] || GOSS_OPTS="--color --format documentation"
[[ ${GOSS_WAIT_OPTS+x} ]] || GOSS_WAIT_OPTS="-r 30s -s 1s > /dev/null"
GOSS_SLEEP=${GOSS_SLEEP:-}

export DW_LAYERS_FILE DW_FINAL_DIR GOSS GOSS_OPTS GOSS_WAIT_OPTS GOSS_SLEEP

