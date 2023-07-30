from functools import cache
from pathlib import Path
import os


default_socket_path = Path("/tmp/mpv.sock")


@cache
def default_config_path() -> Path:
    if xdg_config_home := os.getenv("XDG_CONFIG_HOME"):
        config_home = Path(xdg_config_home)
    else:
        config_home = Path.joinpath(Path.home(), ".config")
    return config_home.joinpath("playlist_ctl/config.yaml")


@cache
def default_cachedir_path() -> Path:
    if xdg_cache_home := os.getenv("XDG_CACHE_HOME"):
        cache_home = Path(xdg_cache_home)
    else:
        cache_home = Path.home().joinpath(".cache")
    return cache_home.joinpath("playlist_ctl")
