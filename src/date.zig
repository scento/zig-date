const std = @import("std");
const testing = std.testing;

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

    /// from_year converts a year number into a Letter.
    fn from_year(year: i32) Letter {
        const ymod: usize = @bitCast(u32, @mod(year, 400));
        return YearToLetter[ymod];
    }

    /// ndays returns the number of days in the year.
    fn ndays(self: Letter) u32 {
        const ltr = @enumToInt(self);
        return 366 - @as(u32, ltr >> 3);
    }

    /// doy_from_md returns the day of year from the month and day of month.
    fn doy_from_md(self: Letter, month: u32, day: u32) u32 {
        const ltr = @enumToInt(self);
        const leap_year = @as(u32, ltr >> 3);

        // lookup map for the ordinal date offset
        const index = ((month - 1) << 6 | (day - 1) << 1 | leap_year << 9);

        const IndexToOrdinalOffset = [766]u32{
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,
            31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  -1,  -1,  31,  31,  31,  31,  31,
            31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,
            59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,  60,  59,
            60,  59,  60,  59,  60,  59,  60,  -1,  -1,  -1,  -1,  -1,  -1,  59,  60,  59,  60,  59,  60,  90,  91,  90,  91,
            90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,
            91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,  90,  91,
            90,  91,  -1,  91,  90,  91,  -1,  -1,  90,  91,  90,  91,  90,  91,  90,  91,  120, 121, 120, 121, 120, 121, 120,
            121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121,
            120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 120, 121, -1,
            -1,  -1,  -1,  120, 121, 120, 121, 120, 121, 120, 121, 120, 121, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152,
            151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151,
            152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 151, 152, -1,  -1,  151, 152,
            151, 152, 151, 152, 151, 152, 151, 152, 151, 152, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181,
            182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182,
            181, 182, 181, 182, 181, 182, 181, 182, 181, 182, 181, 182, -1,  -1,  -1,  -1,  181, 182, 181, 182, 181, 182, 181,
            182, 181, 182, 181, 182, 181, 182, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213,
            212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212,
            213, 212, 213, 212, 213, 212, 213, 212, 213, -1,  -1,  212, 213, 212, 213, 212, 213, 212, 213, 212, 213, 212, 213,
            212, 213, 212, 213, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243,
            244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244,
            243, 244, 243, 244, -1,  -1,  243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243, 244, 243,
            244, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274,
            273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, -1,  -1,  -1,
            -1,  273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 273, 274, 304, 305,
            304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304,
            305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, -1,  -1,  304, 305, 304, 305,
            304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 304, 305, 334, 335, 334, 335, 334,
            335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335,
            334, 335, 334, 335, 334, 335, 334, 335, 334, 335, -1,  -1,  -1,  -1,  334, 335, 334, 335, 334, 335, 334, 335, 334,
            335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 334, 335, 0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,
        };

        return IndexToOrdinalOffset[index] + day;
    }

    // md_from_doy returns the month and day of month from the day of year.
    //fn md_from_doy(self: Letter, doy: u32) struct { u32, u32 } {}
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

test "unit:Letter:doy_from_md" {
    try testing.expectEqual(1, comptime Letter.from_year(2014).doy_from_md(1, 1));
    try testing.expectEqual(2, comptime Letter.from_year(2014).doy_from_md(1, 2));
    try testing.expectEqual(32, comptime Letter.from_year(2014).doy_from_md(2, 1));
}

/// ISO 8601 date consisting of the year, ordinal date and dominical letter.
const Date = packed struct {
    year: i19,
    doy: u9,
    letter: Letter,

    /// from_ymd makes a new Date from the calendar date (year, month and day).
    pub fn from_ymd(year: i19, month: u32, day: u32) DateError!Date {
        const letter = Letter.from_year(year);
        const doy = letter.doy_from_md(month, day);

        return Date{ year, doy, letter };
    }

    /// from_yo makes a new Date from the ordinal date (year and day of year).
    pub fn from_yo(year: i19, doy: u32) DateError!Date {
        const letter = Letter.from_year(year);
        return Date{ year, doy, letter };
    }
};
