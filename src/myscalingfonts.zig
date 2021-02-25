const upaya = @import("upaya");
const sokol = @import("sokol");
const Texture = @import("../zig-upaya/src/texture.zig").Texture;
const std = @import("std");
usingnamespace upaya.imgui;
usingnamespace sokol;

pub var my_font_14: *ImFont = undefined;
pub var my_font_64: *ImFont = undefined;
pub var my_font_256: *ImFont = undefined;

pub fn loadFonts() void {
    var io = igGetIO();
    _ = ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add our UbuntuMono font
    var icons_config = ImFontConfig_ImFontConfig();
    icons_config[0].MergeMode = true;
    icons_config[0].PixelSnapH = true;
    icons_config[0].FontDataOwnedByAtlas = false;

    var data = @embedFile("../assets/Calibri Regular.ttf");
    //my_font = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, ImFontAtlas_GetGlyphRangesDefault(io.Fonts));
    my_font_14 = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, 0, 0);
    my_font_64 = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 64, 0, 0);
    my_font_256 = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 256, 0, 0);

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = Texture.initWithData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h, .nearest);
    ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}
