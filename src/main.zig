const upaya = @import("upaya");
const sokol = @import("sokol");
const Texture = @import("../zig-upaya/src/texture.zig").Texture;
const std = @import("std");
usingnamespace upaya.imgui;
usingnamespace sokol;

var my_font: *ImFont = undefined;

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .app_name = "Super Awesome Sample",
        .window_title = "rene window",
    });
}

fn init() void {
    loadFont();
    std.log.info("Font: {}", .{my_font});
}

fn update() void {
    var w = sapp_width();
    var h = sapp_height();
    var mx: ImVec2 = .{ .x = 0, .y = 0 };
    igGetWindowContentRegionMax(&mx);

    // some more ways to check out our window size
    var vp = igGetWindowViewport();
    var vp_x: i32 = @floatToInt(i32, vp.*.Size.x);
    var vp_y: i32 = @floatToInt(i32, vp.*.Size.y);
    //    std.log.info("{}x{}", .{ w, h });
    //    std.log.info("ViewPort: {}x{}", .{ vp_x, vp_y });
    //    std.log.info("Mx: {}x{}", .{ mx.x, mx.y });

    if (igBegin("hello", null, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_AlwaysVerticalScrollbar | ImGuiWindowFlags_AlwaysHorizontalScrollbar | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_MenuBar)) {
        igSetWindowPosStr("hello", .{ .x = 0, .y = 0 }, ImGuiCond_Always);
        igSetWindowSizeStr("hello", mx, ImGuiCond_Always);
        if (igBeginMenuBar()) {
            defer igEndMenuBar();
            if (igBeginMenu("Help", true)) {
                defer igEndMenu();
                if (igMenuItemBool("About", "About this awesome app", false, true)) {}
            }
            igPushFont(my_font);
            defer igPopFont();
            if (igBeginMenu("Quit", true)) {
                defer igEndMenu();
                if (igMenuItemBool("now!", "Quit now", false, true)) {
                    // sapp_request_quit(); // reports the attempt to free an invalid pointer
                    std.process.exit(0);
                }
            }
        }
        if (igButton("clickme", .{ .x = -1, .y = 0 })) {
            std.log.info("clicked!", .{});
        }

        igEnd();
    }
}

fn loadFont() void {
    var io = igGetIO();
    _ = ImFontAtlas_AddFontDefault(io.Fonts, null);

    // add our UbuntuMono font
    var icons_config = ImFontConfig_ImFontConfig();
    icons_config[0].MergeMode = true;
    icons_config[0].PixelSnapH = true;
    icons_config[0].FontDataOwnedByAtlas = false;

    var data = @embedFile("../assets/Ubuntu-B.ttf");
    //my_font = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, icons_config, ImFontAtlas_GetGlyphRangesDefault(io.Fonts));
    my_font = ImFontAtlas_AddFontFromMemoryTTF(io.Fonts, data, data.len, 14, 0, 0);

    var w: i32 = undefined;
    var h: i32 = undefined;
    var bytes_per_pixel: i32 = undefined;
    var pixels: [*c]u8 = undefined;
    ImFontAtlas_GetTexDataAsRGBA32(io.Fonts, &pixels, &w, &h, &bytes_per_pixel);

    var tex = Texture.initWithData(pixels[0..@intCast(usize, w * h * bytes_per_pixel)], w, h, .nearest);
    ImFontAtlas_SetTexID(io.Fonts, tex.imTextureID());
}
