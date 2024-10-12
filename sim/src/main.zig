const std = @import("std");
const gl = @import("gl");
const glfw = @import("glfw");

var procs: gl.ProcTable = undefined;

const vertex_shader =
    \\#version 330 core
    \\layout (location = 0) in vec3 pos;
    \\void main() {
    \\    gl_Position = vec4(pos.x, pos.y, pos.z, 1.0);
    \\}
;

const fragment_shader =
    \\#version 330 core
    \\out vec4 fragcolor;
    \\void main() {
    \\    fragcolor = vec4(0.75, 0.2, 0.65, 1.0);
    \\}
;

pub fn main() !void {
    if (!glfw.init(.{})) {
        std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
        std.process.exit(1);
    }
    defer glfw.terminate();

    // Create our window
    const window_ = glfw.Window.create(640, 480, "Hello, mach-glfw!", null, null, .{
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

    glfw.makeContextCurrent(window);
    defer glfw.makeContextCurrent(null);

    // Initalizing OpenGL
    if (!procs.init(glfw.getProcAddress)) return error.InitFailed;

    gl.makeProcTableCurrent(&procs);
    defer gl.makeProcTableCurrent(null);

    gl.Viewport(0, 0, 640, 480);

    const vertices = [_]f32{
        0.5,  0.5,  0.0,
        0.5,  -0.5, 0.0,
        -0.5, -0.5, 0.0,
        -0.5, 0.5,  0.0,
    };

    const indices = [_]gl.uint{
        0, 1, 3,
        1, 2, 3,
    };

    var VBO: gl.uint = undefined;
    var VAO: gl.uint = undefined;
    var EBO: gl.uint = undefined;

    gl.GenVertexArrays(1, @ptrCast(&VAO));
    defer gl.DeleteVertexArrays(1, @ptrCast(&VAO));

    gl.GenBuffers(1, @ptrCast(&VBO));
    defer gl.DeleteBuffers(1, @ptrCast(&VBO));

    gl.GenBuffers(1, @ptrCast(&EBO));
    defer gl.DeleteBuffers(1, @ptrCast(&EBO));

    gl.BindVertexArray(VAO);

    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, EBO);
    gl.BufferData(
        gl.ELEMENT_ARRAY_BUFFER,
        @sizeOf(gl.uint) * indices.len,
        &indices,
        gl.STATIC_DRAW,
    );

    gl.BindBuffer(gl.ARRAY_BUFFER, VBO);
    gl.BufferData(
        gl.ARRAY_BUFFER,
        @sizeOf(f32) * vertices.len,
        &vertices,
        gl.STATIC_DRAW,
    );

    var success: i32 = 0;
    var info_log = [_]u8{0} ** 512;

    const vert = gl.CreateShader(gl.VERTEX_SHADER);
    defer gl.DeleteShader(vert);
    gl.ShaderSource(vert, 1, @ptrCast(&vertex_shader), null);
    gl.CompileShader(vert);
    gl.GetShaderiv(vert, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.GetShaderInfoLog(vert, 512, null, &info_log);
        glfw.terminate();
        std.debug.print("{s}\n", .{info_log});
        return error.ShaderFailedCompilation;
    }

    const frag = gl.CreateShader(gl.FRAGMENT_SHADER);
    defer gl.DeleteShader(frag);
    gl.ShaderSource(frag, 1, @ptrCast(&fragment_shader), null);
    gl.CompileShader(frag);
    gl.GetShaderiv(frag, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.GetShaderInfoLog(frag, 512, null, &info_log);
        glfw.terminate();
        std.debug.print("{s}\n", .{info_log});
        return error.ShaderFailedCompilation;
    }

    const program = gl.CreateProgram();
    defer gl.DeleteProgram(program);
    gl.AttachShader(program, vert);
    gl.AttachShader(program, frag);
    gl.LinkProgram(program);
    gl.GetProgramiv(program, gl.LINK_STATUS, &success);

    if (success == 0) {
        gl.GetProgramInfoLog(program, 512, null, &info_log);
        glfw.terminate();
        std.debug.print("{s}\n", .{info_log});
        return error.ProgramFailedLinking;
    }
    gl.UseProgram(program);

    gl.VertexAttribPointer(0, 3, gl.FLOAT, 0, 3 * @sizeOf(f32), 0);
    gl.EnableVertexAttribArray(0);

    gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    gl.BindVertexArray(0);
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);

    gl.BindVertexArray(VAO);
    gl.ClearColor(0.3, 0.7, 0.27, 1);
    while (!window.shouldClose()) {
        gl.Clear(gl.COLOR_BUFFER_BIT);

        gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_INT, 0);

        window.swapBuffers();
        glfw.pollEvents();
    }
}
