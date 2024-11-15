const std = @import("std");
const gl = @import("zopengl").bindings;
const zstbi = @import("zstbi");
const Shader = @import("Shader.zig");

const Self = @This();

id: gl.Uint,

pub const Extension = enum {
    png,
    jpg,
};

const texture_lut = [_][]const u8{
    "texture1",
    "texture2",
    "texture3",
    "texture4",
    "texture5",
    "texture6",
    "texture7",
    "texture8",
    "texture9",
    "texture10",
    "texture11",
    "texture12",
    "texture13",
    "texture14",
    "texture15",
    "texture16",
    "texture17",
    "texture18",
    "texture19",
    "texture20",
    "texture21",
    "texture22",
    "texture23",
    "texture24",
    "texture25",
    "texture28",
    "texture29",
    "texture31",
    "texture32",
};

pub fn init(
    filepath: [:0]const u8,
    comptime extension: Extension,
    shader: *const Shader,
) !Self {
    var id: gl.Uint = undefined;
    gl.genTextures(1, @ptrCast(&id));
    gl.bindTexture(gl.TEXTURE_2D, id);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    var image = try zstbi.Image.loadFromFile(filepath, 0);
    defer image.deinit();
    const color_type = if (extension == .jpg) gl.RGB else gl.RGBA;
    gl.texImage2D(
        gl.TEXTURE_2D,
        0,
        color_type,
        @intCast(image.width),
        @intCast(image.height),
        0,
        color_type,
        gl.UNSIGNED_BYTE,
        image.data.ptr,
    );
    gl.generateMipmap(gl.TEXTURE_2D);

    shader.set_int(texture_lut[id - 1], @intCast(id - 1));

    return .{
        .id = id,
    };
}

// Maybe should return an error if the given shader is not set
pub fn use(self: *const Self) void {
    gl.activeTexture(gl.TEXTURE0 + self.id - 1);
    gl.bindTexture(gl.TEXTURE_2D, self.id);
}
