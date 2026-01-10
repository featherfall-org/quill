local fs = zune.fs
local stdpath = fs.path
local CrateConfig = require("@mgr/specifiers/CrateConfig")
local Process = require("./util/Process")
local ansi = require("./util/ansi")
local dynrequire = require("./dynrequire")

type Array<T> = { T }
type Map<K, V> = { [K]: V }
type Graph<T> = Map<T, Array<T>>
-- Based on Kahn's algorithm
local function toposort<T>(graph: Graph<T>): Array<T>
    local in_degree: Map<T, number> = {}
    for node, neighbors in graph do
        in_degree[node] = 0

        for _, neighbor in neighbors do
            if not in_degree[neighbor] then
                in_degree[neighbor] = 0
            end
            (in_degree :: any)[neighbor] += 1
        end
    end

    local queue: Array<T> = {}
    for node, degree in in_degree do
        if degree == 0 then
            table.insert(queue, node)
        end
    end

    local sorted_order: Array<T> = {}
    while #queue > 0 do
        local node = table.remove(queue, 1)
        table.insert(sorted_order, node)
        for _, neighbor: T in graph[node] or {} do
            local degree = in_degree[neighbor] - 1
            in_degree[neighbor] = degree
            if degree == 0 then
                table.insert(queue, neighbor)
            end
        end
    end

    return sorted_order
end

local function publish(options: {
    dir: string,
    crates: { string },
    package_managers: { string },
    targets: { string },
    output: string,
    dry: boolean,
})
    print(`{ansi.bg.magenta}{ansi.black}{ansi.bold}Ordering{ansi.reset} crates`)
    local dependency_graph = {}
    for _, crate in options.crates do
        local crate_config_path = stdpath.join(options.dir, crate, "crate.luau")
        local crate_config: CrateConfig.CrateConfig =
            dynrequire(crate_config_path) :: any

        local crate_dependencies = {}
        if crate_config.workspace_dependencies then
            for dependency in crate_config.workspace_dependencies do
                table.insert(crate_dependencies, dependency)
            end
        end

        dependency_graph[crate] = crate_dependencies
    end

    local ordered = toposort(dependency_graph)

    for _, package_manager in options.package_managers do
        if package_manager == "wally" then
            local sub_command = if options.dry then "package" else "publish"
            local process =
                Process.new("wally"):argument(sub_command):inherit_stdout()
            if options.dry then
                process:argument("--output"):argument("package.tar.gz")
            end

            for _, crate in ordered do
                local out_dir =
                    stdpath.join(options.output, package_manager, crate)
                print(
                    `{ansi.bg.yellow}{ansi.black}{ansi.bold}Publishing{ansi.reset} wally crate {ansi.cyan}{crate}{ansi.reset}`
                )
                process:option("cwd", out_dir):run()
            end

            continue
        end

        if package_manager ~= "pesde" then
            warn(`Unsupported package manager: {package_manager}`)
            continue
        end

        local process = Process.new("pesde")
            :argument("publish")
            :argument("--yes")
            :inherit_stdout()
        if options.dry then
            process:argument("--dry-run")
        end

        local install_process =
            Process.new("pesde"):argument("install"):inherit_stdout()

        for _, target in options.targets do
            for _, crate in ordered do
                local out_dir =
                    stdpath.join(options.output, package_manager, target, crate)

                if target == "roblox" then
                    print(
                        `{ansi.bg.blue}{ansi.black}{ansi.bold}Updating{ansi.reset} lockfile for pesde crate {ansi.cyan}{crate}{ansi.reset} of target {ansi.red}{target}{ansi.reset}`
                    )
                    install_process:option("cwd", out_dir):run()
                end

                print(
                    `{ansi.bg.yellow}{ansi.black}{ansi.bold}Publishing{ansi.reset} pesde crate {ansi.cyan}{crate}{ansi.reset} to target {ansi.red}{target}{ansi.reset}`
                )
                process:option("cwd", out_dir):run()
            end
        end
    end
end

return publish
