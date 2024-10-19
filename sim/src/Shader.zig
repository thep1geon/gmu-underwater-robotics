const std = @import("std");
const gl = @import("gl");

const Self = @This();

var log = [_]u8{0} ** 512;
var success: i32 = 0;

id: gl.uint,
vert: gl.uint,
frag: gl.uint,

pub fn init(allocator: std.mem.Allocator, vert_filename: []const u8, frag_filename: []const u8) !Self {
    const vert_source = try slurpfile(allocator, vert_filename);
    defer allocator.free(vert_source);

    const vert_shader = gl.CreateShader(gl.VERTEX_SHADER);
    defer gl.DeleteShader(vert_shader);
    gl.ShaderSource(vert_shader, 1, @ptrCast(&vert_source), null);
    gl.CompileShader(vert_shader);
    try check_compilation(vert_shader);

    const frag_source = try slurpfile(allocator, frag_filename);
    defer allocator.free(frag_source);

    const frag_shader = gl.CreateShader(gl.FRAGMENT_SHADER);
    defer gl.DeleteShader(frag_shader);
    gl.ShaderSource(frag_shader, 1, @ptrCast(&frag_source), null);
    gl.CompileShader(frag_shader);
    try check_compilation(frag_shader);

    const program = gl.CreateProgram();
    gl.AttachShader(program, vert_shader);
    gl.AttachShader(program, frag_shader);
    gl.LinkProgram(program);
    try check_linking(program);

    return Self{
        .id = program,
        .vert = vert_shader,
        .frag = frag_shader,
    };
}

pub fn deinit(self: *const Self) void {
    gl.DeleteProgram(self.id);
}

pub fn use(self: *const Self) void {
    gl.UseProgram(self.id);
}

pub fn disable(self: *const Self) void {
    _ = self;
    gl.UseProgram(0);
}

pub fn set_float(self: *const Self, name: []const u8, value: f32) void {
    gl.Uniform1f(gl.GetUniformLocation(self.id, @ptrCast(name.ptr)), value);
}

fn check_linking(program: gl.uint) !void {
    gl.GetProgramiv(program, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.GetProgramInfoLog(program, 512, null, &log);
        std.log.err("{s}\n", .{log});
        return error.ProgramFailedLinking;
    }
}

fn check_compilation(shader: gl.uint) !void {
    gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success);

    if (success == 0) {
        gl.GetShaderInfoLog(shader, 512, null, &log);
        std.log.err("{s}\n", .{log});
        return error.ShaderFailedCompilation;
    }
}

fn slurpfile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    return file.readToEndAlloc(allocator, std.math.maxInt(i32));
}
