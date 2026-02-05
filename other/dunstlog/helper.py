#!/usr/bin/env -S python -u

from dataclasses import dataclass
import html
import os
import subprocess as sp
import sys

DUNSTLOG_PATH = "/tmp/dunstlog"
LINE_FMT = "<b>{title}</b> <i>{timestamp}</i>\r{body}"


@dataclass(slots=True)
class Entry:
    created: str
    level: str
    icon: str
    text: str
    title: str
    app: str

    def __post_init__(self) -> None:
        self.app = html.escape(self.app)
        self.text = html.escape(self.text)
        self.title = html.escape(self.title)


def build_info(e: Entry) -> str:
    info = f"-i {e.icon!r} -a {e.app!r} -u {e.level!r}"
    if e.title and e.text:
        info = f"{info} {e.title!r} {e.text!r}"
    elif not e.title and e.text:
        info = f"{info} {e.text!r}"
    elif not e.text and e.title:
        info = f"{info} {e.title!r}"
    else:
        info = f"{info} {e.app!r}"
    return info


if __name__ == "__main__":
    if not os.path.exists(DUNSTLOG_PATH):
        print(f"\000message\037error: {DUNSTLOG_PATH!r} not found")
        sys.exit(1)

    ROFI_RETV = int(os.environ.get("ROFI_RETV", -1))
    if ROFI_RETV < 0:
        print("\000message\037error: undefined ROFI_RETV")
        sys.exit(1)

    if ROFI_RETV == 1:
        ROFI_INFO = os.environ.get("ROFI_INFO", "")
        if not ROFI_INFO:
            print("\000message\037error: ROFI_INFO is empty\n \000nonselectable\037true")
            sys.exit(1)
        sys.exit(sp.run(f"notify-send {ROFI_INFO}", shell=True, stdout=sp.DEVNULL).returncode)

    print("\000markup-rows\037true")
    lines = []
    with open(DUNSTLOG_PATH) as f:
        lines = [l.strip() for l in f.readlines()]

    if len(lines) % 6 != 0:
        print(
            f"\000message\037error: unexpected dunstlog format ({len(lines)} % 6 != 0)"
        )
        sys.exit(1)

    entries = [
        Entry(
            created=lines[i].strip(),
            level=lines[i + 1].strip(),
            icon=lines[i + 2].strip(),
            text=lines[i + 3].strip(),
            title=lines[i + 4].strip(),
            app=lines[i + 5].strip(),
        )
        for i in range(0, len(lines), 6)
    ]

    fmt = LINE_FMT + "\000icon\037{icon}\037info\037{info}\037urgent\037{urgent}"
    for i, e in enumerate(entries[::-1]):
        print(
            fmt.format(
                title=e.app,
                timestamp=e.created,
                body=e.text or e.title,
                icon=e.icon,
                info=build_info(e),
                urgent="true" if e.level.lower() == "critical" else "false",
            ),
        )
