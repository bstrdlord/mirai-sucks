package service

import (
	"servers/domain"
	"time"
)

type BroadcastService struct {
	bots Cache
}

func NewBroadcastService(bots Cache) *BroadcastService {
	return &BroadcastService{
		bots: bots,
	}
}

func (s *BroadcastService) Broadcast(encPayload string) {
	s.bots.Range(func(k, value any) bool {
		bot := value.(*domain.Bot)
		bot.Conn.Write([]byte(encPayload))
		time.Sleep(10 * time.Millisecond)
		return true
	})

}
