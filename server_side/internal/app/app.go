package app

import (
	"servers/internal/config"
	"servers/internal/delivery"
	"servers/internal/service"
	"sync"
)

type App struct {
	Services *service.Services
	Config   *config.Config
}

func (app *App) Start() {
	var wg sync.WaitGroup
	wg.Add(1)

	// cnc
	{
		cnc := delivery.InitCncDelivery(app.Config, app.Services)
		go cnc.Run()
	}

	// bot
	{
		bot := delivery.InitBotDelivery(app.Config, app.Services)
		go bot.Run()
	}
	wg.Wait()

}
