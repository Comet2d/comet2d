const sdl = @import("sdl");
const cmt = @import("comet");

delta: f32,
last_delta: f32,
integrated_delta: f32,

ticks: u64,
last_ticks: u64,

pub fn delay(_: cmt.time.Time, ms: u32) void {
    sdl.delay(ms);
}

pub fn nextFrame(self: *cmt.time.Time) void {
    self.last_ticks = self.ticks;
    self.last_delta = self.delta;

    self.ticks = sdl.getTicks();
    self.delta = @as(f32, @floatFromInt(self.ticks - self.last_ticks)) / 1000;

    self.integrated_delta = (self.delta + self.last_delta) / 2;
}

pub fn init() !cmt.time.Time {
    const current_ticks = sdl.getTicks();

    return .{
        .delta = 0,
        .last_delta = 0,
        .integrated_delta = 0,

        .ticks = current_ticks,
        .last_ticks = current_ticks,
    };
}
