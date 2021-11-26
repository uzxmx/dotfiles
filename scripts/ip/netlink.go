package main

import (
	"fmt"
	"net"
	"os"

	"github.com/vishvananda/netlink"
)

func main() {
	command := os.Args[1]
	switch command {
	case "list":
		cmdList()
	case "show":
		cmdShow()
	}
}

func cmdList() {
	var deviceType, address string
	for i := 2; i < len(os.Args); i++ {
		arg := os.Args[i]
		switch arg {
		case "-t":
			deviceType = os.Args[i+1]
			i++
		case "-a":
			address = os.Args[i+1]
			i++
		default:
			fmt.Printf("Unsupported option: %s\n", arg)
			os.Exit(1)
		}
	}

	list, _ := netlink.LinkList()
	for _, l := range list {
		if len(deviceType) > 0 && deviceType != l.Type() {
			continue
		}

		if len(address) > 0 {
			addrList, _ := netlink.AddrList(l, 0)
			found := false
			for _, addr := range addrList {
				if addr.IP.String() == address {
					found = true
					break
				}
			}
			if !found {
				continue
			}
		}

		fmt.Println(l.Attrs().Name)
	}
}

func cmdShow() {
	if link, err := netlink.LinkByName(os.Args[2]); err == nil {
		fmt.Printf("Type: %s\n", link.Type())
		var state string
		if link.Attrs().Flags&net.FlagUp == 0 {
			state = "down"
		} else {
			state = "up"
		}
		fmt.Printf("State: %s\n", state)
	}
}
