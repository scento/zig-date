const std = @import("std");
const testing = std.testing;

const DateError = error{
    InvalidArgument,
};

/// DominicalLetter classifies each year of the Gregorian calendar into
/// 10 classes: common and leap years starting with Monday through Sunday.
/// Each letter is encoded in four bits `abbb`, where `a` is `1` for the
/// common year and `bbb` is a non-zero `Weekday` mapping `Mon` to 7 of
/// the last day in the past year.
const DominicalLetter = enum(u4) {
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

    const YearToLetter = [400]DominicalLetter{
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

    /// from_year converts a year number into a DominicalLetter.
    pub fn from_year(year: i32) DominicalLetter {
        const ymod: usize = @bitCast(u32, @mod(year, 400));
        return YearToLetter[ymod];
    }

    /// ndays returns the number of days in the year.
    pub fn ndays(self: DominicalLetter) u32 {
        const common_year = @enumToInt(self);
        return 366 - @as(u32, common_year >> 3);
    }
};

test "unit:DominicalLetter:ndays" {
    try testing.expectEqual(365, comptime DominicalLetter.from_year(2014).ndays());
    try testing.expectEqual(366, comptime DominicalLetter.from_year(2012).ndays());
    try testing.expectEqual(366, comptime DominicalLetter.from_year(2000).ndays());
    try testing.expectEqual(365, comptime DominicalLetter.from_year(1900).ndays());
    try testing.expectEqual(366, comptime DominicalLetter.from_year(0).ndays());
    try testing.expectEqual(365, comptime DominicalLetter.from_year(-1).ndays());
    try testing.expectEqual(366, comptime DominicalLetter.from_year(-4).ndays());
    try testing.expectEqual(365, comptime DominicalLetter.from_year(-99).ndays());
    try testing.expectEqual(365, comptime DominicalLetter.from_year(-100).ndays());
    try testing.expectEqual(365, comptime DominicalLetter.from_year(-399).ndays());
    try testing.expectEqual(366, comptime DominicalLetter.from_year(-400).ndays());
}
