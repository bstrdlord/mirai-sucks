package delivery

import (
	"servers/internal/config"
	"servers/internal/delivery/bot"
	"servers/internal/delivery/cnc"
	"servers/internal/service"
)

func InitCncDelivery(config *config.Config, services *service.Services) *cnc.Handler {
	return cnc.NewHandler(config, services)
}

func InitBotDelivery(config *config.Config, services *service.Services) *bot.Handler {
	return bot.NewHandler(config, services)
}
