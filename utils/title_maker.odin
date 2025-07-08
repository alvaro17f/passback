package utils

import "core:fmt"
import "core:strings"
import "lib:colors"

title_maker :: proc(text: string) {
	border := len(text) + 4

	fmt.printfln(
		"\n%s%s%s",
		colors.BLUE,
		strings.repeat("*", border, context.temp_allocator),
		colors.RESET,
	)
	fmt.printfln(
		"%s*%s %s%s%s %s*%s",
		colors.BLUE,
		colors.RESET,
		colors.RED,
		text,
		colors.RESET,
		colors.BLUE,
		colors.RESET,
	)
	fmt.printfln(
		"%s%s%s",
		colors.BLUE,
		strings.repeat("*", border, context.temp_allocator),
		colors.RESET,
	)
}

