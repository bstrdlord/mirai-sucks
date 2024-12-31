package config

import (
	"encoding/json"
	"os"
)

type Config struct {
	CncAddr string `json:"CncAddr"`
	BotAddr string `json:"BotAddr"`
}

func Read() *Config {
	var config Config

	configBytes, err := os.ReadFile("config.json")
	if err != nil {
		panic(err)
	}

	if err := json.Unmarshal(configBytes, &config); err != nil {
		panic(err)
	}

	return &config
}
