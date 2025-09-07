local core = require("@crates/core")

local function use<T>(singleton: T): T
    return { UNINITIALIZED_DEPENDENCY = true, singleton = singleton } :: any
end

type AdjacencyMatrix<T> = { [T]: { T } }
--- Kahn's algorithm for topological sorting of adjacency matrices
local function toposort<T>(graph: AdjacencyMatrix<T>): { T }
    local in_degree: { [T]: number } = {}
    for node, neighbors in graph do
        in_degree[node] = 0

        for _, neighbor in neighbors do
            if not in_degree[neighbor] then
                in_degree[neighbor] = 0
            end
            (in_degree :: any)[neighbor] += 1
        end
    end

    local queue: { T } = {}
    for node, degree in in_degree do
        if degree == 0 then
            table.insert(queue, node)
        end
    end

    local sorted_order: { T } = {}
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

type Singleton = core.Singleton
export type SortingMethod = | "topological"
local function mod(sorting_method: SortingMethod?): core.Mod
    local dependencies_matrix: AdjacencyMatrix<Singleton> = {}
    local to_inject: { [Singleton]: { [string]: Singleton } } = {}
    local function lifecycle_hook(
        lifecycle: core.Lifecycle,
        singleton: core.Singleton
    )
        if lifecycle ~= "loaded" then
            return
        end

        local dependencies = {}
        local dependencies_map = {}
        for name, value in singleton do
            if
                type(value) == "table"
                or value.UNINITIALIZED_DEPENDENCY ~= true
            then
                continue
            end

            table.insert(dependencies, value.singleton)
            dependencies_map[name] = value.singleton
        end
        dependencies_matrix[singleton] = dependencies
        to_inject[singleton] = dependencies_map
    end

    local function phase_hook(phase: core.Phase, singletons: { Singleton }) end

    return {}
end

return {
    use = use,
    mod = mod,
}
