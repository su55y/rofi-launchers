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
    if match(
        r"^(?:https:\/\/)?((?:www\.)?youtube\.com\/watch\?v=[\w\d_\-]{11}|youtu\.be\/[\w\d_\-]{11})",
        v,
    ):
        return v
    raise ArgumentTypeError("invalid url %r" % v)
