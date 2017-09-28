const Builder = @import("std").build.Builder;

pub fn build(b: &Builder) {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("main", "main.zig");
    exe.setBuildMode(mode);

    exe.setOutputPath("./main");
    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
