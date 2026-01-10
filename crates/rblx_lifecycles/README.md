# Lifecycles

Adds a bunch of `RunService` lifecycles:
- `on_heartbeat` -> `RunService.Heartbeat`
- `on_post_simulation` -> `RunService.PostSimulation`
- `on_pre_animation` -> `RunService.PreAnimation`
- `on_pre_render` -> `RunService.PreRender` -- Doesn't get registered on the server
- `on_pre_simulation` -> `RunService.PreSimulation`

## Usage

```luau
local MySingleton = {}

function MySingleton.on_heartbeat(dt: number)
    -- Ran every Heartbeat
end

...
```

You may also define new or override existing lifecycles for the client and server with `rblx_lifecycles.implement_client_lifecycle` and `rblx_lifecycles.implement_server_lifecycle` respectively.
```luau
implement_lifecycle: (
    name: string,
    event: RBXScriptSignal
) -> ()
```
