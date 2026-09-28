#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

ADDON_ID="plugin.audio.nts"
VERSION="$(python3 -c "import xml.etree.ElementTree as ET; print(ET.parse('${ADDON_ID}/addon.xml').getroot().get('version'))")"
DIST="dist"
STAGE="${DIST}/${ADDON_ID}"

rm -rf "$DIST"
mkdir -p "$STAGE"
cp -r "${ADDON_ID}/addon.xml" "${ADDON_ID}/addon.py" LICENSE.txt "${ADDON_ID}/icon.png" "${ADDON_ID}/resources" "$STAGE/"
find "$STAGE" -name '__pycache__' -exec rm -rf {} +

(cd "$DIST" && zip -r "${ADDON_ID}-${VERSION}.zip" "$ADDON_ID")
echo "Built ${DIST}/${ADDON_ID}-${VERSION}.zip"
