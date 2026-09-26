# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Kodi addon (`plugin.audio.nts`) targeting Kodi 21.x ("Omega") that lets
users play NTS Radio — NTS 1, NTS 2, and the 16 NTS Infinite Mixtapes —
directly from Kodi's Music Add-ons menu. It's the Kodi counterpart to the
[GNOME Shell NTS Radio extension](https://github.com/dcritch/gnome-nts): the
same stream list, reimplemented as a native `plugin.audio.*` addon instead of
a panel indicator driven by `ffplay`.

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
```

Static validation (no Kodi required):

```bash
python3 -m py_compile addon.py resources/lib/*.py     # syntax check (router.py can't be imported outside Kodi — it needs xbmcgui/xbmcplugin/xbmcaddon)
xmllint --noout addon.xml                              # XML well-formedness
pip3 install --user kodi-addon-checker
./package.sh && python3 -m kodi_addon_checker --branch omega dist/plugin.audio.nts   # validate the STAGED package, not the repo root — the repo root's folder name won't match the addon id, and repo-only files (package.sh, tools/, art/, .gitignore) trip the checker's file-whitelist warnings even though they're excluded from the actual package
```

Installing for manual testing on a real Kodi 21.x instance:

```bash
# Option 1: build a zip and use Kodi's "Install from zip file"
./package.sh

# Option 2: copy straight into Kodi's addons dir (Linux)
cp -r . ~/.kodi/addons/plugin.audio.nts/
# Flatpak: ~/.var/app/tv.kodi.Kodi/data/addons/plugin.audio.nts/
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
- **`addon.py`** (repo root) — the thin Kodi entry point. Parses the
  standard Kodi plugin invocation contract (`sys.argv[0]` = base URL,
  `sys.argv[1]` = handle, `sys.argv[2]` = query string) and hands off to
  `resources/lib/router.py`.
- **`resources/lib/streams.py`** — `STREAMS` (NTS 1, NTS 2) and `MIXTAPES`
  (the 16 Infinite Mixtapes) as `Stream(id, label, url)` NamedTuples. This is
  a direct port of `STREAMS`/`MIXTAPES` in `gnome-nts/extension.js` — same
  ids, labels, URLs, and order. If the upstream stream list changes there,
  update it here too.
- **`resources/lib/router.py`** — all `xbmcgui`/`xbmcplugin`/`xbmcaddon`
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
- **No "Stop" affordance** — unlike the GNOME extension's panel menu, Kodi's
  own player OSD already provides stop/pause, so the addon doesn't need to
  (and can't meaningfully) offer one.
- **Localization** — `resources/language/resource.language.en_gb/strings.po`
  holds exactly one real UI string (`#32001` "Mixtapes"). Stream/mixtape
  names are treated as data, not localizable UI chrome, matching how the
  GNOME extension hardcodes English labels.
- **Icon pipeline** — `art/icon-source.svg` is a 512×512 wrapper (solid
  black background, ~96px padding) around the same glyph path used in
  `gnome-nts/icons/nts.svg`, needed because Kodi requires `icon.png` to have
  a solid non-transparent background. `tools/generate-icon.sh` rasterizes it
  via `rsvg-convert` to the committed `icon.png` at the repo root. No fanart
  is included (not required for sideloading, only for official Kodi repo
  submission).
- **`package.sh`** — stages exactly the files Kodi needs
  (`addon.xml`, `addon.py`, `LICENSE.txt`, `icon.png`, `resources/`) into
  `dist/plugin.audio.nts/` (folder name must match the addon id for Kodi's
  zip installer to find `addon.xml`), then zips it. Version is read from
  `addon.xml` itself rather than hardcoded. `dist/` is gitignored.
