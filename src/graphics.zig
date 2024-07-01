const cmt = @import("comet");
const sdl = @import("sdl");

pub const Animation = @import("graphics/Animation.zig");
pub const Graphics = @import("graphics/Graphics.zig");
pub const Texture = @import("graphics/Texture.zig");
pub const TextureAnimator = @import("graphics/TextureAnimator.zig");

pub const Rect = sdl.Rectangle;
pub const Color = sdl.Color;
pub const Font = sdl.ttf.Font;

pub const AnchorPosition = union(enum) {
    absolute: cmt.math.Vec2(i32),
    relative: cmt.math.Vec2(enum { start, middle, end }),

    pub fn resolve(self: cmt.graphics.AnchorPosition, frame_size: cmt.math.Vec2(u32)) cmt.math.Vec2(i32) {
        switch (self) {
            .absolute => |absolute| {
                return absolute.scale(-1);
            },
            .relative => |e| {
                var vec = @as(cmt.math.Vec2(i32), .{ .x = 0, .y = 0 });

                switch (e.x) {
                    .start => vec.x = 0,
                    .middle => vec.x = @divExact(-@as(i32, @intCast(frame_size.x)), 2),
                    .end => vec.x = -@as(i32, @intCast(frame_size.x)),
                }

                switch (e.y) {
                    .start => vec.y = 0,
                    .middle => vec.y = @divExact(-@as(i32, @intCast(frame_size.y)), 2),
                    .end => vec.y = -@as(i32, @intCast(frame_size.y)),
                }

                return vec;
            },
        }
    }
};
