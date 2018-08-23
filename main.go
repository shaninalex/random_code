package main

import (
	"fmt"
	"github.com/PuerkitoBio/goquery"
	"log"
	"os"
	"io"
	"strings"
	"net/http"
)

func ExampleScrape() {
	// Request the HTML page.
	res, err := http.Get("https://world-of-contract.com/team/franz-josef-bartsch")

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

        if ok {
			i := strings.Index(src, "?")
			if i > -1 {
				image_url := src[:i]
				a := strings.Split(image_url, "/")
				filename := a[len(a)-1]

				downloadImage(image_url, filename)

			} else {
				fmt.Println("some thing get wrong today...")
			}
        }
	})
}


func downloadImage( u string, n string ) {
	response, e := http.Get(u)
	if e != nil {
		log.Fatal(e)
	}
	defer response.Body.Close()
	file, err := os.Create(n)
	if err != nil {
		log.Fatal(err)
	}
	_, err = io.Copy(file, response.Body)
	if err != nil {
		log.Fatal(err)
	}
	file.Close()
}


func main() {
	ExampleScrape()
}
