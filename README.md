# NTS Radio Kodi Addon

A Kodi addon that lets you play [NTS Radio](https://www.nts.live/) — NTS 1,
NTS 2, and the NTS Infinite Mixtapes — directly from the Kodi music add-ons
menu. Companion to the [GNOME Shell NTS Radio extension](https://github.com/dcritch/gnome-nts),
reimplemented as a native `plugin.audio.*` Kodi addon.

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

Copy this repository into Kodi's addons directory, named to match the addon
id:

- Linux: `~/.kodi/addons/plugin.audio.nts/`
- Linux (Flatpak): `~/.var/app/tv.kodi.Kodi/data/addons/plugin.audio.nts/`
- macOS: `~/Library/Application Support/Kodi/addons/plugin.audio.nts/`
- Windows: `%APPDATA%\Kodi\addons\plugin.audio.nts\`

Then restart Kodi.

After installing either way, enable/launch it from Add-ons → Music Add-ons →
NTS Radio.

## Known limitations

This addon was developed and statically validated without a local Kodi
installation available. It has not yet been smoke-tested against a real
Kodi 21.2 instance — please verify playback and menu navigation on your own
setup before relying on it.
