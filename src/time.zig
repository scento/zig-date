const std = @import("std");
const testing = std.testing;
const math = std.math;

pub const TimeError = error{
    InvalidArgument,
};

/// ISO 8601 time.
pub const Time = packed struct {
    base: u32,
    frac: u32,

    /// from_hms makes a new Time from hour, minute and second.
    /// This function does not allow for leap seconds.
    pub fn from_hms(hours: u32, mins: u32, secs: u32) TimeError!Time {
        return Time.from_hms_nano(hours, mins, secs, 0);
    }

    /// from_hms_milli makes a new Time from hour, minute, second and millisecond.
    /// The millisecond part can exceed 1000 to represent a leap second.
    pub fn from_hms_milli(hours: u32, mins: u32, secs: u32, millis: u32) TimeError!Time {
        const nanos = math.mul(u32, millis, 1000000) catch {
            return TimeError.InvalidArgument;
        };
        return Time.from_hms_nano(hours, mins, secs, nanos);
    }

    /// from_hms_micro makes a new Time from hour, minute, second and microsecond.
    /// The microsecond part can exceed 1,000,000 to represent a leap second.
    pub fn from_hms_micro(hours: u32, mins: u32, secs: u32, micros: u32) TimeError!Time {
        const nanos = math.mul(u32, micros, 1000) catch {
            return TimeError.InvalidArgument;
        };
        return Time.from_hms_nano(hours, mins, secs, nanos);
    }

    /// from_hms_nano makes a new Time from hour, minute, second and nanosecond.
    /// The nanosecond part can exceed 1,000,000,000 to represent a leap second.
    pub fn from_hms_nano(hours: u32, mins: u32, secs: u32, nanos: u32) TimeError!Time {
        if (hours >= 24 or mins >= 60 or secs >= 60 or nanos >= 2000000000) {
            return TimeError.InvalidArgument;
        }
        const total = hours * 3600 + mins * 60 + secs;
        return Time{ .base = total, .frac = nanos };
    }

    /// from_num_seconds_from_midnight makes a new Time from the number of seconds
    /// since midnight and nanosecond. The nanosecond part can exceed 1,000,000,000
    /// to represent a leap second.
    pub fn from_num_seconds_from_midnight(secs: u32, nanos: u32) TimeError!Time {
        if (secs >= 86400 or nanos >= 2000000000) {
            return TimeError.InvalidArgument;
        }
        return Time{ .base = secs, .frac = nanos };
    }

    /// hour returns the hour number from 0 to 23.
    pub fn hour(self: *const Time) u32 {
        return (self.base / 60) / 60;
    }

    /// minute returns the minute number from 0 to 59.
    pub fn minute(self: *const Time) u32 {
        return (self.base / 60) % 60;
    }

    /// second returns the second number from 0 to 59.
    /// It never returns 60, even in case of a leap second.
    pub fn second(self: *const Time) u32 {
        return self.base % 60;
    }

    /// nanosecond returns the number of nanoseconds since the whole non-leap second.
    /// The range from 1,000,000,000 to 1,999,999,999 represents the leap second.
    pub fn nanosecond(self: *const Time) u32 {
        return self.frac;
    }

    /// num_seconds_from_midnight returns the number of seconds since midnight.
    pub fn num_seconds_from_midnight(self: *const Time) u32 {
        return self.base;
    }
};

test "unit:Time:from_hms" {
    try testing.expectEqual(Time{ .base = 0, .frac = 0 }, try Time.from_hms(0, 0, 0));
    try testing.expectEqual(Time{ .base = 86399, .frac = 0 }, try Time.from_hms(23, 59, 59));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms(24, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms(23, 60, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms(23, 59, 60));
}

test "unit:Time:from_hms_milli" {
    const expectOne = Time{ .base = 0, .frac = 0 };
    const expectTwo = Time{ .base = 86399, .frac = 999000000 };
    const expectThree = Time{ .base = 86399, .frac = 1999000000 };
    try testing.expectEqual(expectOne, try Time.from_hms_milli(0, 0, 0, 0));
    try testing.expectEqual(expectTwo, try Time.from_hms_milli(23, 59, 59, 999));
    try testing.expectEqual(expectThree, try Time.from_hms_milli(23, 59, 59, 1999));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_milli(24, 0, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_milli(23, 60, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_milli(23, 59, 60, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_milli(23, 59, 59, 2000));
    const inEight = Time.from_hms_milli(0, 0, 0, math.maxInt(u32));
    try testing.expectError(TimeError.InvalidArgument, inEight);
    const inNine = Time.from_hms_milli(0, 0, 0, 5000);
    try testing.expectError(TimeError.InvalidArgument, inNine);
}

test "unit:Time:from_hms_micro" {
    const expectOne = Time{ .base = 0, .frac = 0 };
    const expectTwo = Time{ .base = 86399, .frac = 999999000 };
    const expectThree = Time{ .base = 86399, .frac = 1999999000 };
    try testing.expectEqual(expectOne, try Time.from_hms_micro(0, 0, 0, 0));
    try testing.expectEqual(expectTwo, try Time.from_hms_micro(23, 59, 59, 999999));
    try testing.expectEqual(expectThree, try Time.from_hms_micro(23, 59, 59, 1999999));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_micro(24, 0, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_micro(23, 60, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_micro(23, 59, 60, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_micro(23, 59, 59, 2000000));
    const inEight = Time.from_hms_micro(0, 0, 0, math.maxInt(u32));
    try testing.expectError(TimeError.InvalidArgument, inEight);
    const inNine = Time.from_hms_micro(3, 5, 7, 5000000);
    try testing.expectError(TimeError.InvalidArgument, inNine);
}

test "unit:Time:from_hms_nano" {
    const expectOne = Time{ .base = 0, .frac = 0 };
    const expectTwo = Time{ .base = 86399, .frac = 999999999 };
    const expectThree = Time{ .base = 86399, .frac = 1999999999 };
    try testing.expectEqual(expectOne, try Time.from_hms_nano(0, 0, 0, 0));
    try testing.expectEqual(expectTwo, try Time.from_hms_nano(23, 59, 59, 999999999));
    try testing.expectEqual(expectThree, try Time.from_hms_nano(23, 59, 59, 1999999999));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_nano(24, 0, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_nano(23, 60, 0, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_nano(23, 59, 60, 0));
    try testing.expectError(TimeError.InvalidArgument, Time.from_hms_nano(23, 59, 59, 2000000000));
    const inEight = Time.from_hms_nano(0, 0, 0, math.maxInt(u32));
    try testing.expectError(TimeError.InvalidArgument, inEight);
}

test "unit:Time:from_num_seconds_from_midnight" {
    const expectOne = Time{ .base = 0, .frac = 0 };
    const expectTwo = Time{ .base = 86399, .frac = 999999999 };
    const expectThree = Time{ .base = 86399, .frac = 1999999999 };
    try testing.expectEqual(expectOne, try Time.from_num_seconds_from_midnight(0, 0));
    try testing.expectEqual(expectTwo, try Time.from_num_seconds_from_midnight(86399, 999999999));
    const inThree = try Time.from_num_seconds_from_midnight(86399, 1999999999);
    try testing.expectEqual(expectThree, inThree);
    const inFour = Time.from_num_seconds_from_midnight(86400, 0);
    try testing.expectError(TimeError.InvalidArgument, inFour);
    const inFive = Time.from_num_seconds_from_midnight(86399, 2000000000);
    try testing.expectError(TimeError.InvalidArgument, inFive);
}

test "unit:Time:hour" {
    const baseOne = Time{ .base = 0, .frac = 0 };
    const baseTwo = Time{ .base = 86399, .frac = 999999999 };
    try testing.expectEqual(baseOne.hour(), 0);
    try testing.expectEqual(baseTwo.hour(), 23);
}

test "unit:Time:minute" {
    const baseOne = Time{ .base = 0, .frac = 0 };
    const baseTwo = Time{ .base = 86399, .frac = 999999999 };
    try testing.expectEqual(baseOne.minute(), 0);
    try testing.expectEqual(baseTwo.minute(), 59);
}

test "unit:Time:second" {
    const baseOne = Time{ .base = 0, .frac = 0 };
    const baseTwo = Time{ .base = 86399, .frac = 999999999 };
    try testing.expectEqual(baseOne.second(), 0);
    try testing.expectEqual(baseTwo.second(), 59);
}

test "unit:Time:nanosecond" {
    const baseOne = Time{ .base = 0, .frac = 0 };
    const baseTwo = Time{ .base = 86399, .frac = 999999999 };
    try testing.expectEqual(baseOne.nanosecond(), 0);
    try testing.expectEqual(baseTwo.nanosecond(), 999999999);
}

test "unit:Time:num_seconds_from_midnight" {
    const baseOne = Time{ .base = 0, .frac = 0 };
    const baseTwo = Time{ .base = 86399, .frac = 999999999 };
    try testing.expectEqual(baseOne.num_seconds_from_midnight(), 0);
    try testing.expectEqual(baseTwo.num_seconds_from_midnight(), 86399);
}
