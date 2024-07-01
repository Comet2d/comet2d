const std = @import("std");
const lib_sdl = @import("sdl/build.zig");

const lib_comet = @This();

pub fn build(b: *std.Build) void {
    lib_comet.addExamples(b);
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

fn addExamples(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const example_basic = b.addExecutable(.{
        .name = "basic",
        .root_source_file = .{ .cwd_relative = "examples/0_basic.zig" },
        .target = target,
        .optimize = optimize,
    });

    example_basic.root_module.addImport("comet", lib_comet.create(b, example_basic));
    b.installArtifact(example_basic);

    const run_example_basic = b.addRunArtifact(example_basic);
    const run_example_basic_step = b.step("example_basic", "Runs the basic demo");
    run_example_basic_step.dependOn(&run_example_basic.step);

    const example_properties = b.addExecutable(.{
        .name = "properties",
        .root_source_file = .{ .cwd_relative = "examples/1_properties.zig" },
        .target = target,
        .optimize = optimize,
    });

    example_properties.root_module.addImport("comet", lib_comet.create(b, example_properties));
    b.installArtifact(example_properties);

    const run_example_properties = b.addRunArtifact(example_properties);
    const run_example_properties_step = b.step("example_properties", "Runs the properties demo");
    run_example_properties_step.dependOn(&run_example_properties.step);

    const example_texture_loading = b.addExecutable(.{
        .name = "texture_loading",
        .root_source_file = .{ .cwd_relative = "examples/2_texture_loading.zig" },
        .target = target,
        .optimize = optimize,
    });

    example_texture_loading.root_module.addImport("comet", lib_comet.create(b, example_texture_loading));
    b.installArtifact(example_texture_loading);

    const run_example_texture_loading = b.addRunArtifact(example_texture_loading);
    const run_example_texture_loading_step = b.step("example_texture_loading", "Runs the texture loading example");
    run_example_texture_loading_step.dependOn(&run_example_texture_loading.step);

    const example_animation = b.addExecutable(.{
        .name = "animation",
        .root_source_file = .{ .cwd_relative = "examples/3_animation.zig" },
        .target = target,
        .optimize = optimize,
    });

    example_animation.root_module.addImport("comet", lib_comet.create(b, example_animation));
    b.installArtifact(example_animation);

    const run_example_animation = b.addRunArtifact(example_animation);
    const run_example_animation_step = b.step("example_animation", "Runs the animation example");
    run_example_animation_step.dependOn(&run_example_animation.step);

    const example_platformer = b.addExecutable(.{
        .name = "platformer",
        .root_source_file = .{ .cwd_relative = "examples/4_platformer.zig" },
        .target = target,
        .optimize = optimize,
    });

    example_platformer.root_module.addImport("comet", lib_comet.create(b, example_platformer));
    b.installArtifact(example_platformer);

    const run_example_platformer = b.addRunArtifact(example_platformer);
    const run_example_platformer_step = b.step("example_platformer", "Runs the platformer example");
    run_example_platformer_step.dependOn(&run_example_platformer.step);

    const example_text = b.addExecutable(.{
        .name = "text",
        .root_source_file = .{ .cwd_relative = "examples/5_text.zig" },
        .target = target,
        .optimize = optimize,
    });

    example_text.root_module.addImport("comet", lib_comet.create(b, example_text));
    b.installArtifact(example_text);

    const run_example_text = b.addRunArtifact(example_text);
    const run_example_text_step = b.step("example_text", "Runs the text example");
    run_example_text_step.dependOn(&run_example_text.step);
}
