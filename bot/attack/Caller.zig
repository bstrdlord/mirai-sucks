const std = @import("std");

const helpers = @import("../helpers.zig");

const Caller = @This();

const linux = std.os.linux;

const SLEEP_TIME = std.time.ns_per_s / 5;

const prototype = *fn ([4]u8, u16) void;
fork_count: u16,
function: prototype,
args: FnArgs,
duration: u32,

allocator: std.mem.Allocator,

const FnArgs = struct {
    ip: [4]u8,
    port: u16,
};

pub fn init(allocator: std.mem.Allocator, fork_count: u16, duration: u32, function: prototype, args: FnArgs) Caller {
    return .{
        .fork_count = fork_count,
        .function = function,
        .args = args,
        .allocator = allocator,
        .duration = duration,
    };
}

/// u can rewrite and use threads/uring/whatever
pub fn call(self: *const Caller) void {
    const pids = self.allocator.alloc(usize, self.fork_count) catch unreachable;
    defer self.allocator.free(pids);

    const start_timestamp = std.time.milliTimestamp();
    const duration_ms = self.duration * 1000;

    for (pids) |*pid| {
        pid.* = helpers.fork() catch |err| {
            std.debug.print("error {s}\n", .{@errorName(err)});
            return;
        };

        if (pid.* == 0) {
            while (std.time.milliTimestamp() - start_timestamp < duration_ms) {
                self.function(self.args.ip, self.args.port);
                self.function(self.args.ip, self.args.port);
                std.time.sleep(SLEEP_TIME);
            }
            return;
        }
    }
}
