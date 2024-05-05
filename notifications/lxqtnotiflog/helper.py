from dataclasses import dataclass, fields
import datetime as dt
import os.path
import re
import html

UNATTENDED_LIST = os.path.expanduser("~/.cache/lxqt-notificationd/unattended.list")
FMT = "<b>{app}</b> <i>{created}</i>\r{text}\000icon\037{icon}\037info\037{info}"


@dataclass(slots=True)
class Entry:
    created: str
    application: str
    body: str
    icon: str
    summary: str

    def __post_init__(self):
        for attr in fields(self):
            v = self.__getattribute__(attr.name)
            if attr.name == "created":
                if re.match(r"\[\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{3}\]", v):
                    created = dt.datetime(*(int(ch) for ch in v[1:-1].split("-")[:7]))
                    self.__setattr__(attr.name, created.strftime("%T %F"))
                else:
                    self.__setattr__(attr.name, "")
                continue

            tmp = f"{attr.name.capitalize()}="
            if v != tmp and re.match(r"^%s.+" % tmp, v):
                v = v[len(tmp) :]
            else:
                v = ""
            self.__setattr__(attr.name, v)


def build_info(e: Entry) -> str:
    return f"-i {e.icon!r} -a {e.application!r} {e.summary!r} {e.body!r}"


if __name__ == "__main__":
    if not os.path.exists(UNATTENDED_LIST):
        print("\000message\037error: %r not found" % UNATTENDED_LIST, end="\012")
        exit(1)
    rx_lines = re.compile(r"^(\[|App|Summ|Icon|Body).+")
    lines = []
    with open(UNATTENDED_LIST, "r", encoding="utf-8") as f:
        lines = list(filter(lambda l: rx_lines.match(l), f.readlines()))

    if len(lines) % 5 != 0:
        print(
            f"\000message\037error: unexpected file format ({len(lines)} % 5 != 0)",
            end="\012",
        )
        exit(1)

    entries = [
        Entry(
            created=lines[i].strip(),
            application=lines[i + 1].strip(),
            body=html.escape(lines[i + 2].strip()),
            icon=lines[i + 3].strip(),
            summary=html.escape(lines[i + 4].strip()),
        )
        for i in range(0, len(lines), 5)
    ]
    for e in entries[::-1]:
        print(
            FMT.format(
                app=e.application,
                created=e.created,
                text=e.body or e.summary,
                icon=e.icon,
                info=build_info(e),
            ),
            end="\012",
        )
