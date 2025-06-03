package main

import "app"

name :: "passback"
version :: "0.1.0"

main :: proc() {
	app.cli(name, version)
}

