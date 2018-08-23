package main

import (
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"log"
	"net/http"
)

func ExampleScrape() {
	// Request the HTML page.
	res, err := http.Get("https://world-of-contract.com/team/franz-josef-bartsch")
    var images []string

	if err != nil {
		log.Fatal(err)
	}
	defer res.Body.Close()
	if res.StatusCode != 200 {
		log.Fatalf("status code error: %d %s", res.StatusCode, res.Status)
	}

	// Load the HTML document
	doc, err := goquery.NewDocumentFromReader(res.Body)
	if err != nil {
		log.Fatal(err)
	}

	// Find the review items
	doc.Find("figure.profil-bild").Each(func(i int, s *goquery.Selection) {

		src, ok := s.Find("img").Attr("src")
		// find ? position ( if it exist ) and slice all string before ? position
        if ok {
            images = append(images, src)
            fmt.Println(src)
        }

	})

}

func main() {
	ExampleScrape()
}
