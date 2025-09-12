from contextlib import contextmanager
import logging
import json
from pathlib import Path
import socket
from typing import Any


class MpvClient:
    def __init__(self, file: Path) -> None:
        self.file = file
        self.log = logging.getLogger()

    @contextmanager
    def connect(self):
        if not self.file.exists():
            exit("%s not found" % self.file)
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        try:
            s.connect(str(self.file))
            yield s
        except Exception as e:
            self.log.critical(repr(e))
            exit(1)
        finally:
            s.close()

    def mpv_playlist(self) -> tuple[list[dict], Exception | None]:
        with self.connect() as sock:
            cmd = '{"command": ["get_property", "playlist"]}\n'
            self.log.debug(cmd)
            sock.sendall(cmd.encode())
            data, err = self._read_data(self._read_resp(sock))
            if err:
                return [], err
            if not isinstance(data, list):
                err = Exception("unexpected data type: %s (%r)" % (type(data), data))
                self.log.error(err)
                return [], err
            self.log.info("%d playlist items received" % len(data))
            return data, None

    def append(self, url: str) -> Exception | None:
        with self.connect() as sock:
            cmd = '{ "command": ["loadfile", "%s", "append-play"] }\n' % url
            self.log.debug(cmd)
            sock.sendall(cmd.encode())
            _, err = self._read_data(self._read_resp(sock))
            return err

    def remove(self, index: int) -> Exception | None:
        with self.connect() as sock:
            cmd = '{ "command": ["playlist-remove", %d]}\n' % index
            self.log.debug(cmd)
            sock.sendall(cmd.encode())
            resp = self._read_resp(sock)
            if not resp:
                return Exception("can't read response")
            if (err := resp.get("error", "success")) != "success":
                return Exception(err)

    def _read_data(self, resp: dict | None = None) -> tuple[Any, Exception | None]:
        if not resp:
            return None, Exception("can't read response")
        if (err := resp.get("error")) != "success":
            self.log.error(e := Exception("mpv error: %r" % err))
            return None, e
        if (data := resp.get("data")) is None:
            self.log.error(e := Exception("missing `data` in resp: %r" % resp))
            return None, e
        return data, None

    def _read_resp(self, sock: socket.socket) -> dict | None:
        data = b""
        try:
            while chunk := sock.recv(1024):
                data += chunk
                if not chunk or chunk[-1] == ord("\n") or len(chunk) < 1024:
                    break

            self.log.debug("received response: %r" % data)
            for raw_part in data.splitlines():
                part = json.loads(raw_part)
                if "event" in part:
                    continue
                return part
        except Exception as e:
            self.log.error(e)
