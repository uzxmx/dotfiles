package main

import (
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
)

func main() {
	var src []byte
	var err error
	if len(os.Args) < 2 {
		src, err = ioutil.ReadAll(os.Stdin)
	} else {
		src, err = ioutil.ReadFile(os.Args[1])
	}
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	i, j := 0, 0
	size := len(src)
	dest := make([]byte, 0)
	for i < size {
		b := src[i]
		if b == '0' && i+1 < size && (src[i+1] == 'x' || src[i+1] == 'X') {
			i += 2
			j = i
			continue
		}

		if (b >= '0' && b <= '9') || (b >= 'a' && b <= 'f') {
			i += 1
			continue
		}

		if j < i {
			dest = decodeAndAppend(src[j:i], dest)
		}
		i += 1
		j = i
	}

	if j < i {
		dest = decodeAndAppend(src[j:i], dest)
	}

	os.Stdout.Write(dest)
}

func decodeAndAppend(src, dest []byte) []byte {
	ary, err := hex.DecodeString(string(src))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	return append(dest, reverseInplace(ary)...)
}

func reverseInplace(src []byte) []byte {
	i, j := 0, len(src)-1
	for i < j {
		b := src[i]
		src[i] = src[j]
		src[j] = b
		i += 1
		j -= 1
	}
	return src
}
