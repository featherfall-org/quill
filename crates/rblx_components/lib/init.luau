--# selene: allow(undefined_variable)
local CollectionService = game:GetService("CollectionService")
local constructors = require("@self/constructors")
local core = require("@crates/core")
local rblx_types = require("@self/rblx_types")

export type ComponentInfo<T> = constructors.ComponentInfo<T>
type TypeOfKind<Kind> = constructors.TypeOfKind<Kind>
type GetInstance<ClassName> = rblx_types.GetInstance<
    ClassName,
    rblx_types.Instances
>
type function creation_data(t: type): type
    local _ = ComponentInfo(t)

    local function optionalprop(
        props: { [type]: { read: type?, write: type? } },
        prop: type
    ): type?
        for key, rw in props do
            if key ~= prop then
                continue
            end

            local value = rw.read or rw.write
            if value then
                return value
            end
        end
        return nil
    end

    local function fetchprop(
        props: { [type]: { read: type?, write: type? } },
        prop: type
    ): type
        local found = optionalprop(props, prop)
        assert(found ~= nil, `Prop not found: {prop:value()}`)
        return found :: any
    end

    local data = types.newtable()

    local props = t:properties()

    local attributes_prop = optionalprop(props, types.singleton("attributes"))
    if attributes_prop then
        local attributes = types.newtable()
        for key, rw in attributes_prop:properties() do
            local value = rw.read or rw.write
            if not value then
                continue
            end

            local kind = fetchprop(value:properties(), types.singleton("kind"))
            attributes:setreadproperty(key, TypeOfKind(kind))
        end
        data:setreadproperty(types.singleton("attributes"), attributes)
    end

    local children_prop = optionalprop(props, types.singleton("children"))
    if children_prop then
        local children = types.newtable()
        for key, rw in children_prop:properties() do
            local class_name = rw.read or rw.write
            if not class_name then
                continue
            end

            children:setreadproperty(key, GetInstance(class_name))
        end
        data:setreadproperty(types.singleton("children"), children)
    end

    local is_prop = fetchprop(props, types.singleton("is"))
    data:setreadproperty(types.singleton("instance"), GetInstance(is_prop))

    return data
end
export type CreationData<T> = creation_data<T> -- Linker doesn't support type functions

type CreationDataRepresentation = {
    instance: Instance,
    attributes: { [string]: constructors.AttributeType }?,
    children: { [string]: Instance }?,
}

type Component = {
    init: ((Component) -> ())?,
    destroy: ((Component) -> ())?,
    [any]: any,
}

local function fake_info_ctor<T>(info: T): ComponentInfo<T>
    return { UNINITIALIZED_COMPONENT = true, info = info } :: any
end

local function mod(debug: boolean?): core.Mod
    local function lifecycle_hook(
        lifecycle: core.Lifecycle,
        singleton: core.Singleton
    )
        if lifecycle ~= "initialized" then
            return
        end

        local meta: constructors.ComponentInfoRepresentation = singleton.info
        if
            not meta
            or type(meta) ~= "table"
            or not (meta :: any).UNINITIALIZED_COMPONENT
        then
            return
        end
        meta = (meta :: any).info :: constructors.ComponentInfoRepresentation
        singleton.info = meta

        local component_ctor: (core.Singleton, CreationDataRepresentation) -> Component =
            singleton.new
        if not component_ctor or type(component_ctor) ~= "function" then
            return
        end

        local setup_component
        if debug then
            function setup_component(instance: Instance)
                if not instance:IsA(meta.is) then
                    warn(
                        `Tried to set up an instance {instance} with tag {meta.tag} which is not a {meta.is}`
                    )
                    return
                end

                local data: CreationDataRepresentation = {
                    instance = instance,
                }

                if meta.children then
                    local children = {}
                    data.children = children

                    for name, class_name in meta.children do
                        local child = instance:FindFirstChild(name)
                        if not child then
                            warn(
                                `Tried to set up an instance {instance} with tag {meta.tag} which doesn't have a child {name}`
                            )
                            return
                        end

                        if not child:IsA(class_name) then
                            warn(
                                `Tried to set up an instance {instance} with tag {meta.tag} which's child {name} isn't a {class_name}`
                            )
                            return
                        end

                        children[name] = child
                    end
                end

                if meta.attributes then
                    local attributes = {}
                    data.attributes = attributes

                    for name, metadata in meta.attributes do
                        local value = instance:GetAttribute(name)
                        if not value then
                            if metadata.default then
                                attributes[name] = value :: any
                                    or metadata.default
                                continue
                            end

                            warn(
                                `Tried to set up an instance {instance} with tag {meta.tag} which doesn't have an attribute {name}`
                            )
                            return
                        end

                        if typeof(value) ~= metadata.kind then
                            warn(
                                `Tried to set up an instance {instance} with tag {meta.tag} which's atribute {name} isn't of type {value}`
                            )
                            return
                        end

                        attributes[name] = value :: any
                    end
                end

                local component = component_ctor(singleton, data)
                if component.init then
                    component:init()
                end
                return component :: any
            end
        else
            function setup_component(instance: Instance)
                if not instance:IsA(meta.is) then
                    return
                end

                local data: CreationDataRepresentation = {
                    instance = instance,
                }

                if meta.children then
                    local children = {}
                    data.children = children

                    for name, class_name in meta.children do
                        local child = instance:FindFirstChild(name)
                        if not child or not child:IsA(class_name) then
                            return
                        end

                        children[name] = child
                    end
                end

                if meta.attributes then
                    local attributes = {}
                    data.attributes = attributes

                    for name, metadata in meta.attributes do
                        local value = instance:GetAttribute(name)
                        if not value or typeof(value) ~= metadata.kind then
                            if metadata.default then
                                attributes[name] = value :: any
                                    or metadata.default
                                continue
                            end

                            return
                        end

                        attributes[name] = value :: any
                    end
                end

                local component = component_ctor(singleton, data)
                if component.init then
                    component:init()
                end
                return component :: any
            end
        end

        local dtors = {}

        local function handle_tagged(instance: Instance)
            local component = (setup_component :: (Instance) -> Component?)(
                instance
            )
            if component and component.destroy then
                dtors[instance] = function()
                    component:destroy()
                end
            end
        end

        CollectionService:GetInstanceAddedSignal(meta.tag)
            :Connect(handle_tagged)

        CollectionService:GetInstanceRemovedSignal(meta.tag)
            :Connect(function(instance)
                local dtor = dtors[instance]
                if dtor then
                    dtor()
                    dtors[instance] = nil
                end
            end)

        for _, instance in CollectionService:GetTagged(meta.tag) do
            handle_tagged(instance)
        end
    end

    return {
        on_lifecycle = lifecycle_hook,
    }
end

local components = table.freeze {
    mod = mod,

    info = fake_info_ctor,
    attribute = constructors.attribute,
    child = constructors.child,
    singleton = constructors.singleton,
}

return components
