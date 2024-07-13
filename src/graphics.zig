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
                return absolute * @as(cmt.math.Vec2(i32), @splat(-1));
            },
            .relative => |e| {
                var vec = @as(cmt.math.Vec2(i32), .{ 0, 0 });

                switch (e[0]) {
                    .start => vec[0] = 0,
                    .middle => vec[0] = @divExact(-@as(i32, @intCast(frame_size[0])), 2),
                    .end => vec[0] = -@as(i32, @intCast(frame_size[0])),
                }

                switch (e[1]) {
                    .start => vec[1] = 0,
                    .middle => vec[1] = @divExact(-@as(i32, @intCast(frame_size[1])), 2),
                    .end => vec[1] = -@as(i32, @intCast(frame_size[1])),
                }

                return vec;
            },
        }
    }
};
