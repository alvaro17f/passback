package app

import s "../style"
import "../utils"
import "core:fmt"

passback :: proc(config: ^Config) {
	utils.check_keepass_directory(config.path)

	print_config(config)
	found_devices := utils.connected_devices(config.devices)

	if (utils.confirm(default_value = true)) {
		for device in found_devices {
			utils.title_maker(device)
			utils.backup(device, config.path)

			fmt.printfln("%sBackup completed successfully%s", s.color.green, s.color.reset)
		}
	}
}

