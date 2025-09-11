from contextlib import contextmanager
import datetime as dt
import logging
from pathlib import Path
import sqlite3
from typing import Any, Generator


class Storage:
    def __init__(self, file: Path) -> None:
        self.file = file
        self.log = logging.getLogger()
        sqlite3.register_adapter(dt.datetime, lambda v: v.isoformat())

    @contextmanager
    def get_cursor(self, reraise: bool = False) -> Generator[sqlite3.Cursor, Any, None]:
        conn = sqlite3.connect(self.file)
        if self.log.level == logging.DEBUG:
            conn.set_trace_callback(self.log.debug)
        try:
            cursor = conn.cursor()
            yield cursor
        except Exception as e:
            self.log.critical(e)
            if reraise:
                raise e
        else:
            conn.commit()
        finally:
            conn.close()

    def init_db(self) -> Exception | None:
        titles_schema = """
        CREATE TABLE IF NOT EXISTS titles (
            url TEXT PRIMARY KEY NOT NULL,
            title TEXT NOT NULL,
            created DATETIME NOT NULL)"""
        try:
            with self.get_cursor() as cur:
                cur.execute(titles_schema)
        except Exception as e:
            return e

    def insert_title(
        self, url: str, title: str, created: dt.datetime
    ) -> Exception | None:
        query = "INSERT OR IGNORE INTO titles (url, title, created) VALUES (?, ?, ?)"
        try:
            with self.get_cursor() as cur:
                cur.execute(query, (url, title, created))
        except Exception as e:
            return e

    def fetch_one(self, query: str, params: tuple[Any, ...] = tuple()) -> Any:
        with self.get_cursor() as cur:
            return cur.execute(query, params).fetchone()

    def select_title(self, url: str) -> str | None:
        query = "SELECT title FROM titles WHERE url = ? LIMIT 1"
        return self.fetch_one(query, (url,))

    def select_count(self) -> int:
        query = "SELECT COUNT(*) FROM titles"
        count = self.fetch_one(query)
        return count[0] if count else 0

    def fetch_all(self, query: str, params: tuple[Any, ...] = tuple()) -> list[Any]:
        with self.get_cursor() as cur:
            return cur.execute(query, params).fetchall()

    def select_titles(self, urls: list[str]) -> dict[str, str]:
        if len(urls) == 0:
            return {}
        query = f"""
        SELECT url, title FROM titles
        WHERE url in ({','.join('?' * len(urls))})"""
        return {u: t for u, t in self.fetch_all(query, tuple(urls))}

    def select_history(self, limit: int = -1) -> dict[str, str]:
        query = "SELECT url, title FROM titles ORDER BY created DESC LIMIT ?"
        return {url: title for url, title in self.fetch_all(query, (limit,))}

    def get_rowcount(self, query: str, params: tuple[Any, ...] = tuple()) -> int:
        with self.get_cursor() as cur:
            return cur.execute(query, params).rowcount

    def delete(self, url: str) -> bool:
        query = "DELETE FROM titles WHERE url = ?"
        return self.get_rowcount(query, (url,)) == 1

    def delete_except(self, count: int) -> int:
        query = """
        DELETE FROM titles
        WHERE url NOT IN (
            SELECT url FROM titles
            ORDER BY created DESC
            LIMIT ?
        )"""
        return self.get_rowcount(query, (count,))

    def delete_all(self) -> int:
        query = "DELETE FROM titles"
        return self.get_rowcount(query)
