local CrateConfig = require("@mgr/specifiers/CrateConfig")

return CrateConfig {
    name = "dependencies",
    description = "A dependency management solution for Quill",
    version = "0.1.0-alpha.0",
    lib = "lib/",

    targets = {
        luau = true,
        roblox = true,
    },

    workspace_dependencies = {
        core = true,
    },
}
