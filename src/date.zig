const std = @import("std");
const testing = std.testing;

const DateError = error{
    InvalidArgument,
};

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
    pub inline fn number_from_monday(self: Weekday) u3 {
        return switch (self) {
            .Mon => 1,
            .Tue => 2,
            .Wed => 3,
            .Thu => 4,
            .Fri => 5,
            .Sat => 6,
            .Sun => 7,
        };
    }

    /// number_from_sunday returns a day-of-week number starting from Sunday = 1.
    pub inline fn number_from_sunday(self: Weekday) u3 {
        return switch (self) {
            .Mon => 2,
            .Tue => 3,
            .Wed => 4,
            .Thu => 5,
            .Fri => 6,
            .Sat => 7,
            .Sun => 1,
        };
    }

    /// num_days_from_monday returns a day-of-week number starting from Monday = 0.
    pub inline fn num_days_from_monday(self: Weekday) u3 {
        return switch (self) {
            .Mon => 0,
            .Tue => 1,
            .Wed => 2,
            .Thu => 3,
            .Fri => 4,
            .Sat => 5,
            .Sun => 6,
        };
    }

    /// num_days_from_sunday returns a day-of-week number starting from Sunday = 0.
    pub inline fn num_days_from_sunday(self: Weekday) u3 {
        return switch (self) {
            .Mon => 1,
            .Tue => 2,
            .Wed => 3,
            .Thu => 4,
            .Fri => 5,
            .Sat => 6,
            .Sun => 0,
        };
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

test "unit:Weekday:number_from_monday" {
    try testing.expectEqual(0, Weekday.Mon.num_days_from_monday());
    try testing.expectEqual(6, Weekday.Sun.num_days_from_monday());
}

test "unit:Weekday:number_from_sunday" {
    try testing.expectEqual(1, Weekday.Mon.num_days_from_sunday());
    try testing.expectEqual(0, Weekday.Sun.num_days_from_sunday());
}
