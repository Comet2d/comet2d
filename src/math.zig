const std = @import("std");

pub usingnamespace @import("math/vec.zig");

pub fn sign(comptime T: type, value: T) i8 {
    if (value > 0)
        return 1;

    if (value < 0)
        return -1;

    return 0;
}

pub fn clamp(comptime T: type, value: T, minValue: T, maxValue: T) error{WrongValueOrder}!T {
    if (minValue > maxValue) {
        return error.WrongValueOrder;
    }

    if (value > maxValue) {
        return maxValue;
    }

    if (value < minValue) {
        return minValue;
    }

    return value;
}

pub fn min(comptime T: type, a: T, b: T) T {
    if (a < b) {
        return a;
    }

    return b;
}

pub fn max(comptime T: type, a: T, b: T) T {
    if (a > b) {
        return a;
    }

    return b;
}

pub fn moveTowards(comptime T: type, value: T, target: T, amount: T) T {
    const difference = target - value;

    if (@abs(difference) <= amount) {
        return target;
    }

    return value + @as(f32, @floatFromInt(sign(f32, difference))) * amount;
}

pub fn lerp(comptime T: type, value: T, target: T, ratio: T) T {
    return value + (target - value) * ratio;
}

test "mathematical function tests" {
    const expect = std.testing.expect;

    try expect(sign(i32, 0) == @as(i8, 0));
    try expect(sign(f32, 0) == @as(i8, 0));

    try expect(sign(i32, 1) == @as(i8, 1));
    try expect(sign(i32, 50) == @as(i8, 1));

    try expect(sign(f32, 1) == @as(i8, 1));
    try expect(sign(f32, 50) == @as(i8, 1));

    try expect(sign(i32, -1) == @as(i8, -1));
    try expect(sign(i32, -50) == @as(i8, -1));

    try expect(sign(f32, -1) == @as(i8, -1));
    try expect(sign(f32, -50) == @as(i8, -1));

    try expect(clamp(i32, 5, 0, 10) catch unreachable == 5);
    try expect(clamp(i32, -5, 0, 10) catch unreachable == 0);
    try expect(clamp(i32, 15, 0, 10) catch unreachable == 10);

    try expect(clamp(i32, 0, 5, 0) == error.WrongValueOrder);
}
