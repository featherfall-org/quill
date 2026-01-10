# Dependencies

A way to sort your singletons via dependency graphs or singleton priorities.

## Sorting methods

There are currently two sorting methods exposed:
- Topological sorting
- Priority sorting

### Topological sorting

Topological sorting relies on singletons defining their dependencies at the top level via `dependencies.use()`, like so:
```luau
local dependencies = require("@pkg/quill_dependencies")

local MySingleton = {}
MySingleton.my_dependency = dependencies.use(require("@singletons/my_dependency"))

...
```
Internally, this function returns a marker that lets the crate know that this property is an uninitialized dependency to resolve later on:
```luau
local function use<T>(singleton: T): T
    return { UNINITIALIZED_DEPENDENCY = true, singleton = singleton } :: any
end
```
However, we lie to the typechecker about the type of it to allow for a pattern such as this in Luau without overcomplicating the user's code.<br>
This allows for users to shoot themselves in the foot if they're relying on a marked dependency in any code that can run prior to dependencies being resolved, such as the top level of the module, although it's an acceptable trade-off as it's considered a bad pattern to run any kind of logic before at the very least initialization.

Dependencies defined like this **aren't resolved** if any other sorting method than topological is used.

### Priority sorting

Priority sorting relies on the user manually defining priorities for each singleton, and so manually defining their dependency graph.<br>
Singletons with a **higher** priority run before singletons with a lower priority.
```luau
local MySingleton = {}
MySingleton.priority = math.huge -- Always runs first

...
```

## Usage

To use this crate, simply add it to Quill with your preferred sorting method:
```luau
local rblx_lifecycles = require("@pkg/quill_rblx_lifecycles")

Quill:with_mod(rblx_lifecycles.mod("topological" OR "priority"))
```
