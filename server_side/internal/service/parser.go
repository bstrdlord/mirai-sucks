package service

import (
	"fmt"
	"net"
	"servers/domain"
	"strconv"
	"strings"
)

type ParserService struct {
}

func NewParserService() *ParserService {
	return &ParserService{}
}

func (s *ParserService) Parse(payload string) (string, bool, error) {
	payload = strings.Trim(payload, "\n\r")

	args := strings.Split(payload, " ")
	if len(args) < 2 {
		return "", false, fmt.Errorf("invalid command")
	}
	fmt.Println(len(args))

	cmdName := args[0]

	if string(payload[0]) == domain.PREFIX { // method or command
		for _, method := range domain.MethodsMap {
			if method.Name == strings.Trim(cmdName[1:], "\n\r") {
				// [method] [ip] [port] [duration]
				if len(args) < 4 {
					return "", false, fmt.Errorf("%s [ip] [port] [duration]", method.Name)
				}

				if net.ParseIP(args[1]) == nil {
					return "", false, fmt.Errorf("invalid ip: %s", args[1])
				}

				if isInvalidPort(args[2]) {
					return "", false, fmt.Errorf("invalid port: %s", args[2])
				}

				if isInvalidDuration(args[3]) {
					return "", false, fmt.Errorf("invalid duration: %s", args[3])
				}

				return payload[1:], true, nil
			}
		}

		return "", false, fmt.Errorf("unknown method: %s", cmdName[1:])
	}

	for _, command := range domain.CommandsMap {
		fmt.Println(command.Name)
		fmt.Println(cmdName)

		if command.Name == cmdName {
			return "", false, nil
		}

		return "", false, fmt.Errorf("unknown command: %s", cmdName)
	}

	return "", false, fmt.Errorf("unknown command")
}

func isInvalidPort(port string) bool {
	p, err := strconv.Atoi(port)
	if err != nil {
		return true
	}
	return p < 0 && p >= 65536
}

func isInvalidDuration(duration string) bool {
	d, err := strconv.Atoi(duration)
	if err != nil {
		return true
	}
	return d < 0 && d >= domain.MAX_DURATION
}
