package service

import (
	"math/rand"
	"time"
)

type EncService struct {
}

func NewEncService() *EncService {
	return &EncService{}
}

func (s *EncService) Decrypt(in string, key int) string {
	buf := make([]byte, len(in))

	for i, c := range in {
		buf[i] = byte(c ^ rune(key))
	}

	return string(buf)
}

func (s *EncService) Encrypt(in string, key int) string {
	buf := make([]byte, len(in))

	for i, c := range in {
		buf[i] = byte(c ^ rune(key))
	}

	buf = append(buf, 0x7C)
	buf = append(buf, byte(key))

	return string(buf)
}

func (s *EncService) RandKey() int {
	var min, max = 1, 255

	s1 := rand.NewSource(time.Now().UnixNano())
	r := rand.New(s1)
	return r.Intn(max-min+1) + min
}
