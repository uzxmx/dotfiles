package main

import (
	"encoding/hex"
	"flag"
	"fmt"
	"os"
)

func main() {
	flag.Usage = usage
	flag.Parse()

	args := flag.Args()
	if len(args) != 2 {
		usage()
		os.Exit(1)
	}

	a, err := hex.DecodeString(args[0])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	b, err := hex.DecodeString(args[1])
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	var d []byte
	if len(a) > len(b) {
		d = xor(a, a, b, len(b))
	} else {
		d = xor(b, a, b, len(a))
	}
	fmt.Println(hex.EncodeToString(d))
}

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: xor <operand1> <operand2>

Compute the exclusive or of the two operands. The operand should be specified
in hexadecimal.
`)
	flag.PrintDefaults()
}

func xor(dst, a, b []byte, n int) []byte {
	for i := 0; i < n; i++ {
		dst[i] = a[i] ^ b[i]
	}
	return dst
}
