## mpv rofi launchers

##### common dependencies:

- [mpv](https://github.com/mpv-player/mpv)
- [youtube-dl](https://github.com/ytdl-org/youtube-dl) (_or [yt-dlp](https://github.com/yt-dlp/yt-dlp), or any other script specified in_ `$XDG_CONFIG_HOME/mpv/mpv.conf` _as_ `script-opts=ytdl_hook-ytdl_path=scriptname`)

---

### playlist-ctl

##### required dependencies:

- [xclip](https://github.com/astrand/xclip) (_append script_)
- [python>=3.8](https://www.python.org/)

---

### search

##### optional dependencies:

- [go](https://github.com/golang/go)

##### to build downloader:

```shell
go build downloader.go
```

##### search demo:

[demo.webm](https://user-images.githubusercontent.com/78869105/189316747-bdfcdbb5-9174-4684-8aa7-2e7d41105709.webm)
