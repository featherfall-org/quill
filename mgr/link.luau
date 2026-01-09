local fs = zune.fs
local stdpath = fs.path
local io = zune.io
local luau = zune.luau
local fs_util = require("./util/fs")

local ast_types = require("./util/parser/types")
local printer = require("./util/parser/printer")
local visitor = require("./util/parser/visitor")

local function link(options: { crate_path: string })
    local module_path = stdpath.join(options.crate_path, "lib", "init.luau")
    local linker_path = stdpath.join(options.crate_path, "init.luau")
    if not fs_util.exists(module_path) then
        error(`{module_path} doesn't exist.`)
    end

    local contents = fs.readFile(module_path)
    local linker = io.createBufferSink()
    linker:write("local lib = require(\"@self/lib\")\n")

    local parsed = luau.parse(contents)
    local link_visitor = visitor.createVisitor()
    link_visitor.visitTypeAlias = function(alias: ast_types.AstStatTypeAlias)
        if not alias.export then
            return true
        end

        local block: ast_types.AstStatBlock = {
            tag = "block",
            statements = { alias },
        }
        local stringified = printer.printBlock(block)
        linker:write(`{stringified}\n`)

        return true
    end
    visitor.visitBlock(parsed.root, link_visitor)

    linker:write("return lib")
    fs.writeFile(linker_path, linker:flush())
    linker:close()
end

return link
