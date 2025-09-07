--[[
    https://github.com/checkraisefold/warmluau/blob/dbec4199a1897ccfd02bc3f056365b42e577c8f3/ext/std/syntax/parser.luau

    MIT License

    Copyright (c) 2025 Lazarus Industries, LLC

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]
local luau = zune.luau
local json = zune.serde.json
local ast_types = require("@self/types")

type function deerror(t: type): type
    if t.tag ~= "union" then
        return t
    end

    local err = types.singleton("errors")
    local cts = t:components()
    local parts = {}
    for _, ct in cts do
        if ct.tag == "table" then
            local has = false
            for prop in ct:properties() do
                if prop == err then
                    has = true
                    break
                end
            end
            if has then
                continue
            end
        end
        table.insert(parts, ct)
    end

    if #parts < 2 then
        return parts[#parts]
    end

    return types.unionof(unpack(parts))
end

local function check<T>(result: T): deerror<T>
    local cast: any = result
    if cast.errors then
        error(json.encode(cast.errors))
    end
    return result
end

local function parse(source: string): ast_types.AstStatBlock
    return check(luau.parse(source)).root :: ast_types.AstStatBlock
end

local function parseexpr(source: string): ast_types.AstExpr
    return check(luau.parseExpr(source))
end

export type ParseResult = {
    root: ast_types.AstStatBlock,
    eof: ast_types.Eof,
}

local function parsefile(source: string): ParseResult
    local result = check(luau.parse(source)) :: ast_types.ParseResult
    return { root = result.root, eof = result.eof }
end

return {
    parse = parse,
    parseexpr = parseexpr,
    parsefile = parsefile,
}
