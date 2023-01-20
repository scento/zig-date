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
        const leap_year: u32 = @as(u32, ltr >> 3);

        // lookup map for the ordinal date offset
        const index = (@as(u32, leap_year) << 9 | (month - 1) << 5 | (day - 1));

        const IndexToOrdinalOffset = [896]u32{
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   31,  31,  31,  31,  31,  31,  31,
            31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,
            31,  31,  31,  31,  31,  31,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,  59,
            59,  59,  59,  59,  59,  59,  59,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,
            90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,  90,
            120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120,
            120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 120, 151, 151, 151, 151, 151, 151, 151,
            151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151, 151,
            151, 151, 151, 151, 151, 151, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181,
            181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 181, 212,
            212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212,
            212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 243, 243, 243, 243, 243, 243, 243, 243,
            243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243, 243,
            243, 243, 243, 243, 243, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273,
            273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 273, 304, 304,
            304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304,
            304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 304, 334, 334, 334, 334, 334, 334, 334, 334, 334,
            334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334, 334,
            334, 334, 334, 334, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
            0,   0,   0,   0,   0,   31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,
            31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  31,  60,  60,
            60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  60,  91,
            91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,
            91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  91,  121, 121, 121, 121, 121, 121, 121, 121,
            121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121, 121,
            121, 121, 121, 121, 121, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152,
            152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 152, 182, 182,
            182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182,
            182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 182, 213, 213, 213, 213, 213, 213, 213, 213, 213,
            213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213,
            213, 213, 213, 213, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244,
            244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 244, 274, 274, 274,
            274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 274,
            274, 274, 274, 274, 274, 274, 274, 274, 274, 274, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305,
            305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305, 305,
            305, 305, 305, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335,
            335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 335, 0,   0,   0,   0,
            0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
        };

        return IndexToOrdinalOffset[index] + day;
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

test "unit:Letter:doy_from_md" {
    try testing.expectEqual(1, comptime Letter.from_year(2014).doy_from_md(1, 1));
    try testing.expectEqual(2, comptime Letter.from_year(2014).doy_from_md(1, 2));
    try testing.expectEqual(32, comptime Letter.from_year(2014).doy_from_md(2, 1));
}
