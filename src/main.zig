const upaya = @import("upaya");
const sokol = @import("sokol");
const Texture = @import("../zig-upaya/src/texture.zig").Texture;
const std = @import("std");
const uianim = @import("uianim.zig");

usingnamespace upaya.imgui;
usingnamespace sokol;
usingnamespace uianim;

const my_fonts = @import("myscalingfonts.zig");

pub fn main() !void {
    upaya.run(.{
        .init = init,
        .update = update,
        .app_name = "Super Awesome Sample",
        .window_title = "rene window",
        .ini_file_storage = .none,
        .swap_interval = 1, // ca 16ms
        .width = 1920,
        .height = 1080,
    });
}

fn init() void {
    my_fonts.loadFonts() catch unreachable;
    // upaya.colors.setTintColor(upaya.colors.rgbaToVec4(0xcd, 0x0f, 0x00, 0xff));
}

var b: bool = true;

// .
// UI scaling
// .
var global_scale: f32 = 1.0;

fn relativeScaleForAbsoluteScale(new_scale: f32) f32 {
    return new_scale / global_scale;
}

fn scaleUI(new_scale: f32) void {
    var new_relative_scale = relativeScaleForAbsoluteScale(new_scale);
    ImGuiStyle_ScaleAllSizes(igGetStyle(), new_relative_scale);
    igGetIO().*.FontGlobalScale = new_scale;
    std.log.info("new global_scale: {}, new relative scale: {}", .{ global_scale * new_relative_scale, new_relative_scale });
    global_scale = new_scale;
}

// .
// Main Update Frame Loop
// .

var testButtonAnim = ButtonAnim{};
var testButtonAnim2 = ButtonAnim{};

// update will be called at every swap interval. with swap_interval = 1 above, we'll get 60 fps
fn update() void {
    // replace the default font
    my_fonts.pushFontScaled(14);
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
                my_fonts.pushFontScaled(64);
                if (igMenuItemBool("Fullscreen", "Toggle full-screen mode!", false, true)) {
                    sapp_toggle_fullscreen();
                }
                if (igMenuItemBool("Scale 0.5", "", false, true)) {
                    scaleUI(0.5);
                }
                if (igMenuItemBool("Scale 1.0", "", false, true)) {
                    scaleUI(1.0);
                }
                if (igMenuItemBool("Scale 1.5", "", false, true)) {
                    scaleUI(1.5);
                }
                my_fonts.popFontScaled();
            }

            if (igBeginMenu("Quit", true)) {
                defer igEndMenu();
                my_fonts.pushFontScaled(32);
                if (igMenuItemBool("now!", "Quit now", false, true)) {
                    // sapp_request_quit(); // NOTE: reports the attempt to free an invalid pointer
                    std.process.exit(0);
                }
                my_fonts.popFontScaled();
            }
        }

        // we don't want the button size to be scaled shittily. Hence we look for the nearest (lower bound) font size.
        my_fonts.pushFontScaled(my_fonts.getNearestFontSize(100));
        igColumns(5, "", false);
        igSpacing();
        igNextColumn();
        if (animatedButton("clickme", .{ .x = -1, .y = 0 }, &testButtonAnim) == .released) {
            std.log.info("clicked!", .{});
        }
        igNextColumn();
        igSpacing();
        igNextColumn();
        _ = animatedButton("clickme", .{ .x = -1, .y = 0 }, &testButtonAnim2);
        igNextColumn();
        igSpacing();
        igNextColumn();
        igEndColumns();

        my_fonts.popFontScaled();
        //var buttonState = animatedButton("test", .{ .x = 100, .y = 100 }, &testButtonAnim);
        igEnd();

        // pop the default font
        my_fonts.popFontScaled();

        // igShowMetricsWindow(&b);
    }
}
