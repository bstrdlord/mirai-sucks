const helpers = @import("../../helpers.zig");
const std = @import("std");

const IpHeader = @This();

version: u4 = 0x04, // ipv4
ihl: u4 = 0x05, // cause no opts
tos: u8 = 0x00,
len: u16 = 0x00, // will be filled later
total_len: u16 = 0x28, // 20 + 20
id: u16 = 0x01,
flags: u3 = 0x00,
frag_off: u13 = 0x00,
ttl: u8,
protocol: u8,
checksum: u16 = 0x00,
src: [4]u8,
dst: [4]u8,

pub fn init(dst_ip: [4]u8, protocol: u8) IpHeader {
    return .{
        .ttl = helpers.randomInt(u8, 0, 255),
        .protocol = protocol,
        .src = helpers.randomIp(),
        .dst = dst_ip,
    };
}

pub fn marshal(self: *const IpHeader) [20]u8 {
    const hdr_len = 20;

    var buf: [hdr_len]u8 = undefined;

    buf[0] = @as(u8, (4 << 4) | (hdr_len >> 2 & 0x0f));
    buf[1] = self.tos;

    helpers.writeBigEndianU16(buf[2..4], self.total_len);
    helpers.writeBigEndianU16(buf[4..6], self.id);

    const flags_frag: u16 = (self.frag_off & 0x1fff) | @as(u16, self.flags) << 13;
    helpers.writeBigEndianU16(buf[6..8], flags_frag);

    buf[8] = self.ttl;
    buf[9] = self.protocol;

    helpers.writeBigEndianU16(buf[10..12], self.checksum);

    @memcpy(buf[12..16], self.src[0..4]);
    @memcpy(buf[16..20], self.dst[0..4]);

    return buf;
}
