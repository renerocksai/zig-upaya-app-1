const builtin = @import("builtin");
const std = @import("std");
const Builder = std.build.Builder;

// const upaya_build = @import("build_upaya.zig");
const upaya_build = @import("./zig-upaya/src/build.zig");

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});

    // use a different cache folder for macos arm builds
    b.cache_root = if (std.builtin.os.tag == .macos and std.builtin.arch == std.builtin.Arch.aarch64) "zig-arm-cache" else "zig-cache";

    // first item in list will be added as "run" so `zig build run` will always work
    const examples = [_][2][]const u8{
        [_][]const u8{ "rene", "src/main.zig" },
    };

    for (examples) |example, i| {
        createExe(b, target, example[0], example[1]) catch unreachable;

        // first element in the list is added as "run" so "zig build run" works
        if (i == 0) createExe(b, target, "run", example[1]) catch unreachable;
    }

    upaya_build.addTests(b, target);
}

/// creates an exe with all the required dependencies
fn createExe(b: *Builder, target: std.build.Target, name: []const u8, source: []const u8) !void {
    const is_cli = std.mem.endsWith(u8, name, "cli");

    var exe = b.addExecutable(name, source);
    exe.setBuildMode(b.standardReleaseOptions());
    exe.setOutputDir(std.fs.path.join(b.allocator, &[_][]const u8{ b.cache_root, "bin" }) catch unreachable);
    exe.setTarget(target);

    if (is_cli) {
        upaya_build.linkCommandLineArtifact(b, exe, target, "");
    } else {
        addUpayaToArtifact(b, exe, target, "./zig-upaya/");
    }

    const run_cmd = exe.run();
    const exe_step = b.step(name, b.fmt("run {s}.zig", .{name}));
    exe_step.dependOn(&run_cmd.step);
    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}

pub fn addUpayaToArtifact(b: *Builder, exe: *std.build.LibExeObjStep, target: std.build.Target, comptime prefix_path: []const u8) void {
    if (prefix_path.len > 0 and !std.mem.endsWith(u8, prefix_path, "/")) @panic("prefix-path must end with '/' if it is not empty");
    upaya_build.linkArtifact(b, exe, target, prefix_path);
}
