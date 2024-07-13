const std = @import("std");
const cmt = @import("comet"); // I call my import cmt to avoid name collisions with a comet handle

pub fn main() !void {
    // boilerplate for heap allocations
    var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();

    // initialise comet
    var comet = try cmt.init(.{}, &allocator);
    defer comet.quit();

    // load a texture from a file.
    const heart = comet.graphics.loadTexture("assets/heart.png", .{});
    defer heart.destroy();

    // create an animator for the texture. This is required to draw it to the screen.
    var heart_animator = heart.createAnimator();

    // next frame does a bunch of frame setup stuff, as well as delaying for, in this case, 16 milliseconds
    // so you don't hit 100% CPU usage.
    while (comet.nextFrame(16)) {
        // process code goes here
        heart_animator.process(comet.time.integrated_delta);

        comet.graphics.startFrame(.{ .r = 100, .g = 149, .b = 237 });

        // drawing code goes here
        comet.graphics.draw(&heart_animator, .{ 20, 20 }, .{});

        comet.graphics.endFrame();
    }
}
