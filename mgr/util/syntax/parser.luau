local luau = zune.luau
local ast_types = require("./types")

local function parseBlock(source: string | buffer): ast_types.AstStatBlock
    return (luau.parse(source) :: any).root
end

local function parseExpr(source: string | buffer): ast_types.AstExpr
    return luau.parseExpr(source)
end

local function parse(source: string | buffer): ast_types.ParseResult
    return luau.parse(source) :: any
end

local parser = table.freeze {
    parseBlock = parseBlock,
    parseExpr = parseExpr,
    parse = parse,
}

return parser
