package utils

import "../style"
import "core:fmt"
import "core:strings"

title_maker :: proc(text: string) {
	border := len(text) + 4

	fmt.printfln("\n%s%s%s", style.color.blue, strings.repeat("*", border), style.color.reset)
	fmt.printfln(
		"%s*%s %s%s%s %s*%s",
		style.color.blue,
		style.color.reset,
		style.color.red,
		text,
		style.color.reset,
		style.color.blue,
		style.color.reset,
	)
	fmt.printfln("%s%s%s", style.color.blue, strings.repeat("*", border), style.color.reset)
}

