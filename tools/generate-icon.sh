#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
rsvg-convert -w 512 -h 512 -o icon.png art/icon-source.svg
