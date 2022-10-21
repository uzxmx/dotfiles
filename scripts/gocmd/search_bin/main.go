package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
)

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: search_bin <pattern-file> <src-file>

Search in the binary src-file for a sequence of bytes generated from the pattern-file.

Options:
  -l <min-length> The minimum length of the sequence of bytes to be matched, default is 4
`)
	os.Exit(1)
}

type result struct {
	PatternOffset int
	SrcOffset     int
	Length        int
}

func main() {
	var args []string
	minLength := 4
	var err error

	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-l":
			parsed, err := strconv.ParseInt(os.Args[i+1], 10, 32)
			if err != nil {
				fmt.Println("Failed to parse the minimum length")
				os.Exit(1)
			}
			minLength = int(parsed)
			i++
		default:
			args = append(args, arg)
		}
	}

	if len(args) != 2 {
		usage()
	}

	pattern, err := ioutil.ReadFile(args[0])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	src, err := ioutil.ReadFile(args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	results := []result{}

	for i, _ := range pattern[:len(pattern)-minLength+1] {
		for j, _ := range src {
			if pattern[i] != src[j] {
				continue
			}
			size := maxCommonPrefix(pattern[i:], src[j:])
			if size < minLength {
				continue
			}
			r := result{
				PatternOffset: i,
				SrcOffset:     j,
				Length:        size,
			}
			results = append(results, r)
		}
	}

	for _, r := range results {
		fmt.Println(r)
	}
}

func maxCommonPrefix(a, b []byte) int {
	size := 0
	for {
		if size < len(a) && size < len(b) && a[size] == b[size] {
			size++
			continue
		}
		break
	}
	return size
}
