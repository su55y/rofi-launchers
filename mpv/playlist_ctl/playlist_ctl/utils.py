from argparse import ArgumentTypeError
import json
import logging
from pathlib import Path
from re import match
from typing import Optional
import urllib.request


def fetch_title(logger: logging.Logger, vid_url: str) -> Optional[str]:
    try:
        url = "https://youtube.com/oembed?url=%s&format=json" % vid_url
        with urllib.request.urlopen(url, timeout=10) as resp:
            logger.debug(f"{resp.status} {resp.reason} {url}")
            if resp.status != 200:
                raise Exception("%d %s" % (resp.status, resp.reason))
            return json.loads(resp.read().decode("utf-8")).get("title")
    except Exception as e:
        logger.error("can't fetch title for %r: %r" % (vid_url, e))


def validate_url(v: str):
    if Path(v).exists():
        return v
    l = r"^((?:https\:\/\/)?(?:www\.)?youtube\.com\/watch\?v=[-_0-9a-zA-Z]{11})(?:&.+)?$"
    s = r"^((?:https\:\/\/)?youtu\.be\/[-_0-9a-zA-Z]{11})(?:\?.+)?$"
    if (m := match(l, v)) and len(m.groups()) == 1:
        (url,) = m.groups()
    elif (m := match(s, v)) and len(m.groups()) == 1:
        (url,) = m.groups()
    else:
        raise ArgumentTypeError("invalid url %r" % v)
    return url
