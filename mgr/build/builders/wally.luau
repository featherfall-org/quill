local fs = zune.fs
local stdpath = fs.path
local toml = zune.serde.toml
local json = zune.serde.json
local CrateConfig = require("@mgr/specifiers/CrateConfig")
local RootConfig = require("@mgr/specifiers/RootConfig")
local alias_resolver = require("@mgr/build/alias_resolver")
local dynrequire = require("@mgr/dynrequire")
local fs_util = require("../../util/fs")

export type DependencySpecifier =
    | { name: string, version: string }
    | { workspace: string, version: string }

export type BuiltManifest = {
    package: {
        name: string,
        version: string,
        description: string,
        license: string,
        authors: { string },
        realm: "shared",
        homepage: string,
        repository: string,
        include: { string },
        exclude: { string },
    },

    dependencies: { [string]: { name: string, version: string } },
}

local function build(
    dir: string,
    crates: { string },
    targets: { string },
    output: string,
    root_config: RootConfig.RootConfig
)
    local wally_config = root_config.package_managers.wally
    if not wally_config then
        error(
            `Aborting. A wally config doesn't exist in the root configuration.`
        )
    end
    local root_name = wally_config.root_name or root_config.name

    if not fs_util.exists(dir) then
        error(`Aborting build. The directory {dir} doesn't exist.`)
    end

    if not fs_util.exists(output) then
        fs.writeDir(output)
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
        local wally_package_tree: alias_resolver.FsDirNode = {
            name = "wally_package",
            kind = "dir",
            parent = output_tree,
            children = {},
        }
        output_tree.children.wally_package_tree = wally_package_tree
        local package_tree: alias_resolver.FsDirNode = {
            name = "package",
            kind = "dir",
            parent = wally_package_tree,
            children = {},
        }
        wally_package_tree.children.package_tree = package_tree
        package_tree.children = {
            lib = alias_resolver.build_fs_tree(lib_path, package_tree),
            crates = alias_resolver.build_fs_tree(dir, package_tree),
        }

        local output_path = stdpath.join(output, "wally", crate)
        local output_lib_path = stdpath.join(output_path, config.lib)
        if fs_util.exists(output_path) then
            fs.removeDir(output_path, true)
        end
        fs.writeDir(output_lib_path, true)

        local dependencies: { [string]: string } = {}
        if config.dependencies then
            for alias, dependency in config.dependencies do
                dependencies[alias] =
                    `{dependency.wally.name}@{dependency.wally.version}`
            end
        end
        if config.workspace_dependencies then
            for crate_name in config.workspace_dependencies do
                local crate_config_path =
                    stdpath.join(dir, crate_name, "crate.luau")
                local crate_config =
                    dynrequire(crate_config_path) :: CrateConfig.CrateConfig

                dependencies[crate_name] =
                    `{wally_config.scope}/{root_name}_{crate_config.name}@{crate_config.version}`
            end
        end

        for alias in dependencies do
            if wally_package_tree.children[alias] then
                error(`Found duplicate alias {alias}`)
            end

            if alias == "package" then
                error("The alias package is reserved")
            end

            wally_package_tree.children[alias] = {
                name = alias,
                kind = "file",
                parent = wally_package_tree,
            } :: alias_resolver.FsFileNode
        end

        local resolve = alias_resolver.build_resolver(
            output_tree,
            { crates = "wally_package/package/crates", pkg = "wally_package" }
        )

        fs.copy(lib_path, output_lib_path)
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
                local_path = "wally_package/package/" .. local_path

                local handle = fs.openFile(path, { mode = "rw" })
                local contents = handle:read()
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

                    local resolved = resolve(require_path, local_path)
                    local resolved_line =
                        string.gsub(line, require_path, resolved)
                    lines[idx] = resolved_line
                end
                handle:writeSync(table.concat(lines, "\n"))
                handle:sync()
                handle:close()
            end
        )

        local manifest: BuiltManifest = {
            package = {
                name = `{wally_config.scope}/{root_name}/{config.name}`,
                version = config.version,
                description = config.description,
                license = root_config.license,
                authors = root_config.authors,
                realm = "shared",
                homepage = root_config.homepage,
                repository = root_config.repository,
                include = {
                    config.lib,
                    `{config.lib}/**`,
                    "LICENSE",
                    "wally.toml",
                    "README.md",
                    "default.project.json",
                },
                exclude = { "**" },
            },

            dependencies = {},
        }

        local project_file = {
            name = config.name,
            tree = {
                path = "lib",
            },
        }

        local encoded_manifest = toml.encode(manifest :: any)
        local encoded_project_file = json.encode(project_file)
        fs.writeFile(stdpath.join(output_path, "wally.toml"), encoded_manifest)
        fs.writeFile(
            stdpath.join(output_path, "default.project.json"),
            encoded_project_file
        )
        fs.copy("LICENSE", stdpath.join(output_path, "LICENSE"))
        fs.copy(
            stdpath.join(crate_path, "README.md"),
            stdpath.join(output_path, "README.md")
        )
    end
end

return build
