from pathlib import Path
import sys

from playlist_ctl.storage import Storage
from playlist_ctl.mpv_client import MpvClient


class RofiClient:
    def __init__(self, stor: Storage, mpv_client: MpvClient) -> None:
        self.stor = stor
        self.mpv = mpv_client

    def print_history(self, limit: int = -1) -> None:
        history = self.stor.select_history(limit)
        for url, title in history.items():
            print("%s\000info\037%s" % (title, url))

    def print_playlist(self) -> None:
        playlist, err = self.mpv.playlist()
        if err:
            print("\000message\037%s\n \000nonselectable\037true" % err)
            sys.exit(1)
        urls = [u for item in playlist if (u := item.get("filename"))]
        if len(urls) == 0:
            print("\000message\037playlist is empty\n \000nonselectable\037true")
            sys.exit(1)
        titles = self.stor.select_titles(urls)
        for i, vid in enumerate(playlist):
            title = "unknown %d" % i
            if url := vid.get("filename"):
                if (filepath := Path(url)).exists():
                    title = filepath.with_suffix("").name
                else:
                    title = vid.get("title", titles.get(url, url))
            active = "true" if vid.get("current") else "false"
            print("%s\000info\037%d\037active\037%s" % (title, i, active))
