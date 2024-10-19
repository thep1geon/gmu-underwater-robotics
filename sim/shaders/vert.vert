#version 330 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec3 a_color;

uniform float time;

out vec3 color;

mat3 rotate3d_x(float theta) {
    return mat3(1, 0, 0,
                0, cos(theta), -sin(theta),
                0, sin(theta), cos(theta));
}

mat3 rotate3d_y(float theta) {
    return mat3(cos(theta), 0, sin(theta),
                0, 1, 0,
                -sin(theta), 0, cos(theta));
}

mat3 rotate3d_z(float theta) {
    return mat3(cos(theta), -sin(theta), 0,
                sin(theta), cos(theta), 0,
                0, 0, 1);
}

void main() {
    vec3 pos = a_pos * rotate3d_z(time) * rotate3d_y(time) * rotate3d_x(time);
    gl_Position = vec4(pos, 1.0);
    color = a_color;
}
