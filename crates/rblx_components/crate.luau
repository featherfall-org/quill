local CrateConfig = require("@mgr/specifiers/CrateConfig")

return CrateConfig {
    name = "rblx_components",
    description = "A simple components system for Quill",
    version = "0.1.0-alpha.0",
    lib = "lib/",

    targets = {
        roblox = true,
    },

    workspace_dependencies = {
        core = true,
    },
}
