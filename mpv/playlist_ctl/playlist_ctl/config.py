from dataclasses import dataclass
import logging
import os
from pathlib import Path
import sys
from typing import Optional, Union

if sys.version_info >= (3, 11):
    import tomllib
else:
    import tomli as tomllib


DEFAULT_SOCKET_PATH = Path("/tmp/mpv.sock")


def default_config_path() -> Path:
    if xdg_config_home := os.getenv("XDG_CONFIG_HOME"):
        config_home = Path(xdg_config_home)
    else:
        config_home = Path.home().joinpath(".config")
    return config_home.joinpath("playlist_ctl", "config.toml")


def default_datadir_path() -> Path:
    if xdg_data_home := os.getenv("XDG_DATA_HOME"):
        data_home = Path(xdg_data_home)
    else:
        data_home = Path.home().joinpath(".local", "share")
    return data_home.joinpath("playlist_ctl")


def expand_path(path: Union[Path, str]) -> Path:
    return Path(os.path.expandvars(path)).expanduser()


log_levels_map = {
    "debug": logging.DEBUG,
    "info": logging.INFO,
    "warning": logging.WARNING,
    "error": logging.ERROR,
}


@dataclass
class Config:
    data_dir: Path
    keep_last: int
    log_file: Path
    log_level: int
    socket_file: Path
    storage_file: Path

    def __init__(
        self,
        config_file: Optional[Path] = None,
        data_dir: Optional[Path] = None,
        keep_last: Optional[int] = None,
        log_file: Optional[Path] = None,
        log_level: Optional[int] = None,
        socket_file: Optional[Path] = None,
        storage_file: Optional[Path] = None,
    ) -> None:
        self.data_dir = data_dir or default_datadir_path()
        self.keep_last = keep_last if isinstance(keep_last, int) else 100
        self.log_file = log_file or self.data_dir.joinpath("playlist_ctl.log")
        self.log_level = log_level or logging.NOTSET
        self.socket_file = socket_file or DEFAULT_SOCKET_PATH
        self.storage_file = storage_file or self.data_dir.joinpath("playlist_ctl.db")
        if config_file and (config_file := expand_path(config_file)).exists():
            self._override_defaults(config_file)

    def _override_defaults(self, file: Path) -> None:
        with open(file, "rb") as f:
            config = tomllib.load(f)

        if isinstance((keep_last := config.get("keep_last")), int):
            self.keep_last = keep_last
        if isinstance((log_level := config.get("log_level")), str):
            self.log_level = log_levels_map.get(log_level.lower(), logging.NOTSET)
        if data_dir := config.get("data_dir"):
            self.data_dir = expand_path(data_dir)
            self.log_file = self.data_dir.joinpath("playlist_ctl.log")
            self.storage_file = self.data_dir.joinpath("playlist_ctl.db")
        if socket_file := config.get("socket_file"):
            self.socket_file = Path(socket_file)
