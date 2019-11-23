#!/usr/bin/env bash
# This script runs one or several final image(s)
# Usage: run.sh [stage names] {run opts]
#=============================================================================
set -euo pipefail

#-- Get global variables

source ./vars.sh

#---

function do_stages()
{
local stages stage img envfile

stages="$*"

for stage in $stages ; do
  if echo "$RUN_STAGES" | grep -qw "$stage" ; then
    img=$(img_name "$stage")
    RUN_OPTIONS=''
    envfile="$BASE_DIR/docker/$stage/env.sh"
    [ -f "$envfile" ] && source "$envfile"
    [ -z "${CMD+x}" ] && CMD=
    set -x
    docker run $RUN_OPTIONS $CLI_OPTS --name "$CONTAINER_PREFIX$stage" $img $CMD
    set +x
  else
    echo "Warning: $stage: Invalid stage name - ignored"
  fi
done
}

#---

BASE_DIR="$(dirname "$0")"
ACTION=run

export BASE_DIR ACTION

#--

STAGES=''
CLI_OPTS=''

while true ; do
  [ $# = 0 ] && break
  echo "$1" | grep '^-' && break
  STAGES="$STAGES $1"
  shift
done
export CLI_OPTS="$*"
[ -z "$STAGES" ] && STAGES="$RUN_STAGES"

#--

do_stages $STAGES
