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

local function get_modules(parent: Instance): { ModuleScript }
    local modules = {}
    for _, child in parent:GetChildren() do
        if child:IsA("ModuleScript") then
            table.insert(modules, child)
        end
    end
    return modules
end

type Singleton = { [any]: any }
local function load(container: Instance)
    local start = os.clock()

    local graph: Graph<Singleton> = {}
    local to_inject: Map<Singleton, Map<string, Singleton>> = {}
    for _, module in get_modules(container) do
        local singleton = (require)(module)
        local dependencies = {}
        local uninitialized_dependencies: Map<string, Singleton> = {}
        for name, value in singleton do
            if
                type(value) == "table"
                and value.UNINITIALIZED_DEPENDENCY == true
            then
                table.insert(dependencies, value.singleton)
                uninitialized_dependencies[name] = value.singleton
            end
        end
        graph[singleton] = dependencies
        to_inject[singleton] = uninitialized_dependencies
    end

    local ordered = toposort(graph)
    table.clear(graph)

    for idx = #ordered, 1, -1 do
        local singleton = ordered[idx]
        for name, dependency in to_inject[singleton] do
            singleton[name] = dependency
        end

        if singleton.init then
            -- Don't allow for yielding
            -- selene: allow(empty_loop)
            for _ in
                function()
                    (singleton :: any):init()
                end :: any
            do
            end
        end
    end

    for idx = #ordered, 1, -1 do
        local singleton = ordered[idx]
        if singleton.start then
            task.spawn(singleton.start :: any, singleton)
        end
    end

    local took = math.round((os.clock() - start) * 1000)
    print(`✅ Loaded {#ordered} singletons, took {took}ms`)
end

local function noop(container: Instance)
    local start = os.clock()

    local modules = get_modules(container)
    for _, module in modules do
        (require)(module)
    end

    local took = math.round((os.clock() - start) * 1000)
    print(`✅ Loaded {#modules} systems, took {took}ms`)
end

local function use<T>(singleton: T): T
    return { UNINITIALIZED_DEPENDENCY = true, singleton = singleton } :: any
end

return {
    load = load,
    noop = noop,

    use = use,
}
