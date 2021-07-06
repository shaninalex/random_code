// Remove files by given pattern in given directory
// Usage : ./remove_files -path=<str: path to the directory> -type=<str: file type|name pattern>

package main

import (
	"os"
	"fmt"
	"flag"
	"path/filepath"
)

func walkMatch(root, pattern string) ([]string, error) {
	var matches []string
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil
		}
		if matched, err := filepath.Match(pattern, filepath.Base(path)); err != nil {
			return nil
		} else if matched {
			matches = append(matches, path)
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	return matches, nil
}


func main() {

	// define flags
	var fPath = flag.String("path", "", "Root folder to delete files")
	var fType = flag.String("type", "pdf", "File type to delete")

	// read flags
	flag.Parse()

	// get file pathes
	files, err := walkMatch(*fPath, *fType)

	// if not error
	if err == nil {

		// walk through all files
		for _, file := range files {

			if _, err := os.Stat(file); os.IsNotExist(err) {
				fmt.Println("File: ", file, "does not exist\n")
			} else {
				os.Remove(file)
			}
		}
	}
}
