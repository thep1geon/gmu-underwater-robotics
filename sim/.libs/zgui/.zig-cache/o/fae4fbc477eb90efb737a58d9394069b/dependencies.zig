pub const packages = struct {
    pub const @"12201fe677e9c7cfb8984a36446b329d5af23d03dc1e4f79a853399529e523a007fa" = struct {
        pub const available = false;
    };
    pub const @"122034f9b19b0cf44680c98d26e5f67666f356d32194822468263b2dd608dd3ef173" = struct {
        pub const build_root = "/home/magic/Robotics/sim/libs/zgui/../zgpu";
        pub const build_zig = @import("122034f9b19b0cf44680c98d26e5f67666f356d32194822468263b2dd608dd3ef173");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "system_sdk", "1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" },
            .{ "zpool", "1220382cf6bc4de7be53ea0b7f0b3657aa23169168b0b91c09bde7c94914a645e7e9" },
            .{ "dawn_x86_64_windows_gnu", "1220f9448cde02ef3cd51bde2e0850d4489daa0541571d748154e89c6eb46c76a267" },
            .{ "dawn_x86_64_linux_gnu", "12204a3519efd49ea2d7cf63b544492a3a771d37eda320f86380813376801e4cfa73" },
            .{ "dawn_aarch64_linux_gnu", "12205cd13f6849f94ef7688ee88c6b74c7918a5dfb514f8a403fcc2929a0aa342627" },
            .{ "dawn_aarch64_macos", "12201fe677e9c7cfb8984a36446b329d5af23d03dc1e4f79a853399529e523a007fa" },
            .{ "dawn_x86_64_macos", "1220b1f02f2f7edd98a078c64e3100907d90311d94880a3cc5927e1ac009d002667a" },
        };
    };
    pub const @"1220382cf6bc4de7be53ea0b7f0b3657aa23169168b0b91c09bde7c94914a645e7e9" = struct {
        pub const build_root = "/home/magic/Robotics/sim/libs/zgui/../zpool";
        pub const build_zig = @import("1220382cf6bc4de7be53ea0b7f0b3657aa23169168b0b91c09bde7c94914a645e7e9");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"12204a3519efd49ea2d7cf63b544492a3a771d37eda320f86380813376801e4cfa73" = struct {
        pub const available = true;
        pub const build_root = "/home/magic/.cache/zig/p/12204a3519efd49ea2d7cf63b544492a3a771d37eda320f86380813376801e4cfa73";
        pub const build_zig = @import("12204a3519efd49ea2d7cf63b544492a3a771d37eda320f86380813376801e4cfa73");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"12205cd13f6849f94ef7688ee88c6b74c7918a5dfb514f8a403fcc2929a0aa342627" = struct {
        pub const available = false;
    };
    pub const @"12206288b3184abd33ae433bb45b25ae0de6f4500907cb7dba62964f27aba240d53f" = struct {
        pub const build_root = "/home/magic/Robotics/sim/libs/zgui/../zglfw";
        pub const build_zig = @import("12206288b3184abd33ae433bb45b25ae0de6f4500907cb7dba62964f27aba240d53f");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "system_sdk", "1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" },
        };
    };
    pub const @"1220b1f02f2f7edd98a078c64e3100907d90311d94880a3cc5927e1ac009d002667a" = struct {
        pub const available = false;
    };
    pub const @"1220babb7939707ca390b934657dfd3c8c3a6a78cc9442e4cbd43e3f9ffd49daec9e" = struct {
        pub const available = false;
    };
    pub const @"1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" = struct {
        pub const build_root = "/home/magic/Robotics/sim/libs/zgui/../system-sdk";
        pub const build_zig = @import("1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"1220f9448cde02ef3cd51bde2e0850d4489daa0541571d748154e89c6eb46c76a267" = struct {
        pub const available = false;
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "zglfw", "12206288b3184abd33ae433bb45b25ae0de6f4500907cb7dba62964f27aba240d53f" },
    .{ "zgpu", "122034f9b19b0cf44680c98d26e5f67666f356d32194822468263b2dd608dd3ef173" },
    .{ "system_sdk", "1220e3d5313fbf18e0ec03220ad3207f52fd0cf99dbc1a4aad1d702beaf9cd8add38" },
    .{ "freetype", "1220babb7939707ca390b934657dfd3c8c3a6a78cc9442e4cbd43e3f9ffd49daec9e" },
};
