# Components

Components are a powerful way to work with Roblox CollectionService tags to make behaviour for instances.<br>
Thanks to an abhorrent amount of used type functions, everything is completely typesafe.

## Usage

```luau
local components = require("@pkg/quill_rblx_components")

local Door = {}
local door_mt = { __index = Door }

type DoorProperties = {
    is_open: boolean,
    turn_rotation: vector,
    toggle_prompt: ProximityPrompt,
    instance: BasePart,
    connections: { RBXScriptConnection },
}
export type Door = setmetatable<DoorProperties, typeof(door_mt)>

function Door.init(self: Door)
    table.insert(
        self.connections,
        self.toggle_prompt.Triggered:Connect(function()
            self:toggle()
        end)
    )
end

function Door.toggle(self: Door)
    local sign = if self.is_open then -1 else 1
    local target_angles = self.turn_rotation * vector.create(sign, sign, sign)
    self.instance.CFrame *= CFrame.Angles(
        target_angles.x,
        target_angles.y,
        target_angles.z
    )
    self.is_open = not self.is_open
end

function Door.destroy(self: Door)
    for _, connection in self.connections do
        connection:Disconnect()
    end
end

local DoorComponent = {}
DoorComponent.info = components.info {
    attributes = {
        default_state = components.attribute("boolean", false), -- Boolean attribute with default value of `false`
        turn_rotation = components.attribute("vector"), -- Vector attribute with no default value, therefore it must exist, otherwise the constructor doesn't get called
    },
    children = {
        toggle_prompt = components.child("ProximityPrompt"), -- Child called `toggle_prompt` on the tagged instance that's a ProximityPrompt
    },
    is = components.singleton("BasePart"), -- Any instance tagged with `Door` must be a `Part` to be initialized
    tag = components.singleton("Door"),
}
type DoorData = components.CreationData<typeof(DoorComponent.info)>

function DoorComponent.new(self: self, data: DoorData): Door
    local door = {
        is_open = data.attributes.default_state,
        turn_rotation = data.attributes.turn_rotation,
        toggle_prompt = data.children.toggle_prompt,
        instance = data.instance,
        connections = {},
    }
    return setmetatable(door, door_mt)
end

export type self = typeof(DoorComponent)
return DoorComponent
```

Each part tagged with `Door` must:
- Have an attribute `default_state` of type boolean with the default value of `false`
- Have an attribute `turn_rotation` of type vector with no default value; if it doesn't exist, the component isn't constructed for it
- Have a child `toggle_prompt` of kind ProximityPrompt; if it doesn't exist, the component isn't constructed for it

After a fitting door comes into the datamodel, the component will be:
1. Created with `DoorComponent:new()`
2. Initialized with `Door:init()`
3. Destroyed with `Door:destroy()` if the tag gets removed or the instance is destroyed

## Reference

All supported attribute types at the type of writing are also supported by this crate:
- `string`
- `number`
- `boolean`
- `vector`, interchangeable with `Vector3`, exists due to horrendous Roblox types for them
- `Vector3`, interchangeable with `vector`, exists due to horrendous Roblox types for them
- `Vector2`
- `UDim`
- `UDim2`
- `BrickColor`
- `Color3`
- `CFrame`
- `NumberSequence`
- `ColorSequence`
- `NumberRange`
- `Rect`
- `Font`

All instances, past, current and future, are supported by this crate.<br>
Only a select few get end to end typechecking support (see rblx_components/lib/rblx_types.luau -> type Instances), as there currently isn't to the extent of my knowledge a way to do it spare for typing out every single instance class in Roblox.
