package main

import (
	"encoding/hex"
	"fmt"
	"os"
	"strings"
)

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: xor <operand1-in-hex> <operand2-in-hex>

Compute the exclusive or of the two operands. The operand should be specified
in hexadecimal.

Options:
  -r Pad with zeros right when the lenght of operands is not equal (default is left)

Examples:
  xor ff00 00ff
  xor ff00 "00  ff "

  xor ff00 ff     // => ffff
  xor ff00 ff -r  // => 0000
`)
	os.Exit(1)
}

func main() {
	var args []string
	padRight := false

	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-r":
			padRight = true
		default:
			if len(arg) > 0 && arg[0] == '-' {
				usage()
			}
			args = append(args, arg)
		}
	}

	if len(args) != 2 {
		usage()
		os.Exit(1)
	}

	a, err := hex.DecodeString(strings.ReplaceAll(args[0], " ", ""))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	b, err := hex.DecodeString(strings.ReplaceAll(args[1], " ", ""))
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	if len(a) != len(b) {
		if len(a) < len(b) {
			c := a
			a = b
			b = c
		}
		// Here len(b) < len(a). So we need to pad b with zeros to make sure they are equal.
		c := make([]byte, len(a))
		if padRight {
			copy(c, b)
		} else {
			copy(c[len(a)-len(b):], b)
		}
		b = c
	}
	fmt.Println(hex.EncodeToString(xor(a, a, b, len(a))))
}

func xor(dst, a, b []byte, n int) []byte {
	for i := 0; i < n; i++ {
		dst[i] = a[i] ^ b[i]
	}
	return dst
}
