const std = @import("std");
const cmt = @import("comet");

pub fn main() !void {
    var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();

    var comet = try cmt.init(.{}, &allocator);
    defer comet.quit();

    // specify number of frames. .v_frames is available too. .animtion_format is in the form:
    // "[start_frame (inclusive)]..[end_frame (non-inclusive) OR none, meaning the rest of the frames]:[time per frame in seconds]"
    const heart = comet.graphics.loadTexture("assets/heart_sheet.png", .{ .h_frames = 4, .animations = cmt.graphics.Animation.parse(comet.mem.allocator, 4, "0..2:1/2..:0.5") catch unreachable });
    defer heart.destroy();

    var heart_animator = heart.createAnimator();

    while (comet.nextFrame(10)) {
        if (comet.keyboard.isJustDown(.a)) {
            heart_animator.setAnimation(0);
        }

        if (comet.keyboard.isJustDown(.b)) {
            heart_animator.setAnimation(1);
        }

        heart_animator.process(comet.time.integrated_delta);

        comet.graphics.startFrame(.{ .r = 100, .g = 149, .b = 237 });

        comet.graphics.draw(&heart_animator, .{ 20, 20 }, .{});

        comet.graphics.endFrame();
    }
}
