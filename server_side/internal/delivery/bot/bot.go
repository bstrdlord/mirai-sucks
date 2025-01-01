package bot

import (
	"fmt"
	"io"
	"net"
	"servers/domain"
	"servers/internal/config"
	"servers/internal/service"
	"strings"
)

type Handler struct {
	config   *config.Config
	services *service.Services
	bot      domain.Bot
}

func (h *Handler) Run() {
	listener, err := net.Listen("tcp", h.config.BotAddr)
	if err != nil {
		panic(err)
	}

	defer listener.Close()

	fmt.Println("[BOT] Listening on", h.config.BotAddr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}

		h.bot = domain.Bot{
			Ip:   strings.Split(conn.RemoteAddr().String(), ":")[0],
			Conn: conn,
			Addr: conn.RemoteAddr().String(),
		}

		h.botHello()
		go h.keepAlive()
	}
}

func (h Handler) keepAlive() {
	defer func() {
		h.bot.Conn.Close()
		h.services.BotCache.Delete(h.bot.Addr)
	}()

	var b = make([]byte, 1<<10)

	for {
		n, err := h.bot.Conn.Read(b)
		if err != nil {
			fmt.Println(err)
			return
		}

		_, err = h.bot.Conn.Write(b[0:n])
		if err != nil {
			fmt.Println(err)
			return
		}

		_, err = io.Copy(h.bot.Conn, h.bot.Conn)
		if err != nil {
			fmt.Println(err)
			return
		}
	}

}

func (h *Handler) Disconnect() {
	h.services.BotCache.Delete(h.bot.Addr)
	h.bot.Conn.Write([]byte(DISCONNECT_SIGNATURE))
	h.bot.Conn.Close()
}

func NewHandler(config *config.Config, services *service.Services) *Handler {
	return &Handler{
		config:   config,
		services: services,
	}
}
