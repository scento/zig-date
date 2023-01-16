const std = @import("std");
const testing = std.testing;

const Time = @import("time.zig").Time;
const Date = @import("date.zig").Date;

/// ISO 8601 combined date and time.
const DateTime = struct {
    date: Date,
    time: Time,
};

test {
    _ = @import("time.zig");
    _ = @import("date.zig");
}
