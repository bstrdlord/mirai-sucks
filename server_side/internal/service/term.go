package service

import "net"

type TermService struct{}

func NewTermService() *TermService {
	return &TermService{}
}

func (s *TermService) Cls(conn net.Conn) {
	conn.Write([]byte("\x1B[2J\x1B[H"))
}
