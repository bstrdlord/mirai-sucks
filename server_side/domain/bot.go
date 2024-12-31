package domain

import "net"

type Bot struct {
	Ip   string
	Conn net.Conn
}
