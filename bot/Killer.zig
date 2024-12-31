const std = @import("std");

const helpers = @import("helpers.zig");
const linux = std.os.linux;

const Killer = @This();

allocator: std.mem.Allocator,

pub fn init(allocator: std.mem.Allocator) Killer {
    return .{
        .allocator = allocator,
    };
}

pub fn killByPort(self: Killer, kill_port: u16) !void {
    const file = try std.fs.cwd().openFile("/proc/net/tcp", .{});
    defer file.close();

    const data = try file.readToEndAlloc(self.allocator, 1 << 20);
    defer self.allocator.free(data);

    var lines = std.mem.splitScalar(u8, data, '\n');

    _ = lines.next(); // skip first line

    while (lines.next()) |line| {
        if (line.len < 10) continue;

        var parts = std.mem.splitScalar(u8, line, ' ');

        _ = parts.next();

        while (parts.next()) |part| {
            if (part.len < 10) continue;

            var port_it = std.mem.splitScalar(u8, line[6..19], ':');
            _ = port_it.next(); // skip first part

            const port = port_it.next().?;

            const port_p = helpers.parseHexToU16(port) catch |err| {
                std.debug.print("err {s}", .{@errorName(err)});
                continue;
            };

            if (port_p != kill_port) continue;

            var inode_it = std.mem.splitScalar(u8, line[90..], ' ');
            _ = inode_it.next(); // skip first part

            const inode = inode_it.next().?;

            const pid = self.getPidByInode(inode) catch |err| {
                std.debug.print("err {s}", .{@errorName(err)});
                continue;
            };
            helpers.kill(pid, 9) catch |err| {
                std.debug.print("err {s}", .{@errorName(err)});
                continue;
            };
            break; // killed
        }
    }
}

fn getPidByInode(self: Killer, inode: []const u8) !i32 {
    var proc = try std.fs.cwd().openDir("/proc", .{ .iterate = true });
    defer proc.close();

    var iter = proc.iterate();

    while (try iter.next()) |entry| {
        if (entry.name[0] < '0' or entry.name[0] > '9') continue;

        const pid = try std.fmt.parseInt(i32, entry.name, 10);

        const path = std.mem.concat(self.allocator, u8, &[_][]const u8{ "/proc/", entry.name, "/fd" }) catch unreachable;

        var fd_path = try std.fs.cwd().openDir(path, .{ .iterate = true });
        defer fd_path.close();

        var fd_iter = fd_path.iterate();
        while (try fd_iter.next()) |fd_entry| { // nigga
            const pathname = std.mem.concat(self.allocator, u8, &[_][]const u8{ path, "/", fd_entry.name }) catch unreachable;

            var link_path: [std.fs.max_path_bytes]u8 = undefined;

            _ = try std.fs.realpath(pathname, &link_path);

            const s = std.mem.concat(self.allocator, u8, &[_][]const u8{ "socket:[", inode, "]" }) catch unreachable;

            if (std.mem.containsAtLeast(u8, &link_path, 1, s)) {
                return pid;
            }
        }
    }

    return error.NoPidFound;
}

/// rebind ports
pub fn rebind(self: Killer, port: u16) !void {
    _ = self; // autofix
    const fd = linux.socket(linux.AF.INET, linux.SOCK.STREAM, 0);
    // defer _ = linux.close(@intCast(fd));

    const sockaddr = std.net.Address{ .in = std.net.Ip4Address.init([4]u8{ 127, 0, 0, 1 }, port) };

    helpers.bind(@intCast(fd), &sockaddr.any, sockaddr.getOsSockLen()) catch |err| {
        std.debug.print("cant bind to port {d}: {s}\n", .{ port, @errorName(err) });
        return;
    };

    helpers.listen(@intCast(fd), 1) catch |err| {
        std.debug.print("cant listen on port {d}: {s}\n", .{ port, @errorName(err) });
        return;
    };
}
