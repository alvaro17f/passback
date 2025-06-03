package style

@(private)
Color :: struct {
	red:       string,
	green:     string,
	yellow:    string,
	blue:      string,
	magenta:   string,
	cyan:      string,
	gray:      string,
	black:     string,
	reset:     string,
	bold:      string,
	underline: string,
}

color := Color {
	red       = "\x1b[31m",
	green     = "\x1b[32m",
	yellow    = "\x1b[33m",
	blue      = "\x1b[34m",
	magenta   = "\x1b[35m",
	cyan      = "\x1b[36m",
	gray      = "\x1b[37m",
	black     = "\x1b[30m",
	reset     = "\x1b[0m",
	bold      = "\x1b[1m",
	underline = "\x1b[4m",
}

