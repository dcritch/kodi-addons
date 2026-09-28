from urllib.parse import urlencode

import xbmcaddon
import xbmcgui
import xbmcplugin

from resources.lib.streams import MIXTAPES, STREAMS

ADDON = xbmcaddon.Addon()
_ = ADDON.getLocalizedString
ICON = ADDON.getAddonInfo('icon')


def _build_url(base_url, **params):
    return f'{base_url}?{urlencode(params)}'


def _make_listitem(stream):
    li = xbmcgui.ListItem(label=stream.label)
    li.setProperty('IsPlayable', 'true')
    li.setContentLookup(False)  # skip HEAD probe on the live stream URL

    tag = li.getMusicInfoTag()
    tag.setTitle(stream.label)
    tag.setArtist('NTS Radio')
    tag.setGenres(['Radio'])

    li.setArt({'icon': ICON, 'thumb': ICON})
    return li


def _list_streams(handle, streams):
    items = [(s.url, _make_listitem(s), False) for s in streams]
    xbmcplugin.addDirectoryItems(handle, items, len(items))
    xbmcplugin.setContent(handle, 'songs')
    xbmcplugin.endOfDirectory(handle, cacheToDisc=False)


def list_root(base_url, handle):
    for stream in STREAMS:
        xbmcplugin.addDirectoryItem(handle, stream.url, _make_listitem(stream), isFolder=False)

    mixtapes_li = xbmcgui.ListItem(label=_(32001))  # "Mixtapes"
    mixtapes_li.setArt({'icon': 'DefaultMusicPlaylists.png'})
    xbmcplugin.addDirectoryItem(handle, _build_url(base_url, action='mixtapes'), mixtapes_li, isFolder=True)

    xbmcplugin.setContent(handle, 'songs')
    xbmcplugin.endOfDirectory(handle, cacheToDisc=False)


def list_mixtapes(handle):
    _list_streams(handle, MIXTAPES)


def run(base_url, handle, params):
    if params.get('action') == 'mixtapes':
        list_mixtapes(handle)
    else:
        list_root(base_url, handle)
