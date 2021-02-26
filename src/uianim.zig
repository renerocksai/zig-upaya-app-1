const upaya = @import("upaya");
usingnamespace upaya.imgui;

// .
// Animation
// .
pub const frame_dt: f32 = 0.016; // roughly 16ms per frame
var ui_key_count: u32 = 0;
pub fn nextUiKey() u32 {
    ui_key_count += 1;
    return ui_key_count;
}

pub const ButtonState = enum {
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
pub fn doButton(label: [*c]const u8, size: ImVec2) ButtonState {
    var released = igButton(label, size);

    if (released) return .released;
    if (igIsItemActive() and igIsItemHovered(ImGuiHoveredFlags_RectOnly)) return .pressed;
    if (igIsItemHovered(ImGuiHoveredFlags_RectOnly)) return .hovered;
    return .none;
}

pub const ButtonAnim = struct {
    ticker: u32 = 0,
    prevState: ButtonState = .none,
    currentState: ButtonState = .none,
    global_anim_duration: i32 = 100, // @TODO : note, this will probably be split into individual animation times
    current_color: ImVec4 = ImVec4{},
};

pub fn animateColor(from: ImVec4, to: ImVec4, duration_ms: i32, ticker: u32) ImVec4 {
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

pub fn animatedButton(label: [*c]const u8, size: ImVec2, anim: *ButtonAnim) ButtonState {
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
