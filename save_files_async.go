package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"sync"
)

func main() {
	links := []string{
		"https://example.com/image1.jpg",
		"https://example.com/image2.jpg",
		"https://example.com/image3.jpg",
	}

	var wg sync.WaitGroup
	wg.Add(len(links))

	for _, link := range links {
		go func(link string) {
			defer wg.Done()

			response, err := http.Get(link)
			if err != nil {
				fmt.Printf("Error downloading %s: %s\n", link, err.Error())
				return
			}

			defer response.Body.Close()

			file, err := os.Create(fmt.Sprintf("downloads/%s", getFileName(link)))
			if err != nil {
				fmt.Printf("Error creating file %s: %s\n", getFileName(link), err.Error())
				return
			}

			defer file.Close()

			_, err = io.Copy(file, response.Body)
			if err != nil {
				fmt.Printf("Error saving file %s: %s\n", getFileName(link), err.Error())
				return
			}

			fmt.Printf("Downloaded %s\n", link)
		}(link)
	}

	wg.Wait()
	fmt.Println("All downloads completed")
}

func getFileName(link string) string {
	parts := strings.Split(link, "/")
	return parts[len(parts)-1]
}
