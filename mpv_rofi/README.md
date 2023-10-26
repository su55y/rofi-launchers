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

### pytfeeder

##### required dependencies:

- [python>=3.8](https://www.python.org/)

---

### search

##### required dependencies:

- [curl>=7.18](https://github.com/curl/curl)
- [go](https://github.com/golang/go) (_thumbs downloader_)

##### to build downloader:

```shell
go build downloader.go
```

---

### video_chooser

##### required dependencies:

- [go](https://github.com/golang/go) (_printer_)

---

##### search demo:

[demo.webm](https://user-images.githubusercontent.com/78869105/189316747-bdfcdbb5-9174-4684-8aa7-2e7d41105709.webm)
