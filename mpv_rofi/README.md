## mpv rofi launchers

##### dependencies:

- rofi
- mpv
- youtube-dl (_or yt-dlp, or any other script specified in_ `$XDG_CONFIG_HOME/mpv/mpv.conf` _as_ `script-opts=ytdl_hook-ytdl_path=scriptname`)
- go (_for building alternative downloader_)

##### building downloader:

```bash
go build downloader.go
```

##### search demo:

[demo.webm](https://user-images.githubusercontent.com/78869105/189316747-bdfcdbb5-9174-4684-8aa7-2e7d41105709.webm)
