# NTS Radio Kodi Addon

A Kodi addon that lets you play [NTS Radio](https://www.nts.live/) — NTS 1,
NTS 2, and the NTS Infinite Mixtapes — directly from the Kodi music add-ons
menu.

This is an unofficial, personal project and is not affiliated with or
endorsed by NTS.

## Requirements

- Kodi 21.x ("Omega")

## Features

- **NTS 1 / NTS 2**: play either live stream directly from the addon's root
  listing.
- **Mixtapes**: browse and play any of the 16 NTS Infinite Mixtapes from a
  submenu.

No account, API key, or extra dependencies are required — streams are played
directly from NTS's public CDN URLs using Kodi's own player.

## Installation

### Option 1: Install from zip

```bash
./package.sh
```

This produces `dist/plugin.audio.nts-<version>.zip`. In Kodi: Settings →
Add-ons → enable "Unknown sources" if prompted → Install from zip file →
select the generated zip.

### Option 2: Copy to the Kodi addons directory

Copy the `plugin.audio.nts/` folder from this repository into Kodi's addons
directory:

- Linux: `~/.kodi/addons/`
- Linux (Flatpak): `~/.var/app/tv.kodi.Kodi/data/addons/`
- macOS: `~/Library/Application Support/Kodi/addons/`
- Windows: `%APPDATA%\Kodi\addons\`

Then restart Kodi.

After installing either way, enable/launch it from Add-ons → Music Add-ons →
NTS Radio.

## Known limitations

This addon has been smoke-tested against real Kodi 21.x instances (both a
physical device and a local Kodi 21.3 flatpak install): the addon loads,
the root and Mixtapes listings render correctly, and NTS 1/NTS 2/mixtape
streams play back through Kodi's own player. A few minor follow-up items
from that testing are still being worked through, so treat this as
working but not yet fully polished.
