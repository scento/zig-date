const std = @import("std");
const testing = std.testing;

/// The day of week.
const Weekday = enum(u3) {
    Mon = 7,
    Tue = 1,
    Wed = 2,
    Thu = 3,
    Fri = 4,
    Sat = 5,
    Sun = 6,

    /// succ returns the next day in the week.
    pub inline fn succ(self: Weekday) Weekday {
        return switch (self) {
            .Mon => .Tue,
            .Tue => .Wed,
            .Wed => .Thu,
            .Thu => .Fri,
            .Fri => .Sat,
            .Sat => .Sun,
            .Sun => .Mon,
        };
    }

    /// pred returns the previous day in the week.
    pub inline fn pred(self: Weekday) Weekday {
        return switch (self) {
            .Mon => .Sun,
            .Tue => .Mon,
            .Wed => .Tue,
            .Thu => .Wed,
            .Fri => .Thu,
            .Sat => .Fri,
            .Sun => .Sat,
        };
    }

    /// number_from_monday returns a day-of-week number starting from Monday = 1.
    /// (ISO 8601 weekday number)
    pub inline fn number_from_monday(self: Weekday) u8 {
        const v = [7]u8{ 2, 3, 4, 5, 6, 7, 1 };
        return v[@enumToInt(self) - 1];
    }

    /// number_from_sunday returns a day-of-week number starting from Sunday = 1.
    pub inline fn number_from_sunday(self: Weekday) u8 {
        const v = [7]u8{ 3, 4, 5, 6, 7, 1, 2 };
        return v[@enumToInt(self) - 1];
    }

    /// num_days_from_monday a day-of-week number starting from Monday = 0.
    pub inline fn num_days_from_monday(self: Weekday) u8 {
        const v = [7]u8{ 1, 2, 3, 4, 5, 6, 0 };
        return v[@enumToInt(self) - 1];
    }

    /// num_days_from_sunday a day-of-week number starting from Sunday = 0.
    pub inline fn num_days_from_sunday(self: Weekday) u8 {
        const v = [7]u8{ 2, 3, 4, 5, 6, 0, 1 };
        return v[@enumToInt(self) - 1];
    }
};

test "unit:Weekday:succ" {
    try testing.expectEqual(Weekday.Tue, Weekday.Mon.succ());
    try testing.expectEqual(Weekday.Mon, Weekday.Sun.succ());
}

test "unit:Weekday:pred" {
    try testing.expectEqual(Weekday.Sat, Weekday.Sun.pred());
    try testing.expectEqual(Weekday.Sun, Weekday.Mon.pred());
}

test "unit:Weekday:number_from_monday" {
    try testing.expectEqual(1, Weekday.Mon.number_from_monday());
    try testing.expectEqual(7, Weekday.Sun.number_from_monday());
}

test "unit:Weekday:number_from_sunday" {
    try testing.expectEqual(2, Weekday.Mon.number_from_sunday());
    try testing.expectEqual(1, Weekday.Sun.number_from_sunday());
}

test "unit:Weekday:num_days_from_monday" {
    try testing.expectEqual(0, Weekday.Mon.num_days_from_monday());
    try testing.expectEqual(6, Weekday.Sun.num_days_from_monday());
}

test "unit:Weekday:num_days_from_sunday" {
    try testing.expectEqual(1, Weekday.Mon.num_days_from_sunday());
    try testing.expectEqual(0, Weekday.Sun.num_days_from_sunday());
}
