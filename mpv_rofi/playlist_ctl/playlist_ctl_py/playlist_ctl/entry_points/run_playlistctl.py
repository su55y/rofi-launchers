import argparse
import logging
from pathlib import Path
from typing import Union

from playlist_ctl.config import Config
from playlist_ctl.defaults import default_config_path
from playlist_ctl.mpv_client import MpvClient
from playlist_ctl.rofi_client import RofiClient
from playlist_ctl.storage import Storage
from playlist_ctl.utils import validate_url


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-a",
        "--append",
        metavar="URL",
        type=validate_url,
        help="'append-play' and update titles cache, prints added title to stdout",
    )
    parser.add_argument(
        "-c",
        "--config",
        default=default_config_path(),
        metavar="PATH",
        type=Path,
        help="config file path (default: %(default)s)",
    )
    return parser.parse_args()


def init_logger(level: int, file: Path) -> None:
    log = logging.getLogger()
    log.setLevel(level)
    fh = logging.FileHandler(file)
    fh.setFormatter(
        logging.Formatter(
            fmt="[%(asctime)s %(levelname)s] %(message)s (%(funcName)s:%(lineno)d)",
            datefmt="%H:%M:%S %d/%m/%y",
        )
    )
    log.addHandler(fh)


def die(err: Union[Exception, str]) -> None:
    print(err)
    exit(1)


def main():
    args = parse_args()
    config = Config(config_file=args.config)
    if config.cache_dir.exists() and not config.cache_dir.is_dir():
        die("%s is invalid cache directory" % config.cache_dir)
    if not config.cache_dir.exists():
        config.cache_dir.mkdir(parents=True)
    if config.log_level > 0:
        init_logger(config.log_level, config.log_file)

    stor = Storage(config.storage_file)
    if err := stor.init_db():
        die("can't create table: %s" % err)

    mpv = MpvClient(config.socket_file)
    if args.append:
        if err := mpv.append(args.append):
            die(err)
        if (file := Path(args.append)).exists():
            print(file.name.rstrip(file.suffix))
            exit(0)
        if err := stor.add_title(args.append):
            die(err)
        if not (title := stor.select_title(args.append)):
            die("title not found for %r" % args.append)
        print(title)
    else:
        RofiClient(stor, mpv).print_playlist()
