package cnc

import (
	"fmt"
	"net"
	"servers/internal/config"
	"servers/internal/service"
	"time"
)

type Handler struct {
	config   *config.Config
	services *service.Services
}

type Conn struct {
	handler *Handler
	conn    net.Conn
}

func (h *Handler) Run() {
	listener, err := net.Listen("tcp", h.config.CncAddr)
	if err != nil {
		panic(err)
	}

	defer listener.Close()

	fmt.Println("[CNC] Listening on", h.config.CncAddr)

	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}

		/* 		// connStruct := Conn{
		   		// 	handler: h,
		   		// 	conn:    conn,
		   		// } */

		go func() {
			defer conn.Close()

			h.helloPage(conn)
		}()

	}

}

func (h *Handler) helloPage(conn net.Conn) {
	conn.SetDeadline(time.Now().Add(time.Duration(30 * time.Minute)))
	h.services.Term.Cls(conn)

	h.RunConnHandler(conn)

}

func NewHandler(config *config.Config, services *service.Services) *Handler {
	return &Handler{
		config:   config,
		services: services,
	}
}
