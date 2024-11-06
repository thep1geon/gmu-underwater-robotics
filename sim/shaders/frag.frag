#version 330 core

uniform float time;
uniform sampler2D texture1;
uniform sampler2D texture2;

out vec4 fragcolor;

in vec3 color;
in vec2 uv;

void main() {
    fragcolor = mix(texture(texture1, uv), texture(texture2, uv), 0.2);
    fragcolor *= vec4(color, 0.5);
}
