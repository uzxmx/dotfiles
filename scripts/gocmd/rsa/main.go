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
	fmt.Fprintf(os.Stderr, `Usage: rsa enc|dec [plaintext | ciphertext]

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

	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "--cert-file":
			certFile = os.Args[i+1]
			if _, err = os.Stat(certFile); os.IsNotExist(err) {
				fmt.Println("Certificate file " + certFile + " does not exist.")
				os.Exit(1)
			}
			i++
		case "--pubkey-file":
			pubkeyFile = os.Args[i+1]
			if _, err = os.Stat(pubkeyFile); os.IsNotExist(err) {
				fmt.Println("Public key file " + pubkeyFile + " does not exist.")
				os.Exit(1)
			}
			i++
		case "-N":
			modulus, err = hex.DecodeString(strings.ReplaceAll(strings.ReplaceAll(os.Args[i+1], " ", ""), ":", ""))
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			i++
		case "-E":
			exponent, err = hex.DecodeString(strings.ReplaceAll(os.Args[i+1], " ", ""))
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			i++
		case "--rand":
			randomBytes, err = hex.DecodeString(strings.ReplaceAll(os.Args[i+1], " ", ""))
			if err != nil {
				fmt.Println(err)
				os.Exit(1)
			}
			i++
		case "--privkey-file":
			privkeyFile = os.Args[i+1]
			if _, err = os.Stat(privkeyFile); os.IsNotExist(err) {
				fmt.Println("Private key file " + privkeyFile + " does not exist.")
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
		if len(certFile) == 0 && len(pubkeyFile) == 0 && (len(modulus) == 0 || len(exponent) == 0) {
			fmt.Println("You must specify a public key to encrypt.")
			os.Exit(1)
		} else {
			var publicKey *rsa.PublicKey
			if len(certFile) != 0 {
				cert, err := x509.ParseCertificate(decodePEM(certFile).Bytes)
				if err != nil {
					fmt.Printf("Failed to parse certificate: %v\n", err)
					os.Exit(1)
				}
				var ok bool
				publicKey, ok = cert.PublicKey.(*rsa.PublicKey)
				if !ok {
					fmt.Println("The certificate doesn't contain a RSA public key")
					os.Exit(1)
				}
			} else if len(pubkeyFile) != 0 {
				publicKey, err = x509.ParsePKCS1PublicKey(decodePEM(pubkeyFile).Bytes)
				if err != nil {
					fmt.Printf("Failed to parse public key: %v\n", err)
					os.Exit(1)
				}
			} else {
				if len(modulus) == 0 {
					fmt.Println("Public key modulus is required.")
				}
				if len(exponent) == 0 {
					fmt.Println("Public key exponent is required.")
					os.Exit(1)
				}
				publicKey = &rsa.PublicKey{
					N: new(big.Int).SetBytes(modulus),
					E: int(binary.BigEndian.Uint32(exponent)),
				}
			}

			dst = encrypt(publicKey, randomBytes, src)
		}
	} else {
		privateKey, err := x509.ParsePKCS1PrivateKey(decodePEM(privkeyFile).Bytes)
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
		dst = decrypt(privateKey, src)
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

func decodePEM(filename string) *pem.Block {
	content, err := ioutil.ReadFile(filename)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	block, _ := pem.Decode(content)
	if x509.IsEncryptedPEMBlock(block) {
		fmt.Println("Encrypted PEM is not supported.")
		os.Exit(1)
	}
	return block
}

func decrypt(privateKey *rsa.PrivateKey, ciphertext []byte) []byte {
	plaintext, err := rsa.DecryptPKCS1v15(rand.Reader, privateKey, ciphertext)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	return plaintext
}

func encrypt(publicKey *rsa.PublicKey, randomBytes, plaintext []byte) []byte {
	var reader io.Reader

	if len(randomBytes) == 0 {
		reader = rand.Reader
	} else {
		reader = &randReader{
			data: randomBytes,
			pos:  0,
		}
	}

	ciphertext, err := rsa.EncryptPKCS1v15(reader, publicKey, plaintext)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	return ciphertext
}

type randReader struct {
	data []byte
	pos  int
}

func (r *randReader) Read(p []byte) (int, error) {
	n := copy(p, r.data[r.pos:])
	if n > 0 {
		r.pos += n
		return n, nil
	} else {
		return 0, errors.New("Cannot get more random.")
	}
}
