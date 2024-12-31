const std = @import("std");
const builtin = @import("builtin");

pub fn getArch() []const u8 {
    // std.debug.print("ARCH is: {s}\n", .{arch});

    // TODO: fix
    return "x86_64";
}

const use_libc = builtin.link_libc or switch (builtin.os.tag) {
    .windows, .wasi => true,
    else => false,
};

// std.posix.errno
fn _errno(rc: anytype) std.os.linux.E {
    if (use_libc) {
        return if (rc == -1) @enumFromInt(std.c._errno().*) else .SUCCESS;
    }
    const signed: isize = @bitCast(rc);
    const int = if (signed > -4096 and signed < 0) -signed else 0;
    return @enumFromInt(int);
}

pub fn errno(res: usize) !void {
    switch (_errno(res)) {
        .SUCCESS => return,
        .ACCES => return error.PermissionDenied,
        .PERM => return error.PermissionDenied,
        .ADDRINUSE => return error.AddressInUse,
        .ADDRNOTAVAIL => return error.AddressNotAvailable,
        .AFNOSUPPORT => return error.AddressFamilyNotSupported,
        .AGAIN, .INPROGRESS => return error.WouldBlock,
        .ALREADY => return error.ConnectionPending,
        .BADF => unreachable, // sockfd is not a valid open file descriptor.
        .CONNREFUSED => return error.ConnectionRefused,
        .CONNRESET => return error.ConnectionResetByPeer,
        .FAULT => unreachable, // The socket structure address is outside the user's address space.
        .INTR => std.debug.print("INTR", .{}),
        .ISCONN => unreachable, // The socket is already connected.
        .HOSTUNREACH => return error.NetworkUnreachable,
        .NETUNREACH => return error.NetworkUnreachable,
        .NOTSOCK => unreachable, // The file descriptor sockfd does not refer to a socket.
        .PROTOTYPE => unreachable, // The socket type does not support the requested communications protocol.
        .TIMEDOUT => return error.ConnectionTimedOut,
        .NOENT => return error.FileNotFound, // Returned when socket is AF.UNIX and the given path does not exist.
        .CONNABORTED => unreachable, // Tried to reuse socket that previously received error.ConnectionRefused.
        else => |err| return std.posix.unexpectedErrno(err),
    }
}

pub fn randomInt(comptime T: type, min: T, max: T) T {
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        std.posix.getrandom(std.mem.asBytes(&seed)) catch unreachable;
        break :blk seed;
    });
    const rand = prng.random();

    return rand.intRangeAtMost(T, min, max);
}

pub fn writeBigEndianU16(buf: []u8, value: u16) void {
    buf[0] = @intCast(value >> 8);
    buf[1] = @intCast(value & 0xFF);
}

pub fn writeBigEndianU32(buf: []u8, value: u32) void {
    buf[0] = @intCast(value >> 24);
    buf[1] = @intCast(value >> 16 & 0xFF);
    buf[2] = @intCast(value >> 8 & 0xFF);
    buf[3] = @intCast(value & 0xFF);
}

pub fn calculateChecksum(header: []u8) u16 {
    var sum: u32 = 0;

    for (header, 0..) |byte, index| {
        if (index % 2 == 0) {
            sum += @as(u16, @intCast(byte)) << 8 | @as(u16, @intCast(header[index + 1]));
        }
    }

    if (header.len % 2 != 0) {
        sum += @as(u16, @intCast(header[header.len - 1])) << 8;
    }

    while (sum >> 16 != 0) {
        sum = (sum & 0xFFFF) + (sum >> 16);
    }

    return @intCast(~sum & 0xFFFF);
}

pub fn fork() !usize {
    const rc = std.os.linux.fork();
    switch (_errno(rc)) {
        .SUCCESS => return @intCast(rc),
        .AGAIN => return error.SystemResources,
        .NOMEM => return error.SystemResources,
        else => |err| return std.posix.unexpectedErrno(err),
    }
}

pub fn setsockopt(fd: i32, level: i32, optname: u32, optval: [*]const u8, optlen: std.os.linux.socklen_t) !void {
    switch (_errno(std.os.linux.setsockopt(fd, level, optname, optval, optlen))) {
        .SUCCESS => {},
        .BADF => unreachable, // always a race condition
        .NOTSOCK => unreachable, // always a race condition
        .INVAL => unreachable,
        .FAULT => unreachable,
        .DOM => return error.TimeoutTooBig,
        .ISCONN => return error.AlreadyConnected,
        .NOPROTOOPT => return error.InvalidProtocolOption,
        .NOMEM => return error.SystemResources,
        .NOBUFS => return error.SystemResources,
        .PERM => return error.PermissionDenied,
        .NODEV => return error.NoDevice,
        else => |err| return std.posix.unexpectedErrno(err),
    }
}

pub fn sendto(fd: i32, buf: [*]const u8, len: usize, flags: u32, addr: ?*const std.os.linux.sockaddr, alen: std.os.linux.socklen_t) !usize {
    while (true) {
        const rc = std.os.linux.sendto(fd, buf, len, flags, addr, alen);
        switch (_errno(rc)) {
            .SUCCESS => return @intCast(rc),
            .ACCES => return error.AccessDenied,
            .AGAIN => return error.WouldBlock,
            .ALREADY => return error.FastOpenAlreadyInProgress,
            .BADF => unreachable, // always a race condition
            .CONNRESET => return error.ConnectionResetByPeer,
            .DESTADDRREQ => unreachable, // The socket is not connection-mode, and no peer address is set.
            .FAULT => unreachable, // An invalid user space address was specified for an argument.
            .INTR => continue,
            .INVAL => return error.UnreachableAddress,
            .ISCONN => unreachable, // connection-mode socket was connected already but a recipient was specified
            .MSGSIZE => return error.MessageTooBig,
            .NOBUFS => return error.SystemResources,
            .NOMEM => return error.SystemResources,
            .NOTSOCK => unreachable, // The file descriptor sockfd does not refer to a socket.
            .OPNOTSUPP => unreachable, // Some bit in the flags argument is inappropriate for the socket type.
            .PIPE => return error.BrokenPipe,
            .AFNOSUPPORT => return error.AddressFamilyNotSupported,
            .LOOP => return error.SymLinkLoop,
            .NAMETOOLONG => return error.NameTooLong,
            .NOENT => return error.FileNotFound,
            .NOTDIR => return error.NotDir,
            .HOSTUNREACH => return error.NetworkUnreachable,
            .NETUNREACH => return error.NetworkUnreachable,
            .NOTCONN => return error.SocketNotConnected,
            .NETDOWN => return error.NetworkSubsystemFailed,
            else => |err| return std.posix.unexpectedErrno(err),
        }
    }
}

pub fn randomIp() [4]u8 {
    return [4]u8{ randomInt(u8, 0, 255), randomInt(u8, 0, 255), randomInt(u8, 0, 255), randomInt(u8, 0, 255) };
}

pub fn parseIp(ip_str: []const u8) [4]u8 {
    var parsed_ip: [4]u8 = undefined;

    var idx: usize = 0;
    var current_value: u8 = 0;

    for (ip_str) |c| {
        if (c == '.') {
            parsed_ip[idx] = current_value;
            idx += 1;
            current_value = 0;
        } else {
            current_value = current_value * 10 + (c - '0');
        }
    }
    parsed_ip[idx] = current_value;
    return parsed_ip;
}
