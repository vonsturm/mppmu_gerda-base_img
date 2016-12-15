#!/bin/bash -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"${SCRIPT_DIR}"/install-sw.sh root 6.06.08 /opt/root
"${SCRIPT_DIR}"/install-sw.sh clhep 2.1.3.1 /opt/clhep
"${SCRIPT_DIR}"/install-sw.sh geant4 9.6.4 /opt/geant4
