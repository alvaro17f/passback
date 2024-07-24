const std = @import("std");
const app = @import("app/app.zig").app;
const eql = std.mem.eql;
const style = @import("utils/style.zig").Style;

const version = "0.1.0";

pub const Cli = struct {
    devices: [][]const u8,
    path: []const u8,
};

fn printHelp() void {
    std.debug.print(
        \\
        \\ ***************************************************
        \\ PASSBACK - A tool to backup your keepass database
        \\ ***************************************************
        \\ -d : USB devices to backup to
        \\ -p : Path to keepass db (default is ~/keepass)
        \\ -h, help : Display this help message
        \\ -v, version : Display the current version
        \\
        \\
    , .{});
}

fn printVersion() void {
    std.debug.print("{s}\nPASSBACK version: {s}{s}\n{s}", .{ style.Black, style.Cyan, version, style.Reset });
}

fn getHostname(buffer: *[64]u8) []const u8 {
    return std.posix.gethostname(buffer) catch "unknown";
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var cli = Cli{
        .devices = undefined,
        .path = "~/keepass",
    };

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len <= 1) {
        return std.debug.print("{s}Error: no devices were provided. Try using \"-d\" flag.\n{s}", .{ style.Red, style.Reset });
    }

    for (args[1..], 0..) |arg, idx| {
        if (arg[0] == '-') {
            for (arg[1..]) |flag| {
                switch (flag) {
                    'h' => {
                        return printHelp();
                    },
                    'v' => {
                        return printVersion();
                    },
                    'd', 'p' => {
                        if (idx + 2 >= args.len) {
                            return std.debug.print("{s}Error: \"-{c}\" flag requires an argument\n{s}", .{ style.Red, flag, style.Reset });
                        }
                        if (flag == 'd') {
                            var devices = std.ArrayList([]const u8).init(allocator);
                            for (args[idx + 2 ..]) |argument| {
                                if (argument[0] == '-') {
                                    break;
                                }
                                try devices.append(argument);
                            }

                            cli.devices = devices.items;
                        }
                        if (flag == 'p') cli.path = args[idx + 2];
                    },
                    else => return std.debug.print("{s}Error: Unknown flag \"-{c}\"\n{s}", .{ style.Red, flag, style.Reset }),
                }
            }
        } else if (idx == 0) {
            for (args[1..]) |argument| {
                if (eql(u8, argument, "help")) {
                    return printHelp();
                }
                if (eql(u8, argument, "version")) {
                    return printVersion();
                }

                return std.debug.print("{s}Error: Unknown argument \"{s}\"\n{s}", .{ style.Red, argument, style.Reset });
            }
        }
    }

    return try app(cli);
}
