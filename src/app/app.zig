const std = @import("std");
const print = std.debug.print;
const tools = @import("../utils/tools.zig");
const cmd = @import("../utils/commands.zig").cmd;
const Cli = @import("../main.zig").Cli;
const checkDevices = @import("../utils/devices.zig").checkDevices;
const style = @import("../utils/style.zig").Style;

pub fn app(cli: Cli) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    if (!try tools.pathExists(allocator, cli.path)) {
        print("{s}Error: path does not exist.{s}\n", .{ style.Red, style.Reset });

        return std.process.exit(0);
    }

    try tools.titleMaker("PASSBACK Configuration");
    cmd.configPrint(cli.devices, cli.path);

    const found_devices = try areDevicesConnected(allocator, cli.devices);

    if (try tools.confirm(true, null)) {
        for (found_devices[0..]) |device| {
            try tools.titleMaker(device);
            try backup(allocator, device, cli.path);

            std.debug.print("{s}Backup completed successfully!{s}\n", .{ style.Green, style.Reset });
        }
    }
}

fn areDevicesConnected(allocator: std.mem.Allocator, cli_devices: [][]const u8) ![][]const u8 {
    const devices = try checkDevices(allocator, cli_devices);
    if (devices.found_devices.len == 0) {
        print("{s}Error: no devices were found. Exiting... 😢{s}\n", .{ style.Red, style.Reset });

        return std.process.exit(0);
    }

    if (devices.missing_devices.len > 0) {
        std.debug.print("{s}Found devices: {s}\n", .{ style.Green, devices.found_devices });
        std.debug.print("{s}Missing devices: {s}\n", .{ style.Red, devices.missing_devices });
    } else {
        std.debug.print("{s}All devices are ready 😀{s}", .{ style.Green, style.Reset });
    }

    return devices.found_devices;
}

fn mountPath(allocator: std.mem.Allocator, device: []const u8) ![]const u8 {
    const username = try tools.getUsername();
    return try std.fmt.allocPrint(allocator, "/run/media/{s}/{s}/keepass", .{ username, device });
}

fn rsyncCommand(allocator: std.mem.Allocator, path: []const u8, mount_path: []const u8) !void {
    const rsync_cmd = try std.fmt.allocPrint(allocator, "rsync -O -r -t -v --progress -s {s} {s}", .{ path, mount_path });
    _ = tools.runCmd(true, rsync_cmd) catch {
        std.debug.print("{s}Error: failed to backup. Exiting... 😢{s}\n", .{ style.Red, style.Reset });

        return std.process.exit(0);
    };
}

fn backup(allocator: std.mem.Allocator, device: []const u8, path: []const u8) !void {
    const mount_path = try mountPath(allocator, device);
    const mount_path_exists = try tools.pathExists(allocator, mount_path);

    if (!mount_path_exists) {
        std.debug.print("{s}Error: path does not exist.{s}\n", .{ style.Red, style.Reset });

        const mount_device_cmd = try std.fmt.allocPrint(allocator, "udisksctl mount -b /dev/disk/by-label/{s}", .{device});
        _ = tools.runCmd(false, mount_device_cmd) catch {
            std.debug.print("{s}Error: failed to mount device. Exiting... 😢{s}\n", .{ style.Red, style.Reset });

            return std.process.exit(0);
        };
    }

    try rsyncCommand(allocator, path, mount_path);
}
