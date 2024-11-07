const gl = @import("zopengl").bindings;
const za = @import("zalgebra");
const keys = @import("keys.zig");
const camera = @import("camera.zig");
const time = @import("time.zig");
const Vec3 = za.Vec3;

pub var speed: f32 = 5.0;

pub var yaw: f32 = 0;
pub var pitch: f32 = 0;

pub var fov: f32 = 90;

pub var pos = Vec3.new(0.0, 0.0, 3.0);
pub var target = Vec3.new(0.0, 0.0, 0.0);
pub var direction: Vec3 = undefined;
pub var right: Vec3 = undefined;
pub var up: Vec3 = undefined;
pub var front = Vec3.new(0.0, 0.0, -1.0);

pub var view = za.Mat4.identity();

pub var aspect_ratio: f32 = undefined;
pub var projection: za.Mat4 = undefined;

pub fn init() void {
    direction = Vec3.norm(pos.sub(target));
    right = Vec3.norm(Vec3.cross(Vec3.up(), direction));
    up = Vec3.cross(direction, right);

    projection = za.perspective(fov, aspect_ratio, 0.1, 100.0);

    var viewport: [4]gl.Int = [_]i32{0} ** 4;
    gl.getIntegerv(gl.VIEWPORT, @ptrCast(&viewport));
    const window_width = viewport[2];
    const window_height = viewport[3];
    aspect_ratio = @floatFromInt(@divTrunc(window_width, window_height));

    view = za.Mat4.lookAt(
        pos,
        pos.add(front),
        up,
    );
}

pub fn update_pos() void {
    // Update the postion based on the currently pressed keys
    if (keys.w) {
        pos = pos.add(front.scale(speed * time.delta));
    }
    if (keys.s) {
        pos = pos.sub(front.scale(speed * time.delta));
    }
    if (keys.a) {
        pos = pos.sub(
            Vec3.norm(Vec3.cross(front, up)).scale(speed * time.delta),
        );
    }
    if (keys.d) {
        pos = pos.add(
            Vec3.norm(Vec3.cross(front, up)).scale(speed * time.delta),
        );
    }
}

pub fn update() void {
    camera.front.xMut().* = @cos(camera.yaw) * @cos(camera.pitch);
    camera.front.yMut().* = @sin(camera.pitch);
    camera.front.zMut().* = @sin(camera.yaw) * @cos(camera.pitch);
    camera.front = camera.front.norm();
}
