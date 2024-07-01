const cmt = @import("comet");
const sdl = @import("sdl");

audio_device: sdl.AudioDevice,

pub fn loadAudio(_: *const cmt.audio.Audio, path: [:0]const u8, options: struct {}) cmt.audio.Wav {
    _ = options;

    const wav = sdl.loadWav(path) catch unreachable;
    return wav;
}

pub fn queue(self: *const cmt.audio.Audio, wav: *const cmt.audio.Wav) void {
    self.audio_device.clearQueuedAudio();
    self.audio_device.queueAudio(wav.buffer) catch unreachable;
}

pub fn deinit(self: *const cmt.audio.Audio) void {
    self.audio_device.close();
}

pub fn init() cmt.audio.Audio {
    const open_device_result = sdl.openAudioDevice(.{ .desired_spec = .{
        .sample_rate = 22050,
        .channel_count = 2,
        .callback = null,
        .userdata = null,
    } }) catch unreachable;

    open_device_result.device.pause(false);

    return .{
        .audio_device = open_device_result.device,
    };
}
