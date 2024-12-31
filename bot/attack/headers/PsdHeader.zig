const std = @import("std");
const helpers = @import("../../helpers.zig");

const PsdHeader = @This();

src: [4]u8,
dst: [4]u8,
zero: u8 = 0x00,
protocol: u8 = 0x00,
len: u16 = 0x14,

pub fn init(dst_ip: [4]u8, protocol: u8) PsdHeader {
    return .{
        .src = helpers.randomIp(),
        .dst = dst_ip,
        .protocol = protocol,
    };
}

pub fn marshal(self: *PsdHeader, buffer: []u8) void {
    @memcpy(buffer[0..4], self.src[0..4]);
    @memcpy(buffer[4..8], self.dst[0..4]);

    buffer[8] = self.zero;
    buffer[9] = self.protocol;

    helpers.writeBigEndianU16(buffer[10..12], self.len);
}
