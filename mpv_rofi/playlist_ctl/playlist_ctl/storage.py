from contextlib import contextmanager
import datetime as dt
import logging
from pathlib import Path
import sqlite3
from typing import Dict, Optional, Tuple

from playlist_ctl.utils import fetch_title


class Storage:
    def __init__(self, file: Path) -> None:
        self.file = file
        self.log = logging.getLogger()

    @contextmanager
    def get_cursor(self):
        conn = sqlite3.connect(self.file)
        try:
            cursor = conn.cursor()
            yield cursor
        except Exception as e:
            self.log.critical(e)
        else:
            conn.commit()
        finally:
            conn.close()

    def init_db(self) -> Optional[Exception]:
        titles_schema = """CREATE TABLE IF NOT EXISTS titles (
        url TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        created DATETIME NOT NULL)"""
        try:
            with self.get_cursor() as cur:
                cur.execute(titles_schema)
        except Exception as e:
            return e

    def add_title(self, url: str) -> Optional[Exception]:
        if self.select_title(url) is not None:
            return
        if (title := fetch_title(self.log, url)) is None:
            return Exception("can't fetch title for %r" % url)
        created = str(dt.datetime.now(dt.timezone.utc))
        return self.insert_title((url, title, created))

    def insert_title(self, title: Tuple[str, str, str]) -> Optional[Exception]:
        query = "INSERT OR IGNORE INTO titles (url, title, created) VALUES (?, ?, ?)"
        try:
            with self.get_cursor() as cur:
                self.log.debug("%s: %s" % (query, title))
                cur.execute(query, title)
        except Exception as e:
            self.log.error(e)
            return e

    def select_title(self, url: str) -> Optional[str]:
        query = "SELECT title FROM titles WHERE url = ? LIMIT 1"
        try:
            with self.get_cursor() as cur:
                self.log.debug("%s, url: %r" % (query, url))
                cur.execute(query, (url,))
                title, *_ = row if (row := cur.fetchone()) else (None,)
                return title
        except Exception as e:
            self.log.error(e)

    def select_titles(self, urls: str) -> Dict[str, str]:
        query = "SELECT url, title FROM titles WHERE url in (%s)" % urls
        try:
            with self.get_cursor() as cur:
                self.log.debug(query)
                cur.execute(query)
                return {url: title for url, title in cur.fetchall()}
        except Exception as e:
            self.log.error("can't select titles: %s" % e)
            return {}

    def select_count(self) -> int:
        query = "SELECT COUNT(*) FROM titles"
        try:
            with self.get_cursor() as cur:
                self.log.debug(query)
                count, *_ = cur.execute(query).fetchone()
                return count
        except Exception as e:
            self.log.error("can't select count: %s" % e)
            return -1

    def select_history(self, limit: int = -1) -> Dict[str, str]:
        query = "SELECT url, title FROM titles ORDER BY created DESC LIMIT ?"
        try:
            with self.get_cursor() as cur:
                self.log.debug("%s, %d" % (query, limit))
                cur.execute(query, (limit,))
                return {url: title for url, title in cur.fetchall()}
        except Exception as e:
            self.log.error("can't select history: %s" % e)
            return {}

    def delete_except(self, count: int) -> int:
        query = (
            """DELETE FROM titles
            WHERE url NOT IN (
                SELECT url FROM titles
                ORDER BY created DESC
                LIMIT %d
            )"""
            % count
        )
        try:
            with self.get_cursor() as cur:
                self.log.debug(query)
                return cur.execute(query).rowcount
        except Exception as e:
            self.log.error(e)
            return -1

    def delete_all(self) -> int:
        query = "DELETE FROM titles"
        try:
            with self.get_cursor() as cur:
                self.log.debug(query)
                return cur.execute(query).rowcount
        except Exception as e:
            self.log.error(e)
            return -1
