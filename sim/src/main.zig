const std = @import("std");
const gl = @import("gl");
const glfw = @import("glfw");
const za = @import("zalgebra");
const Vec3 = za.Vec3;

const Shader = @import("Shader.zig");
const object = @import("object.zig");
const VAO = object.VAO;
const VBO = object.VBO;
const EBO = object.EBO;

var procs: gl.ProcTable = undefined;

var wireframe: bool = false;
var pause: bool = false;

var delta_time: f32 = 0;
var last_frame: f32 = 0;

const mouse = struct {
    var last_x: f32 = 300;
    var last_y: f32 = 300;
    var sensitivity: f32 = 0.005;
    var first: bool = true;
};

const keys = struct {
    var w: bool = false;
    var s: bool = false;
    var a: bool = false;
    var d: bool = false;
};

const camera = struct {
    var speed: f32 = 2.5;

    var yaw: f32 = -90.0;
    var pitch: f32 = 0;

    var fov: f32 = 90;

    var pos = Vec3.new(0.0, 0.0, 3.0);
    var target = Vec3.new(0.0, 0.0, 0.0);
    var direction: Vec3 = undefined;
    var right: Vec3 = undefined;
    var up: Vec3 = undefined;
    var front = Vec3.new(0.0, 0.0, -1.0);

    pub fn init() void {
        direction = Vec3.norm(pos.sub(target));
        right = Vec3.norm(Vec3.cross(Vec3.up(), direction));
        up = Vec3.cross(direction, right);
    }

    pub fn update() void {
        // Update the postion based on the currently pressed keys
        if (keys.w) {
            camera.pos = camera.pos.add(camera.front.scale(camera.speed * delta_time));
        }
        if (keys.s) {
            camera.pos = camera.pos.sub(camera.front.scale(camera.speed * delta_time));
        }
        if (keys.a) {
            camera.pos = camera.pos.sub(
                Vec3.norm(Vec3.cross(camera.front, camera.up)).scale(camera.speed * delta_time),
            );
        }
        if (keys.d) {
            camera.pos = camera.pos.add(
                Vec3.norm(Vec3.cross(camera.front, camera.up)).scale(camera.speed * delta_time),
            );
        }
    }
};

fn window_size_callback(window: glfw.Window, width: i32, height: i32) void {
    _ = window;
    gl.Viewport(0, 0, @intCast(width), @intCast(height));
}

fn mouse_callback(window: glfw.Window, x_pos: f64, y_pos: f64) void {
    _ = window;

    if (mouse.first) {
        mouse.last_x = @floatCast(x_pos);
        mouse.last_y = @floatCast(y_pos);
        mouse.first = false;
    }

    var x_offset: f32 = @floatCast(x_pos - mouse.last_x);
    var y_offset: f32 = @floatCast(mouse.last_y - y_pos);
    mouse.last_x = @floatCast(x_pos);
    mouse.last_y = @floatCast(y_pos);

    x_offset *= mouse.sensitivity;
    y_offset *= mouse.sensitivity;

    camera.pitch += y_offset;
    camera.yaw += x_offset;

    if (camera.pitch >= 89.0)
        camera.pitch = 89;
    if (camera.pitch <= -89.0)
        camera.pitch = -89;

    camera.front.xMut().* = @cos(camera.yaw) * @cos(camera.pitch);
    camera.front.yMut().* = @sin(camera.pitch);
    camera.front.zMut().* = @sin(camera.yaw) * @cos(camera.pitch);
    camera.front = camera.front.norm();
}

fn scroll_callback(window: glfw.Window, x_offset: f64, y_offset: f64) void {
    _ = .{ window, x_offset };

    camera.fov -= @floatCast(y_offset);

    const lower: f32 = 1;
    const upper: f32 = 90;

    if (camera.fov < lower)
        camera.fov = lower;
    if (camera.fov > upper)
        camera.fov = upper;
}

fn key_callback(
    window: glfw.Window,
    key: glfw.Key,
    scancode: i32,
    action: glfw.Action,
    mods: glfw.Mods,
) void {
    _ = .{ window, scancode, mods };

    if (action == .press) {
        switch (key) {
            .t => {
                if (wireframe) {
                    gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE);
                } else {
                    gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL);
                }

                wireframe = !wireframe;
            },
            .space => {
                pause = !pause;

                if (pause) {
                    window.setCursorPosCallback(null);
                    window.setScrollCallback(null);
                    window.setInputModeCursor(.normal);
                } else {
                    window.setCursorPosCallback(mouse_callback);
                    window.setScrollCallback(scroll_callback);
                    window.setInputModeCursor(.disabled);
                    window.setCursorPos(@floatCast(mouse.last_x), @floatCast(mouse.last_y));
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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());

    defer {
        arena.deinit();

        if (gpa.deinit() == .leak) {
            std.log.err("{}\n", .{gpa.detectLeaks()});
        }
    }

    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const window_ = glfw.Window.create(600, 600, "Physics Simulation", null, null, .{
        .resizable = false,
        .context_version_major = 3,
        .context_version_minor = 3,
        .opengl_profile = .opengl_core_profile,
    });
    if (window_ == null) {
        std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    const window = window_.?;
    defer window.destroy();

    // Setting the callbacks
    window.setKeyCallback(key_callback);
    window.setSizeCallback(window_size_callback);
    window.setCursorPosCallback(mouse_callback);
    window.setScrollCallback(scroll_callback);

    window.setInputModeCursor(.disabled);

    glfw.makeContextCurrent(window);
    defer glfw.makeContextCurrent(null);

    // Initalizing OpenGL
    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    camera.init();

    gl.Viewport(
        0,
        0,
        @intCast(window.getSize().width),
        @intCast(window.getSize().height),
    );

    const vertices = [_]f32{
        // front
        0.5, 0.5, 0.5, 1.0, 0.0, 0.0, // top right
        -0.5, 0.5, 0.5, 0.0, 1.0, 0.0, // top left
        0.5, -0.5, 0.5, 0.0, 0.0, 1.0, // bottom right
        -0.5, -0.5, 0.5, 1.0, 0.0, 1.0, // bottom left
        // back
        0.5, 0.5, -0.5, 1.0, 1.0, 0.0, // top right
        -0.5, 0.5, -0.5, 0.0, 1.0, 0.0, // top left
        0.5, -0.5, -0.5, 0.0, 0.0, 1.0, // bottom right
        -0.5, -0.5, -0.5, 1.0, 0.0, 1.0, // bottom left
    };

    const indices = [_]gl.uint{
        0, 1, 3,
        0, 3, 2,
        4, 6, 0,
        2, 6, 0,
        6, 7, 4,
        5, 7, 4,
        3, 1, 7,
        5, 1, 7,
        5, 4, 1,
        0, 4, 1,
        2, 3, 7,
        2, 6, 7,
    };

    var vao = VAO.init();
    defer vao.deinit();

    var ebo = EBO.init(&indices);
    defer ebo.deinit();

    var vbo = VBO.init(&vertices);
    defer vbo.deinit();

    vao.bind();
    defer vao.unbind();

    vbo.bind();
    ebo.bind();

    gl.EnableVertexAttribArray(0);
    gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), 0);

    gl.EnableVertexAttribArray(1);
    gl.VertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 6 * @sizeOf(f32), 3 * @sizeOf(f32));

    const shader = try Shader.init(
        arena.allocator(),
        "shaders/vert.vert",
        "shaders/frag.frag",
    );
    defer shader.deinit();
    shader.use();

    gl.Enable(gl.DEPTH_TEST);

    var model = za.Mat4.identity();
    model = model.rotate(-55.0, Vec3.new(1.0, 0.0, 0.0));

    var view = za.Mat4.identity();
    view = za.Mat4.lookAt(
        camera.pos,
        camera.pos.add(camera.front),
        camera.up,
    );

    const window_width: f32 = @floatFromInt(window.getSize().width);
    const window_height: f32 = @floatFromInt(window.getSize().height);
    const aspect_ratio: f32 = @floatCast(window_width / window_height);
    var projection = za.perspective(camera.fov, aspect_ratio, 0.1, 100.0);

    var direction = Vec3.zero();
    direction.xMut().* = @cos(camera.yaw) * @cos(camera.pitch);
    direction.yMut().* = @sin(camera.pitch);
    direction.zMut().* = @sin(camera.yaw) * @cos(camera.pitch);

    gl.ClearColor(0.02, 0.2, 0.27, 1);
    var time: f64 = 0;
    while (!window.shouldClose()) {
        if (!pause) {
            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

            time = glfw.getTime();
            delta_time = @floatCast(time - last_frame);
            last_frame = @floatCast(time);

            shader.set_float("time", @floatCast(time));
            model = za.Mat4.identity();
            model = model.rotate(@floatCast(time * 64), Vec3.new(1.0, 0.5, 1.0));
            shader.set_mat4("model", &model);
            view = za.Mat4.lookAt(
                camera.pos,
                camera.pos.add(camera.front),
                camera.up,
            );
            camera.update();
            shader.set_mat4("view", &view);
            projection = za.perspective(camera.fov, aspect_ratio, 0.1, 100.0);
            shader.set_mat4("projection", &projection);
            gl.DrawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, 0);

            model = model.translate(Vec3.new(0, 2, -1.3));
            model = model.rotate(@floatCast(time * 32), Vec3.new(-1.0, 0.5, 0.0));
            shader.set_mat4("model", &model);
            gl.DrawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, 0);

            model = model.translate(Vec3.new(3, -3, -1));
            model = model.rotate(@floatCast(time * 128), Vec3.new(0, 0.5, -0.5));
            shader.set_mat4("model", &model);
            gl.DrawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, 0);

            model = model.translate(Vec3.new(-2, 3.2, 3));
            model = model.rotate(65, Vec3.new(1.0, 0.5, -0.5));
            model = model.rotate(@floatCast(time * 64), Vec3.new(1.0, 0, 0.5));
            shader.set_mat4("model", &model);
            gl.DrawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, 0);

            window.swapBuffers();
        }

        glfw.setTime(time);

        glfw.pollEvents();
    }
}
