local CrateConfig = require("@mgr/specifiers/CrateConfig")

return CrateConfig {
    name = "core",
    description = "A featherweight framework for Luau",
    version = "0.1.0-alpha.1",
    lib = "lib/",

    targets = {
        luau = true,
        roblox = true,
    },
}
