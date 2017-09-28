const std = @import("std");
const assert = debug.assert;

fn escape(comptime literal: []const u8) -> []const u8 {
    "\x1b[" ++ literal
}

pub const ResetAll = escape("c");

pub const Color = enum {
    Simple: u8,
    Ansi: u8,
    TrueColor: struct { r: u8, g: u8, b: u8 },
};

pub const Black        = Color.Simple { 30 };
pub const Red          = Color.Simple { 31 };
pub const Green        = Color.Simple { 32 };
pub const Yellow       = Color.Simple { 33 };
pub const Blue         = Color.Simple { 34 };
pub const Magenta      = Color.Simple { 35 };
pub const Cyan         = Color.Simple { 36 };
pub const LightGray    = Color.Simple { 37 };
pub const Default      = Color.Simple { 39 };
pub const DarkGray     = Color.Simple { 90 };
pub const LightRed     = Color.Simple { 91 };
pub const LightGreen   = Color.Simple { 92 };
pub const LightYellow  = Color.Simple { 93 };
pub const LightBlue    = Color.Simple { 94 };
pub const LightMagenta = Color.Simple { 95 };
pub const LightCyan    = Color.Simple { 96 };
pub const White        = Color.Simple { 97 };

pub fn Color216(r: u8, g: u8, b: u8) -> Color {
    assert(r <= 5 and g <= 5 and b <= 5);
    Color.Ansi { 16 + 36 * r + 6 * g + b }
}

pub fn GrayScale24(shade: u8) -> Color {
    assert(shade < 24);
    Color.Ansi { 0xe8 + shade }
}

pub fn Color256(code: u8) -> Color {
    Color.Ansi { code }
}

pub fn TrueColor(r: u8, g: u8, b: u8) -> Color {
    Color.TrueColor { .r = r, .g = g, .b = b }
}

// If we had a @stringify operator we could do most everything we need to.
// The only slightly annoying thing would runtime Color's but we could utilize buffers and
// the like somehow. This case less common in my mind.
//
// var buffer: [3]u8 = undefined;
fn u8ToLit(comptime x: u8) -> []const u8 {
    // if (x < 10) {
    //     buffer[0] = x + '0';
    //     buffer[0..1]
    // } else if (x < 100) {
    //     buffer[0] = (x % 10) + '0';
    //     buffer[1] = (x / 10) + '0';
    //     buffer[0..2]
    // } else {
    //     buffer[0] = (x % 10) + '0';
    //     buffer[1] = ((x / 10) % 10) + '0';
    //     buffer[2] = (x / 100) + '0';
    //     buffer[0..3]
    // }

    "_"
}

pub fn Fg(comptime color: Color) -> []const u8 {
    comptime switch (color) {
        Color.Simple    => |v| escape(u8ToLit(v) ++ "m"),
        Color.Ansi      => |v| escape("38;5;" ++ u8ToLit(v) ++ "m"),
        Color.TrueColor => |v| escape("38;2;" ++ u8ToLit(v.r) ++ ";" ++ u8ToLit(v.g) ++
                                      ";" ++ u8ToLit(v.b) ++ "m"),
    }
}

pub fn Bg(comptime color: Color) -> []const u8 {
    comptime switch (color) {
        Color.Simple    => |v| escape(u8ToLit(v + 10) ++ "m"),
        Color.Ansi      => |v| escape("48;5;" ++ u8ToLit(v) ++ "m"),
        Color.TrueColor => |v| escape("48;2;" ++ u8ToLit(v.r) ++ ";" ++ u8ToLit(v.g) ++
                                      ";" ++ u8ToLit(v.b) ++ "m"),
    }
}

pub const Attr = struct {
    pub const Reset       = escape("m");
    pub const Bright      = escape("1m");
    pub const Dim         = escape("2m");
    pub const Italic      = escape("3m");
    pub const Underline   = escape("4m");
    pub const Blink       = escape("5m");
    pub const Invert      = escape("7m");
    pub const Crossed     = escape("9m");
    pub const NoBright    = escape("21m");
    pub const NoDim       = escape("22m");
    pub const NoItalic    = escape("23m");
    pub const NoUnderline = escape("24m");
    pub const NoBlink     = escape("25m");
    pub const NoInvert    = escape("27m");
    pub const NoCrossed   = escape("29m");
    pub const Framed      = escape("51m");
};

pub const Erase = struct {
    pub const Down        = escape("J");
    pub const Up          = escape("1J");
    pub const Screen      = escape("2J");
    pub const EndOfLine   = escape("K");
    pub const StartOfLine = escape("1K");
    pub const Line        = escape("2K");
};

pub const Cursor = struct {
    pub const Hide    = escape("?25hl");
    pub const Show    = escape("?25h");
    pub const Save    = escape("s");
    pub const Restore = escape("u");

    // The following are not-compile-time known and should be used via a standard println.
    //
    // This requires a buffer or a separate call (not using printf).
    pub fn Goto(x: u8, y: u8) -> []const u8 {
        assert(x != 0 and y != 0);
        escape("{};{}H", x, y)
    }

    pub fn Up(amount: u8) -> []const u8 {
        escape("{}A", amount);
    }

    pub fn Down(amount: u8) -> []const u8 {
        escape("{}B", amount)
    }

    pub fn Right(amount: u8) -> []const u8 {
        escape("{}C", amount)
    }

    pub fn Left(amount: u8) -> []const u8 {
        escape("{}D", amount)
    }
};

pub const Screen = struct {
    pub const Save    = escape("?47h");
    pub const Restore = escape("?47l");
};

// Add a closest match function to the standard 256 color mappings.
//
// Allow specifying either the 16-color standard, 216-color, or True-Color as the
// parameter space output.
