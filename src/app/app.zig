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

    try tools.titleMaker("PASSBACK Configuration");
    cmd.configPrint(cli.devices, cli.path);

    try areDevicesConnected(allocator, cli.devices);

    if (try tools.confirm(true, null)) {
        for (cli.devices[0..]) |device| {
            try tools.titleMaker(device);
        }
    }
}

fn areDevicesConnected(allocator: std.mem.Allocator, cli_devices: [][]const u8) !void {
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
}
