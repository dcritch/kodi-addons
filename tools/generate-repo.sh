#!/bin/bash
# Builds the hosted repository layout under dist/repo/, ready to be synced
# to https://stderr.ca/kodi/ (see repository.dcritch/addon.xml for the URLs
# Kodi is told to fetch this from).
set -euo pipefail
cd "$(dirname "$0")/.."

REPO_ADDON_ID="repository.dcritch"
NTS_ADDON_ID="plugin.audio.nts"
OUT="dist/repo"

version_of() {
    python3 -c "import xml.etree.ElementTree as ET; print(ET.parse('$1').getroot().get('version'))"
}

addon_xml_body() {
    # Re-serializes just the <addon>...</addon> element, dropping the XML
    # declaration prolog, so multiple addon.xml files can be concatenated
    # into one <addons> document.
    python3 -c "
import xml.etree.ElementTree as ET
print(ET.tostring(ET.parse('$1').getroot(), encoding='unicode'))
"
}

# --- plugin.audio.nts ---
./package.sh
NTS_VERSION="$(version_of ${NTS_ADDON_ID}/addon.xml)"
mkdir -p "${OUT}/${NTS_ADDON_ID}"
cp "dist/${NTS_ADDON_ID}-${NTS_VERSION}.zip" "${OUT}/${NTS_ADDON_ID}/"
cp "${NTS_ADDON_ID}/addon.xml" "${NTS_ADDON_ID}/icon.png" "${OUT}/${NTS_ADDON_ID}/"

# --- repository.dcritch ---
REPO_VERSION="$(version_of ${REPO_ADDON_ID}/addon.xml)"
REPO_STAGE="dist/${REPO_ADDON_ID}"
rm -rf "$REPO_STAGE"
mkdir -p "$REPO_STAGE"
cp "${REPO_ADDON_ID}/addon.xml" "${REPO_ADDON_ID}/icon.png" "$REPO_STAGE/"
(cd dist && zip -r "${REPO_ADDON_ID}-${REPO_VERSION}.zip" "$REPO_ADDON_ID")
mkdir -p "${OUT}/${REPO_ADDON_ID}"
cp "dist/${REPO_ADDON_ID}-${REPO_VERSION}.zip" "${OUT}/${REPO_ADDON_ID}/"
cp "${REPO_ADDON_ID}/addon.xml" "${REPO_ADDON_ID}/icon.png" "${OUT}/${REPO_ADDON_ID}/"

# --- addons.xml + checksum, covering both addons ---
{
    echo '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
    echo '<addons>'
    addon_xml_body "${NTS_ADDON_ID}/addon.xml"
    addon_xml_body "${REPO_ADDON_ID}/addon.xml"
    echo '</addons>'
} > "${OUT}/addons.xml"

md5sum "${OUT}/addons.xml" | cut -d' ' -f1 > "${OUT}/addons.xml.md5"

echo "Repo staged at ${OUT}/ — rsync its contents to https://stderr.ca/kodi/"
