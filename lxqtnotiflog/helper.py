from dataclasses import dataclass
import datetime as dt
import os.path
import re

UNATTENDED_LIST = os.path.expanduser("~/.cache/lxqt-notificationd/unattended.list")


@dataclass(slots=True)
class Entry:
    created: str
    application: str
    body: str
    icon: str
    summary: str
    text: str = ""
    title: str = ""


def build_info(e: Entry) -> str:
    return f"-i {e.icon!r} -a {e.application!r} {e.title!r} {e.text}"


if __name__ == "__main__":
    if not os.path.exists(UNATTENDED_LIST):
        print("\000message\037error: %r not found" % UNATTENDED_LIST, end="\012")
        exit(1)
    rx_lines = re.compile(r"^(\[|App|Summ|Icon|Body).+")
    lines = []
    with open(UNATTENDED_LIST) as f:
        lines = list(filter(lambda l: rx_lines.match(l), f.readlines()))

    if len(lines) % 5 != 0:
        print(
            "\000message\037error: unexpected dunstlog format (%d % 5 != 0)"
            % len(lines),
            end="\012",
        )
        exit(1)

    entries = [
        Entry(
            created=lines[i].strip(),
            application=lines[i + 1].strip(),
            body=lines[i + 2].strip(),
            icon=lines[i + 3].strip(),
            summary=lines[i + 4].strip(),
        )
        for i in range(0, len(lines), 5)
    ]
    rx_date = re.compile(r"\[\d{4}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{3}\]")
    rx_app = re.compile(r"^Application=.+")
    rx_body = re.compile(r"^Body=.+")
    rx_summary = re.compile(r"^Summary=.+")
    rx_icon = re.compile(r"Icon=.+")
    for e in entries[::-1]:
        if rx_date.match(e.created):
            e.created = dt.datetime(*(int(v) for v in e.created[1:-1].split("-")[:7]))
        else:
            e.created = "-"
        if e.application != "Application=" and rx_app.match(e.application):
            e.application = e.application[len("Application=") :]
        else:
            e.application = "-"
        if e.body != "Body=" and rx_body.match(e.body):
            e.text = e.body[len("Body=") :]
        if e.summary != "Summary=" and rx_summary.match(e.summary):
            e.title = e.summary[len("Summary=") :]
        if e.icon != "Icon=" and rx_icon.match(e.icon):
            e.icon = e.icon[len("Icon=") :]

        print(
            "<b>%s</b> <i>%s</i>\r%s\000icon\037%s\037info\037%s"
            % (e.application, e.created, e.text or e.title, e.icon, build_info(e)),
            end="\012",
        )
