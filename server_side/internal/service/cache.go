package service

import (
	"sync"
)

type CacheService struct {
	storage sync.Map
}

func NewCacheService() *CacheService {
	return &CacheService{}
}

func (s *CacheService) Get(key string) any {
	v, _ := s.storage.Load(key)
	return v
}

func (s *CacheService) Set(key string, value any) {
	s.storage.Store(key, value)
}

func (s *CacheService) Delete(key string) {
	s.storage.Delete(key)
}

func (s *CacheService) Has(key string) bool {
	_, ok := s.storage.Load(key)
	return ok
}

func (s *CacheService) Range(f func(key, value any) bool) {
	s.storage.Range(f)
}
