const std = @import("std");
const cmt = @import("comet");

allocator: *const std.mem.Allocator,

pub fn init(allocator: *const std.mem.Allocator) cmt.mem.Memory {
    return .{
        .allocator = allocator,
    };
}
