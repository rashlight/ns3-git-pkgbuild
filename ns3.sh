#!/bin/sh
cd "/opt/ns3/"
if command -v sudo > /dev/null 2>&1; then
  sudo -u ns3 ./ns3 "$@"
elif command -v doas > /dev/null 2>&1; then
  doas -u ns3 ./ns3 "$@"
elif command -v pkexec > /dev/null 2>&1; then
  pkexec --user ns3 ./ns3 "$@"
else
  echo "No compatible privilege elevation programs detected, fallback to running in root"
  su -c "./ns3 $@" ns3
fi
