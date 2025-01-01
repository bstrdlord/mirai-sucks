package service

import (
	"fmt"
	"servers/domain"
)

type CmdsService struct {
	bots Cache
}

func NewCmdsService(bots Cache) *CmdsService {
	return &CmdsService{
		bots: bots,
	}
}

func (s *CmdsService) GetBots() string {

	var bots = make(map[string]int)
	var out string

	s.bots.Range(func(k, value any) bool {
		cast, err := domain.SafeCast[domain.Bot](value)
		if err != nil {
			panic(err)
		}
		bots[cast.Arch]++
		return true
	})

	for arch, i := range bots {
		out += fmt.Sprintf("%s: %d\n\r", arch, i)
	}

	return out
}
