const upaya = @import("upaya");
const sokol = @import("sokol");
const Texture = @import("../zig-upaya/src/texture.zig").Texture;
const std = @import("std");
usingnamespace upaya.imgui;
usingnamespace sokol;

var my_fonts = std.AutoHashMap(i32, *ImFont).init(std.heap.page_allocator);

const baked_font_sizes = [_]i32{ 14, 64, 128, 256 };

pub fn loadFonts() error{OutOfMemory}!void {
    var io = igGetIO();
    _ = ImFontAtlas_AddFontDefault(io.Fonts, null);

    var font_config = ImFontConfig_ImFontConfig();
    font_config[0].MergeMode = true;
    font_config[0].PixelSnapH = true;
    font_config[0].OversampleH = 1;
    font_config[0].OversampleV = 1;
    font_config[0].FontDataOwnedByAtlas = false;

    var data = @embedFile("../assets/Calibri Regular.ttf");
    //my_font = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, ImFontAtlas_GetGlyphRangesDefault(io.Fonts));

    for (baked_font_sizes) |fsize, i| {
        var font = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, @intToFloat(f32, fsize), 0, 0);
        try my_fonts.put(fsize, font);
    }

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = Texture.initWithData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h, .nearest);
    ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}

var last_scale: f32 = 0.0;
var last_font: *ImFont = undefined;

pub fn pushFontScaled(pixels: i32) void {
    var min_diff: i32 = 1000;
    var found_font_size: i32 = baked_font_sizes[0];
    var font: *ImFont = my_fonts.get(baked_font_sizes[0]).?; // we don't ever down-scale. hence, default to minimum font size

    // the bloody hash map says it doesn't support field access when trying to iterate:
    //    var it = my_fonts.iterator();
    //     for (it.next()) |item| {
    for (baked_font_sizes) |fsize, i| {
        var diff = pixels - fsize;

        std.log.debug("diff={}, pixels={}, fsize={}", .{ diff, pixels, fsize });
        // we only ever upscale, hence we look for positive differences only
        if (diff >= 0) {
            // we try to find the minimum difference
            if (diff < min_diff) {
                std.log.debug("  diff={} is < than {}, so our new temp found_font_size={}", .{ diff, min_diff, fsize });
                min_diff = diff;
                font = my_fonts.get(fsize).?;
                found_font_size = fsize;
            }
        }
    }

    // we assume we have a font, now scale it
    last_scale = font.*.Scale;
    const new_scale: f32 = @intToFloat(f32, pixels) / @intToFloat(f32, found_font_size);
    std.log.debug("--> Requested font size: {}, scaling from size: {} with scale: {}\n", .{ pixels, found_font_size, new_scale });
    font.*.Scale = new_scale;
    igPushFont(font);
    last_font = font;
}

pub fn popFontScaled() void {
    igPopFont();
    last_font.*.Scale = last_scale;
}
