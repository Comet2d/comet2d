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

    // load a font from a file
    const font = comet.graphics.loadFont("assets/pixel.ttf", 8); // font size 10
    defer font.close();

    comet.graphics.setFont(&font);

    // load a texture from a file.
    const joke = comet.graphics.print("what do you call a man with a shovel on his head?", &cmt.graphics.Color.white, .{}) catch unreachable;
    defer joke.destroy();

    const punchline = comet.graphics.print("doug", &cmt.graphics.Color.white, .{}) catch unreachable;
    defer punchline.destroy();

    // create an animator for the texture. This is required to draw it to the screen.
    var text_animator = joke.createAnimator();
    var punchline_animator = punchline.createAnimator();

    // next frame does a bunch of frame setup stuff, as well as delaying for, in this case, 16 milliseconds
    // so you don't hit 100% CPU usage.
    while (comet.nextFrame(16)) {
        // process code goes here
        text_animator.process(comet.time.integrated_delta);
        punchline_animator.process(comet.time.integrated_delta);

        comet.graphics.startFrame(.{ .r = 100, .g = 149, .b = 237 });

        // drawing code goes here
        comet.graphics.draw(&text_animator, .{ 0, 20 }, .{});
        comet.graphics.draw(&punchline_animator, .{ 0, 36 }, .{});

        comet.graphics.endFrame();
    }
}
