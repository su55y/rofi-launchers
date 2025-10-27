from argparse import ArgumentTypeError
import json
import logging
from pathlib import Path
from re import match
import urllib.request


def fetch_yt_title(logger: logging.Logger, vid_url: str) -> str | None:
    try:
        url = "https://youtube.com/oembed?url=%s&format=json" % vid_url
        with urllib.request.urlopen(url, timeout=10) as resp:
            logger.debug(f"{resp.status} {resp.reason} {url}")
            if resp.status != 200:
                raise Exception("%d %s" % (resp.status, resp.reason))
            return json.loads(resp.read().decode("utf-8")).get("title")
    except Exception as e:
        logger.error("can't fetch title for %r: %r" % (vid_url, e))


def clean_url(v: str) -> str:
    if Path(v).exists():
        return v
    for p in (
        r"^((?:https\:\/\/)?(?:www\.)?youtube\.com\/watch\?v=[-_0-9a-zA-Z]{11})(?:&.+)?$",
        r"^((?:https\://)?(?:www\.)?youtube\.com\/shorts\/[-_0-9a-zA-Z]{11})(?:.*)?$",
        r"^((?:https\:\/\/)?(?:www\.)?youtube\.com\/playlist\?list=[A-Za-z0-9\-_]{18,34})",
        r"^((?:https\:\/\/)?youtu\.be\/[-_0-9a-zA-Z]{11})(?:\?.+)?$",
        r"^((?:https?:\/\/)?(?:www\.)?twitch\.tv\/(?:videos\/\d{10}|[^?\/]+))$",
    ):
        if (m := match(p, v)) and len(m.groups()) == 1:
            return m.groups()[0]
    return v
