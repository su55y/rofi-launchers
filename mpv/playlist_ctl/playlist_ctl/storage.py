from contextlib import contextmanager
import datetime as dt
import logging
from pathlib import Path
import sqlite3
from typing import Dict, List, Optional


class Storage:
    def __init__(self, file: Path) -> None:
        self.file = file
        self.log = logging.getLogger()
        sqlite3.register_adapter(dt.datetime, lambda v: v.isoformat())

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
        titles_schema = """
        CREATE TABLE IF NOT EXISTS titles (
            url TEXT PRIMARY KEY NOT NULL,
            title TEXT NOT NULL,
            created DATETIME NOT NULL)"""
        with self.get_cursor() as cur:
            cur.execute(titles_schema)

    def insert_title(
        self, url: str, title: str, created: dt.datetime
    ) -> Optional[Exception]:
        query = "INSERT OR IGNORE INTO titles (url, title, created) VALUES (?, ?, ?)"
        with self.get_cursor() as cur:
            self.log.debug(f"{query}, ({url = !r}, {title = !r}, {created = })")
            cur.execute(query, (url, title, created))

    def select_title(self, url: str) -> Optional[str]:
        query = "SELECT title FROM titles WHERE url = ? LIMIT 1"
        with self.get_cursor() as cur:
            self.log.debug(f"{query}, {url = !r}")
            cur.execute(query, (url,))
            title, *_ = row if (row := cur.fetchone()) else (None,)
            return title

    def select_titles(self, urls: List[str]) -> Dict[str, str]:
        if len(urls) == 0:
            return {}
        query = f"""
        SELECT url, title FROM titles
        WHERE url in ({','.join('?' * len(urls))})"""
        with self.get_cursor() as cur:
            self.log.debug(f"{query}, {urls = !r}")
            return {u: t for u, t in cur.execute(query, (urls,)).fetchall()}

    def select_count(self) -> int:
        query = "SELECT COUNT(*) FROM titles"
        with self.get_cursor() as cur:
            self.log.debug(query)
            count, *_ = cur.execute(query).fetchone()
            return count

    def select_history(self, limit: int = -1) -> Dict[str, str]:
        query = "SELECT url, title FROM titles ORDER BY created DESC LIMIT ?"
        with self.get_cursor() as cur:
            self.log.debug(f"{query}, {limit = }")
            cur.execute(query, (limit,))
            return {url: title for url, title in cur.fetchall()}

    def delete_except(self, count: int) -> int:
        query = """
        DELETE FROM titles
        WHERE url NOT IN (
            SELECT url FROM titles
            ORDER BY created DESC
            LIMIT ?
        )"""
        with self.get_cursor() as cur:
            self.log.debug(query)
            return cur.execute(query, (count,)).rowcount

    def delete_all(self) -> int:
        query = "DELETE FROM titles"
        with self.get_cursor() as cur:
            self.log.debug(query)
            return cur.execute(query).rowcount
