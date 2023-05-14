package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
)

const (
	apiUrl  = "https://%s.wikipedia.org/w/api.php?action=opensearch&namespace=0&format=json&formatversion=2&limit=10&search=%s"
	errRead = "<span color='#f00' weight='bold'>[ERROR]</span> can't read response 😧\000nonselectable\037true"
	errReq  = "<span color='#f00' weight='bold'>[ERROR]</span> bad request 😠\000nonselectable\037true"
)

var langs = []map[string]string{
	{
		"lang":   "uk",
		"empty":  "<span color='gray'>нічого не знайдено</span> 😴\000icon\037ua_square\037nonselectable\037true",
		"format": "<span weight='bold'>%d</span>) %s\000icon\037ua_square\037info\037%s\n",
	},
	{
		"lang":   "en",
		"empty":  "<span color='gray'>nothing found</span> 😴\000icon\037uk_square\037nonselectable\037true",
		"format": "<span weight='bold'>%d</span>) %s\000icon\037uk_square\037info\037%s\n",
	},
}

type SearchResult struct {
	Search           string
	Titles, Links, S []string
}

func parseUrl(lang string, query string) string {
	return fmt.Sprintf(apiUrl, lang, query)
}

func formatOutput(result SearchResult, l int) {
	if len(result.Links) == 0 {
		fmt.Println(langs[l]["empty"])
		return
	}

	for i, link := range result.Links {
		fmt.Printf(langs[l]["format"], i+1, result.Titles[i], link)
	}
}

func find(subj string) {
	for i, lang := range langs {
		response, err := http.Get(parseUrl(lang["lang"], url.QueryEscape(subj)))
		if err != nil {
			fmt.Println(errReq)
			continue
		}
		defer response.Body.Close()
		var result SearchResult
		if err := json.NewDecoder(response.Body).Decode(&[]interface{}{
			&result.Search,
			&result.Titles,
			&result.S,
			&result.Links,
		}); err != nil {
			fmt.Println(errRead)
			continue
		}
		formatOutput(result, i)
	}
}

func main() {
	if len(os.Args[1]) == 0 {
		os.Exit(1)
	}

	find(os.Args[1])
}
