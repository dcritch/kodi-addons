#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
rsvg-convert -w 512 -h 512 -o plugin.audio.nts/icon.png plugin.audio.nts/art/icon-source.svg
