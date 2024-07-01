const std = @import("std");
const cmt = @import("comet");

const Player = struct {
    position: cmt.math.Vec2(f32) = .{ .x = 160, .y = 30 },
    velocity: cmt.math.Vec2(f32) = .{ .x = 0, .y = 0 },
    jump_buffer_time: f32 = 0,

    const top_speed = 200;
    const acceleration = 600;
};

var player: Player = .{};

pub fn main() !void {
    var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
    const allocator = gpa.allocator();

    defer _ = gpa.deinit();
    defer _ = gpa.detectLeaks();

    var comet = try cmt.init(.{}, &allocator);
    defer comet.quit();

    const heart = comet.graphics.loadTexture("assets/heart_sheet.png", .{ .h_frames = 4, .anchor_position = .{ .relative = .{ .x = .middle, .y = .end } } });
    defer heart.destroy();

    var heart_animator = heart.createAnimator();

    while (comet.nextFrame(16)) {
        heart_animator.process(comet.time.integrated_delta);

        player.velocity.y += 900 * comet.time.integrated_delta;

        if (player.jump_buffer_time > 0) {
            player.jump_buffer_time -= comet.time.integrated_delta;
        }

        if (comet.keyboard.isDown(.space)) {
            player.jump_buffer_time = 0.4;
        }

        if (player.jump_buffer_time > 0 and player.position.y == 180) {
            player.velocity.y = -300;
            player.jump_buffer_time = 0;
        }

        const input_axis = @as(i32, @intFromBool(comet.keyboard.isDown(.d))) - @as(i32, @intFromBool(comet.keyboard.isDown(.a)));
        const target_velocity = input_axis * Player.top_speed;
        player.velocity.x = cmt.math.moveTowards(f32, player.velocity.x, @floatFromInt(target_velocity), Player.acceleration * comet.time.integrated_delta);

        player.position = player.position.add(player.velocity.scale(comet.time.delta));

        if (player.position.y > 180) {
            player.position.y = 180;
            player.velocity.y = 0;
        }

        if (player.position.x > 316) {
            player.position.x = 316;
            player.velocity.x *= -1;
        }

        if (player.position.x < 3) {
            player.position.x = 3;
            player.velocity.x *= -1;
        }

        comet.graphics.startFrame(.{ .r = 100, .g = 149, .b = 237 });

        // drawing code goes here
        comet.graphics.draw(&heart_animator, player.position.intFromFloat(i32), .{});

        comet.graphics.endFrame();
    }
}
