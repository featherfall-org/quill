local RunService = game:GetService("RunService")
local core = require("@crates/core")

local CLIENT_LIFECYCLES = {
    on_heartbeat = RunService.Heartbeat,
    on_post_simulation = RunService.PostSimulation,
    on_pre_animation = RunService.PreAnimation,
    on_pre_render = RunService.PreRender,
    on_pre_simulation = RunService.PreSimulation,
}
local SERVER_LIFECYCLES = {
    on_heartbeat = RunService.Heartbeat,
    on_post_simulation = RunService.PostSimulation,
    on_pre_animation = RunService.PreAnimation,
    on_pre_simulation = RunService.PreSimulation,
}

type ConnectFn = (any, (...any) -> ...any) -> any
type SignalLike =
    ({ Connect: ConnectFn } & { connect: ConnectFn })
    | RBXScriptSignal

local function safe_connect(event: SignalLike, fn: (...any) -> ())
    const connect: ConnectFn = event.Connect or event.connect

    if typeof(connect) == "function" then
        connect(event, fn)

        return true
    end

    return false
end

local function mod(): core.Mod
    local lifecycles_table = if RunService:IsServer()
        then SERVER_LIFECYCLES
        else CLIENT_LIFECYCLES

    local function lifecycle_hook(
        lifecycle: core.Lifecycle,
        singleton: core.Singleton
    )
        if lifecycle ~= "initialized" then
            return
        end

        for name, event: SignalLike in lifecycles_table do
            local fn: ((any, ...any) -> ())? = singleton[name]
            if not fn then
                continue
            end

            if typeof(fn) ~= "function" then
                warn(
                    `Tried registering lifecycle {name} for singleton {singleton}, got {typeof(
                        fn
                    )} instead of function`
                )
                continue
            end

            local function update(...: any)
                fn(singleton, ...)
            end

            local success = safe_connect(event, update)

            if not success then
                warn(
                    `Failed to connect lifecycle {name} for singleton {singleton}. Expected an RBXScriptSignal or signal-like object with a Connect/connect method, got {typeof(
                        event
                    )}.`
                )
            end
        end
    end

    return {
        on_lifecycle = lifecycle_hook,
    }
end

--- Implements a lifecycle for the client.\
--- Make sure this is called prior to modules being initialized.
local function implement_client_lifecycle(name: string, event: SignalLike)
    CLIENT_LIFECYCLES[name] = event
end

--- Implements a lifecycle for the server.\
--- Make sure this is called prior to modules being initialized.
local function implement_server_lifecycle(name: string, event: SignalLike)
    SERVER_LIFECYCLES[name] = event
end

local rblx_lifecycles = table.freeze {
    mod = mod,

    implement_client_lifecycle = implement_client_lifecycle,
    implement_server_lifecycle = implement_server_lifecycle,
}

return rblx_lifecycles
