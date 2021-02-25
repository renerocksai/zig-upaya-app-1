const upaya = @import("upaya");
const sokol = @import("sokol");
const Texture = @import("../zig-upaya/src/texture.zig").Texture;
const std = @import("std");
usingnamespace upaya.imgui;
usingnamespace sokol;

const my_fonts = @import("myscalingfonts.zig");

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .app_name = "Super Awesome Sample",
        .window_title = "rene window",
    });
}

fn init() void {
    my_fonts.loadFonts() catch unreachable;
}

fn update() void {
    var mx: ImVec2 = .{ .x = 0, .y = 0 };
    igGetWindowContentRegionMax(&mx);

    if (igBegin("hello", null, ImGuiWindowFlags_NoSavedSettings | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoDocking | ImGuiWindowFlags_AlwaysVerticalScrollbar | ImGuiWindowFlags_AlwaysHorizontalScrollbar | ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_MenuBar)) {
        igSetWindowPosStr("hello", .{ .x = 0, .y = 0 }, ImGuiCond_Always);
        igSetWindowSizeStr("hello", mx, ImGuiCond_Always);
        if (igBeginMenuBar()) {
            defer igEndMenuBar();
            if (igBeginMenu("Help", true)) {
                defer igEndMenu();
                my_fonts.pushFontScaled(14);
                if (igMenuItemBool("About", "About this awesome app", false, true)) {}
                my_fonts.popFontScaled(); // NOTE: for some reason, defer-ring this inside the if block does not work!
            }

            if (igBeginMenu("View", true)) {
                defer igEndMenu();
                my_fonts.pushFontScaled(129);
                if (igMenuItemBool("Fullscreen", "Toggle full-screen mode!", false, true)) {
                    sapp_toggle_fullscreen();
                }
                my_fonts.popFontScaled();
            }

            if (igBeginMenu("Quit", true)) {
                defer igEndMenu();
                my_fonts.pushFontScaled(14);
                if (igMenuItemBool("now!", "Quit now", false, true)) {
                    // sapp_request_quit(); // NOTE: reports the attempt to free an invalid pointer
                    std.process.exit(0);
                }
                my_fonts.popFontScaled();
            }
        }

        // we don't want the button size to be scaled shittily. Hence we look for the nearest (lower bound) font size.
        my_fonts.pushFontScaled(my_fonts.getNearestFontSize(200));
        if (igButton("clickme", .{ .x = -1, .y = 0 })) {
            std.log.info("clicked!", .{});
        }
        my_fonts.popFontScaled();

        igEnd();
    }
}
