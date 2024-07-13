const std = @import("std");
const cmt = @import("comet");
const sdl = @import("sdl");

comet: *const cmt.Comet,

window: sdl.Window,
renderer: sdl.Renderer,
render_texture: sdl.Texture,
render_resolution: cmt.math.Vec2(u32),
window_size: cmt.math.Vec2(u32),
window_ratio: i32,
current_font: ?*const cmt.graphics.Font,

pub fn loadTexture(self: *const cmt.graphics.Graphics, path: [:0]const u8, options: struct {
    h_frames: u32 = 1,
    v_frames: u32 = 1,
    animations: ?std.ArrayList(cmt.graphics.Animation) = null,
    anchor_position: cmt.graphics.AnchorPosition = .{ .relative = .{ .start, .start } },
}) cmt.graphics.Texture {
    const raw_texture = sdl.image.loadTexture(self.renderer, path) catch unreachable;

    const animation_data = cmt.graphics.Texture.AnimationData.from(&raw_texture, .{
        .h_frames = options.h_frames,
        .v_frames = options.v_frames,
        .animations = options.animations orelse b: {
            var arr = std.ArrayList(cmt.graphics.Animation).initCapacity(self.comet.mem.allocator.*, 1) catch unreachable;
            arr.append(.{ .start_frame = 0, .end_frame = 1, .seconds_per_frame = 1, .frames_per_second = 1 }) catch unreachable;
            break :b arr;
        },
        .anchor_position = options.anchor_position,
    });

    return .{
        .texture = raw_texture,
        .animation_data = animation_data,
    };
}

pub fn print(self: *const cmt.graphics.Graphics, text: [:0]const u8, color: *const cmt.graphics.Color, options: struct { anchor_position: cmt.graphics.AnchorPosition = .{ .absolute = .{ 0, 0 } } }) !cmt.graphics.Texture {
    const font = self.current_font orelse return error.FontNotSet;
    const surface = font.renderTextSolid(text, color.*) catch unreachable;
    defer surface.destroy();

    const raw_texture = sdl.createTextureFromSurface(self.renderer, surface) catch unreachable;

    var animations = std.ArrayList(cmt.graphics.Animation).init(self.comet.mem.allocator.*);

    animations.append(.{
        .start_frame = 0,
        .end_frame = 1,
        .frames_per_second = 1,
        .seconds_per_frame = 1,
    }) catch unreachable;

    const animation_data = cmt.graphics.Texture.AnimationData.from(&raw_texture, .{
        .animations = animations,
        .anchor_position = options.anchor_position,
    });

    return .{
        .texture = raw_texture,
        .animation_data = animation_data,
    };
}

pub fn measureText(self: *const cmt.graphics.Graphics, text: [:0]const u8, comptime IntT: type) !cmt.math.Vec2(IntT) {
    const font = self.current_font orelse return error.FontNotSet;
    const size = font.sizeText(text) catch unreachable;
    return .{ @intCast(size.width), @intCast(size.height) };
}

pub fn loadFont(_: *const cmt.graphics.Graphics, path: [:0]const u8, size: u32) cmt.graphics.Font {
    const font = sdl.ttf.openFont(path, @intCast(size)) catch unreachable;
    return font;
}

pub fn startFrame(self: *const cmt.graphics.Graphics, color: cmt.graphics.Color) void {
    self.renderer.setTarget(self.render_texture) catch unreachable;
    self.renderer.setColor(color) catch unreachable;
    self.renderer.clear() catch unreachable;
}

pub fn setFont(self: *cmt.graphics.Graphics, font: *const cmt.graphics.Font) void {
    self.current_font = font;
}

pub fn drawRaw(self: *const cmt.graphics.Graphics, texture: *const cmt.graphics.Texture, position: cmt.math.Vec2(i32), frame: u32, options: cmt.graphics.Texture.DrawOptions) void {
    const src_rect = texture.animation_data.frame(frame);

    const target_rect = @as(cmt.graphics.Rect, .{
        .x = position[0] + texture.animation_data.anchor_position[0],
        .y = position[1] + texture.animation_data.anchor_position[1],
        .width = src_rect.width,
        .height = src_rect.height,
    });

    const h_flip_flag = @as(sdl.RendererFlip, if (options.h_flipped) .horizontal else .none);
    const v_flip_flag = @as(sdl.RendererFlip, if (options.v_flipped) .vertical else .none);
    const flip_flag = @intFromEnum(h_flip_flag) | @intFromEnum(v_flip_flag);

    self.renderer.copyEx(
        texture.texture,
        target_rect,
        src_rect,
        0,
        null,
        @enumFromInt(flip_flag),
    ) catch unreachable;
}

pub fn draw(self: *const cmt.graphics.Graphics, animator: *const cmt.graphics.TextureAnimator, position: cmt.math.Vec2(i32), options: cmt.graphics.Texture.DrawOptions) void {
    const src_rect = animator.texture.animation_data.frame(animator.frame);

    const target_rect = @as(cmt.graphics.Rect, .{
        .x = position[0] + animator.texture.animation_data.anchor_position[0],
        .y = position[1] + animator.texture.animation_data.anchor_position[1],
        .width = src_rect.width,
        .height = src_rect.height,
    });

    const h_flip_flag = @as(sdl.RendererFlip, if (options.h_flipped) .horizontal else .none);
    const v_flip_flag = @as(sdl.RendererFlip, if (options.v_flipped) .vertical else .none);
    const flip_flag = @intFromEnum(h_flip_flag) | @intFromEnum(v_flip_flag);

    self.renderer.copyEx(
        animator.texture.texture,
        target_rect,
        src_rect,
        0,
        null,
        @enumFromInt(flip_flag),
    ) catch unreachable;
}

pub fn drawRect(self: *const cmt.graphics.Graphics, rect: cmt.graphics.Rect, color: *const cmt.graphics.Color) void {
    self.renderer.setColor(color.*) catch unreachable;
    self.renderer.fillRect(rect) catch unreachable;
    self.renderer.setColor(cmt.graphics.Color.white) catch unreachable;
}

pub fn endFrame(self: *const cmt.graphics.Graphics) void {
    self.renderer.setTarget(null) catch unreachable;
    self.renderer.copy(self.render_texture, null, null) catch unreachable;
    self.renderer.present();
}

pub fn deinit(self: *const cmt.graphics.Graphics) void {
    self.renderer.destroy();
    self.window.destroy();
}

pub fn init(comptime properties: *const cmt.CometProperties, comet: *const cmt.Comet) !cmt.graphics.Graphics {
    const window = try sdl.createWindow(
        properties.name,
        .{ .centered = {} },
        .{ .centered = {} },
        properties.window_size[0],
        properties.window_size[1],
        .{ .vis = .shown },
    );

    const renderer = try sdl.createRenderer(window, null, .{ .accelerated = true });
    renderer.setDrawBlendMode(.blend) catch unreachable;
    const render_texture = sdl.createTexture(renderer, .rgba8888, .target, properties.render_resolution[0], properties.render_resolution[1]) catch unreachable;

    const window_ratio = @divExact(properties.window_size[0], properties.render_resolution[0]);

    return .{
        .comet = comet,
        .window = window,
        .renderer = renderer,
        .render_texture = render_texture,
        .render_resolution = properties.render_resolution,
        .window_size = properties.window_size,
        .window_ratio = window_ratio,
        .current_font = null,
    };
}
