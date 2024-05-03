## mpv launchers

##### common dependencies:

- [mpv](https://github.com/mpv-player/mpv)
- [youtube-dl](https://github.com/ytdl-org/youtube-dl) (_or [yt-dlp](https://github.com/yt-dlp/yt-dlp), or any other script specified in_ `$XDG_CONFIG_HOME/mpv/mpv.conf` _as_ `script-opts=ytdl_hook-ytdl_path=scriptname`)
- [xclip](https://github.com/astrand/xclip) (_optional for append script_)

---

| launcher      | required                                                                       |
| ------------- | ------------------------------------------------------------------------------ |
| playlist-ctl  | [python>=3.8](https://www.python.org/)                                         |
| search        | [curl>=7.18](https://github.com/curl/curl), [go](https://github.com/golang/go) |
| video_chooser | [go](https://github.com/golang/go)                                             |

---

##### search demo:

[demo.webm](https://user-images.githubusercontent.com/78869105/189316747-bdfcdbb5-9174-4684-8aa7-2e7d41105709.webm)
