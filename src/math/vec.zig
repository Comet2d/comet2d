pub fn Vec2(comptime T: type) type {
    return struct {
        pub const zero: @This() = .{ .x = 0, .y = 0 };
        pub const one: @This() = .{ .x = 1, .y = 1 };

        x: T,
        y: T,

        pub fn add(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x + other.x,
                .y = self.y + other.y,
            };
        }

        pub fn subtract(self: @This(), other: @This()) @This() {
            return .{
                .x = self.x - other.x,
                .y = self.y - other.y,
            };
        }

        pub fn scale(self: @This(), factor: T) @This() {
            return .{
                .x = self.x * factor,
                .y = self.y * factor,
            };
        }

        pub fn normalised(self: @This()) @This() {
            return self.scale(1 / self.length());
        }

        pub fn length(self: @This()) f32 {
            switch (@typeInfo(T)) {
                .Int => |_| {
                    return @sqrt(self.x << 1 + self.y << 1);
                },
                .Float => |_| {
                    return @sqrt(self.x * self.x + self.y * self.y);
                },
                else => @compileError("Cannot take length of type"),
            }
        }

        pub fn round(self: @This(), Result: type) Vec2(Result) {
            return .{ .x = @round(self.x), .y = @round(self.y) };
        }

        pub fn floatFromInt(self: @This(), FloatType: type) Vec2(FloatType) {
            return .{ .x = @floatFromInt(self.x), .y = @floatFromInt(self.y) };
        }

        pub fn intFromFloat(self: @This(), IntType: type) Vec2(IntType) {
            return .{ .x = @intFromFloat(self.x), .y = @intFromFloat(self.y) };
        }

        pub fn distanceTo(self: *const @This(), other: *const @This()) T {
            return @sqrt(self.distanceSquaredTo(other));
        }

        pub fn distanceSquaredTo(self: *const @This(), other: *const @This()) T {
            const dx = self.x - other.x;
            const dy = self.y - other.y;
            return dx * dx + dy * dy;
        }
    };
}
