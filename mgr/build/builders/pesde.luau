local fs = zune.fs
local stdpath = fs.path
local toml = zune.serde.toml
local CrateConfig = require("@mgr/specifiers/CrateConfig")
local RootConfig = require("@mgr/specifiers/RootConfig")
local alias_resolver = require("@mgr/build/alias_resolver")
local ansi = require("@mgr/util/ansi")
local dynrequire = require("@mgr/dynrequire")
local fs_util = require("../../util/fs")

export type DependencySpecifier = | { name: string, version: string }

export type BuiltManifest = {
    name: string,
    version: string,
    description: string,
    license: string,
    authors: { string },
    repository: string,
    includes: { string },

    target: {
        environment: string,
        lib: string,
        build_files: { string }?,
    },

    indices: {
        default: string,
    },

    dependencies: {
        [string]: DependencySpecifier,
    },
}

local function build(
    dir: string,
    crates: { string },
    targets: { string },
    output: string,
    root_config: RootConfig.RootConfig
)
    local pesde_config = root_config.package_managers.pesde
    if not pesde_config then
        error(
            `Aborting. A pesde config doesn't exist in the root configuration.`
        )
    end
    local root_name = pesde_config.root_name or root_config.name

    if not fs_util.exists(dir) then
        error(`Aborting build. The directory {dir} doesn't exist.`)
    end

    if not fs_util.exists(output) then
        fs.makeDir(output)
    end

    for _, crate in crates do
        local crate_path = stdpath.join(dir, crate)
        local config_path = stdpath.join(crate_path, "crate.luau")
        if not fs_util.exists(config_path) then
            error(
                `Aborting build. The crate {crate} @ path {crate_path} doesn't have a config @ path {config_path}.`
            )
        end

        local config = dynrequire(config_path) :: CrateConfig.CrateConfig
        local lib_path = stdpath.join(crate_path, config.lib)
        local output_tree: alias_resolver.FsDirNode = {
            name = "root",
            kind = "dir",
            children = {},
        }
        output_tree.children = {
            lib = alias_resolver.build_fs_tree(lib_path, output_tree),
            crates = alias_resolver.build_fs_tree(dir, output_tree),
        }

        local found_target = false
        for crate_target in config.targets do
            if not table.find(targets, crate_target) then
                continue
            end
            found_target = true

            print(
                `{ansi.bg.yellow}{ansi.black}{ansi.bold}Building{ansi.reset} pesde crate {ansi.cyan}{crate}{ansi.reset} of target {ansi.red}{crate_target}{ansi.reset}`
            )

            local output_path =
                stdpath.join(output, "pesde", crate_target, crate)
            local output_lib_path = stdpath.join(output_path, config.lib)
            if fs_util.exists(output_path) then
                fs.deleteDir(output_path, true)
            end
            fs.makeDir(output_path, true)
            fs.copy(lib_path, output_lib_path)

            local aliases = { crates = "crates" }
            local pkg_path = `{crate_target}_packages`
            if fs_util.exists(pkg_path) then
                output_tree.children[pkg_path] =
                    alias_resolver.build_fs_tree(pkg_path, output_tree)
                aliases.pkg = pkg_path
            end

            local resolve = alias_resolver.build_resolver(output_tree, aliases)

            fs_util.traverse(
                output_lib_path,
                function(path, name, metadata, local_path)
                    if
                        metadata.kind ~= "file"
                        or stdpath.extension(path) ~= ".luau"
                    then
                        return
                    end
                    local_path = string.gsub(local_path, "\\", "/")

                    local contents = fs.readFile(path)
                    local lines = string.split(contents, "\n")
                    for idx, line in lines do
                        local require_path =
                            string.match(line, "require%(\"(@[^\"]+)\"%)")
                        if not require_path then
                            continue
                        end

                        local alias = string.match(require_path, "^@([^/]+)")
                        if not alias or alias == "self" then
                            continue
                        end

                        if alias ~= "pkg" and alias ~= "crates" then
                            print(
                                `Found unresolvable alias (not @pkg or @crates) in file {path} at line {idx}:\n{line}`
                            )
                            continue
                        end

                        local resolved_path = resolve(require_path, local_path)
                        local resolved =
                            string.gsub(resolved_path, "crates", pkg_path, 1)
                        local resolved_line =
                            string.gsub(line, require_path, resolved)
                        lines[idx] = resolved_line
                    end

                    -- Dumbass windows behavior patch, replace in zune 0.6.0 with handles end-to-end
                    local handle = fs.createFile(path, { truncate = true })
                    handle:write(table.concat(lines, "\n"))
                    handle:sync()
                    handle:close()
                end
            )

            local dependencies: { [string]: any } = {}
            local has_dependencies = false
            if config.dependencies then
                for alias, dependency in config.dependencies do
                    has_dependencies = true
                    dependencies[alias] = dependency.pesde
                end
            end
            if config.workspace_dependencies then
                for crate_name in config.workspace_dependencies do
                    has_dependencies = true
                    local crate_config_path =
                        stdpath.join(dir, crate_name, "crate.luau")
                    local crate_config =
                        dynrequire(crate_config_path) :: CrateConfig.CrateConfig
                    dependencies[crate_name] = {
                        name = `{pesde_config.scope}/{root_name}_{crate_config.name}`,
                        version = crate_config.version,
                    }
                end
            end

            local manifest: BuiltManifest = {
                name = `{pesde_config.scope}/{root_name}_{config.name}`,
                version = config.version,
                description = config.description,
                license = root_config.license,
                authors = root_config.authors,
                repository = root_config.repository,
                includes = { config.lib, "LICENSE", "pesde.toml", "README.md" },

                target = {
                    environment = crate_target,
                    lib = `{config.lib}init.luau`,
                    build_files = if crate_target == "roblox"
                        then { config.lib }
                        else nil,
                },

                indices = {
                    default = pesde_config.registry,
                },

                dependencies = dependencies,
            }

            if not has_dependencies then
                manifest.dependencies = nil :: any
            end

            local encoded_manifest = toml.encode(manifest :: any)
            fs.writeFile(
                stdpath.join(output_path, "pesde.toml"),
                encoded_manifest
            )
            fs.copy("LICENSE", stdpath.join(output_path, "LICENSE"))
            fs.copy(
                stdpath.join(crate_path, "README.md"),
                stdpath.join(output_path, "README.md")
            )
        end

        if not found_target then
            warn(
                `Encountered an error, but continuing - the crate {crate} doesn't support any listed targets.`
            )
            continue
        end
    end
end

return build
