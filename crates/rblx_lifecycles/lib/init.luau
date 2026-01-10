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

        for name, event: RBXScriptSignal in lifecycles_table do
            local fn = singleton[name]
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

            event:Connect(fn)
        end
    end

    return {
        on_lifecycle = lifecycle_hook,
    }
end

--- Implements a lifecycle for the client.\
--- Make sure this is called prior to modules being initialized.
local function implement_client_lifecycle(name: string, event: RBXScriptSignal)
    CLIENT_LIFECYCLES[name] = event
end

--- Implements a lifecycle for the server.\
--- Make sure this is called prior to modules being initialized.
local function implement_server_lifecycle(name: string, event: RBXScriptSignal)
    SERVER_LIFECYCLES[name] = event
end

return {
    mod = mod,

    implement_client_lifecycle = implement_client_lifecycle,
    implement_server_lifecycle = implement_server_lifecycle,
}
