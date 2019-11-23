#!/usr/bin/env bash
# This script builds intermediate and final images
# Usage: build.sh [stage names] [build opts]
# This script is run by root
#=============================================================================
set -euo pipefail

#---------------

cleanup()
{
local rc

rc="$1"

if [ -z "${BASE_DIR+x}" ] ; then
  echo "ERROR: BASE_DIR is not set - cannot cleanup"
  exit 1
fi

rm -rf $TMP_DF "$BASE_DIR/tmp"

exit $rc
}

#---------------
# Analyze a Dockerfile and build the corresponding option string

function file_options()
{
local dfile res arg args

dfile="$1"
res=

# Build args

args=$(awk '( $1 == "ARG" ) { print $2 }' <"$dfile" | grep -v '=')
for arg in $args ; do
  value=$(eval "echo \$$arg")
  res="$res --build-arg $arg=$value"
done

echo "$res"
}

#---

function do_stages()
{
local stages stage img dfile ddir fopts envfile options

stages="$*"

# Ensure stages are run in the right order
for stage in $BUILD_STAGES ; do
  echo "$stages" | grep -qw "$stage" || continue
  echo "Building stage: $stage"
  echo >"$TMP_DF"
  echo 'USER 0' >>"$TMP_DF"
  img=$(img_name "$stage")
  dfile="$BASE_DIR/Dockerfile.$stage"
  export STAGE="$stage"
  fopts="$(file_options "$dfile")"
  BUILD_OPTIONS=''
  ddir="$BASE_DIR/docker/$stage"
  envfile="$ddir/env.sh"
  [ -f "$envfile" ] && source "$envfile"
  options="$BUILD_OPTIONS $CLI_OPTS $fopts"
  cd "$BASE_DIR"
  [ -f "README.md" ] && echo "ADD README.md /docker.$stage/README.md" >>"$TMP_DF"
  echo "ADD Dockerfile.$stage /docker.$stage/Dockerfile" >>"$TMP_DF"
  echo "RUN test -d /docker.$stage && rm -rf /docker && ln -s docker.$stage /docker" >>"$TMP_DF"
  echo "RUN echo $stage >>/etc/dwrap.layers" >>"$TMP_DF"
  if [ -x "$ddir/$ACTION.pre.sh" ] ; then
    echo "Running pre-$ACTION script"
    bash "$ddir/$ACTION.pre.sh"
    cd "$BASE_DIR"
  fi
  #-- Restore runtime user (last USER line in Dockerfile)
  uline="$(awk '$1 == "USER"' <$dfile | tail -1)"
  [ "X$uline" = X ] || echo "$uline" >>$TMP_DF
  set -x
  cat "$dfile" "$TMP_DF" | docker build $options -t "$img" -f - .
  set +x
  if [ -x "$ddir/$ACTION.post.sh" ] ; then
    echo "Running post-$ACTION script"
    bash "$ddir/$ACTION.post.sh"
    cd "$BASE_DIR"
  fi
done
}

#============================================================================
# Main

BASE_DIR="$PWD"
cmd="$0"
c="$(readlink -f $cmd)"
[ -n "$c" ] && cmd="$c"
cd "$(dirname "$cmd")"
DBUILD_DIR="$(/bin/pwd)"
cd "$BASE_DIR"

source ./vars.sh  #-- Get global variables

ACTION=build

TMP_DF=/tmp/.df_$ACTION.tmp.$$

export BASE_DIR DBUILD_DIR ACTION TMP_DF

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
[ -z "$STAGES" ] && STAGES="$BUILD_STAGES"
echo "$STAGES" | grep -qw all && STAGES="$BUILD_STAGES"

#--

do_stages $STAGES

#--
# Cleanup and exit

cleanup 0
