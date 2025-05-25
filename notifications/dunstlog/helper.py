from dataclasses import dataclass
import html
from os.path import exists
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
    if not exists(DUNSTLOG_PATH):
        print(f"\000message\037error: {DUNSTLOG_PATH!r} not found", end="\012")
        sys.exit(1)
    lines = []
    with open(DUNSTLOG_PATH) as f:
        lines = [l.strip() for l in f.readlines()]

    if len(lines) % 6 != 0:
        print(
            f"\000message\037error: unexpected dunstlog format ({len(lines)} % 6 != 0)",
            end="\012",
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
            end="\012",
        )
