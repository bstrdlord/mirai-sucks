const std = @import("std");
const helpers = @import("../../helpers.zig");

const TcpHeader = @This();

src_port: u16,
dst_port: u16,
seq: u32,
ack: u32 = 0x00,
data_offset: u8 = 0x05,
flags: u8,
window_size: u16,
checksum: u16 = 0x00,
urg_ptr: u16 = 0x00,

pub fn init(dst_port: u16, flags: u8) TcpHeader {
    return .{
        .src_port = helpers.randomInt(u16, 2000, 64000),
        .dst_port = dst_port,
        .seq = helpers.randomInt(u32, 700, 2000),
        .ack = 0,
        .flags = flags,
        .window_size = helpers.randomInt(u16, 2000, 10000),
    };
}

pub fn marshal(self: *TcpHeader, buffer: []u8) void {
    helpers.writeBigEndianU16(buffer[0..2], self.src_port);

    helpers.writeBigEndianU16(buffer[2..4], self.dst_port);
    helpers.writeBigEndianU32(buffer[4..8], self.seq);
    helpers.writeBigEndianU32(buffer[8..12], self.ack);

    buffer[12] = 20 / 4 << 4; // cause no opts
    buffer[13] = self.flags;
    helpers.writeBigEndianU16(buffer[14..16], self.window_size);
    helpers.writeBigEndianU16(buffer[16..18], self.checksum);
    helpers.writeBigEndianU16(buffer[18..20], self.urg_ptr);
}

pub fn calcChecksum(self: *TcpHeader, data: []const u8) u16 {
    _ = self; // autofix
    var sum: u32 = 0;
    var i: usize = 0;
    while (i < data.len) : (i += 2) {
        sum += (@as(u32, @intCast(data[i])) << 8) + @as(u32, @intCast(data[i + 1]));
    }
    if (data.len % 2 != 0) {
        sum += data[data.len - 1];
    }
    sum += sum >> 16;
    return @intCast(~sum & 0xFFFF);
}
