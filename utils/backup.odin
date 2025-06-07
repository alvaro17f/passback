package utils

import s "../style"
import "core:fmt"
import os "core:os/os2"

@(private)
Devices_Check :: struct {
	found:   [dynamic]string,
	missing: [dynamic]string,
}

@(private)
check_devices :: proc(devices: []string) -> Devices_Check {
	found_devices: [dynamic]string
	missing_devices: [dynamic]string

	for device in devices {
		state, err := exec(fmt.tprintf("lsblk -o LABEL | grep -w %s", device), false, false)
		if (err != nil) {
			fmt.printfln("Error runing command: %s", err)
		}

		if (state.exit_code == 0) {
			append_elem(&found_devices, device)
		} else {
			append_elem(&missing_devices, device)
		}
	}

	return {found = found_devices, missing = missing_devices}
}

connected_devices :: proc(devices: []string) -> [dynamic]string {
	devices := check_devices(devices)
	defer delete(devices.missing)

	if (len(devices.found) == 0) {
		fmt.printfln(
			"%sError: no devices were found. Exiting... 😢%s",
			s.color.red,
			s.color.reset,
		)
		os.exit(1)
	}

	if (len(devices.missing) > 0) {
		fmt.println()
		fmt.printfln("%sFound devices: %s%s", s.color.green, s.color.reset, devices.found)
		fmt.printfln("%sMissing devices: %s%s", s.color.red, s.color.reset, devices.missing)
	} else {
		fmt.println()
		fmt.printfln(
			"%sAll devices are ready 😀: %s%s",
			s.color.green,
			devices.found,
			s.color.reset,
		)
	}

	return devices.found
}

mount_path :: proc(device: string) -> string {
	username := os.get_env("USER", context.temp_allocator)
	return fmt.tprintf("/run/media/%s/%s/keepass", username, device)
}

rsync_cmd :: proc(path: string, mount_path: string) {
	cmd := fmt.tprintf("rsync -O -r -t -v --progress -s %s %s", path, mount_path)
	_, err := exec(cmd)
	if (err != nil) {
		fmt.printfln("%sError: failed to backup. Exiting... 😢%s", s.color.red, s.color.reset)
		os.exit(1)
	}
}

backup :: proc(device: string, path: string) {
	mount_path := mount_path(device)
	mount_path_exists := os.exists(mount_path)
	mount_device_cmd := fmt.tprintf("udisksctl mount -b /dev/disk/by-label/%s", device)

	if (!mount_path_exists) {
		fmt.printfln("%sError: path does not exist.%s", s.color.red, s.color.reset)

		_, err := exec(mount_device_cmd, false, false)
		if (err != nil) {
			fmt.printfln(
				"%sError: failed to mount device. Exiting... 😢%s",
				s.color.red,
				s.color.reset,
			)
			os.exit(1)
		}
	}

	rsync_cmd(path, mount_path)
}

