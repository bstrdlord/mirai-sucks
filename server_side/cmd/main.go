package main

import (
	"servers/internal/app"
	"servers/internal/config"
	"servers/internal/service"
)

func main() {
	services := service.NewServices()
	config := config.Read()

	app := &app.App{
		Services: services,
		Config:   config,
	}

	app.Start()
}
