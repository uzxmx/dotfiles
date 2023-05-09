#!/usr/bin/env python

"""
You need to install below dependency first.

pip install requests[socks]
"""

import sys
import requests
import json
import traceback

def get_ip(proxies=None):
    try:
        r = requests.get('http://httpbin.org/ip', proxies=proxies)
        return json.loads(r.text)['origin']
    except Exception as e:
        traceback.print_exc()

addr = sys.argv[1]

proxies = {
    'http': f'socks5h://{addr}',
    'https': f'socks5h://{addr}'
}

ip = get_ip(proxies)
print(ip)
