pub const packages = struct {
    pub const @"122034f9b19b0cf44680c98d26e5f67666f356d32194822468263b2dd608dd3ef173" = struct {
        pub const build_root = "/home/magic/Robotics/sim/.libs/zgui/../zgpu";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"12206288b3184abd33ae433bb45b25ae0de6f4500907cb7dba62964f27aba240d53f" = struct {
        pub const build_root = "/home/magic/Robotics/sim/.libs/zgui/../zglfw";
        pub const build_zig = @import("12206288b3184abd33ae433bb45b25ae0de6f4500907cb7dba62964f27aba240d53f");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "system_sdk", "1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" },
        };
    };
    pub const @"1220babb7939707ca390b934657dfd3c8c3a6a78cc9442e4cbd43e3f9ffd49daec9e" = struct {
        pub const available = false;
    };
    pub const @"1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" = struct {
        pub const build_root = "/home/magic/Robotics/sim/.libs/zgui/../system-sdk";
        pub const build_zig = @import("1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "zglfw", "12206288b3184abd33ae433bb45b25ae0de6f4500907cb7dba62964f27aba240d53f" },
    .{ "zgpu", "122034f9b19b0cf44680c98d26e5f67666f356d32194822468263b2dd608dd3ef173" },
    .{ "system_sdk", "1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" },
    .{ "freetype", "1220babb7939707ca390b934657dfd3c8c3a6a78cc9442e4cbd43e3f9ffd49daec9e" },
};
