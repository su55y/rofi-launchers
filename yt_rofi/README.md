## yt search rofi launcher

### dependencies
-   rofi
-   mpv
-   youtube-dl (*or yt-dlp, or any other script specified in* `$XDG_CONFIG_HOME/mpv/mpv.conf` *as* `script-opts=ytdl_hook-ytdl_path=scriptname`)
-   gawk
-   go (*for building alternative downloader*)

### building downloader
```bash
# to build the downloader
go build downloader.go
```

### demo
[demo.webm](https://user-images.githubusercontent.com/78869105/189316747-bdfcdbb5-9174-4684-8aa7-2e7d41105709.webm)
