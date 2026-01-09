local CrateConfig = require("@mgr/specifiers/CrateConfig")
local RootConfig = require("@mgr/specifiers/RootConfig")
local dynrequire = require("@self/dynrequire")
local frkcli = require("@self/vendor/frkcli")
local process = zune.process
local fs = zune.fs
local fs_util = require("@self/util/fs")

local root_config = require("./root")

local available_crates = {}
local available_targets = {}
for _, entry in fs.entries(root_config.crates) do
    if entry.kind ~= "directory" then
        continue
    end

    local path = fs.path.join(root_config.crates, entry.name, "crate.luau")
    if not fs_util.exists(path) then
        continue
    end

    local crate_config = dynrequire(path) :: CrateConfig.CrateConfig
    for target in crate_config.targets do
        if not table.find(available_targets, target) then
            table.insert(available_targets, target)
        end
    end

    table.insert(available_crates, entry.name)
end
local available_crates_help = "all," .. table.concat(available_crates, ",")
local available_targets_help = "all," .. table.concat(available_targets, ",")

local available_package_managers = {}
for name in
    root_config.package_managers :: { [string]: RootConfig.PackageManagerConfig }
do
    table.insert(available_package_managers, name)
end
local available_package_managers_help = "all,"
    .. table.concat(available_package_managers, ",")

local cli = frkcli.new_subcommands("mgr", "A CLI to manage the Quill monorepo")

local cmd_check = cli:add_subcommand("check", "Lints and tests the code")
cmd_check:add_positional("source", {
    help = "The source folder / file to check",
    default = root_config.crates,
    aliases = { "-s" },
})

local cmd_link = cli:add_subcommand("link", "Creates a linker file for a crate")
cmd_link:add_positional("crates", {
    help = `The crates to create a linker for. Available: {available_crates_help}`,
    default = root_config.crates,
    aliases = { "-c" },
})

local cmd_build =
    cli:add_subcommand("build", "Builds the crates into distributable packages")
cmd_build:add_option("crates", {
    help = `A comma separated list of crates to build. Available: {available_crates_help}`,
    default = "all",
    aliases = { "-c" },
})
cmd_build:add_option("package-managers", {
    help = `A comma separated list of package managers to build for. Available: {available_package_managers_help}`,
    default = "all",
    aliases = { "-p" },
})
cmd_build:add_option("targets", {
    help = "A comma separated list of targets to build for, if available on a crate. Available: all,luau,roblox",
    default = "all",
    aliases = { "-t" },
})
cmd_build:add_option("output", {
    help = "The folder to output the built crates into",
    default = "out/",
    aliases = { "-o" },
})

local cmd_publish = cli:add_subcommand(
    "publish",
    "Publishes the crates to all supported package managers"
)
cmd_publish:add_option("crates", {
    help = `A comma separated list of crates to build. Available: {available_crates_help}`,
    default = "all",
    aliases = { "-c" },
})
cmd_publish:add_option("package-managers", {
    help = `A comma separated list of package managers to publish. Available: {available_package_managers_help}`,
    default = "all",
    aliases = { "-p" },
})
cmd_publish:add_option("targets", {
    help = `A comma separated list of targets to build for, if available on a crate. Available: {available_targets_help}`,
    default = "all",
    aliases = { "-t" },
})
cmd_publish:add_option("storage", {
    help = "The folder the built crates reside in",
    default = "out/",
    aliases = { "-s" },
})
cmd_publish:add_flag("build", {
    help = "Whether the crates should be built prior to publishing",
    aliases = { "-b" },
})

local process_args = process.args
table.remove(process_args, 1)

local parsed, err = cli:parse(process_args)
if err ~= nil then
    error(err)
end
assert(parsed)

local function parse_crates(str: string): { string }
    local crates = string.split(str, ",")
    if table.find(crates, "all") then
        crates = available_crates
    else
        for _, crate in crates do
            if not table.find(available_crates, crate) then
                error(
                    `The provided crate {crate} is not available / does not exist.`
                )
            end
        end
    end

    if #crates <= 0 then
        error("Quitting. None of the provided crates are available.")
    end

    return crates
end

local values = parsed.result.values
local flags = parsed.result.flags
if parsed.command == "check" then
    require("@self/check") {
        source = values.source,
    }
elseif parsed.command == "link" then
    local crates = parse_crates(values.crates)
    for _, crate in crates do
        local path = fs.path.join(root_config.crates, crate)
        require("@self/link") {
            crate_path = path,
        }
    end
elseif parsed.command == "build" or parsed.command == "publish" then
    local crates = parse_crates(values.crates)

    local package_managers = string.split(values["package-managers"], ",")
    if table.find(package_managers, "all") then
        package_managers = available_package_managers
    else
        for _, package_manager in package_managers do
            if not table.find(available_package_managers, package_manager) then
                error(
                    `The provided package manager {package_manager} is not available. Check your root configuration.`
                )
            end
        end
    end

    if #package_managers <= 0 then
        local msg = if parsed.command == "publish"
            then "Quitting. The number of package managers to publish to is 0."
            else "Quitting. The number of package managers to build for is 0."
        warn(msg)
    end

    local targets = string.split(values.targets, ",")
    if table.find(targets, "all") then
        targets = available_targets
    else
        for _, target in targets do
            if not table.find(available_targets, target) then
                error(
                    `The provided target {target} is not available. Check your crate configurations.`
                )
            end
        end
    end

    if flags.build or parsed.command == "build" then
        local output = if parsed.command == "build"
            then values.output
            else values.storage

        require("@self/build") {
            dir = root_config.crates,
            crates = crates,
            package_managers = package_managers,
            targets = targets,
            output = output,
            root_config = root_config,
        }
    end

    if parsed.command ~= "publish" then
        return
    end

    -- publish {crates} from {values.storage} on {targets} to {package_managers}
end
