package utils

import s "../style"
import "core:fmt"
import os "core:os/os2"
import "core:strings"

@(private)
path_contains_kdbx :: proc(path: string) -> bool {
	files, err := os.read_all_directory_by_path(path, context.temp_allocator)
	if (err != nil) {
		fmt.printfln("Error: %s", err)
		os.exit(1)
	}

	for file in files {
		if (strings.ends_with(file.name, ".kdbx")) {
			return true
		}
	}

	return false
}

check_keepass_directory :: proc(path: string) {
	if (!os.is_dir(path)) {
		fmt.printfln("%sError: path \"%s\" does not exist.%s", s.color.red, path, s.color.reset)
		os.exit(1)
	}

	if (!path_contains_kdbx(path)) {
		fmt.printfln(
			"%sError: path \"%s\" does not contains a keepass database.%s",
			s.color.red,
			path,
			s.color.reset,
		)
		os.exit(1)
	}
}

