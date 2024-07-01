const std = @import("std");
const cmt = @import("comet");
const sdl = @import("sdl");

keystate: sdl.KeyboardState,
last_keystate: sdl.KeyboardState,
backbuffer: []const u8,

pub fn isJustUp(self: *const cmt.keyboard.Keyboard, key: sdl.Scancode) bool {
    return !self.keystate.isPressed(key) and self.last_keystate.isPressed(key);
}

pub fn isDown(self: *const cmt.keyboard.Keyboard, key: sdl.Scancode) bool {
    return self.keystate.isPressed(key);
}

pub fn isJustDown(self: *const cmt.keyboard.Keyboard, key: sdl.Scancode) bool {
    return self.keystate.isPressed(key) and !self.last_keystate.isPressed(key);
}

pub fn init(allocator: *const std.mem.Allocator) !cmt.keyboard.Keyboard {
    const keystate = sdl.getKeyboardState();

    const last_keystate: sdl.KeyboardState = .{
        .states = try allocator.alloc(u8, keystate.states.len),
    };

    const backbuffer = try allocator.alloc(u8, keystate.states.len);

    return .{
        .keystate = keystate,
        .last_keystate = last_keystate,
        .backbuffer = backbuffer,
    };
}

pub fn nextFrame(self: *cmt.keyboard.Keyboard) void {
    @memcpy(@constCast(self.last_keystate.states), self.backbuffer);
    @memcpy(@constCast(self.backbuffer), self.keystate.states);
}
