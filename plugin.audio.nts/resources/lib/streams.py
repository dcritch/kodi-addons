from typing import List, NamedTuple


class Stream(NamedTuple):
    id: str
    label: str
    url: str


STREAMS: List[Stream] = [
    Stream('nts1', 'NTS 1', 'https://audio-edge-qse4n.yyz.g.radiomast.io/nts1'),
    Stream('nts2', 'NTS 2', 'https://audio-edge-qse4n.yyz.g.radiomast.io/nts2'),
]

# NTS Infinite Mixtapes: https://www.nts.live/infinite-mixtapes
MIXTAPES: List[Stream] = [
    Stream('mixtape4', 'Poolside', 'https://stream-mixtape-geo.ntslive.net/mixtape4'),
    Stream('mixtape', 'Slow Focus', 'https://stream-mixtape-geo.ntslive.net/mixtape'),
    Stream('mixtape2', 'Low Key', 'https://stream-mixtape-geo.ntslive.net/mixtape2'),
    Stream('mixtape6', 'Memory Lane', 'https://stream-mixtape-geo.ntslive.net/mixtape6'),
    Stream('mixtape5', '4 To The Floor', 'https://stream-mixtape-geo.ntslive.net/mixtape5'),
    Stream('mixtape21', 'Island Time', 'https://stream-mixtape-geo.ntslive.net/mixtape21'),
    Stream('mixtape26', 'The Tube', 'https://stream-mixtape-geo.ntslive.net/mixtape26'),
    Stream('mixtape35', 'Sheet Music', 'https://stream-mixtape-geo.ntslive.net/mixtape35'),
    Stream('mixtape27', 'Feelings', 'https://stream-mixtape-geo.ntslive.net/mixtape27'),
    Stream('mixtape3', 'Expansions', 'https://stream-mixtape-geo.ntslive.net/mixtape3'),
    Stream('mixtape22', 'Rap House', 'https://stream-mixtape-geo.ntslive.net/mixtape22'),
    Stream('mixtape31', 'Labyrinth', 'https://stream-mixtape-geo.ntslive.net/mixtape31'),
    Stream('mixtape24', 'Sweat', 'https://stream-mixtape-geo.ntslive.net/mixtape24'),
    Stream('mixtape36', 'Otaku', 'https://stream-mixtape-geo.ntslive.net/mixtape36'),
    Stream('mixtape34', 'The Pit', 'https://stream-mixtape-geo.ntslive.net/mixtape34'),
    Stream('mixtape23', 'Field Recordings', 'https://stream-mixtape-geo.ntslive.net/mixtape23'),
]
