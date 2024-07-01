# Comet2d
Simple 2d game framework for simple 2d games

## Documentation
At this point there is little point in creating documentation - the API will change so much that documentation will become outdated almost instantly, creating even more technical debt than there already is. Instead of documentation, see the examples and the source code. The source code is (in my opinion) well written with descriptive names so *should* be easy enough to navigate and understand.

## Setup Guide
Currently the easiest way to add to a project is as a git submodule.

```sh
git submodule add "https://github.com/DispairingGoose/comet2d.git" "comet2d/"
git submodule update --init --recursive
```

To reference a specific version, use the following:
```sh
cd comet2d
git checkout tags/v0.0.1
```

Next, add it to your `build.zig`.
```zig
const std = @import("std");
const lib_comet = @import("comet2d/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "my_game",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("comet", lib_comet.create(b, exe));

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
```

## Supported platforms
Internally, this project uses [ikskuh/SDL.zig](https://github.com/ikskuh/SDL.zig) for its graphics, input and audio. As a result, all platforms supported by that librry are suppported by comet.

Linux is fully supported.

Windows is **not** supported. This is due to the fact that the SDL_TTF bindings are not supported yet on Windows, and as of currently there is no way to 'compile out' the font functions in this library

It is my understanding that Mac is supported. However, I don't have a Mac so cannot test this.

## License
This software is licensed under the zlib license. See the [license](LICENSE).