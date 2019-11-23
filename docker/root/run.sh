#!/usr/bin/env bash
#
# This script is generally overriden by one in an upper layer.
#
# This script runs as 'duser'
#=============================================================================
set -euo pipefail

exec dwrap sleep
