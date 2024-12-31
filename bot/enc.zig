const std = @import("std");

// xor algorithm for encryption, but u can rewrite and use other algos (note: dont forget to rewrite the server side too)

pub fn enc(allocator: std.mem.Allocator, in: []const u8, key: u8) []const u8 {
    // add 10 because we need to add the key
    const buf = allocator.alloc(u8, in.len + 10) catch unreachable;

    for (in, 0..) |c, i| {
        buf[i] = c ^ key;
    }

    // append key to the end
    buf[in.len + 1] = 0x7C;
    buf[in.len + 2] = key;

    return trimTrailingNulls(buf);
}

pub fn dec(allocator: std.mem.Allocator, in: []const u8) []const u8 {
    const buf = allocator.alloc(u8, in.len - 2) catch unreachable;

    const key = in[in.len - 1]; // get key from the end

    for (in[0 .. in.len - 2], 0..) |c, i| {
        buf[i] = c ^ key;
    }
    return buf;
}

fn trimTrailingNulls(buf: []const u8) []const u8 {
    var i: usize = buf.len - 1;
    while (i > 0) : (i -= 1) {
        if (buf[i] != 0) {
            break;
        }
    }
    return buf[0 .. i + 1];
}
