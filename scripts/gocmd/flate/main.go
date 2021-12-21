package main

import (
	"bytes"
	"compress/flate"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: flate [data-in-hex]

Compress or decompress data. By default the input is specified by the
argument, and output goes to the stdout, with hexadecimal text format. You can
switch to use files and/or binary format.

Options:
  -d Decompress
  -l <level> Decompress level, default is 9 (BestCompression).
             Levels range from 1 (BestSpeed) to 9 (BestCompression), higher
             levels typically run slower but compress more. Level 0
             (NoCompression) does not attempt any compression; it only adds the
             necessary DEFLATE framing.
             Level -1 (DefaultCompression) uses the default compression level.
             Level -2 (HuffmanOnly) will use Huffman compression only.

  --in-file <input-file>
  --in-bin Input as binary, default is hexadecimal text

  --out-file <output-file>
  --out-bin Output as binary, default is hexadecimal text
`)
	os.Exit(1)
}

func main() {
	var args []string
	var compressMode = true
	level := 9
	var inputFile, outputFile string
	inputAsBinary := false
	outputAsBinary := false
	var err error

	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-d":
			compressMode = false
		case "-l":
			compressMode = false
			parsed, err := strconv.ParseInt(os.Args[i+1], 10, 32)
			if err != nil {
				fmt.Println("Failed to parse level")
				os.Exit(1)
			}
			level = int(parsed)
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
			if len(args) < 1 || len(args[0]) == 0 {
				fmt.Println("A hexadecimal string should be specified as input.")
				os.Exit(1)
			}
			hexString = args[0]
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

	if compressMode {
		buf := bytes.NewBuffer(nil)
		writer, err := flate.NewWriter(buf, level)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		_, err = writer.Write(src)
		if err != nil {
			writer.Close()
			fmt.Println(err)
			os.Exit(1)
		}
		writer.Close()
		dst = buf.Bytes()
	} else {
		reader := flate.NewReader(bytes.NewReader(src))
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		defer reader.Close()
		dst, err = ioutil.ReadAll(reader)
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
