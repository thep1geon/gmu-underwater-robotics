const std = @import("std");
const glfw = @import("glfw");
const gl = @import("gl");

// *----------------*
// All things objects
// *----------------*

// Vertex Array Object
pub const VAO = struct {
    id: gl.uint,

    pub fn init() VAO {
        var id: gl.uint = undefined;
        gl.GenVertexArrays(1, @ptrCast(&id));

        return .{
            .id = id,
        };
    }

    pub fn deinit(self: *VAO) void {
        gl.DeleteVertexArrays(1, @ptrCast(&self.id));
    }

    pub fn bind(self: *const VAO) void {
        gl.BindVertexArray(self.id);
    }

    pub fn unbind(self: *const VAO) void {
        _ = self;
        gl.BindVertexArray(0);
    }
};

// vertex buffer object
// var vbo: gl.uint = undefined;
// gl.genbuffers(1, @ptrcast(&vbo));
// defer gl.deletebuffers(1, @ptrcast(&vbo));
pub const VBO = struct {
    bound: bool,
    id: gl.uint,
    vertices: []const f32,

    pub fn init(data: []const f32) VBO {
        var id: gl.uint = undefined;
        gl.GenBuffers(1, @ptrCast(&id));

        var vbo = VBO{
            .id = id,
            .vertices = data,
            .bound = false,
        };

        var bound_buffer: gl.uint = undefined;
        gl.GetIntegerv(gl.ARRAY_BUFFER, @ptrCast(&bound_buffer));

        vbo.bind();

        vbo.set_data(vbo.vertices) catch @panic("UNREACHABLE");

        gl.BindBuffer(gl.ARRAY_BUFFER, bound_buffer);

        return vbo;
    }

    pub fn deinit(self: *VBO) void {
        gl.DeleteBuffers(1, @ptrCast(&self.id));
    }

    pub fn bind(self: *VBO) void {
        self.bound = true;
        gl.BindBuffer(gl.ARRAY_BUFFER, self.id);
    }

    pub fn unbind(self: *VBO) void {
        self.bound = false;
        gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    }

    pub fn set_data(self: *const VBO, verts: []const f32) !void {
        if (!self.bound) return error.BufferNotBound;
        gl.BufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * verts.len), verts.ptr, gl.STATIC_DRAW);
    }
};

// Element Buffer Object
pub const EBO = struct {
    id: gl.uint,
    indices: []const gl.uint,
    bound: bool,

    pub fn init(data: []const gl.uint) EBO {
        var id: gl.uint = undefined;
        gl.GenBuffers(1, @ptrCast(&id));

        var ebo = EBO{
            .id = id,
            .indices = data,
            .bound = false,
        };

        var bound_buffer: gl.uint = undefined;
        gl.GetIntegerv(gl.ELEMENT_ARRAY_BUFFER, @ptrCast(&bound_buffer));

        ebo.bind();

        ebo.set_data(ebo.indices) catch @panic("UNREACHABLE");

        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, bound_buffer);

        return ebo;
    }

    pub fn deinit(self: *EBO) void {
        gl.DeleteBuffers(1, @ptrCast(&self.id));
    }

    pub fn bind(self: *EBO) void {
        self.bound = true;
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }

    pub fn unbind(self: *EBO) void {
        self.bound = false;
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }

    pub fn set_data(self: *const EBO, indices: []const gl.uint) !void {
        if (!self.bound) return error.BufferNotBound;
        gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(gl.uint) * indices.len), indices.ptr, gl.STATIC_DRAW);
    }
};
