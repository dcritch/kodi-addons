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

summary_of() {
    python3 -c "
import xml.etree.ElementTree as ET
root = ET.parse('$1').getroot()
meta = root.find(\"./extension[@point='xbmc.addon.metadata']\")
print(meta.find('summary').text)
"
}

description_of() {
    python3 -c "
import xml.etree.ElementTree as ET
root = ET.parse('$1').getroot()
meta = root.find(\"./extension[@point='xbmc.addon.metadata']\")
print(meta.find('description').text)
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

# --- index.html, a human-friendly landing page for https://stderr.ca/kodi/ ---
NTS_SUMMARY="$(summary_of "${NTS_ADDON_ID}/addon.xml")"
NTS_DESCRIPTION="$(description_of "${NTS_ADDON_ID}/addon.xml")"
REPO_SUMMARY="$(summary_of "${REPO_ADDON_ID}/addon.xml")"
REPO_DESCRIPTION="$(description_of "${REPO_ADDON_ID}/addon.xml")"

python3 -c "
import sys

template_path, out_path = sys.argv[1], sys.argv[2]
values = {
    '__ADDON_COUNT__': '2',
    '__NTS_VERSION__': sys.argv[3],
    '__NTS_SUMMARY__': sys.argv[4],
    '__NTS_DESCRIPTION__': sys.argv[5],
    '__REPO_VERSION__': sys.argv[6],
    '__REPO_SUMMARY__': sys.argv[7],
    '__REPO_DESCRIPTION__': sys.argv[8],
}
with open(template_path) as f:
    html = f.read()
for placeholder, value in values.items():
    html = html.replace(placeholder, value)
with open(out_path, 'w') as f:
    f.write(html)
" "tools/repo-index.html.tmpl" "${OUT}/index.html" \
  "$NTS_VERSION" "$NTS_SUMMARY" "$NTS_DESCRIPTION" \
  "$REPO_VERSION" "$REPO_SUMMARY" "$REPO_DESCRIPTION"

echo "Repo staged at ${OUT}/ — rsync its contents to https://stderr.ca/kodi/"
