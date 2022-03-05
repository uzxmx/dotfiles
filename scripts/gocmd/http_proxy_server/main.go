package main

import (
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"github.com/elazarl/goproxy"
	"log"
	"net/http"
	"net/url"
	"os"
)

func usage() {
	fmt.Fprintf(os.Stderr, `Usage: start_http_proxy_server

Start an HTTP proxy server.

Options:
  -b <address> Address bound to. Default is localhost:8080
  -p <proxy-url> Another proxy server to forward requests to, e.g. https://user:password@foo:8443
`)
	os.Exit(1)
}

func main() {
	address := "localhost:8080"
	var proxyURLString string
	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-b":
			address = os.Args[i+1]
			i++
		case "-p":
			proxyURLString = os.Args[i+1]
			i++
		default:
			usage()
		}
	}

	proxy := goproxy.NewProxyHttpServer()

	if len(proxyURLString) > 0 {
		proxyURL, err := url.Parse(proxyURLString)
		if err != nil {
			log.Fatal(err)
		}

		proxy.Tr = &http.Transport{
			Proxy:           http.ProxyURL(proxyURL),
			TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
		}

		username := proxyURL.User.Username()
		password, _ := proxyURL.User.Password()
		var proxyAuthorization string
		if len(username) > 0 || len(password) > 0 {
			proxyAuthorization = "Basic " + base64.StdEncoding.EncodeToString([]byte(username+":"+password))
		}
		proxy.ConnectDial = proxy.NewConnectDialToProxyWithHandler(proxyURLString, func(req *http.Request) {
			if len(proxyAuthorization) > 0 {
				req.Header.Set("Proxy-Authorization", proxyAuthorization)
			}
		})
	}

	proxy.Verbose = true
	log.Println("Listening at", address)
	log.Fatal(http.ListenAndServe(address, proxy))
}
