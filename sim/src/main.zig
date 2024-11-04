const glfw = @import("zglfw");
const std = @import("std");
const za = @import("zalgebra");
const zgui = @import("zgui");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const Vec3 = za.Vec3;
const Vec2 = za.Vec2;

const Vertex = @import("Vertex.zig");
const Shader = @import("Shader.zig");
const object = @import("object.zig");
const VAO = object.VAO;
const VBO = object.VBO;
const EBO = object.EBO;

var wireframe: bool = false;
var paused: bool = false;

const time = struct {
    var delta: f32 = 0;
    var glfw: f32 = 0;
    var last_frame: f32 = 0;
};

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
            camera.pos = camera.pos.add(camera.front.scale(camera.speed * time.delta));
        }
        if (keys.s) {
            camera.pos = camera.pos.sub(camera.front.scale(camera.speed * time.delta));
        }
        if (keys.a) {
            camera.pos = camera.pos.sub(
                Vec3.norm(Vec3.cross(camera.front, camera.up)).scale(camera.speed * time.delta),
            );
        }
        if (keys.d) {
            camera.pos = camera.pos.add(
                Vec3.norm(Vec3.cross(camera.front, camera.up)).scale(camera.speed * time.delta),
            );
        }
    }
};

fn window_size_callback(window: *glfw.Window, width: i32, height: i32) callconv(.C) void {
    _ = window;
    gl.viewport(0, 0, @intCast(width), @intCast(height));
}

fn mouse_callback(window: *glfw.Window, x_pos: f64, y_pos: f64) callconv(.C) void {
    _ = window;

    if (paused) {
        return;
    }

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

fn scroll_callback(window: *glfw.Window, x_offset: f64, y_offset: f64) callconv(.C) void {
    _ = .{ window, x_offset };

    if (paused) {
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

fn key_callback(
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
                if (wireframe) {
                    gl.polygonMode(gl.FRONT_AND_BACK, gl.LINE);
                } else {
                    gl.polygonMode(gl.FRONT_AND_BACK, gl.FILL);
                }

                wireframe = !wireframe;
            },
            .space => {
                paused = !paused;

                if (paused) {
                    window.setInputMode(.cursor, glfw.Cursor.Mode.normal);
                } else {
                    window.setCursorPos(@floatCast(mouse.last_x), @floatCast(mouse.last_y));
                    window.setInputMode(.cursor, glfw.Cursor.Mode.disabled);
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

    glfw.init() catch {
        std.log.err("failed to initialize GLFW: ", .{});
        std.process.exit(1);
    };
    defer glfw.terminate();

    // Create our window
    glfw.windowHint(.resizable, 0);
    // glfw.windowHint(.context_version_major, 3);
    // glfw.windowHint(.context_version_minor, 3);
    // glfw.windowHintTyped(.opengl_profile, .opengl_core_profile);
    const window = glfw.Window.create(700, 700, "Physics Simulation", null) catch {
        var str = "failed to create GLFW window";
        std.log.err("failed to create GLFW window: {any}", .{glfw.maybeErrorString(@ptrCast(&str))});
        std.process.exit(1);
    };
    defer window.destroy();

    // Setting the callbacks
    _ = window.setKeyCallback(key_callback);
    _ = window.setSizeCallback(window_size_callback);
    _ = window.setCursorPosCallback(mouse_callback);
    _ = window.setScrollCallback(scroll_callback);

    window.setInputMode(.cursor, glfw.Cursor.Mode.disabled);

    glfw.makeContextCurrent(window);

    try zopengl.loadCoreProfile(glfw.getProcAddress, 3, 3);

    camera.init();

    zgui.init(gpa.allocator());
    defer zgui.deinit();

    zgui.backend.init(window);
    defer zgui.backend.deinit();

    zgui.getStyle().setColorsDark();
    const font = zgui.io.addFontFromFile("resources/caskaydia-cove.ttf", 16);
    zgui.io.setDefaultFont(font);

    gl.viewport(
        0,
        0,
        @intCast(window.getSize()[0]),
        @intCast(window.getSize()[1]),
    );

    const vertices = [_]Vertex{
        Vertex.init(
            Vec3.new(-0.5, 0.5, 0),
            Vec2.zero(),
            Vec3.zero(),
        ),
        Vertex.init(
            Vec3.new(0.5, 0.5, 0),
            Vec2.zero(),
            Vec3.zero(),
        ),
        Vertex.init(
            Vec3.new(0, 0, 0),
            Vec2.zero(),
            Vec3.zero(),
        ),
    };

    const indices = [_]gl.Uint{
        0, 1, 2,
    };

    var vao = VAO.init();
    defer vao.deinit();

    var ebo = EBO.init(&indices);
    defer ebo.deinit();

    var vbo = VBO.init(&vertices, arena.allocator());
    defer vbo.deinit();

    vao.bind();
    defer vao.unbind();

    vbo.bind();
    ebo.bind();

    const shader = try Shader.init(
        arena.allocator(),
        "shaders/vert.vert",
        "shaders/frag.frag",
    );
    defer shader.deinit();
    shader.use();

    gl.enable(gl.DEPTH_TEST);

    var model = za.Mat4.identity();
    model = model.rotate(-55.0, Vec3.new(1.0, 0.0, 0.0));

    var view = za.Mat4.identity();
    view = za.Mat4.lookAt(
        camera.pos,
        camera.pos.add(camera.front),
        camera.up,
    );

    const window_width: f32 = @floatFromInt(window.getSize()[0]);
    const window_height: f32 = @floatFromInt(window.getSize()[1]);
    const aspect_ratio: f32 = @floatCast(window_width / window_height);
    var projection = za.perspective(camera.fov, aspect_ratio, 0.1, 100.0);

    gl.clearColor(0.02, 0.2, 0.27, 1);
    time.glfw = 0;
    while (!window.shouldClose()) {
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        if (!paused) {
            time.glfw = @floatCast(glfw.getTime());
            time.delta = time.glfw - time.last_frame;
            time.last_frame = time.glfw;
        } else {
            glfw.setTime(time.glfw);
        }

        shader.set_float("time", @floatCast(time.glfw));
        model = za.Mat4.identity();
        model = model.rotate(@floatCast(time.glfw * 64), Vec3.new(1.0, 0.5, 1.0));
        shader.set_mat4("model", &model);
        view = za.Mat4.lookAt(
            camera.pos,
            camera.pos.add(camera.front),
            camera.up,
        );

        if (!paused) {
            camera.update();
        }

        shader.set_mat4("view", &view);
        projection = za.perspective(camera.fov, aspect_ratio, 0.1, 100.0);
        shader.set_mat4("projection", &projection);
        gl.drawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, @ptrFromInt(0));

        model = model.translate(Vec3.new(0, 2, -1.3));
        model = model.rotate(@floatCast(time.glfw * 32), Vec3.new(-1.0, 0.5, 0.0));
        shader.set_mat4("model", &model);
        gl.drawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, @ptrFromInt(0));

        model = model.translate(Vec3.new(3, -3, -1));
        model = model.rotate(@floatCast(time.glfw * 128), Vec3.new(0, 0.5, -0.5));
        shader.set_mat4("model", &model);
        gl.drawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, @ptrFromInt(0));

        model = model.translate(Vec3.new(-2, 3.2, 3));
        model = model.rotate(65, Vec3.new(1.0, 0.5, -0.5));
        model = model.rotate(@floatCast(time.glfw * 64), Vec3.new(1.0, 0, 0.5));
        shader.set_mat4("model", &model);
        gl.drawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, @ptrFromInt(0));

        if (paused) {
            zgui.backend.newFrame(
                @intCast(window.getSize()[0]),
                @intCast(window.getSize()[1]),
            );
            zgui.setNextWindowPos(.{ .x = 20.0, .y = 20.0, .cond = .appearing });
            zgui.setNextWindowSize(.{ .w = -1.0, .h = -1.0, .cond = .appearing });

            if (zgui.begin("My window", .{})) {
                zgui.bulletText("Hello, GUI!", .{});

                if (zgui.button("Print 'Hello, World!'", .{})) {
                    std.debug.print("Hello, World!\n", .{});
                }
            }

            zgui.end();

            zgui.backend.draw();
        }

        window.swapBuffers();
        glfw.pollEvents();
    }
}
