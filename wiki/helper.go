package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
)

const (
	errBadRequest = "bad request 😠\\x00nonselectable\\x1ftrue"
)

var langs = []map[string]string{
	{
		"url":      "https://uk.wikipedia.org/w/api.php?action=opensearch&namespace=0&format=json&search=%s",
		"notFound": "нічого не знайдено 😴\\x00icon\\x1fua_square\\x1fnonselectable\\x1ftrue",
		"format":   "%d) %s\\x00icon\\x1fua_square\\x1finfo\\x1f%s\n",
	},
	{
		"url":      "https://en.wikipedia.org/w/api.php?action=opensearch&namespace=0&format=json&search=%s",
		"notFound": "nothing found 😴\\x00icon\\x1fuk_square\\x1fnonselectable\\x1ftrue",
		"format":   "%d) %s\\x00icon\\x1fuk_square\\x1finfo\\x1f%s\n",
	},
}

type WSRes struct {
	Search           string
	Titles, Links, S []string
}

func formatOutput(result WSRes, l int) {
	if len(result.Links) == 0 {
		fmt.Println(langs[l]["notFound"])
		return
	}

	for i, link := range result.Links {
		fmt.Printf(langs[l]["format"], i+1, result.Titles[i], link)
	}
}

func find(subj string) {
	for i, lang := range langs {
		if res, err := http.Get(fmt.Sprintf(lang["url"], url.QueryEscape(subj))); err == nil {
			wsr := WSRes{}
			defer res.Body.Close()
			body, _ := ioutil.ReadAll(res.Body)
			if err := json.Unmarshal(body, &[]interface{}{
				&wsr.Search,
				&wsr.Titles,
				&wsr.S,
				&wsr.Links}); err == nil {
				formatOutput(wsr, i)
			}
		} else {
			fmt.Println(errBadRequest)
		}
	}
}

func main() {
	if len(os.Args[1]) == 0 {
		os.Exit(1)
	}

	find(os.Args[1])
}
