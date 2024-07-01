const std = @import("std");
const lib_sdl = @import("sdl/build.zig");

pub fn build(_: *std.Build) void {
    // TODO - Run tests
}

pub fn create(b: *std.Build, exe: *std.Build.Step.Compile) *std.Build.Module {
    const sdl = lib_sdl.init(b, null);

    sdl.link(exe, .static);
    sdl.linkTtf(exe);

    exe.linkSystemLibrary("sdl2_image");

    const lib_path = comptime block: {
        break :block std.fs.path.dirname(@src().file) orelse ".";
    };

    const mod = b.createModule(.{
        .root_source_file = .{ .cwd_relative = lib_path ++ "/src/comet.zig" },
    });

    mod.addImport("comet", mod);
    mod.addImport("sdl", sdl.getWrapperModule());

    return mod;
}
