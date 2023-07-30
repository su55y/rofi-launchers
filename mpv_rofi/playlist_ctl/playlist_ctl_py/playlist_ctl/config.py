from dataclasses import dataclass
import logging
from pathlib import Path
from typing import Optional

from playlist_ctl import defaults
from playlist_ctl.utils import read_config, expand_path


log_levels_map = {
    "debug": logging.DEBUG,
    "info": logging.INFO,
    "warning": logging.WARNING,
    "error": logging.ERROR,
}


@dataclass
class Config:
    cache_dir: Path
    log_file: Path
    log_level: int
    socket_file: Path
    storage_file: Path

    def __init__(
        self,
        config_file: Optional[Path] = None,
        cache_dir: Optional[Path] = None,
        log_file: Optional[Path] = None,
        log_level: Optional[int] = None,
        socket_file: Optional[Path] = None,
        storage_file: Optional[Path] = None,
    ) -> None:
        self.cache_dir = cache_dir or defaults.default_cachedir_path()
        self.log_file = log_file or self.cache_dir.joinpath("playlist_ctl.log")
        self.log_level = log_level or logging.NOTSET
        self.socket_file = socket_file or defaults.default_socket_path
        self.storage_file = storage_file or self.cache_dir.joinpath("playlist_ctl.db")
        if config_file:
            config_file = expand_path(config_file)
            if config_file.exists():
                self._override_defaults(config_file)

    def _override_defaults(self, file: Path) -> None:
        config = read_config(file)
        if isinstance((log_level := config.get("log_level")), str):
            self.log_level = log_levels_map.get(log_level.lower(), logging.NOTSET)
        if cache_dir := config.get("cache_dir"):
            self.cache_dir = expand_path(cache_dir)
            self.log_file = self.cache_dir.joinpath("playlist_ctl.log")
            self.storage_file = self.cache_dir.joinpath("playlist_ctl.db")
        if socket_file := config.get("socket_file"):
            self.socket_file = Path(socket_file)
