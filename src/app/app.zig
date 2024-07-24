const std = @import("std");
const print = std.debug.print;
const tools = @import("../utils/tools.zig");
const cmd = @import("../utils/commands.zig").cmd;
const Cli = @import("../main.zig").Cli;

pub fn app(cli: Cli) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    // const allocator = arena.allocator();

    try tools.titleMaker("PASSBACK Configuration");
    cmd.configPrint(cli.devices, cli.path);
    if (try tools.confirm(true, null)) {
        for (cli.devices[0..]) |device| {
            try tools.titleMaker(device);
        }
    }
}
