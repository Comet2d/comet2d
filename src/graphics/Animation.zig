const std = @import("std");
const cmt = @import("comet");

start_frame: u32,
end_frame: u32,
frames_per_second: f32,
seconds_per_frame: f32,

pub fn parse(allocator: *const std.mem.Allocator, total_frames: u32, format: []const u8) error{ InvalidFormat, InvalidNumberFormat }!std.ArrayList(cmt.graphics.Animation) {
    var list = std.ArrayList(cmt.graphics.Animation).init(allocator.*);

    var animation_parts = std.mem.splitScalar(u8, format, '/');

    while (animation_parts.next()) |animation_part| {
        if (animation_part.len == 0) continue;

        const colon_index = std.mem.indexOf(u8, animation_part, ":");
        if (colon_index == null) {
            return error.InvalidFormat;
        }

        const frame_range = animation_part[0..colon_index.?];
        const frames_per_second_str = animation_part[colon_index.? + 1 ..];

        const dotdot_index = std.mem.indexOf(u8, frame_range, "..");
        if (dotdot_index == null) {
            return error.InvalidFormat;
        }

        const start_frame_str = frame_range[0..dotdot_index.?];
        const end_frame_str = frame_range[dotdot_index.? + 2 ..];

        var start_frame: u32 = 0;
        var end_frame: u32 = total_frames;

        if (start_frame_str.len > 0) {
            start_frame = std.fmt.parseInt(u32, start_frame_str, 10) catch return error.InvalidNumberFormat;
        }

        if (end_frame_str.len > 0) {
            end_frame = std.fmt.parseInt(u32, end_frame_str, 10) catch return error.InvalidNumberFormat;
        }

        const frames_per_second = std.fmt.parseFloat(f32, frames_per_second_str) catch return error.InvalidNumberFormat;

        const animation = cmt.graphics.Animation.init(start_frame, end_frame, frames_per_second);
        list.append(animation) catch unreachable;
    }

    return list;
}

pub fn init(start_frame: u32, end_frame: u32, frames_per_second: f32) cmt.graphics.Animation {
    return .{ .start_frame = start_frame, .end_frame = end_frame, .frames_per_second = frames_per_second, .seconds_per_frame = 1 / frames_per_second };
}

test "animation parsing" {
    const animations = try cmt.graphics.Animation.parse(&std.testing.allocator, 4, "0..1:2/3..:5");
    defer animations.deinit();

    const first = animations.items[0];
    try std.testing.expect(first.start_frame == 0);
    try std.testing.expect(first.end_frame == 1);
    try std.testing.expect(first.frames_per_second == 2);
    try std.testing.expect(first.seconds_per_frame == 0.5);

    const second = animations.items[1];
    try std.testing.expect(second.start_frame == 3);
    try std.testing.expect(second.end_frame == 4);
    try std.testing.expect(second.frames_per_second == 5);
    try std.testing.expect(second.seconds_per_frame == 0.2);
}
