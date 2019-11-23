#!/usr/bin/env bash
#
#============================================================================
set -euo pipefail

. sysfunc

#---

source /docker.root/dwrap_vars.sh

#----

function _dw_layers()
{
cat $DW_LAYERS_FILE
}

#----

function _dw_scripts()
{
local res f name

name="$1"

res=''
for i in $(_dw_layers); do
  f="/docker.$i/$name"
  [ -f "$f" ] && res="$res $f"
done

echo "$res"
}

#----

run_goss_tests()
{
local var_opts gfiles gfile dir


for gfile in $(_dw_scripts goss_wait.yaml) ; do
    sf_trace "Waiting for $gfile to pass before running tests"
    dir="$(dirname "$gfile")"
    var_opts=
    [ -f "$dir/goss_vars.yaml" ] && var_opts="--vars='$dir/goss_vars.yaml'"
    $GOSS -g "$gfile" $var_opts validate $GOSS_WAIT_OPTS \
      || sf_error "$gfile: didn't pass"
done

if [ "X$GOSS_SLEEP" != X ]; then
  sf_msg "Sleeping for $GOSS_SLEEP"
  sleep "$GOSS_SLEEP"
fi

for gfile in $(_dw_scripts goss.yaml) ; do
    sf_msg "Running tests from $gfile"
    dir="$(dirname "$gfile")"
    var_opts=
    [ -f "$dir/goss_vars.yaml" ] && var_opts="--vars='$dir/goss_vars.yaml'"
    $GOSS -g "$gfile" $var_opts validate $GOSS_OPTS \
      || sf_error "$gfile: test failed"
done
}

#----

function dw_test()
{
local f

for f in $(_dw_scripts test.sh) ; do
    sf_msg "Running test from $f"
    bash $f $*
done

run_goss_tests
}

#----

function dw_init()
{
local f

for f in $(_dw_scripts init.sh) ; do
    sf_msg "$f: Running init script"
    bash $f $*
done
}

#----

function util_usage()
{
local rc msg u

rc=0
if [ $# != 0 ]; then
  echo "ERROR: $*"
  rc=1
fi

echo "Usage: dwrap util <utility> [options]"
echo
echo "Available utilities:"
typeset -F | sed 's/^declare -f //' | grep '^ut_' | sed 's/^ut_//' \
  | while read u ; do
  echo "    - $u"
done

exit $rc
}

#----

function dw_util()
{
local util func i

for i in $(_dw_scripts util.sh) ; do
  [ -f "$i" ] && source $i
done

[ $# = 0 ] && util_usage
util="$1"
shift
func="ut_$util"
type "$func" >/dev/null 2>&1 || util_usage "$util: Unknown utility"
eval "$func $* ; _rc=\$?"
return $_rc
}

#----

dw_sleep()
{
while true; do sleep 3600 ; done
}

#----

function dw_run()
{
local runscript

runscript="$DW_FINAL_DIR/run.sh"
if [ -x "$runscript" ] ; then
  exec "$runscript" $*
else
  sf_msg "Run script ($runscript) not found or not executable - Going to sleep..."
  exec dwrap sleep
fi
}

#----

function dw_stop()
{
local script

script="$DW_FINAL_DIR/stop.sh"
if [ -x "$script" ] ; then
  exec "$script" $*
else
  sf_error "Stop script ($script) not found or not executable"
fi
}

#----

function usage()
{
local rc msg u

rc=0
if [ $# != 0 ]; then
  echo "ERROR: $*"
  rc=1
fi

echo "Usage: dwrap <command> [options]"
echo
echo "Available commands:"
typeset -F | sed 's/^declare -f //' | grep '^dw_' | sed 's/^dw_//' \
  | while read u ; do
  echo "    - $u"
done

exit $rc
}

#----
# MAIN
# Dispatch functions

for script in $(_dw_scripts dwrap.sh) ; do
  source $script
done

[ $# = 0 ] && usage
cmd="$1"
shift

func="dw_$cmd"
type "$func" >/dev/null 2>&1 || usage "$cmd: Unknown command"
eval "$func $* ; _rc=\$?"
exit $_rc
