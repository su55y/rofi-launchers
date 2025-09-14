import argparse
import datetime as dt
import logging
from pathlib import Path
import sys
from typing import NoReturn

from playlist_ctl.config import Config, default_config_path
from playlist_ctl.mpv_client import MpvClient
from playlist_ctl.rofi_client import RofiClient
from playlist_ctl.storage import Storage
from playlist_ctl.utils import validate_url, fetch_title


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-a",
        "--append",
        metavar="URL",
        type=validate_url,
        help="'append-play' and update titles db, prints added title to stdout",
    )
    parser.add_argument(
        "-c",
        "--config",
        default=default_config_path(),
        metavar="PATH",
        type=Path,
        help="config file path (default: %(default)s)",
    )
    parser.add_argument(
        "--clean-cache",
        action="store_true",
        help="removes all entries from database except last x, defined as `keep_last` in config (default: 100)",
    )
    parser.add_argument("-d", "--delete", metavar="URL", help="Delete url from history")
    parser.add_argument(
        "-D", "--debug", action="store_true", help="print debug log to stdout"
    )
    parser.add_argument(
        "--history",
        action="store_true",
        help="prints last entries from history",
    )
    parser.add_argument(
        "-l",
        "--limit",
        type=int,
        default=100,
        help="history limit (default: %(default)s)",
    )
    parser.add_argument(
        "-r", "--remove", type=int, help="'playlist-remove' given index"
    )
    return parser.parse_args()


def init_logger(level: int, file: Path, debug: bool = False) -> logging.Logger:
    log = logging.getLogger()
    if debug:
        h = logging.StreamHandler()
        log.addHandler(h)
        log.setLevel(logging.DEBUG)
        return log
    if level == logging.NOTSET:
        h = logging.NullHandler()
        log.addHandler(h)
        return log
    log.setLevel(level)
    fh = logging.FileHandler(file)
    fh.setFormatter(
        logging.Formatter(
            fmt="[%(asctime)s %(levelname)s] %(message)s (%(funcName)s:%(lineno)d)",
            datefmt="%H:%M:%S %d/%m/%y",
        )
    )
    log.addHandler(fh)
    return log


def die(err: Exception | str) -> NoReturn:
    print(err)
    sys.exit(1)


def main():
    args = parse_args()
    config = Config(config_file=args.config)
    if config.data_dir.exists() and not config.data_dir.is_dir():
        die("%s is invalid data directory" % config.data_dir)
    if not config.data_dir.exists():
        config.data_dir.mkdir()

    log = init_logger(config.log_level, config.log_file, args.debug)

    stor = Storage(config.storage_file)
    if err := stor.init_db():
        die("can't create table: %s" % err)

    mpv = MpvClient(config.socket_file)
    if args.append:
        if err := mpv.append(args.append):
            die(err)
        if (file := Path(args.append)).exists():
            title = file.with_suffix("").name
        elif (title := stor.select_title(args.append)) is None:
            if "twitch.tv" in args.append:
                title = args.append
            else:
                title = fetch_title(log, args.append)
                if title is None:
                    die("can't fetch title for %r" % args.append)
                if err := stor.insert_title(
                    url=args.append,
                    title=title,
                    created=dt.datetime.now(dt.timezone.utc),
                ):
                    die(err)
        print(title[0] if len(title) == 1 else title)
    elif args.remove:
        if err := mpv.remove(args.remove):
            die(err)
    elif args.delete:
        ok = stor.delete(args.delete)
        sys.exit(1 if not ok else 0)
    elif args.clean_cache:
        stor.delete_except(config.keep_last)
    elif args.history:
        RofiClient(stor, mpv).print_history(args.limit)
    else:
        RofiClient(stor, mpv).print_playlist()
