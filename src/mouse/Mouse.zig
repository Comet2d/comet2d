const std = @import("std");
const cmt = @import("comet");
const sdl = @import("sdl");

comet: *const cmt.Comet,

mouse_state: sdl.MouseState,
last_mouse_state: sdl.MouseState,

scrollDelta: i8 = 0,

pub fn getScrollDelta(self: *const cmt.mouse.Mouse) i8 {
    return self.scrollDelta;
}

pub fn isJustUp(self: *const cmt.mouse.Mouse, mouse_button: sdl.MouseButton) bool {
    return !self.mouse_state.buttons.getPressed(mouse_button) and self.last_mouse_state.buttons.getPressed(mouse_button);
}

pub fn isDown(self: *const cmt.mouse.Mouse, mouse_button: sdl.MouseButton) bool {
    return self.mouse_state.buttons.getPressed(mouse_button);
}

pub fn isJustDown(self: *const cmt.mouse.Mouse, mouse_button: sdl.MouseButton) bool {
    return self.mouse_state.buttons.getPressed(mouse_button) and !self.last_mouse_state.buttons.getPressed(mouse_button);
}

pub fn position(self: *const cmt.mouse.Mouse) cmt.math.Vec2(i32) {
    const mouse_state = sdl.getMouseState();

    return .{
        .x = @intCast(@divFloor(@as(i32, @intCast(mouse_state.x)), self.comet.graphics.windowRatio)),
        .y = @intCast(@divFloor(@as(i32, @intCast(mouse_state.y)), self.comet.graphics.windowRatio)),
    };
}

pub fn setMouse(_: *const cmt.mouse.Mouse, visibility: bool) void {
    _ = sdl.showCursor(visibility) catch unreachable;
}

pub fn nextFrame(self: *cmt.mouse.Mouse) void {
    self.last_mouse_state = self.mouse_state;
    self.mouse_state = sdl.getMouseState();

    self.scrollDelta = 0;
}

pub fn init(comet: *const cmt.Comet) cmt.mouse.Mouse {
    return .{
        .comet = comet,

        .mouse_state = sdl.getMouseState(),
        .last_mouse_state = sdl.getMouseState(),
    };
}
