package bot

import (
	"fmt"
	"net"
	"servers/domain"
	"servers/internal/config"
	"servers/internal/service"
	"strings"
)

type Handler struct {
	config   *config.Config
	services *service.Services
	bot      *domain.Bot
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

		h.bot = &domain.Bot{
			Ip:   strings.Split(conn.RemoteAddr().String(), ":")[0],
			Conn: conn,
		}
		/* 		// connStruct := Conn{
		   		// 	handler: h,
		   		// 	conn:    conn,
		   		// } */

		go func() {
			defer conn.Close()

			h.RunConnHandler(conn)
		}()

	}
}

func NewHandler(config *config.Config, services *service.Services) *Handler {
	return &Handler{
		config:   config,
		services: services,
	}
}
