package main

import (
	"errors"
	"flag"
	"io"
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
	flag.StringVar(&urlList, "l", "", "url list separeted by space")
	flag.StringVar(&outputDir, "o", "", "cache dir path")

	flag.Parse()
}

func parseUrls() {
	urls = make(map[string]string)
	for _, u := range strings.Split(urlList, " ") {
		if !r.MatchString(u) {
			continue
		}

		s := r.FindStringSubmatch(u)
		if len(s) != 2 {
			continue
		}

		urls[s[1]] = u
	}
}

func exists(path string) bool {
	_, err := os.Stat(path)
	return !errors.Is(err, os.ErrNotExist) && err == nil
}

func download_file(url, filepath string, wg *sync.WaitGroup) {
	defer wg.Done()

	resp, err := http.Get(url)
	if err != nil {
		return
	}
	defer resp.Body.Close()

	out, err := os.Create(filepath)
	if err != nil {
		return
	}
	defer func() { _ = out.Close() }()

	_, _ = io.Copy(out, resp.Body)
}

func main() {
	parseFlags()
	parseUrls()
	var wg sync.WaitGroup
	for id, url := range urls {
		filepath := filepath.Join(outputDir, id)
		if exists(filepath) {
			continue
		}
		wg.Add(1)
		go download_file(url, filepath, &wg)
	}
	wg.Wait()
}
