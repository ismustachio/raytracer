const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const lib = b.addStaticLibrary("mathEngine", "libs/mathEngine/mathEngine.zig");
    lib.setBuildMode(mode);
    lib.addPackagePath("mathEngine", "libs/mathEngine/mathEngine.zig");

    const exe = b.addExecutable("raytracer", "src/main.zig");
    exe.addPackagePath("mathEngine", "libs/mathEngine/mathEngine.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibrary(lib);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("tests/tests.zig");
    exe_tests.addPackagePath("mathEngine", "libs/mathEngine/mathEngine.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);
    exe_tests.linkLibrary(lib);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
