const cmt = @import("comet");
const sdl = @import("sdl");

texture: *const cmt.graphics.Texture,

current_animation: u32,
frame: u32,
animation_progress: f32,

pub fn setAnimation(self: *cmt.graphics.TextureAnimator, new_animation: u32) void {
    if (new_animation == self.current_animation) {
        return;
    }

    self.current_animation = new_animation;

    const animation = &self.texture.animation_data.animations.items[new_animation];
    self.frame = animation.start_frame;
    self.animation_progress = @floatFromInt(animation.start_frame);
}

pub fn process(self: *cmt.graphics.TextureAnimator, delta: f32) void {
    const current_animation = &self.texture.animation_data.animations.items[self.current_animation];
    self.animation_progress += delta * current_animation.seconds_per_frame;
    self.frame = @intFromFloat(self.animation_progress);

    while (self.frame >= current_animation.end_frame) {
        self.animation_progress -= @floatFromInt(current_animation.end_frame - current_animation.start_frame);
        self.frame = @intFromFloat(self.animation_progress); // TODO - Optimise
    }
}

pub fn init(texture: *const cmt.graphics.Texture) cmt.graphics.TextureAnimator {
    return .{ .texture = texture, .current_animation = texture.animator };
}
