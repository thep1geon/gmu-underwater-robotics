const std = @import("std");
const za = @import("zalgebra");
const Vec2 = za.Vec2;
const Vec3 = za.Vec3;

const Self = @This();

pos: Vec3,
tex_coord: Vec2,
normal: Vec3,

pub fn init(pos: Vec3, tex_coord: Vec2, normal: Vec3) Self {
    return .{
        .pos = pos,
        .tex_coord = tex_coord,
        .normal = normal,
    };
}
