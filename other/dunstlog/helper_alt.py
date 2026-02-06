#!/usr/bin/env -S python -u

from dataclasses import dataclass
from datetime import datetime, timedelta
import json
import html
import os
import subprocess as sp
import sys
import time
from typing import Self, NoReturn

DATETIME_FMT = "%I:%M %p"
DUNST_HISTORY_CMD = "dunstctl history"
LINE_FMT = "<b>{title}</b> <i>{timestamp}</i>\r{body}"


class InvalidJSON(Exception):
    pass


boot_timedelta = timedelta(seconds=time.clock_gettime(time.CLOCK_BOOTTIME))


def calc_timestamp(microseconds: float) -> datetime:
    global boot_timedelta
    return datetime.now() - (boot_timedelta - timedelta(microseconds=microseconds))


@dataclass
class Entry:
    body: str = ""
    summary: str = ""
    icon_path: str = ""
    urgency: str = ""
    timestamp: str = ""
    appname: str = ""

    def from_obj(self, obj: dict[str, dict]) -> Self:
        for k in vars(self):
            match obj[k]:
                case {"type": _, "data": data}:
                    if k == "timestamp":
                        data = calc_timestamp(data).strftime(DATETIME_FMT)
                    setattr(self, k, html.escape(data.strip()))
                case _:
                    raise InvalidJSON()
        return self


def parse_history(raw: str) -> list[Entry]:
    d = json.loads(raw)
    data_list = d.get("data")
    if not isinstance(data_list, list) or len(data_list) != 1:
        raise InvalidJSON(f"Unexpected output format: type={type(data_list).__name__}")
    data_list = data_list[0]
    if not isinstance(data_list, list):
        raise InvalidJSON(f"Unexpected output format: type={type(data_list).__name__}")
    return [Entry().from_obj(obj) for obj in data_list]


def build_info(e: Entry) -> str:
    info = f"-i {e.icon_path!r} -a {e.appname!r} -u {e.urgency!r}"
    if e.summary and e.body:
        info = f"{info} {e.summary!r} {e.body!r}"
    elif not e.summary and e.body:
        info = f"{info} {e.body!r}"
    elif not e.body and e.summary:
        info = f"{info} {e.summary!r}"
    else:
        info = f"{info} {e.appname!r}"
    return info


def die(msg: str | Exception) -> NoReturn:
    print(f"\000message\037error: {msg}\n \000nonselectable\037true")
    sys.exit(1)


if __name__ == "__main__":
    ROFI_RETV = int(os.environ.get("ROFI_RETV", -1))
    if ROFI_RETV < 0:
        die("undefined ROFI_RETV")

    if ROFI_RETV == 1:
        ROFI_INFO = os.environ.get("ROFI_INFO", "")
        if not ROFI_INFO:
            die("ROFI_INFO is empty")
        sys.exit(sp.run(f"notify-send {ROFI_INFO}", shell=True, stdout=sp.DEVNULL).returncode)

    code, out = sp.getstatusoutput(DUNST_HISTORY_CMD)
    if code != 0:
        die(f"{DUNST_HISTORY_CMD!r} returns status {code}: {out}")

    try:
        history = parse_history(out)
    except (Exception, InvalidJSON) as e:
        die(e)

    print("\000markup-rows\037true")
    fmt = LINE_FMT + "\000icon\037{icon}\037info\037{info}\037urgent\037{urgent}"
    for e in history:
        print(
            fmt.format(
                title=e.appname,
                timestamp=e.timestamp,
                body=(e.body or e.summary).replace("\n", " "),
                icon=e.icon_path,
                info=build_info(e),
                urgent=["false", "true"][e.urgency.lower() == "critical"],
            ),
        )
