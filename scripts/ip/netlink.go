package main

import (
	"fmt"
	"os"
	"github.com/vishvananda/netlink"
)

func main() {
	if link, err := netlink.LinkByName(os.Args[1]); err == nil {
		fmt.Println(link.Type())
	}
}
