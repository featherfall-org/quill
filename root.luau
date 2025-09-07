local RootConfig = require("@mgr/specifiers/RootConfig")

return RootConfig {
    name = "quill",
    crates = "crates",

    repository = "https://github.com/featherfall-org/quill",
    homepage = "https://featherfall-org.github.io/quill",
    authors = { "Featherfall" },
    license = "MIT",

    package_managers = {
        pesde = {
            scope = "featherfall",
            registry = "https://github.com/pesde-pkg/index",
        },
        wally = {
            scope = "featherfall-org",
            registry = "https://github.com/UpliftGames/wally-index",
        },
    },
}
