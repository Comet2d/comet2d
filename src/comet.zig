const std = @import("std");
const sdl = @import("sdl");

pub const math = @import("math.zig");

pub const audio = @import("audio.zig");
pub const graphics = @import("graphics.zig");
pub const mem = @import("mem.zig");
pub const time = @import("time.zig");
pub const keyboard = @import("keyboard.zig");
pub const mouse = @import("mouse.zig");

pub const Comet = struct {
    audio: audio.Audio,
    time: time.Time,
    graphics: graphics.Graphics,
    keyboard: keyboard.Keyboard,
    mem: mem.Memory,
    mouse: mouse.Mouse,

    pub fn nextFrame(self: *Comet, ms: u32) bool {
        self.mouse.nextFrame();

        while (sdl.pollEvent()) |ev| {
            switch (ev) {
                .quit => return false,
                .mouse_wheel => |mouseWheelEvent| {
                    self.mouse.scrollDelta = @as(i8, @intCast(math.sign(i32, mouseWheelEvent.delta_y)));
                },
                else => {},
            }
        }

        self.time.nextFrame();
        self.keyboard.nextFrame();

        self.time.delay(ms);
        return true;
    }

    pub fn quit(self: *Comet) void {
        self.mem.allocator.free(self.keyboard.last_keystate.states);
        self.mem.allocator.free(self.keyboard.backbuffer);

        self.audio.deinit();
        self.graphics.deinit();

        sdl.ttf.quit();
        sdl.image.quit();
        sdl.quit();

        self.mem.allocator.destroy(self);
    }

    pub fn init(comptime properties: CometProperties, allocator: *const std.mem.Allocator) !*Comet {
        try sdl.init(.{ .video = true, .events = true, .audio = true });
        try sdl.image.init(.{ .png = true });
        try sdl.ttf.init();

        const comet = try allocator.create(Comet);

        comet.* = .{
            .audio = audio.Audio.init(),
            .graphics = try graphics.Graphics.init(&properties, comet),
            .time = try time.Time.init(),
            .keyboard = try keyboard.Keyboard.init(allocator),
            .mouse = mouse.Mouse.init(comet),
            .mem = mem.Memory.init(allocator),
        };

        return comet;
    }
};

pub const CometProperties = struct {
    name: [:0]const u8 = "My Comet Game",
    render_resolution: math.Vec2(u32) = .{ .x = 320, .y = 180 },
    window_size: math.Vec2(u32) = .{ .x = 1280, .y = 720 },
};

pub fn init(comptime properties: CometProperties, allocator: *const std.mem.Allocator) !*Comet {
    return Comet.init(properties, allocator);
}
