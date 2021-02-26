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
// Animation
// .
const frame_dt: f32 = 0.016; // roughly 16ms per frame
var ui_key_count: u32 = 0;
fn nextUiKey() u32 {
    ui_key_count += 1;
    return ui_key_count;
}

const ButtonState = enum {
    none = 0,
    hovered,
    pressed,
    released,
};

// doButton(label, size)
// see https://github.com/ocornut/imgui/issues/777
// you could use it like this:
//        currentColor = ... depending on current button state
//        ImGui::PushStyleColor(ImGuiCol_Button, currentColor);
//        ImGui::PushStyleColor(ImGuiCol_ButtonActive, currentColor);
//        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, currentColor);
//        auto state = doButton("Press Me", size);
//        ImGui::PopStyleColor(3);
fn doButton(label: [*c]const u8, size: ImVec2) ButtonState {
    var released = igButton(label, size);

    if (released) return .released;
    if (igIsItemActive() and igIsItemHovered(ImGuiHoveredFlags_RectOnly)) return .pressed;
    if (igIsItemHovered(ImGuiHoveredFlags_RectOnly)) return .hovered;
    return .none;
}

const ButtonAnim = struct {
    ticker: u32 = 0,
    prevState: ButtonState = .none,
    currentState: ButtonState = .none,
    global_anim_duration: i32 = 100, // @TODO : note, this will probably be split into individual animation times
    current_color: ImVec4 = ImVec4{},
};

fn animateColor(from: ImVec4, to: ImVec4, duration_ms: i32, ticker: u32) ImVec4 {
    var duration_ticks: f32 = @intToFloat(f32, duration_ms) / (frame_dt * 1000);
    if (ticker >= @floatToInt(u32, duration_ticks)) {
        return to;
    }
    if (ticker <= 1) {
        return from;
    }

    var ret = from;
    var fticker: f32 = @intToFloat(f32, ticker);
    ret.x += (to.x - from.x) / duration_ticks * fticker;
    ret.y += (to.y - from.y) / duration_ticks * fticker;
    ret.z += (to.z - from.z) / duration_ticks * fticker;
    ret.w += (to.w - from.w) / duration_ticks * fticker;
    return ret;
}

fn animatedButton(label: [*c]const u8, size: ImVec2, anim: *ButtonAnim) ButtonState {
    var fromColor = ImVec4{};
    var toColor = ImVec4{};
    switch (anim.prevState) {
        .none => fromColor = igGetStyleColorVec4(ImGuiCol_Button).*,
        .hovered => fromColor = igGetStyleColorVec4(ImGuiCol_ButtonHovered).*,
        .pressed => fromColor = igGetStyleColorVec4(ImGuiCol_ButtonActive).*,
        .released => fromColor = igGetStyleColorVec4(ImGuiCol_ButtonActive).*,
    }

    switch (anim.currentState) {
        .none => toColor = igGetStyleColorVec4(ImGuiCol_Button).*,
        .hovered => toColor = igGetStyleColorVec4(ImGuiCol_ButtonHovered).*,
        .pressed => toColor = igGetStyleColorVec4(ImGuiCol_ButtonActive).*,
        .released => toColor = igGetStyleColorVec4(ImGuiCol_ButtonActive).*,
    }

    var currentColor = animateColor(fromColor, toColor, anim.global_anim_duration, anim.ticker);
    igPushStyleColorVec4(ImGuiCol_Button, currentColor);
    igPushStyleColorVec4(ImGuiCol_ButtonHovered, currentColor);
    igPushStyleColorVec4(ImGuiCol_ButtonActive, currentColor);
    var state = doButton(label, size);
    igPopStyleColor(3);

    anim.ticker += 1;
    if (state != anim.currentState) {
        anim.prevState = anim.currentState;
        anim.currentState = state;
        anim.ticker = 0;
    }
    anim.current_color = currentColor;
    return state;
}

// .
// Main Update Frame Loop
// .

var testButtonAnim = ButtonAnim{};

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
        my_fonts.pushFontScaled(my_fonts.getNearestFontSize(200));
        if (animatedButton("clickme", .{ .x = -1, .y = 0 }, &testButtonAnim) == .released) {
            std.log.info("clicked!", .{});
        }
        my_fonts.popFontScaled();
        //var buttonState = animatedButton("test", .{ .x = 100, .y = 100 }, &testButtonAnim);
        igEnd();

        // pop the default font
        my_fonts.popFontScaled();

        // igShowMetricsWindow(&b);
    }
}
