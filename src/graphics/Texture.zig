const std = @import("std");
const cmt = @import("comet");
const sdl = @import("sdl");

texture: sdl.Texture,
animation_data: cmt.graphics.Texture.AnimationData,

pub const AnimationData = struct {
    animations: std.ArrayList(cmt.graphics.Animation),

    h_frames: u32,
    v_frames: u32,

    frame_width: u32,
    frame_height: u32,

    anchor_position: cmt.math.Vec2(i32),

    total_frames: u32,

    pub fn frame(self: *const AnimationData, idx: u32) cmt.graphics.Rect {
        const row = idx / self.h_frames;
        const col = idx % self.h_frames;

        const x = col * self.frame_width;
        const y = row * self.frame_height;

        return .{
            .x = @intCast(x),
            .y = @intCast(y),
            .width = @intCast(self.frame_width),
            .height = @intCast(self.frame_height),
        };
    }

    pub fn from(texture: *const sdl.Texture, options: struct { h_frames: u32 = 1, v_frames: u32 = 1, animations: std.ArrayList(cmt.graphics.Animation), anchor_position: cmt.graphics.AnchorPosition }) AnimationData {
        const textureInfo = texture.query() catch unreachable;
        const total_frames = options.h_frames * options.v_frames;

        const frame_width = @as(u32, @intCast(textureInfo.width)) / options.h_frames;
        const frame_height = @as(u32, @intCast(textureInfo.height)) / options.v_frames;

        const animation_data = .{
            .animations = options.animations,
            .h_frames = options.h_frames,
            .v_frames = options.v_frames,
            .frame_width = frame_width,
            .frame_height = frame_height,
            .total_frames = total_frames,
            .anchor_position = options.anchor_position.resolve(.{ frame_width, frame_height }),
        };

        return animation_data;
    }
};

pub const DrawOptions = struct {
    h_flipped: bool = false,
    v_flipped: bool = false,
};

pub fn destroy(self: *const cmt.graphics.Texture) void {
    self.animation_data.animations.deinit();
    self.texture.destroy();
}

pub fn createAnimator(self: *const cmt.graphics.Texture) cmt.graphics.TextureAnimator {
    const startup_animation = &self.animation_data.animations.items[0];

    return .{
        .texture = self,
        .current_animation = 0,
        .frame = startup_animation.start_frame,
        .animation_progress = @floatFromInt(startup_animation.start_frame),
    };
}
