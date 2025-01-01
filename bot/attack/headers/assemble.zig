const std = @import("std");

const TcpHeader = @import("TcpHeader.zig");
const PsdHeader = @import("PsdHeader.zig");
const IpHeader = @import("IpHeader.zig");

const helpers = @import("../../helpers.zig");

/// assemble packet
pub fn packet(ip_h_bytes: [20]u8, tcp_h: *TcpHeader, psd_h: *PsdHeader) [40]u8 {

    // shitcoded haha
    var bytes: [20]u8 = undefined;

    tcp_h.marshal(&bytes);

    var buffer: [40]u8 = undefined;

    psd_h.marshal(&buffer);

    var tcph_b: [20]u8 = undefined;

    tcp_h.marshal(&tcph_b);

    for (tcph_b, 0..) |byte, i| {
        buffer[12 + i] = byte;
    }

    tcp_h.checksum = tcp_h.calcChecksum(&buffer);

    var tcp_hdr: [20]u8 = undefined;
    tcp_h.marshal(&tcp_hdr);

    var fin_buf: [40]u8 = undefined;

    std.mem.copyForwards(u8, fin_buf[0..ip_h_bytes.len], &ip_h_bytes);
    std.mem.copyForwards(u8, fin_buf[ip_h_bytes.len..tcp_hdr.len], &tcp_hdr);

    return fin_buf;
}

pub fn payload(comptime len: usize) []u8 {
    var buf: [len]u8 = undefined;

    std.posix.getrandom(&buf) catch |err| {
        std.debug.print("err {s}\n", .{@errorName(err)});
    };

    return &buf;
}
