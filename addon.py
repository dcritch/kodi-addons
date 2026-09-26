#!/usr/bin/env python3
import sys
from urllib.parse import parse_qsl

from resources.lib import router

if __name__ == '__main__':
    base_url = sys.argv[0]
    handle = int(sys.argv[1])
    params = dict(parse_qsl(sys.argv[2][1:]))
    router.run(base_url, handle, params)
