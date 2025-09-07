local RootConfig = require("@mgr/specifiers/RootConfig")
local build_pesde = require("@self/builders/pesde")
local build_wally = require("@self/builders/wally")

local function build(options: {
    dir: string,
    crates: { string },
    package_managers: { string },
    targets: { string },
    output: string,
    root_config: RootConfig.RootConfig,
})
    for _, package_manager in options.package_managers do
        if package_manager == "pesde" then
            build_pesde(
                options.dir,
                options.crates,
                options.targets,
                options.output,
                options.root_config
            )
        elseif package_manager == "wally" then
            build_wally(
                options.dir,
                options.crates,
                options.targets,
                options.output,
                options.root_config
            )
        else
            error(`Invalid package manager: {package_manager}`)
        end
    end
end

return build
