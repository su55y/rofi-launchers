from contextlib import contextmanager
import logging
import json
from pathlib import Path
import socket
from typing import Any, Dict, List, Optional, Tuple


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

    def mpv_playlist(self) -> Tuple[List[Dict], Optional[Exception]]:
        with self.connect() as sock:
            cmd = '{"command": ["get_property", "playlist"]}\n'
            self.log.debug(cmd)
            sock.sendall(cmd.encode())
            data, err = self._read_data(self._read_resp(sock))
            if err:
                self.log.error(err)
                return [], err
            if not isinstance(data, List):
                err = Exception("unexpected data type: %s (%r)" % (type(data), data))
                self.log.error(err)
                return [], err
            self.log.info("%d playlist items received" % len(data))
            return data, None

    def append(self, url: str) -> Optional[Exception]:
        with self.connect() as sock:
            cmd = '{ "command": ["loadfile", "%s", "append-play"] }\n' % url
            self.log.debug(cmd)
            sock.sendall(cmd.encode())
            _, err = self._read_data(self._read_resp(sock))
            if err:
                self.log.error(err)
                return err

    def _read_data(
        self, resp: Optional[Dict] = None
    ) -> Tuple[Any, Optional[Exception]]:
        if not resp:
            return None, Exception("can't read response")
        if (err := resp.get("error")) != "success":
            return None, Exception("mpv error: %s" % err)
        if (data := resp.get("data")) is None:
            return None, Exception("data not found in resp: %r" % resp)
        return data, None

    def _read_resp(self, sock: socket.socket) -> Optional[Dict]:
        data = b""
        try:
            while chunk := sock.recv(1024):
                data += chunk
                if chunk[-1] == 10 or len(chunk) < 1024:
                    break

            self.log.debug("received response: %r" % data)
            for raw_part in data.split(b"\n"):
                part = json.loads(raw_part)
                if "event" in part.keys():
                    continue
                return part
        except Exception as e:
            self.log.error(e)
