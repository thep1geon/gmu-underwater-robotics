const std = @import("std");
const glfw = @import("zglfw");
const gl = @import("zopengl").bindings;
const Vertex = @import("Vertex.zig");

// *----------------*
// All things objects
// *----------------*

// Vertex Array Object
pub const VAO = struct {
    id: gl.Uint,

    pub fn init() VAO {
        var id: gl.Uint = undefined;
        gl.genVertexArrays(1, @ptrCast(&id));

        return .{
            .id = id,
        };
    }

    pub fn deinit(self: *VAO) void {
        gl.deleteVertexArrays(1, @ptrCast(&self.id));
    }

    pub fn bind(self: *const VAO) void {
        gl.bindVertexArray(self.id);

        // Position
        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), null);

        // uv
        gl.enableVertexAttribArray(1);
        gl.vertexAttribPointer(1, 2, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));

        // normal
        gl.enableVertexAttribArray(2);
        gl.vertexAttribPointer(2, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), @ptrFromInt(5 * @sizeOf(f32)));
    }

    pub fn unbind(self: *const VAO) void {
        _ = self;
        gl.bindVertexArray(0);
    }
};

// vertex buffer object
// var vbo: gl.uint = undefined;
// gl.genbuffers(1, @ptrcast(&vbo));
// defer gl.deletebuffers(1, @ptrcast(&vbo));
pub const VBO = struct {
    bound: bool,
    id: gl.Uint,
    vertices: []const Vertex,

    pub fn init(data: []const Vertex, allocator: std.mem.Allocator) VBO {
        var id: gl.Uint = undefined;
        gl.genBuffers(1, @ptrCast(&id));

        var vbo = VBO{
            .id = id,
            .vertices = data,
            .bound = false,
        };

        var bound_buffer: gl.Uint = undefined;
        gl.getIntegerv(gl.ARRAY_BUFFER, @ptrCast(&bound_buffer));

        vbo.bind();

        vbo.send_data(vbo.vertices, allocator) catch @panic("UNREACHABLE");

        gl.bindBuffer(gl.ARRAY_BUFFER, bound_buffer);

        return vbo;
    }

    pub fn deinit(self: *VBO) void {
        gl.deleteBuffers(1, @ptrCast(&self.id));
    }

    pub fn bind(self: *VBO) void {
        self.bound = true;
        gl.bindBuffer(gl.ARRAY_BUFFER, self.id);
    }

    pub fn unbind(self: *VBO) void {
        self.bound = false;
        gl.bindBuffer(gl.ARRAY_BUFFER, 0);
    }

    pub fn send_data(self: *const VBO, verts: []const Vertex, allocator: std.mem.Allocator) !void {
        _ = allocator;
        if (!self.bound) return error.BufferNotBound;
        gl.bufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * verts.len), verts.ptr, gl.STATIC_DRAW);
    }
};

// Element Buffer Object
pub const EBO = struct {
    id: gl.Uint,
    indices: []const gl.Uint,
    bound: bool,

    pub fn init(data: []const gl.Uint) EBO {
        var id: gl.Uint = undefined;
        gl.genBuffers(1, @ptrCast(&id));

        var ebo = EBO{
            .id = id,
            .indices = data,
            .bound = false,
        };

        var bound_buffer: gl.Uint = undefined;
        gl.getIntegerv(gl.ELEMENT_ARRAY_BUFFER, @ptrCast(&bound_buffer));

        ebo.bind();

        ebo.set_data(ebo.indices) catch @panic("UNREACHABLE");

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, bound_buffer);

        return ebo;
    }

    pub fn deinit(self: *EBO) void {
        gl.deleteBuffers(1, @ptrCast(&self.id));
    }

    pub fn bind(self: *EBO) void {
        self.bound = true;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }

    pub fn unbind(self: *EBO) void {
        self.bound = false;
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }

    pub fn set_data(self: *const EBO, indices: []const gl.Uint) !void {
        if (!self.bound) return error.BufferNotBound;
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(gl.Uint) * indices.len), indices.ptr, gl.STATIC_DRAW);
    }
};
