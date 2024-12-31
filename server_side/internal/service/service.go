package service

import (
	"net"
)

type Encrypter interface {
	Encrypt(in string, key int) string
	Decrypt(in string, key int) string
	// generates random key (0-255)
	RandKey() int
}

type Parser interface {
	Parse(payload string) (string, bool, error)
}

type Term interface {
	Cls(conn net.Conn)
}

type Cache interface {
	Set(key string, value any)
	Get(key string) any
	Delete(key string)
	Has(key string) bool
	Range(f func(key, value any) bool)
}

type Broadcaster interface {
	Broadcast(encPayload string)
}

type Services struct {
	Parser      Parser
	Term        Term
	BotCache    Cache
	Broadcaster Broadcaster
	Encrypter   Encrypter
}

func NewServices() *Services {

	botCache := NewCacheService()
	parser := NewParserService()
	term := NewTermService()

	broadcaster := NewBroadcastService(botCache)
	encrypter := NewEncService()

	return &Services{
		Parser:      parser,
		Term:        term,
		BotCache:    botCache,
		Broadcaster: broadcaster,
		Encrypter:   encrypter,
	}

}
