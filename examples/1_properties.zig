const std = @import("std");
const cmt = @import("comet");

pub fn main() !void {
    var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();

    var comet = try cmt.init(.{
        .name = "Sky Game", // name of the window
        .render_resolution = .{ .x = 60, .y = 60 }, // the resolution your game is rendered at
        .window_size = .{ .x = 480, .y = 480 }, // the size of the window
    }, &allocator);
    defer comet.quit();

    const heart = comet.graphics.loadTexture("assets/heart.png", .{});
    defer heart.destroy();

    var heart_animator = heart.createAnimator();

    while (comet.nextFrame(16)) {
        heart_animator.process(comet.time.integrated_delta);

        comet.graphics.startFrame(.{ .r = 100, .g = 149, .b = 237 });

        comet.graphics.draw(&heart_animator, .{ .x = 20, .y = 20 }, .{});

        comet.graphics.endFrame();
    }
}
