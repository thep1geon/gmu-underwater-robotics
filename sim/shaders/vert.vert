#version 330 core

layout (location = 0) in vec3 a_pos;
layout (location = 1) in vec3 a_color;

uniform float time;

out vec3 color;

void main() {
    gl_Position = vec4(a_pos.x*cos(time), a_pos.y*sin(time), a_pos.z+sin(time), 1.0);
    color = a_color;
}
