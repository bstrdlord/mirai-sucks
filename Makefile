bot: 
	cd bot && zig build-exe -fsingle-threaded -OReleaseSmall -fno-unwind-tables -DARCH=32 main.zig

bot_run: bot 
	cd bot && sudo ./main

server: 
	cd server_side && go run cmd/main.go 

.PHONY: bot
