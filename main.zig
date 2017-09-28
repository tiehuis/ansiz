const std = @import("std");
const printf = std.io.stdout.printf;

use @import("ansiz.zig");

pub fn main() -> %void {
    // Zig should be able to determine that Bg(Green) is fully comptime knowable without the
    // explicit indication.
    %%printf(comptime Bg(Green) ++ "Hello, World!\n");
}
