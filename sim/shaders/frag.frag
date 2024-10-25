#version 330 core

uniform float time;

out vec4 fragcolor;

in vec3 color;

void main() {
    fragcolor = vec4(((sin(2*time)+2)/2)*color, 1.0);
}
