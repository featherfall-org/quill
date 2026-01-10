# Core

The core crate of Quill.

## Defining singletons

A singleton is defined to be a table of any shape and type, with optionally an init and start method.
```luau
export type Singleton = {
    init: ((Singleton) -> ())?,
    start: ((Singleton) -> ())?,
    [any]: any,
}
```

Init is executed after all modules are loaded and **cannot yield**.<br>
Start is executed after all modules are initialized and can yield, as it's ran in another thread with `task.spawn`.

```luau
local MySingleton = {}

function MySingleton.init(self: self)
    -- Initialize your properties and everything that other singletons may depend on here.
    -- For example, you'd initialize your datastore wrapper or signals in this function.
end

function MySingleton.start(self: self)
    -- Run your singletons' logic here.
    -- For example, you'd put a game loop here.
end

-- Allows for easy typechecking of any properties and methods.
export type self = typeof(MySingleton)
return MySingleton
```

## Defining modules

Modules are Quill extensions which can hook onto:
- Singleton lifecycles:
  - `injected` - called once a singleton has been injected by the user with `Quill:with_singleton` or `Quill:with_singletons`
  - `loaded` - called once a singleton's modulescript has been loaded by the module loader; injected modules are skipped by this, as the user passes a loaded singleton to the framework in place of a module
  - `initialized` - called once a singleton has been initialized; immediately if it doesn't have an `:init ` method, or if it has one, after it was called
  - `started` - called once a singleton has been started; immediately if it doesn't have a `:start` method, or if it has one, after it was called
- Module loader phases:
  - `pre_loading` - called before any modules are loaded; injected modules are loaded prior to this, as the user passes a loaded singleton to the framework in place of a module 
  - `post_loading` - called after all modules were loaded
  - `pre_initialization` - called before singletons are initialized
  - `post_initialization` - called after singletons are initialized
  - `pre_starting` - called before singletons are started
  - `post_starting` - called after singletons are started

Lifecycle hooks are called with a singleton and its current lifecycle:
```luau
type LifecycleHook = (lifecycle: Lifecycle, singleton: Singleton) -> ()
```

Phases are called with a list of all singletons currently attached to the framework and the current module loader phase:
```luau
type PhaseHook = (phase: Phase, singletons: { Singleton }) -> ()
```

## Building and starting the framework

After creating quill with `Quill.new`, you may:
- Add Quill modules with `Quill:with_mod`
- Add modulescripts with `Quill:with_module` and `Quill:with_modules`
- Inject singletons with `Quill:with_singleton` and `Quill:with_singletons`
- Lastly, start Quill with `Quill:write`

Ideally, you'd add Quill modules prior to anything else, as injecting singletons runs the injected lifecycle hooks for them.

For example:
```luau
local quill = require("@pkg/quill")
local rblx_lifecycles = require("@pkg/quill_rblx_lifecycles")

quill.new()
    :with_mod(rblx_lifecycles.mod)
    :with_modules(script.singletons:GetChildren())
    :write()
```
