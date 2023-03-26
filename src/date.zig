const builtin = @import("builtin");
const std = @import("std");
const testing = std.testing;

// DateError enumerates possible Date-related errors.
const DateError = error{
    InvalidArgument,
};

/// (Dominical)Letter classifies each year of the Gregorian calendar into
/// 10 classes: common and leap years starting with Monday through Sunday.
/// Each letter is encoded in four bits `abbb`, where `a` is `1` for the
/// common year and `bbb` is a non-zero `Weekday` mapping `Mon` to 7 of
/// the last day in the past year.
const Letter = enum(u4) {
    A = 0o15,
    AG = 0o05,
    B = 0o14,
    BA = 0o04,
    C = 0o13,
    CB = 0o03,
    D = 0o12,
    DC = 0o02,
    E = 0o11,
    ED = 0o01,
    F = 0o17,
    FE = 0o07,
    G = 0o16,
    GF = 0o06,

    /// YearToLetter is the 400-years repeating pattern of dominical letters.
    const YearToLetter = [400]Letter{
        .BA, .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,
        .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,
        .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB,
        .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,  .F,  .E,
        .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,  .G,
        .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,  .F,  .E,  .DC, .B,
        .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,  .C,  .B,  .A,  .G,  .FE,
        .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,
        .GF, .E,  .D,  .C,  .BA, .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,
        .B,  .AG, .F,  .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,
        .D,  .C,  .BA, .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG,
        .F,  .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,
        .BA, .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,
        .D,  .CB, .A,  .G,  .F,  .E,  .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,
        .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,  .F,  .E,  .DC,
        .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,  .G,  .F,
        .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,  .F,  .E,  .DC, .B,  .A,
        .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,
        .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE,
        .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,
        .G,  .F,  .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,
        .C,  .BA, .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,
        .E,  .D,  .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA,
        .G,  .F,  .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,
        .CB, .A,  .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,  .BA, .G,  .F,
        .E,  .DC, .B,  .A,  .G,  .FE, .D,  .C,  .B,  .AG, .F,  .E,  .D,  .CB, .A,
        .G,  .F,  .ED, .C,  .B,  .A,  .GF, .E,  .D,  .C,
    };

    const MdlToOl = [_]u8{
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 64,  64,  64,  64,  64,  64,  64,  64,  64,
        64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,
        64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,
        64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,  64,
        64,  64,  64,  64,  64,  64,  64,  64,  255, 255, 66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,  66,
        66,  66,  66,  66,  66,  66,  66,  255, 255, 255, 255, 255, 255, 255, 72,
        74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,
        72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,
        74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,
        72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,  74,  72,
        74,  255, 255, 74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,
        74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,
        76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,
        74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,  76,  74,
        76,  74,  76,  255, 255, 255, 255, 78,  80,  78,  80,  78,  80,  78,  80,
        78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,
        80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,
        78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,  80,  78,
        80,  78,  80,  78,  80,  78,  80,  78,  80,  255, 255, 80,  82,  80,  82,
        80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,
        82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,
        80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  80,
        82,  80,  82,  80,  82,  80,  82,  80,  82,  80,  82,  255, 255, 255, 255,
        84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,
        86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,
        84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,
        86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,  84,  86,
        84,  86,  255, 255, 86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,
        88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,
        86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,
        88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,  86,  88,
        86,  88,  86,  88,  86,  88,  255, 255, 88,  90,  88,  90,  88,  90,  88,
        90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,
        88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,
        90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,  88,  90,
        88,  90,  88,  90,  88,  90,  88,  90,  255, 255, 255, 255, 92,  94,  92,
        94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,
        92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,
        94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,
        92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  92,  94,  255,
        255, 94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,
        94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,
        96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,
        94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,  96,  94,
        96,  255, 255, 255, 255, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100,
        98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,
        100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100,
        98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,  100, 98,
        100, 98,  100, 98,  100, 98,  100,
    };

    /// from_year converts a year number into a Letter.
    fn from_year(year: i32) Letter {
        const ymod: usize = @bitCast(u32, @mod(year, 400));
        return YearToLetter[ymod];
    }

    /// ndays returns the number of days in the year.
    fn ndays(self: Letter) u32 {
        comptime if (builtin.target.cpu.arch.endian() != .Little) {
            @compileError("Date bit arithmetic requires little-endian architecture");
        };
        const ltr = @enumToInt(self);
        return 366 - @as(u32, ltr >> 3);
    }

    /// dm_to_doy translates day and month to the day of year.
    fn dm_to_doy(self: Letter, day: u5, month: u4) DateError!u9 {
        comptime if (builtin.target.cpu.arch.endian() != .Little) {
            @compileError("Date bit arithmetic requires little-endian architecture");
        };
        const ltr = @enumToInt(self);
        const leap = @as(u32, ltr >> 3);
        const index = (@as(u32, month) << 6) | (@as(u32, day) << 1) | (@as(u32, leap));

        if (index > MdlToOl.len) {
            return DateError.InvalidArgument;
        }

        const doy = @truncate(u9, (index -% (@as(u32, MdlToOl[index]) & 0x3ff)) >> 1);
        if (doy > 365) {
            return DateError.InvalidArgument;
        }

        return doy;
    }
};

test "unit:Letter:ndays" {
    try testing.expectEqual(365, comptime Letter.from_year(2014).ndays());
    try testing.expectEqual(366, comptime Letter.from_year(2012).ndays());
    try testing.expectEqual(366, comptime Letter.from_year(2000).ndays());
    try testing.expectEqual(365, comptime Letter.from_year(1900).ndays());
    try testing.expectEqual(366, comptime Letter.from_year(0).ndays());
    try testing.expectEqual(365, comptime Letter.from_year(-1).ndays());
    try testing.expectEqual(366, comptime Letter.from_year(-4).ndays());
    try testing.expectEqual(365, comptime Letter.from_year(-99).ndays());
    try testing.expectEqual(365, comptime Letter.from_year(-100).ndays());
    try testing.expectEqual(365, comptime Letter.from_year(-399).ndays());
    try testing.expectEqual(366, comptime Letter.from_year(-400).ndays());
}

test "unit:Letter:dm_to_doy" {
    try testing.expectEqual(61, comptime (try Letter.from_year(2018).dm_to_doy(2, 3)));
    try testing.expectEqual(1, comptime (try Letter.from_year(2023).dm_to_doy(1, 1)));
    try testing.expectEqual(2, comptime (try Letter.from_year(2023).dm_to_doy(2, 1)));
    try testing.expectEqual(45, comptime (try Letter.from_year(2015).dm_to_doy(14, 2)));
    try testing.expectError(DateError.InvalidArgument, Letter.from_year(2012).dm_to_doy(0, 1));
    try testing.expectError(DateError.InvalidArgument, Letter.from_year(2015).dm_to_doy(29, 2));
}

/// ISO 8601 date consisting of year, ordinal date and domicial letter.
pub const Date = packed struct {
    year: i19,
    doy: u9,
    letter: Letter,

    /// from_yo makes a new Date from the ordinal date (year and day of year).
    pub fn from_yo(year: i19, doy: u9) DateError!Date {
        const letter = Letter.from_year(year);
        if (doy < 1 or doy > letter.ndays()) {
            return DateError.InvalidArgument;
        }

        return .{ .year = year, .doy = doy, .letter = letter };
    }

    /// from_ymd makes a new Date from the calendar date (year, month and day).
    pub fn from_ymd(year: i19, month: u4, day: u5) DateError!Date {
        const letter = Letter.from_year(year);
        const doy = letter.dm_to_doy(day, month) catch |err| return err;

        return .{ .year = year, .doy = doy, .letter = letter };
    }
};

test "unit:Date:from_yo" {
    try testing.expectEqual(Letter.D, comptime (try Date.from_yo(2015, 100)).letter);
    try testing.expectError(DateError.InvalidArgument, Date.from_yo(2015, 0));
    try testing.expectEqual(2015, comptime (try Date.from_yo(2015, 365)).year);
    try testing.expectError(DateError.InvalidArgument, Date.from_yo(2015, 366));
    try testing.expectEqual(366, comptime (try Date.from_yo(-4, 366)).doy);
}

test "unit:Date:from_ymd" {
    try testing.expectEqual(61, comptime (try Date.from_ymd(2018, 3, 2)).doy);
    try testing.expectEqual(45, comptime (try Date.from_ymd(2015, 2, 14)).doy);
    try testing.expectError(DateError.InvalidArgument, Date.from_ymd(2012, 0, 3));
    try testing.expectError(DateError.InvalidArgument, Date.from_ymd(2015, 2, 29));
    try testing.expectEqual(60, comptime (try Date.from_ymd(-4, 2, 29)).doy);
}
