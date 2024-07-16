const std = @import("std");

pub fn Vec2(comptime T: type) type {
    return VecOrElseArray(T, 2);
}

pub fn Vec3(comptime T: type) type {
    return VecOrElseArray(T, 3);
}

pub fn Vec4(comptime T: type) type {
    return VecOrElseArray(T, 4);
}

pub fn squareMagnitude(vec: anytype) VecElementInner(@TypeOf(vec)) {
    var mag = @as(VecElementInner(@TypeOf(vec)), 0);

    inline for (0..vecLength(@TypeOf(vec))) |idx| {
        const component = vec[idx];
        mag += component * component;
    }

    return mag;
}

pub fn magnitude(vec: anytype) VecElementInner(@TypeOf(vec)) {
    return @sqrt(squareMagnitude(vec));
}

pub fn normalise(vec: anytype) @TypeOf(vec) {
    const mag = magnitude(vec);
    return vec / @as(@TypeOf(vec), @splat(mag));
}

pub fn distanceSquaredBetween(a: anytype, b: @TypeOf(a)) VecElementInner(@TypeOf(a)) {
    const diff = a - b;
    return squareMagnitude(diff);
}

pub fn distanceBetween(a: anytype, b: @TypeOf(a)) VecElementInner(@TypeOf(a)) {
    return @sqrt(distanceSquaredBetween(a, b));
}

fn VecOrElseArray(comptime T: type, comptime len: usize) type {
    switch (@typeInfo(T)) {
        .Float, .Int, .Bool => return @Vector(len, T),
        else => return [len]T,
    }
}

fn VecElementInner(vec_type: type) type {
    switch (@typeInfo(vec_type)) {
        .Vector => |vector_type| {
            return vector_type.child;
        },
        else => @compileError("Can't apply vector operation to non-vector type"),
    }
}

fn vecLength(vec_type: type) comptime_int {
    switch (@typeInfo(vec_type)) {
        .Vector => |vector_type| {
            return vector_type.len;
        },
        else => @compileError("Can't apply vector operation to non-vector type"),
    }
}

test "vec operations" {
    const expect = std.testing.expect;

    try expect(Vec2(i32) == @Vector(2, i32));
    try expect(Vec2(*i32) == [2]*i32);

    const vec_1 = @as(Vec2(f32), .{ 0, 2 });
    const vec_2 = @as(Vec2(f32), .{ 3, 4 });

    try expect(magnitude(vec_1) == 2);
    try expect(squareMagnitude(vec_1) == 4);

    try expect(magnitude(vec_2) == 5);
    try expect(squareMagnitude(vec_2) == 25);

    try expect(std.meta.eql(normalise(vec_1), @as(Vec2(f32), .{ 0, 1 })));
    try expect(std.meta.eql(normalise(vec_2), @as(Vec2(f32), .{ 0.6, 0.8 })));

    // Test Vec3
    const vec3_1 = @as(Vec3(f32), .{ 1, 2, 3 });
    const vec3_2 = @as(Vec3(f32), .{ 4, 5, 6 });

    try expect(magnitude(vec3_1) == @sqrt(@as(f32, 14)));
    try expect(squareMagnitude(vec3_1) == 14);

    try expect(magnitude(vec3_2) == @sqrt(@as(f32, 77)));
    try expect(squareMagnitude(vec3_2) == 77);

    try expect(std.meta.eql(normalise(vec3_1), @as(Vec3(f32), .{ 1 / @sqrt(@as(f32, 14)), 2 / @sqrt(@as(f32, 14)), 3 / @sqrt(@as(f32, 14)) })));
    try expect(std.meta.eql(normalise(vec3_2), @as(Vec3(f32), .{ 4 / @sqrt(@as(f32, 77)), 5 / @sqrt(@as(f32, 77)), 6 / @sqrt(@as(f32, 77)) })));

    // Test Vec4
    const vec4_1 = @as(Vec4(f32), .{ 1, 2, 3, 4 });
    const vec4_2 = @as(Vec4(f32), .{ 5, 6, 7, 8 });

    try expect(magnitude(vec4_1) == @sqrt(@as(f32, 30)));
    try expect(squareMagnitude(vec4_1) == 30);

    try expect(magnitude(vec4_2) == @sqrt(@as(f32, 174)));
    try expect(squareMagnitude(vec4_2) == 174);

    try expect(std.meta.eql(normalise(vec4_1), @as(Vec4(f32), .{ 1 / @sqrt(@as(f32, 30)), 2 / @sqrt(@as(f32, 30)), 3 / @sqrt(@as(f32, 30)), 4 / @sqrt(@as(f32, 30)) })));
    try expect(std.meta.eql(normalise(vec4_2), @as(Vec4(f32), .{ 5 / @sqrt(@as(f32, 174)), 6 / @sqrt(@as(f32, 174)), 7 / @sqrt(@as(f32, 174)), 8 / @sqrt(@as(f32, 174)) })));

    // Test distanceBetween
    const vec_3 = @as(Vec2(f32), .{ 1, 1 });
    const vec_4 = @as(Vec2(f32), .{ 4, 5 });

    try expect(distanceBetween(vec_3, vec_4) == 5);

    const vec3_3 = @as(Vec3(f32), .{ 1, 1, 1 });
    const vec3_4 = @as(Vec3(f32), .{ 4, 5, 6 });

    try expect(distanceBetween(vec3_3, vec3_4) == @sqrt(@as(f32, 50)));

    const vec4_3 = @as(Vec4(f32), .{ 1, 1, 1, 1 });
    const vec4_4 = @as(Vec4(f32), .{ 5, 6, 7, 8 });

    try expect(distanceBetween(vec4_3, vec4_4) == @sqrt(@as(f32, 126)));
}
