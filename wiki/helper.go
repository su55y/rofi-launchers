package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"html"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"sync"
	"time"
)

const (
	apiUrl         = "https://%s.wikipedia.org/w/api.php?action=opensearch&namespace=0&format=json&formatversion=2&limit=%d&search=%s"
	entryFmt       = "<span weight='bold'>%d</span>) %s\000icon\037%s_wiki\037info\037%s\n"
	errMessageRofi = "\000message\037error: %s\n"
	searchFmt      = "<span weight='bold'>-</span>) search\000icon\037%s_wiki\037info\037https://%s.wikipedia.org/wiki/Special:Search\n"
)

var (
	limit int
	langs = [2]string{"uk", "en"}
	query string
)

type Article struct {
	Title, Url string
}

func fetchArticles(c *http.Client, u string) ([]Article, error) {
	resp, err := c.Get(u)
	if err != nil {
		return nil, fmt.Errorf("can't fetch articles: %v", err)
	}
	defer func() { _ = resp.Body.Close() }()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("can't read response: %v", err)
	}

	var titles, urls []string
	if err := json.Unmarshal(body, &[]interface{}{nil, &titles, nil, &urls}); err != nil {
		return nil, fmt.Errorf("can't parse articles: %v", err)
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
	articles, err := fetchArticles(client, fmt.Sprintf(apiUrl, lang, limit, url.QueryEscape(query)))
	if err != nil {
		fmt.Printf(errMessageRofi, err.Error()[:79])
		fmt.Printf(searchFmt, lang, lang)
		return
	}
	if len(articles) == 0 {
		fmt.Printf(searchFmt, lang, lang)
		return
	}
	for i, a := range articles {
		fmt.Printf(entryFmt, i+1, a.Title, lang, a.Url)
	}
}

func die(err error) {
	fmt.Printf("\000message\037err: %s\n \000nonselectable\037true\n", err.Error())
	os.Exit(1)
}

func main() {
	flag.StringVar(&query, "q", "", "search query (required)")
	flag.IntVar(&limit, "l", 10, "set results count limit for each request")
	flag.Parse()
	if len(query) == 0 {
		die(fmt.Errorf("query is empty"))
	}

	client := &http.Client{Timeout: time.Second * 5}
	wg := sync.WaitGroup{}
	for _, lang := range langs {
		wg.Add(1)
		go fetchAndPrint(client, &wg, lang)
	}
	wg.Wait()
}
