#version 330 core

out vec4 fragcolor;

in vec3 color;

void main() {
    fragcolor = vec4(color, 1.0);
}
