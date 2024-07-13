pub fn Vec2(comptime T: type) type {
    switch (@typeInfo(T)) {
        .Float, .Int, .Bool => return @Vector(2, T),
        else => return [2]T,
    }
}
