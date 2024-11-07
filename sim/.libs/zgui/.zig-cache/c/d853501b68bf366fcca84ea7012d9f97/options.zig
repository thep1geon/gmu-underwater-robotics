pub const @"build.Backend" = enum (u3) {
    no_backend = 0,
    glfw_wgpu = 1,
    glfw_opengl3 = 2,
    glfw_dx12 = 3,
    win32_dx12 = 4,
    glfw = 5,
};
pub const backend: @"build.Backend" = .no_backend;
pub const shared: bool = false;
pub const with_implot: bool = true;
pub const with_gizmo: bool = true;
pub const with_node_editor: bool = true;
pub const with_te: bool = false;
pub const with_freetype: bool = false;
pub const use_wchar32: bool = false;
