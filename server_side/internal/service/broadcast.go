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
		bot, err := domain.SafeCast[domain.Bot](value)
		if err != nil {
			panic(err)
		}
		// TODO: remove if error
		bot.Conn.Write([]byte(encPayload))
		time.Sleep(10 * time.Millisecond)
		return true
	})

}
