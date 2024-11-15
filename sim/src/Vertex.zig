const std = @import("std");
const za = @import("zalgebra");
const Vec2 = za.Vec2;
const Vec3 = za.Vec3;

const Self = @This();

pos: Vec3,
uvs: Vec2,
normal: Vec3,

pub fn init(pos: Vec3, uvs: Vec2, normal: Vec3) Self {
    return .{
        .pos = pos,
        .uvs = uvs,
        .normal = normal,
    };
}

pub fn to_slice(self: *const Self) [8]f32 {
    const pos: [3]f32 = self.pos.data;
    const uvs: [2]f32 = self.uvs.data;
    const normal: [3]f32 = self.normal.data;
    return pos ++ uvs ++ normal;
}
