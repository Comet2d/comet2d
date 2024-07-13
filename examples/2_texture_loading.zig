const std = @import("std");
const cmt = @import("comet");

pub fn main() !void {
    var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();

    var comet = try cmt.init(.{}, &allocator);
    defer comet.quit();

    // defaults to top left of texture
    const heart = comet.graphics.loadTexture("assets/heart.png", .{});
    defer heart.destroy();

    // can provide an anchor position as either .start, .middle or .end, or as an absolute position
    const heart_centered = comet.graphics.loadTexture("assets/heart.png", .{ .anchor_position = .{ .relative = .{ .middle, .middle } } });
    // const heart_centered = comet.graphics.loadTexture("assets/heart.png", .{ .anchor_position = .{ .absolute = .{  4, 4 } } });
    defer heart_centered.destroy();

    const heart_frames = comet.graphics.loadTexture("assets/heart_sheet.png", .{ .h_frames = 4 });
    defer heart_frames.destroy();

    // One texture can have any number of animators. The texture must live for at least as long as all of its animators, otherwise
    // bad things will happen
    var heart_animator = heart.createAnimator();
    var heart_centered_animator = heart_centered.createAnimator();
    var heart_frames_animator = heart_frames.createAnimator();

    while (comet.nextFrame(16)) {
        heart_animator.process(comet.time.integrated_delta);
        heart_centered_animator.process(comet.time.integrated_delta);
        heart_frames_animator.process(comet.time.integrated_delta);

        comet.graphics.startFrame(.{ .r = 100, .g = 149, .b = 237 });

        comet.graphics.draw(&heart_animator, .{ 10, 20 }, .{});
        comet.graphics.draw(&heart_centered_animator, .{ 20, 20 }, .{});
        comet.graphics.draw(&heart_frames_animator, .{ 30, 20 }, .{});

        comet.graphics.endFrame();
    }
}
