--# selene: allow(undefined_variable)
local rblx_types = require("./rblx_types")

type luau_vector = vector
type rbx_vector2 = Vector2
type rbx_vector3 = Vector3
type rbx_udim = UDim
type rbx_udim2 = UDim2
type rbx_brickcolor = BrickColor
type rbx_color3 = Color3
type rbx_cframe = CFrame
type rbx_numbersequence = NumberSequence
type rbx_colorsequence = ColorSequence
type rbx_numberrange = NumberRange
type rbx_rect = Rect
type rbx_font = Font
export type function TypeOfKind(kind: type): type
    local singleton = kind:is("singleton") and kind:value()
    assert(singleton ~= nil, "The passed type isn't a singleton")

    if singleton == "string" then
        return types.string
    elseif singleton == "number" then
        return types.number
    elseif singleton == "boolean" then
        return types.boolean
    elseif singleton == "vector" then
        return luau_vector
    elseif singleton == "Vector2" then
        return rbx_vector2
    elseif singleton == "Vector3" then
        return rbx_vector3
    elseif singleton == "UDim" then
        return rbx_udim
    elseif singleton == "UDim2" then
        return rbx_udim2
    elseif singleton == "BrickColor" then
        return rbx_brickcolor
    elseif singleton == "Color3" then
        return rbx_color3
    elseif singleton == "CFrame" then
        return rbx_cframe
    elseif singleton == "NumberSequence" then
        return rbx_numbersequence
    elseif singleton == "ColorSequence" then
        return rbx_colorsequence
    elseif singleton == "NumberRange" then
        return rbx_numberrange
    elseif singleton == "Rect" then
        return rbx_rect
    elseif singleton == "Font" then
        return rbx_font
    end
    error(
        `Unknown attribute type: {singleton}\nExpected string, number, boolean, vector, Vector2, Vector3, UDim, UDim2, BrickColor, Color3, CFrame, NumberSequence, ColorSequence, NumberRange, Rect or Font.`
    )
end

export type function ComponentInfo(t: type): type
    assert(t:is("table"), "`t` isn't a table")

    local props = t:properties()

    -- selene: allow(shadowing)
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

    -- selene: allow(shadowing)
    local function fetchprop(
        props: { [type]: { read: type?, write: type? } },
        prop: type
    ): type
        local found = optionalprop(props, prop)
        assert(found ~= nil, `Prop not found: {prop:value()}`)
        return found
    end

    for key in props do
        local name = key:is("singleton") and key:value()
        assert(name ~= nil, `Found non singleton key: {key}`)
        assert(
            name == "is"
                or name == "tag"
                or name == "attributes"
                or name == "children",
            `Found an extra key: {name}`
        )
    end

    local is_prop = fetchprop(props, types.singleton("is"))
    assert(
        is_prop:is("singleton") and typeof(is_prop:value()) == "string",
        "`is` isn't a string singleton"
    )
    local tag_prop = fetchprop(props, types.singleton("tag"))
    assert(
        tag_prop:is("singleton") and typeof(tag_prop:value()) == "string",
        "`tag` isn't a string singleton"
    )

    local attributes_prop = optionalprop(props, types.singleton("attributes"))
    if attributes_prop then
        assert(attributes_prop:is("table"), "`attributes` isn't a table")
        assert(
            attributes_prop:indexer() == nil,
            "`attributes` shouldn't have an indexer but rather be a record"
        )
        for key, rw in attributes_prop:properties() do
            local attr_name = key:is("singleton") and key:value()
            assert(
                attr_name and typeof(attr_name) == "string",
                "Each key of `attributes` must be a string singleton"
            )
            local value = rw.read or rw.write
            assert(
                value ~= nil and value:is("table"),
                `Expected attribute {attr_name} to be a table with metadata about it`
            )

            local attr_props = value:properties()
            local kind_prop = fetchprop(attr_props, types.singleton("kind"))
            assert(
                kind_prop ~= nil and kind_prop:is("singleton"),
                `Expected attribute {attr_name} to have a \`kind\` key`
            )
            local expected_type: type = TypeOfKind(kind_prop)
            local default_prop =
                optionalprop(attr_props, types.singleton("default"))
            if default_prop then
                if default_prop.tag == "union" then
                    for _, component in default_prop:components() do
                        if component == types.singleton(nil) then
                            continue
                        end

                        default_prop = component
                        break
                    end
                end

                assert(
                    default_prop == expected_type,
                    `Unknown default type for attribute {attr_name}: expected {expected_type.tag} and got {default_prop.tag}`
                )
            end
        end
    end

    local children_prop = optionalprop(props, types.singleton("children"))
    if children_prop then
        assert(children_prop:is("table"), "`children` isn't a table")
        assert(
            children_prop:indexer() == nil,
            "`children` shouldn't have an indexer but rather be a record"
        )
        for key, rw in children_prop:properties() do
            local child_name = key:is("singleton") and key:value()
            assert(
                child_name and typeof(child_name) == "string",
                "Each key of `children` must be a string singleton"
            )
            local value = rw.read or rw.write
            assert(
                value ~= nil
                    and value:is("singleton")
                    and typeof(value:value()) == "string",
                `Expected child {child_name} to be a string singleton of it's class name`
            )
        end
    end

    return t
end

-- Luau vectors and Roblox Vector3s are interchangeable, although the types are absolute ass for it, so we define attribute kinds for both.
export type AttributeKind =
    | "string"
    | "number"
    | "boolean"
    | "vector"
    | "Vector2"
    | "Vector3"
    | "UDim"
    | "UDim2"
    | "BrickColor"
    | "Color3"
    | "CFrame"
    | "NumberSequence"
    | "ColorSequence"
    | "NumberRange"
    | "Rect"
    | "Font"
export type AttributeType =
    | string
    | number
    | boolean
    | vector
    | Vector2
    | Vector3
    | UDim
    | UDim2
    | BrickColor
    | Color3
    | CFrame
    | NumberSequence
    | ColorSequence
    | NumberRange
    | Rect
    | Font

export type AttributeMetadata = {
    kind: AttributeKind,
    default: AttributeType?,
}

export type ComponentInfoRepresentation = {
    is: string,
    tag: string,
    attributes: { [string]: AttributeMetadata }?,
    children: { [string]: string }?,
}

local function info_ctor<T>(info: T): ComponentInfo<T>
    return info
end

type function CheckKind(kind: type): type
    local singleton = kind:is("singleton") and kind:value()
    assert(singleton ~= nil, "The passed type isn't a singleton")
    assert(
        singleton == "string"
            or singleton == "number"
            or singleton == "boolean"
            or singleton == "vector"
            or singleton == "Vector2"
            or singleton == "Vector3"
            or singleton == "UDim"
            or singleton == "UDim2"
            or singleton == "BrickColor"
            or singleton == "Color3"
            or singleton == "CFrame"
            or singleton == "NumberSequence"
            or singleton == "ColorSequence"
            or singleton == "NumberRange"
            or singleton == "Rect"
            or singleton == "Font",
        `Unknown attribute type: {singleton}\nExpected string, number, boolean, vector, Vector2, Vector3, UDim, UDim2, BrickColor, Color3, CFrame, NumberSequence, ColorSequence, NumberRange, Rect or Font.`
    )
    return kind
end

local function attribute_ctor<T>(
    kind: T | AttributeKind,
    default: TypeOfKind<T>?
): { kind: CheckKind<T>, default: TypeOfKind<T>? }
    return {
        kind = kind :: any,
        default = default,
    }
end

local function child_ctor<T>(class_name: T | keyof<rblx_types.Instances> | ""): T
    return class_name
end

local function singleton_ctor<T>(x: T | ""): T
    return x
end

local constructors = table.freeze {
    info = info_ctor,
    attribute = attribute_ctor,
    child = child_ctor,
    singleton = singleton_ctor,
}

return constructors
