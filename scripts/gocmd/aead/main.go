package main

import (
	"crypto/aes"
	"crypto/cipher"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: aead enc|dec [plaintext | ciphertext]

Encrypt or decrypt with AEAD. By default the input is specified by the
argument, and output goes to the stdout, with hexadecimal text format. You can
switch to use files and/or binary format.

Options:
  -k <key> AES key in hexadecimal, with 128 or 256 bits
  -n <nonce> Nonce in hexadecimal
  -a <additional-data> Additional data in hexadecimal

  --in-file <input-file>
  --in-bin Input as binary, default is hexadecimal text

  --out-file <output-file>
  --out-bin Output as binary, default is hexadecimal text
`)
	os.Exit(1)
}

func main() {
	var args []string
	var key []byte
	var nonce []byte
	var additionalData []byte
	var inputFile, outputFile string
	inputAsBinary := false
	outputAsBinary := false
	var err error

	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-k":
			key, err = hex.DecodeString(strings.ReplaceAll(os.Args[i+1], " ", ""))
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			i++
		case "-n":
			nonce, err = hex.DecodeString(strings.ReplaceAll(os.Args[i+1], " ", ""))
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			i++
		case "-a":
			additionalData, err = hex.DecodeString(strings.ReplaceAll(os.Args[i+1], " ", ""))
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			i++
		case "--in-file":
			inputFile = os.Args[i+1]
			if _, err = os.Stat(inputFile); os.IsNotExist(err) {
				fmt.Println("Input file " + inputFile + " does not exist.")
				os.Exit(1)
			}
			i++
		case "--in-bin":
			inputAsBinary = true
		case "--out-file":
			outputFile = os.Args[i+1]
			if _, err = os.Stat(outputFile); !os.IsNotExist(err) {
				fmt.Println("Output file " + outputFile + " already exists.")
				os.Exit(1)
			}
			i++
		case "--out-bin":
			outputAsBinary = true
		default:
			if len(arg) > 0 && arg[0] == '-' {
				usage()
			}
			args = append(args, arg)
		}
	}

	if len(args) < 1 || (args[0] != "enc" && args[0] != "dec") {
		usage()
	}

	if len(key) == 0 {
		fmt.Println("A key is required.")
		os.Exit(1)
	}
	if len(nonce) == 0 {
		fmt.Println("A nonce is required.")
		os.Exit(1)
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	aesgcm, err := cipher.NewGCM(block)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	var src, dst []byte
	if len(inputFile) == 0 || !inputAsBinary {
		var hexString string
		if len(inputFile) != 0 {
			src, err = ioutil.ReadFile(inputFile)
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			hexString = string(src)
		} else {
			if len(args) < 2 || len(args[1]) == 0 {
				fmt.Println("A hexadecimal string should be specified as input.")
				os.Exit(1)
			}
			hexString = args[1]
		}
		src, err = hex.DecodeString(strings.ReplaceAll(strings.Trim(hexString, "\n"), " ", ""))
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	} else {
		src, err = ioutil.ReadFile(inputFile)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}

	if args[0] == "enc" {
		dst = aesgcm.Seal(nil, nonce, src, additionalData)
	} else {
		dst, err = aesgcm.Open(nil, nonce, src, additionalData)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}

	if len(outputFile) == 0 {
		fmt.Println(hex.EncodeToString(dst))
	} else {
		if !outputAsBinary {
			dst = []byte(hex.EncodeToString(dst))
		}
		ioutil.WriteFile(outputFile, dst, 0644)
	}
}
