local luau = zune.luau
local fs = zune.fs

local cache = {}
local function dynrequire<T>(path: string): T
    local hit = cache[path]
    if hit then
        return hit :: T
    end

    local contents = fs.readFile(path)
    local bytecode = luau.compile(contents, { optimization_level = 2 })
    local result = luau.load(bytecode)() :: any
    cache[path] = result
    return result :: T
end

return dynrequire
