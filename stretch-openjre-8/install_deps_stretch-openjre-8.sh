#!/usr/bin/env bash
set -euxo pipefail

# This man folder is required to be able to install packages, but it does not exist in debian:stretch-slim.
# So we create it.
mkdir -p /usr/share/man/man1
# install jre without pining the version, beacause debian stretch provide stable openjdk version 8
# and mostly upgrade for security reason
apt-get update && apt-get -qy install openjdk-8-jre

# Debug tools untils we have our ledger-stretch-slim image
apt-get install -yq curl netcat iputils-ping iproute2 lsof procps

# Cleanup
apt-get clean
rm -rf -- /var/lib/apt/lists/*
exit 0
