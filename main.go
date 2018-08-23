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

const imageFolder = "./persons/"

func ExampleScrape() {
	// Request the HTML page.
	res, err := http.Get("https://world-of-contract.com/team/")

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
	doc.Find("figure.profil-bild-teaser").Each(func(i int, s *goquery.Selection) {

		person_url, ok := s.Find("a").Attr("href")
		p := strings.Split(person_url, "/")
		p_name := p[len(p)-1]

		if ok {
			p_url := "https://world-of-contract.com" + person_url
			p_res, err := http.Get(p_url)
			if err != nil { log.Fatal(err) }
			defer p_res.Body.Close()
			if p_res.StatusCode != 200 { log.Fatalf("status code error: %d %s", res.StatusCode, res.Status) }
			p_doc, err := goquery.NewDocumentFromReader(p_res.Body)
			if err != nil { log.Fatal(err) }
			p_doc.Find("figure.profil-bild").Each(func(i int, s *goquery.Selection) {
				src, ok := s.Find("img").Attr("src")
				if ok {
					i := strings.Index(src, "?")
					if i > -1 {
						image_url := src[:i]
						a := strings.Split(image_url, "/")
						filename := a[len(a)-1]
						downloadImage(image_url, filename, p_name)
					} else {
						fmt.Println("some thing get wrong today...")
					}
				}
			})
		} else {
			fmt.Println("some thing goes wrong")
		}
	})
}

func downloadImage( u string, n string, f string ) {
	response, e := http.Get(u)
	if e != nil {
		log.Fatal(e)
	}
	defer response.Body.Close()
	file, err := os.Create( imageFolder + f + "__" + n )
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
