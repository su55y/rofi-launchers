from argparse import ArgumentTypeError
import logging
from os.path import expandvars
from pathlib import Path
from re import match
from typing import Dict, Optional, Union

import requests
import yaml


def expand_path(path: Union[Path, str]) -> Path:
    return Path(expandvars(path)).expanduser()


def fetch_title(logger: logging.Logger, vid_url: str) -> Optional[str]:
    try:
        url = "https://youtube.com/oembed?url=%s&format=json" % vid_url
        resp = requests.get(url)
        logger.debug("%d %s %s" % (resp.status_code, resp.reason, resp.url))
        if resp.status_code != 200:
            raise Exception("%d %s" % (resp.status_code, resp.reason))
        return resp.json().get("title")
    except Exception as e:
        logger.error("can't fetch title for %r: %s" % (vid_url, e))


def read_config(file: Path) -> Dict:
    try:
        with open(file) as f:
            return yaml.safe_load(f)
    except Exception as e:
        exit("invalid config %s: %s" % (file, e))


def validate_url(v: str):
    if Path(v).exists():
        return v
    if match(
        r"^(?:https:\/\/)?((?:www\.)?youtube\.com\/watch\?v=[\w\d_\-]{11}|youtu\.be\/[\w\d_\-]{11})",
        v,
    ):
        return v
    raise ArgumentTypeError("invalid url %r" % v)
