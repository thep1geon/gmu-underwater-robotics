const glfw = @import("zglfw");
const std = @import("std");
const zgui = @import("zgui");
const zstbi = @import("zstbi");

const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const za = @import("zalgebra");
const Vec3 = za.Vec3;
const Vec2 = za.Vec2;

const keys = @import("keys.zig");
const camera = @import("camera.zig");
const mouse = @import("mouse.zig");
const time = @import("time.zig");
const callbacks = @import("callbacks.zig");
const settings = @import("settings.zig");
const objects = @import("objects.zig");
const VAO = objects.VAO;
const VBO = objects.VBO;
const EBO = objects.EBO;

const Texture = @import("Texture.zig");
const Vertex = @import("Vertex.zig");
const Shader = @import("Shader.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    defer if (gpa.deinit() == .leak) {
        std.log.err("{}\n", .{gpa.detectLeaks()});
    };

    zstbi.init(gpa.allocator());
    defer zstbi.deinit();
    zstbi.setFlipVerticallyOnLoad(true);

    glfw.init() catch {
        std.log.err("failed to initialize GLFW: ", .{});
        std.process.exit(1);
    };
    defer glfw.terminate();

    // Create our window
    glfw.windowHint(.resizable, 0);
    glfw.windowHint(.context_version_major, 3);
    glfw.windowHint(.context_version_minor, 3);
    glfw.windowHintTyped(.opengl_profile, .opengl_core_profile);
    const window = glfw.Window.create(800, 800, "Physics Simulation", null) catch {
        var str = "failed to create GLFW window";
        std.log.err("failed to create GLFW window: {any}", .{glfw.maybeErrorString(@ptrCast(&str))});
        std.process.exit(1);
    };
    defer window.destroy();

    // Setting the callbacks
    _ = window.setKeyCallback(callbacks.key_callback);
    _ = window.setSizeCallback(callbacks.window_size_callback);
    _ = window.setCursorPosCallback(callbacks.mouse_callback);
    _ = window.setScrollCallback(callbacks.scroll_callback);

    mouse.last_x = @as(f32, @floatFromInt(window.getSize()[0])) / @as(f32, 2);
    mouse.last_y = @as(f32, @floatFromInt(window.getSize()[1])) / @as(f32, 2);

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
            Vec3.new(0.5, 0.5, 0),
            Vec2.new(1, 1),
            Vec3.new(1, 0, 0),
        ),
        Vertex.init(
            Vec3.new(0.5, -0.5, 0),
            Vec2.new(1, 0),
            Vec3.new(0, 1, 0),
        ),
        Vertex.init(
            Vec3.new(-0.5, -0.5, 0),
            Vec2.new(0, 0),
            Vec3.new(0, 0, 1),
        ),
        Vertex.init(
            Vec3.new(-0.5, 0.5, 0),
            Vec2.new(0, 1),
            Vec3.new(1, 1, 0),
        ),
    };

    const indices = [_]gl.Uint{
        0, 1, 3,
        1, 2, 3,
    };

    var vao = VAO.init();
    defer vao.deinit();

    var ebo = EBO.init(&indices);
    defer ebo.deinit();

    var vbo = VBO.init(&vertices, gpa.allocator());
    defer vbo.deinit();

    vao.bind();
    defer vao.unbind();

    vbo.bind();
    ebo.bind();

    const shader = try Shader.init(
        gpa.allocator(),
        "shaders/vert.vert",
        "shaders/frag.frag",
    );
    defer shader.deinit();
    shader.use();

    const brick_tex = try Texture.init(
        "resources/wall.jpg",
        .jpg,
        &shader,
    );
    const smile_tex = try Texture.init(
        "resources/awesomeface.png",
        .png,
        &shader,
    );

    brick_tex.use();
    smile_tex.use();

    gl.enable(gl.DEPTH_TEST);

    var model = za.Mat4.identity();
    model = model.rotate(-55.0, Vec3.new(1.0, 0.0, 0.0));

    gl.clearColor(0.02, 0.2, 0.27, 1);
    time.glfw = 0;
    while (!window.shouldClose()) {
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        if (!settings.paused) {
            time.glfw = @floatCast(glfw.getTime());
            time.delta = time.glfw - time.last_frame;
            time.last_frame = time.glfw;
            camera.update_pos();
        } else {
            glfw.setTime(time.glfw);
        }

        shader.set_float("time", @floatCast(time.glfw));
        model = za.Mat4.identity();
        model = model.rotate(@floatCast(time.glfw * 64), Vec3.new(1.0, 0.5, 1.0));
        shader.set_mat4("model", &model);
        camera.view = za.Mat4.lookAt(
            camera.pos,
            camera.pos.add(camera.front),
            camera.up,
        );

        shader.set_mat4("view", &camera.view);
        camera.projection = za.perspective(camera.fov, camera.aspect_ratio, 0.1, 100.0);
        shader.set_mat4("projection", &camera.projection);
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

        model = model.translate(Vec3.new(5, -4, 0));
        model = model.rotate(32, Vec3.new(0.5, 0, 0));
        model = model.rotate(@floatCast(time.glfw * 32), Vec3.new(0.5, 0, 0.5));
        shader.set_mat4("model", &model);
        gl.drawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, @ptrFromInt(0));

        model = model.translate(Vec3.new(-4, 3.2, 3));
        model = model.rotate(-128, Vec3.new(0, 0.5, 0));
        model = model.rotate(@floatCast(time.glfw * 256), Vec3.new(0, 0.9, 0));
        shader.set_mat4("model", &model);
        gl.drawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, @ptrFromInt(0));

        zgui.backend.newFrame(
            @intCast(window.getSize()[0]),
            @intCast(window.getSize()[1]),
        );

        if (settings.paused) {
            zgui.setNextWindowPos(.{ .x = 20.0, .y = 20.0, .cond = .appearing });
            zgui.setNextWindowSize(.{ .w = -1.0, .h = -1.0, .cond = .appearing });

            if (zgui.begin("My window", .{})) {
                zgui.bulletText("Hello, GUI!", .{});

                if (zgui.button("Print 'Hello, World!'", .{})) {
                    std.debug.print("Hello, World!\n", .{});
                }
            }

            zgui.end();
        }

        zgui.showMetricsWindow(null);

        zgui.backend.draw();

        window.swapBuffers();
        glfw.pollEvents();
    }
}
