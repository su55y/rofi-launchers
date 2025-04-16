from pathlib import Path
from threading import Thread
import sys

from playlist_ctl.storage import Storage
from playlist_ctl.mpv_client import MpvClient


class RofiClient:
    def __init__(self, stor: Storage, client: MpvClient) -> None:
        self.stor = stor
        self.client = client

    def print_history(self, limit: int = -1) -> None:
        history = self.stor.select_history(limit)
        for url, title in history.items():
            print("%s\000info\037%s" % (title, url))

    def print_playlist(self) -> None:
        playlist, err = self.client.mpv_playlist()
        if err:
            print("\000message\037%s\n \000nonselectable\037true" % err)
            sys.exit(1)
        urls = ", ".join("%r" % u for v in playlist if (u := v.get("filename")))
        titles = self.stor.select_titles(urls)
        current = None
        for i, vid in enumerate(playlist):
            if (url := vid.get("filename")) is None:
                title = "unknown %d" % i
            else:
                if (filepath := Path(url)).exists():
                    title = filepath.name
                elif (title := titles.get(url)) is None:
                    title = url
                    Thread(target=self.stor.add_title, args=(url,)).start()
            print("%s\000info\037%d" % (title, i))
            if vid.get("current"):
                current = i
        if isinstance(current, int):
            print("\000active\037%d" % current)
