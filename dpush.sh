#!/usr/bin/env bash
# This script pushes images to docker hub
# Usage: push.sh [stage names] [push opts]
# This script is run by root
#=============================================================================
set -euo pipefail

#-- Get global variables

source ./vars.sh

#---------------

cleanup()
{
local rc

rc="$1"

if [ -z "${BASE_DIR}" ] ; then
  echo "ERROR: BASEDIR is not set - cannot cleanup"
else
  rm -rf "$BASE_DIR/tmp"
fi

exit $rc
}

#---

function do_stages()
{
local stages stage img ddir envfile options

stages="$*"

for stage in $stages ; do
  if echo "$PUSH_STAGES" | grep -qw "$stage" ; then
    echo "Pushing stage: $stage"
    img=$(img_name "$stage")
    PUSH_OPTIONS=''
    ddir="$BASE_DIR/docker/$stage"
    envfile="$ddir/env.sh"
    [ -f "$envfile" ] && source "$envfile"
    options="$PUSH_OPTIONS $CLI_OPTS"
    cd "$BASE_DIR"
    if [ -x "$ddir/$ACTION.pre.sh" ] ; then
      echo "Running pre-$ACTION script"
      "$ddir/$ACTION.pre.sh"
      cd "$BASE_DIR"
    fi
    docker push "$img"
    if [ -x "$ddir/$ACTION.post.sh" ] ; then
      echo "Running post-$ACTION script"
      "$ddir/$ACTION.post.sh"
    fi
  else
    echo "Warning: $stage: Invalid stage name - ignored"
  fi
done
}

#============================================================================
# Main

savepwd="$PWD"
cd "$(dirname "$0")"
BASE_DIR="$(/bin/pwd)"
cd "$savepwd"

ACTION=push

TMP_DF=/tmp/.df_$ACTION.tmp.$$

export BASE_DIR ACTION TMP_DF

trap 'cleanup 1' 1 2 3 6 15

#--

STAGES=''
CLI_OPTS=''

while true ; do
  [ $# = 0 ] && break
  echo "$1" | grep -q '^-' && break
  STAGES="$STAGES $1"
  shift
done
export CLI_OPTS="$*"
[ -z "$STAGES" ] && STAGES="$PUSH_STAGES"
echo "$STAGES" | grep -qw all && STAGES="$PUSH_STAGES"

#--

do_stages $STAGES

#--
# Cleanup and exit

cleanup 0
