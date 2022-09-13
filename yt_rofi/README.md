## yt search rofi launcher

```bash
# to build the downloader
go build downloader.go
```
[demo.webm](https://user-images.githubusercontent.com/78869105/189316747-bdfcdbb5-9174-4684-8aa7-2e7d41105709.webm)

### dependencies:
-   rofi
-   mpv
-   youtube-dl (*or yt-dlp, or any other script specified in `$XDG_CONFIG_HOME/mpv/mpv.conf` as `script-opts=ytdl_hook-ytdl_path=scriptname`*)
-   gawk
