# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Kodi addon (`plugin.audio.nts`) targeting Kodi 21.x ("Omega") that lets
users play NTS Radio — NTS 1, NTS 2, and the 16 NTS Infinite Mixtapes —
directly from Kodi's Music Add-ons menu.

This repo hosts two Kodi addons side by side, each in its own top-level
folder named after its addon id: `plugin.audio.nts/` (the NTS Radio addon
itself) and `repository.dcritch/` (a Kodi add-on repository that lets users
install/update `plugin.audio.nts` from `https://stderr.ca/kodi/` — see
"Addon repository" below). Repo-level tooling (`package.sh`, `tools/`,
`README.md`, this file) lives at the root, outside either addon folder.

There is no Kodi installation in this development environment — verification
here is limited to static checks (syntax, XML schema, `kodi-addon-checker`).
Real playback and menu rendering must be confirmed on an actual Kodi 21.x
instance.

## Commands

No build step for development — Kodi loads the addon's Python files
directly. `package.sh` only exists to produce a sideload-ready zip.

```bash
./package.sh                    # stage addon files into dist/plugin.audio.nts/ and zip to dist/plugin.audio.nts-<version>.zip
./tools/generate-icon.sh        # regenerate icon.png from art/icon-source.svg via rsvg-convert
./tools/generate-repo.sh        # stage the hosted Kodi repository layout into dist/repo/ (see "Addon repository" below)
```

Static validation (no Kodi required):

```bash
python3 -m py_compile plugin.audio.nts/addon.py plugin.audio.nts/resources/lib/*.py     # syntax check (router.py can't be imported outside Kodi — it needs xbmcgui/xbmcplugin/xbmcaddon)
xmllint --noout plugin.audio.nts/addon.xml repository.dcritch/addon.xml                  # XML well-formedness
pip3 install --user kodi-addon-checker
./package.sh && python3 -m kodi_addon_checker --branch omega dist/plugin.audio.nts   # validate the STAGED package, not the plugin.audio.nts/ source folder — repo-only files (package.sh, tools/, .gitignore, the repository.dcritch/ sibling addon) trip the checker's file-whitelist warnings even though they're excluded from the actual package
```

Installing for manual testing on a real Kodi 21.x instance:

```bash
# Option 1: build a zip and use Kodi's "Install from zip file"
./package.sh

# Option 2: copy straight into Kodi's addons dir (Linux)
cp -r plugin.audio.nts ~/.kodi/addons/
# Flatpak: ~/.var/app/tv.kodi.Kodi/data/addons/
```

After installing, check Kodi's log (Settings → System → Logging → enable
debug logging) for errors from the addon.

## Architecture

- **`addon.xml`** — the Kodi addon manifest: id (`plugin.audio.nts`),
  `<requires><import addon="xbmc.python" version="3.0.1"/></requires>` (Kodi
  20/21's Python API level), the `xbmc.python.pluginsource` extension point
  (`library="addon.py"`, `<provides>audio</provides>`), and addon metadata
  (summary, description, license, icon asset). Note:
  `<reuselanguageinvoker>` was deliberately **not** added — it fails schema
  validation for `pluginsource` extensions under the current Omega XSD (only
  `<provides>`/`<medialibraryscanpath>` are valid children).
- **`plugin.audio.nts/addon.py`** — the thin Kodi entry point. Parses the
  standard Kodi plugin invocation contract (`sys.argv[0]` = base URL,
  `sys.argv[1]` = handle, `sys.argv[2]` = query string) and hands off to
  `resources/lib/router.py`.
- **`plugin.audio.nts/resources/lib/streams.py`** — `STREAMS` (NTS 1, NTS 2)
  and `MIXTAPES` (the 16 Infinite Mixtapes) as `Stream(id, label, url)`
  NamedTuples.
- **`plugin.audio.nts/resources/lib/router.py`** — all `xbmcgui`/`xbmcplugin`/`xbmcaddon`
  interaction lives here. `run()` dispatches on the `action` query param:
  no action → `list_root()` (NTS 1 and NTS 2 as directly playable items,
  plus a "Mixtapes" folder item); `action=mixtapes` → `list_mixtapes()` (all
  16 mixtapes, playable). There is **no `play`/resolve action** — NTS's
  stream URLs are plain, already-playable HTTP audio streams, so each
  `ListItem`'s path is the raw stream URL directly with
  `setProperty('IsPlayable', 'true')`; Kodi's player opens it without
  re-invoking the addon. `setContentLookup(False)` is set on every item to
  stop Kodi from probing the live stream with a HEAD/range request before
  playback.
- **No "Stop" affordance** — Kodi's own player OSD already provides
  stop/pause, so the addon doesn't need to (and can't meaningfully) offer
  one.
- **Localization** — `plugin.audio.nts/resources/language/resource.language.en_gb/strings.po`
  holds exactly one real UI string (`#32001` "Mixtapes"). Stream/mixtape
  names are treated as data, not localizable UI chrome.
- **Icon pipeline** — `plugin.audio.nts/art/icon-source.svg` is a 512×512
  wrapper (solid black background, ~96px padding) around the NTS glyph,
  needed because Kodi requires `icon.png` to have a solid non-transparent
  background. `tools/generate-icon.sh` rasterizes it via `rsvg-convert` to
  the committed `plugin.audio.nts/icon.png`. No fanart
  is included (not required for sideloading, only for official Kodi repo
  submission).
- **`package.sh`** — stages exactly the files Kodi needs
  (`addon.xml`, `addon.py`, `icon.png`, `resources/` from `plugin.audio.nts/`,
  plus the repo-root `LICENSE.txt`) into `dist/plugin.audio.nts/` (folder
  name must match the addon id for Kodi's zip installer to find
  `addon.xml`), then zips it. Version is read from `plugin.audio.nts/addon.xml`
  itself rather than hardcoded. `dist/` is gitignored. `LICENSE.txt` lives at
  the repo root (one license covers the whole repo, both addons) rather than
  inside `plugin.audio.nts/`.
- **Addon repository** — `repository.dcritch/` is a second, separate Kodi
  addon (source alongside `plugin.audio.nts/`, both at the repo root) of type
  `xbmc.addon.repository`. Its `addon.xml` points Kodi at
  `https://stderr.ca/kodi/` for `addons.xml`, `addons.xml.md5`, and the
  per-addon zips (`<datadir zip="true">`). `tools/generate-repo.sh` builds
  the actual hosted layout into `dist/repo/`: it runs `package.sh` for
  `plugin.audio.nts`, zips `repository.dcritch/` the same way, and
  concatenates both `addon.xml` files into one `addons.xml` (+ its
  `.md5` checksum) — the format Kodi's repository mechanism expects.
  Publishing a new version means bumping the relevant `addon.xml`
  (`plugin.audio.nts`'s or `repository.dcritch`'s), re-running
  `tools/generate-repo.sh`, and syncing `dist/repo/`'s contents to
  `https://stderr.ca/kodi/` (e.g. `rsync -av dist/repo/ host:/path/to/kodi/`
  — not committed here, so this last step is manual/external to this repo).
  Users add the repo in Kodi once via `repository.dcritch`'s zip
  (Install from zip file), then install/update `plugin.audio.nts` through
  Kodi's normal addon browser from then on.
