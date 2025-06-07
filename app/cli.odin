package app

import "../app"
import s "../style"
import "../utils"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:sys/posix"


@(private)
Config :: struct {
	name:    string,
	version: string,
	path:    string,
	devices: []string,
}

@(private)
help :: proc(name: string) {
	fmt.printfln(
		`
***************************************************
%s - A tool to backup your keepass database
***************************************************
-d : USB devices to backup to
-p : Path to keepass db (default is ~/keepass)
-h, help : Display this help message
-v, version : Display the current version
  `,
		strings.to_upper(name),
	)
}

@(private)
version :: proc(name: string, version: string) {
	fmt.printfln(
		"\n%s%s Version:%s %s%s%s",
		s.color.yellow,
		strings.to_upper(name),
		s.color.reset,
		s.color.cyan,
		version,
		s.color.reset,
	)
}

@(private)
get_hostname :: proc() -> string {
	uname: posix.utsname
	posix.uname(&uname)

	return strings.clone(string(uname.nodename[:]))
}

@(private)
styled_config_line :: proc(key: string, value: $T) {
	fmt.printfln(
		"%s ◉ %s%s%s%s = %s%v%s",
		s.color.cyan,
		s.color.reset,
		s.color.red,
		key,
		s.color.reset,
		s.color.cyan,
		value,
		s.color.reset,
	)
}

print_config :: proc(config: ^Config) {
	utils.title_maker(strings.to_upper(config.name, context.temp_allocator))
	styled_config_line("devices", config.devices)
	styled_config_line("path", config.path)
}


cli :: proc(app_name: string, app_version: string) {
	arguments := os.args[1:]

	config := Config {
		name    = app_name,
		version = app_version,
		devices = []string{},
		path    = fmt.tprintf("%s/keepass/", os.get_env("HOME", context.temp_allocator)),
	}

	if (len(arguments) == 0) {
		fmt.printfln(
			"%sError: no devices were provided. Try using \"-d\" flag.%s",
			s.color.red,
			s.color.reset,
		)
		os.exit(1)
	}

	if (len(arguments) == 1) {
		switch (arguments[0]) {
		case "help":
			help(config.name)
		case "version":
			version(config.name, config.version)
		}
	}


	out: for argument, idx in arguments {
		switch (argument) {
		case "-h":
			help(config.name)
			break out
		case "-v":
			version(config.name, config.version)
			break out
		case "-d":
			rest := arguments[idx + 1:]
			idx_end: int

			for arg, i in rest {
				if (strings.contains_rune(arg, '-')) {
					idx_end = i
				}
			}

			if (idx_end == 0) {
				config.devices = rest
			} else {
				config.devices = rest[:idx_end]
			}
		case "-p":
			path := arguments[idx + 1]

			if (strings.contains_rune(path, '~')) {
				strings.replace_all(path, "~", fmt.tprintf("%s", os.get_env("HOME")))
			}


			config.path = path
		}
	}

	app.passback(&config)
}

