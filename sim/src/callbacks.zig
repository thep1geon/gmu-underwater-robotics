const std = @import("std");
const glfw = @import("zglfw");
const gl = @import("zopengl").bindings;

const mouse = @import("mouse.zig");
const settings = @import("settings.zig");
const keys = @import("keys.zig");
const camera = @import("camera.zig");

pub fn window_size_callback(window: *glfw.Window, width: i32, height: i32) callconv(.C) void {
    _ = window;
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

pub fn mouse_callback(window: *glfw.Window, x_pos: f64, y_pos: f64) callconv(.C) void {
    _ = window;

    mouse.moved = true;

    if (mouse.first) {
        mouse.last_x = @floatCast(x_pos);
        mouse.last_y = @floatCast(y_pos);
        mouse.first = false;
    }

    var x_offset: f32 = @floatCast(x_pos - mouse.last_x);
    var y_offset: f32 = @floatCast(mouse.last_y - y_pos);
    mouse.last_x = @floatCast(x_pos);
    mouse.last_y = @floatCast(y_pos);

    if (settings.paused) {
        return;
    }

    x_offset *= mouse.sensitivity;
    y_offset *= mouse.sensitivity;

    camera.pitch += y_offset;
    camera.yaw += x_offset;

    camera.front.xMut().* = @cos(camera.yaw) * @cos(camera.pitch);
    camera.front.yMut().* = @sin(camera.pitch);
    camera.front.zMut().* = @sin(camera.yaw) * @cos(camera.pitch);
    camera.front = camera.front.norm();
}

pub fn scroll_callback(window: *glfw.Window, x_offset: f64, y_offset: f64) callconv(.C) void {
    _ = .{ window, x_offset };

    if (settings.paused) {
        return;
    }

    camera.fov -= @floatCast(y_offset);

    const lower: f32 = 1;
    const upper: f32 = 90;

    if (camera.fov < lower)
        camera.fov = lower;
    if (camera.fov > upper)
        camera.fov = upper;
}

pub fn key_callback(
    window: *glfw.Window,
    key: glfw.Key,
    scancode: i32,
    action: glfw.Action,
    mods: glfw.Mods,
) callconv(.C) void {
    _ = .{ window, scancode, mods };

    if (action == .press) {
        switch (key) {
            .t => {
                if (settings.wireframe) {
                    gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);
                } else {
                    gl.polygonMode(gl.FRONT_AND_BACK, gl.FILL);
                }

                settings.wireframe = !settings.wireframe;
            },
            .space => {
                settings.paused = !settings.paused;

                if (settings.paused) {
                    window.setInputMode(.cursor, glfw.Cursor.Mode.normal);
                    mouse.moved = false;
                } else {
                    window.setInputMode(.cursor, glfw.Cursor.Mode.disabled);
                    if (!mouse.moved) {
                        window.setCursorPos(@floatCast(mouse.last_x), @floatCast(mouse.last_y));
                    }
                }
            },
            .q => window.setShouldClose(true),
            .w => keys.w = true,
            .s => keys.s = true,
            .a => keys.a = true,
            .d => keys.d = true,
            else => {},
        }
    }

    if (action == .release) {
        switch (key) {
            .w => keys.w = false,
            .s => keys.s = false,
            .a => keys.a = false,
            .d => keys.d = false,
            else => {},
        }
    }
}
