export type Singleton = {
    priority: number?,
    init: ((Singleton) -> ())?,
    start: ((Singleton) -> ())?,
    [any]: any,
}

export type Lifecycle = | "loaded" | "injected" | "initialized" | "started"
export type LifecycleHook<E... = ()> = (
    lifecycle: Lifecycle,
    singleton: Singleton,
    E...
) -> ()

export type Phase =
    | "pre_loading"
    | "post_loading"
    | "pre_initialization"
    | "post_initialization"
    | "pre_starting"
    | "post_starting"
export type PhaseHook<E... = ()> = (
    phase: Phase,
    singletons: { Singleton },
    E...
) -> ()

local Quill = {}
local mt = { __index = Quill }
export type Identity = setmetatable<{
    modules: { ModuleScript },
    singletons: { Singleton },

    lifecycle_hooks: { LifecycleHook },
    phase_hooks: { PhaseHook },
}, typeof(mt)>

local function constructor(): Identity
    local self = {
        modules = {},
        singletons = {},

        lifecycle_hooks = {},
        phase_hooks = {},
    }
    return setmetatable(self, mt)
end

function Quill.with_module(self: Identity, module: ModuleScript): Identity
    table.insert(self.modules, module)
    return self
end

function Quill.with_modules(self: Identity, modules: { ModuleScript }): Identity
    table.move(modules, 1, #modules, #self.modules + 1, self.modules)
    return self
end

local function no_yield<A..., R...>(fn: (A...) -> R..., ...: A...)
    local packed = { ... }
    -- selene: allow(empty_loop)
    for _ in
        function()
            fn(table.unpack(packed) :: any)
        end :: any
    do
    end
end

local function call_closures<T..., R...>(hooks: { (T...) -> R... }, ...: T...)
    for _, hook in hooks do
        no_yield(hook, ...)
    end
end

--- Util function for better types
local function call_lifecycle_hooks(
    hooks: { LifecycleHook },
    lifecycle: Lifecycle,
    singleton: Singleton
)
    call_closures(hooks, lifecycle, singleton)
end

--- Util function for better types
local function call_phase_hooks(
    hooks: { PhaseHook },
    phase: Phase,
    singletons: { Singleton }
)
    call_closures(hooks, phase, singletons)
end

function Quill.with_singleton(self: Identity, singleton: Singleton): Identity
    table.insert(self.singletons, singleton)
    call_lifecycle_hooks(self.lifecycle_hooks, "injected", singleton)
    return self
end

function Quill.with_singletons(
    self: Identity,
    singletons: { Singleton }
): Identity
    for _, singleton in singletons do
        table.insert(self.singletons, singleton)
        call_lifecycle_hooks(self.lifecycle_hooks, "injected", singleton)
    end
    return self
end

-- make this a modinterface
export type Mod = {
    on_lifecycle: LifecycleHook?,
    on_phase: PhaseHook?,
}

--- Hooks can get expensive as they're ran on every single phase / lifecycle. Use them sparingly.
--- Hooks cannot yield.
function Quill.with_mod(self: Identity, mod: Mod): Identity
    if mod.on_lifecycle then
        table.insert(self.lifecycle_hooks, mod.on_lifecycle)
    end

    if mod.on_phase then
        table.insert(self.phase_hooks, mod.on_phase)
    end

    return self
end

function Quill.write(self: Identity)
    local clock_begin = os.clock()

    call_phase_hooks(self.phase_hooks, "pre_loading", {})
    for _, module in self.modules do
        local singleton = (require)(module)
        table.insert(self.singletons :: any, singleton)
        call_lifecycle_hooks(self.lifecycle_hooks, "loaded", singleton)
    end

    call_phase_hooks(self.phase_hooks, "post_loading", self.singletons)

    call_phase_hooks(self.phase_hooks, "pre_initialization", self.singletons)
    for _, singleton in self.singletons do
        if not singleton.init then
            continue
        end

        no_yield(singleton.init, singleton)
        call_lifecycle_hooks(self.lifecycle_hooks, "initialized", singleton)
    end
    call_phase_hooks(self.phase_hooks, "post_initialization", self.singletons)

    call_phase_hooks(self.phase_hooks, "pre_starting", self.singletons)
    for _, singleton in self.singletons do
        if not singleton.start then
            continue
        end

        task.spawn(singleton.start, singleton)
        call_lifecycle_hooks(self.lifecycle_hooks, "started", singleton)
    end
    call_phase_hooks(self.phase_hooks, "post_starting", self.singletons)

    local clock_end = os.clock()
    local time_took = math.round((clock_end - clock_begin) * 1000)

    print(`[🪶] Started {#self.singletons} singletons in {time_took}ms`)
end

return { new = constructor }
