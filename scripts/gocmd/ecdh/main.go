package main

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/binary"
	"encoding/hex"
	"encoding/pem"
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"math/big"
	"os"
	"strings"
)

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: ecdh

Subcommands:
  parse - parse EC private key by x509


Encrypt or decrypt with RSA. By default the input is specified by the
argument, and output goes to the stdout, with hexadecimal text format. You can
switch to use files and/or binary format.

When encrypting, there are three ways to specify the public key: by certificate
file, or by public key file, or by modulus and exponent.

Encrypt options:
  --cert-file Certificate file. Only support PEM format
  --pubkey-file Public key file. Only support PEM format
  -N <modulus> Public key modulus in hexadecimal
  -E <exponent> Public key exponent in hexadecimal

Decrypt options:
  --privkey-file Private key file. Only support PEM format

Common options:
  --rand <random> Random in hexadecimal, which is used when encrypting or decrypting
  --in-file <input-file>
  --in-bin Input as binary, default is hexadecimal text

  --out-file <output-file>
  --out-bin Output as binary, default is hexadecimal text
`)
	os.Exit(1)
}

func main() {
	var args []string
	var certFile, pubkeyFile, privkeyFile string
	var randomBytes []byte
	var modulus, exponent []byte
	var inputFile, outputFile string
	inputAsBinary := false
	outputAsBinary := false
	var err error

	if os.Args[1] == "-h" {
		usage()
	} else {
		subcommand = os.Args[1]
	}

	if subcommand == "parse" {

	}

	for i := 2; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		default:
			usage()
		}
	}
}
