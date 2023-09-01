from dataclasses import dataclass
from os.path import exists

DUNSTLOG_PATH = "/tmp/dunstlog"


@dataclass(slots=True)
class Entry:
    created: str
    level: str
    icon: str
    text: str
    title: str
    app: str


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
        print("\000message\037error: %r not found" % DUNSTLOG_PATH, end="\012")
        exit(1)
    lines = []
    with open(DUNSTLOG_PATH) as f:
        lines = [l.strip() for l in f.readlines()]

    if len(lines) % 6 != 0:
        print(
            "\000message\037error: unexpected dunstlog format (%d % 6 != 0)"
            % len(lines),
            end="\012",
        )
        exit(1)

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
    urgents = []
    for i, e in enumerate(entries[::-1]):
        print(
            "<b>%s</b> <i>%s</i>\r%s\000icon\037%s\037info\037%s"
            % (e.app, e.created, e.text or e.title, e.icon, build_info(e)),
            end="\012",
        )
        if e.level.lower() == "critical":
            urgents.append(i)
    if urgents:
        print("\000urgent\037%s\012" % ",".join(str(i) for i in urgents))
