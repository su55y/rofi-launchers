package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"html"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"
	"sync"
	"time"
)

const (
	apiUrl           = "https://%s.wikipedia.org/w/api.php?action=opensearch&namespace=0&format=json&formatversion=2&limit=%d&search=%s"
	entryFmt         = "<span weight='bold'>%d</span>) %s\000icon\037%s_wiki\037info\037%s\n"
	errMsgFmt        = "\000message\037error: %s\n"
	searchFmt        = "<span weight='bold'>-</span>) search\000icon\037%s_wiki\037info\037https://%s.wikipedia.org/wiki/Special:Search\n"
	defaultUserAgent = "SearchBot/0.0 (https://github.com/su55y/rofi-launchers; su55y@protonmail.com)"
)

var (
	isDebug            bool
	limit              int
	langs              = [2]string{"uk", "en"}
	query              string
	timeout            int
	logFilePath        string
	defaultLogFilePath string = path.Join(os.TempDir(), "rofi_wiki_helper.log")
	userAgent          string
)

type Article struct {
	Title, Url string
}

func formatUrl(lang string) string {
	return fmt.Sprintf(apiUrl, lang, limit, url.QueryEscape(query))
}

func fetchArticles(c *http.Client, u string) ([]Article, error) {
	req, err := http.NewRequest("GET", u, nil)
	if err != nil {
		die(err)
	}
	req.Header.Set("User-Agent", userAgent)

	resp, err := c.Do(req)
	if err != nil {
		return nil, fmt.Errorf("can't fetch articles: %v", err)
	}
	log.Printf("GET %s %s\n", resp.Status, u)
	defer func() { _ = resp.Body.Close() }()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("can't read response: %v", err)
	}

	var titles, urls []string
	if err := json.Unmarshal(body, &[]any{nil, &titles, nil, &urls}); err != nil {
		return nil, fmt.Errorf("can't parse articles: %v (%s)", err, string(body))
	}

	if len(titles) != len(urls) {
		return nil, fmt.Errorf("count of titles (%d) != urls (%d)", len(titles), len(urls))
	}

	articles := make([]Article, len(titles))
	for i := 0; i < len(titles); i++ {
		articles[i] = Article{Title: html.EscapeString(titles[i]), Url: urls[i]}
	}

	return articles, nil
}

func fetchAndPrint(client *http.Client, wg *sync.WaitGroup, lang string) {
	defer wg.Done()
	articles, err := fetchArticles(client, formatUrl(lang))
	if err != nil {
		log.Printf("fetch error (%s): %s\n", lang, err.Error())
		fmt.Printf(errMsgFmt, err.Error())
		fmt.Printf(searchFmt, lang, lang)
		return
	}

	log.Printf("%s: %d articles\n", lang, len(articles))
	if len(articles) == 0 {
		fmt.Printf(searchFmt, lang, lang)
		return
	}
	for i, a := range articles {
		fmt.Printf(entryFmt, i+1, a.Title, lang, a.Url)
	}
}

func die(err error) {
	fmt.Printf(
		"%s\n \000nonselectable\037true\n",
		html.EscapeString(fmt.Sprintf(errMsgFmt, err.Error())),
	)
	log.Fatal(err)
}

func initLogger() {
	var logFile *os.File
	var err error

	if isDebug {
		logFile, err = os.OpenFile(logFilePath, os.O_WRONLY|os.O_APPEND|os.O_CREATE, 0644)
	} else {
		logFile, err = os.Open(os.DevNull)
	}
	if err != nil {
		log.Panic(err)
	}

	log.SetOutput(logFile)
	log.SetFlags(log.LstdFlags | log.Lshortfile | log.Lmicroseconds)
}

func main() {
	flag.StringVar(&query, "q", "", "search query (required)")
	flag.IntVar(&limit, "l", 10, "set results count limit for each request")
	flag.IntVar(&timeout, "t", 10, "set http client timeout")
	flag.BoolVar(&isDebug, "d", false, "enable debug logging")
	flag.StringVar(&logFilePath, "D", defaultLogFilePath, "log file path")
	flag.StringVar(&userAgent, "u", defaultUserAgent, "user agent header")
	flag.Parse()

	initLogger()

	log.Printf("search query: %#+v\n", query)

	if len(query) == 0 {
		die(fmt.Errorf("query is empty"))
	}

	client := &http.Client{Timeout: time.Duration(timeout) * time.Second}
	wg := sync.WaitGroup{}
	for _, lang := range langs {
		wg.Add(1)
		go fetchAndPrint(client, &wg, lang)
	}
	wg.Wait()
}
