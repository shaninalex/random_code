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
				// fmt.Printf("url: %v\n", image_url)
				a := strings.Split(image_url, "/")
				filename := a[len(a)-1]


				response, e := http.Get(image_url)
			    if e != nil {
			        log.Fatal(e)
			    }
			    defer response.Body.Close()

			    //open a file for writing
			    file, err := os.Create(filename)
			    if err != nil {
			        log.Fatal(err)
			    }
			    // Use io.Copy to just dump the response body to the file. This supports huge files
			    _, err = io.Copy(file, response.Body)
			    if err != nil {
			        log.Fatal(err)
			    }
			    file.Close()
			    fmt.Println("Success!")


			} else {
				fmt.Println("some thing get wrong today...")
			}
        }

	})

}



func main() {
	ExampleScrape()
}
