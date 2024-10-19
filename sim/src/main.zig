const std = @import("std");
const gl = @import("gl");
const glfw = @import("glfw");

const Shader = @import("Shader.zig");
const object = @import("object.zig");
const VAO = object.VAO;
const VBO = object.VBO;
const EBO = object.EBO;

const Camera = @import("Camera.zig");

var procs: gl.ProcTable = undefined;

var wireframe: bool = false;

fn toggle_wireframe() void {
    wireframe = !wireframe;
}

fn window_size_callback(window: glfw.Window, width: i32, height: i32) void {
    _ = window;
    gl.Viewport(0, 0, @intCast(width), @intCast(height));
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
        if (key == .space) {
            toggle_wireframe();
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

    window.setKeyCallback(key_callback);
    window.setSizeCallback(window_size_callback);

    glfw.makeContextCurrent(window);
    defer glfw.makeContextCurrent(null);

    // Initalizing OpenGL
    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    gl.Viewport(
        0,
        0,
        @intCast(window.getSize().width),
        @intCast(window.getSize().height),
    );

    const vertices = [_]f32{
        // front
        0.5, 0.5, 0.5, 1.0, 0.0, 1.0, // top right
        -0.5, 0.5, 0.5, 1.0, 0.0, 1.0, // top left
        0.5, -0.5, 0.5, 1.0, 0.0, 1.0, // bottom right
        -0.5, -0.5, 0.5, 0.0, 1.0, 1.0, // bottom left
        // back
        0.5, 0.5, -0.5, 0.0, 1.0, 1.0, // top right
        -0.5, 0.5, -0.5, 1.0, 1.0, 1.0, // top left
        0.5, -0.5, -0.5, 0.0, 0.0, 1.0, // bottom right
        -0.5, -0.5, -0.5, 1.0, 0.0, 1.0, // bottom left
    };

    const indices = [_]gl.uint{
        0, 1, 2,
        3, 1, 2,
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

    gl.ClearColor(0.02, 0.2, 0.27, 1);
    while (!window.shouldClose()) {
        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        if (wireframe) {
            gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE);
        } else {
            gl.PolygonMode(gl.FRONT_AND_BACK, gl.FILL);
        }

        const time = glfw.getTime();
        shader.set_float("time", @floatCast(time));

        gl.DrawElements(gl.TRIANGLES, @intCast(ebo.indices.len), gl.UNSIGNED_INT, 0);

        window.swapBuffers();
        glfw.pollEvents();
    }
}
