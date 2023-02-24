package main

import (
	"errors"
	"flag"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync"
)

var (
	urls      map[string]string
	outputDir string
	urlList   string
	r         = regexp.MustCompile(
		"^https:\\/\\/i\\.ytimg\\.com\\/vi\\/([a-zA-Z0-9\\-_]{11})\\/.*$",
	)
)

func parseFlags() {
	flag.StringVar(&outputDir, "o", "", "")
	flag.StringVar(&outputDir, "output", "", "thumbnails cache dir")
	flag.StringVar(&urlList, "l", "", "")
	flag.StringVar(&urlList, "links", "", "url list separeted by space")

	flag.Parse()
}

func init() {
	parseFlags()
	urls = make(map[string]string)
	for _, u := range strings.Split(urlList, " ") {
		if r.MatchString(u) {
			if s := r.FindStringSubmatch(u); len(s) == 2 {
				urls[s[1]] = u
			}
		}
	}
}

func exists(path string) bool {
	_, err := os.Stat(path)
	return !errors.Is(err, os.ErrNotExist) && err == nil
}

func download_file(url, path string, wg *sync.WaitGroup) {
	defer wg.Done()

	filename := filepath.Join(outputDir, path)
	if exists(filename) {
		return
	}

	resp, err := http.Get(url)
	if err != nil {
		log.Fatal(err)
	}
	defer resp.Body.Close()

	out, err := os.Create(filename)
	if err != nil {
		panic(err)
	}
	defer out.Close()

	io.Copy(out, resp.Body)
}

func main() {
	var wg sync.WaitGroup
	for k, u := range urls {
		wg.Add(1)
		go download_file(u, k, &wg)
	}
	wg.Wait()
}
