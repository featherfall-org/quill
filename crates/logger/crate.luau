local CrateConfig = require("@mgr/specifiers/CrateConfig")

return CrateConfig {
    name = "logger",
    description = "A tiny, context aware logger for Quill",
    version = "0.1.0-alpha.2",
    lib = "lib",

    targets = {
        luau = true,
        roblox = true,
    },
}
