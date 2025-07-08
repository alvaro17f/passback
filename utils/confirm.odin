package utils

import "core:fmt"
import "core:os"
import "core:strings"
import "lib:colors"


confirm :: proc(message: string = "Proceed?", default_value: bool = false) -> bool {
	default_value_str := default_value ? "(Y/n)" : "(y/N)"

	buf: [256]byte

	fmt.printf(
		"\n%s%s%s %s%s%s: ",
		colors.YELLOW,
		message,
		colors.RESET,
		(default_value ? colors.GREEN : colors.RED),
		default_value_str,
		colors.RESET,
	)

	n, err := os.read(os.stdin, buf[:])
	if err != nil {
		fmt.panicf("Error reading confirmation: ", err)
	}
	confirmation := strings.to_lower(string(buf[:n]))
	defer delete(confirmation)

	switch (confirmation) {
	case "y\n", "yes\n":
		return true
	case "n\n", "no\n":
		return false
	}

	return default_value
}

