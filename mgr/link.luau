local fs = zune.fs
local stdpath = fs.path
local io = zune.io
local Process = require("@mgr/util/Process")
local fs_util = require("./util/fs")

local ast_types = require("./util/syntax/types")
local parser = require("./util/syntax/parser")
local printer = require("./util/syntax/printer")
local visitor = require("./util/syntax/visitor")

local function link(options: { crate_path: string })
    local module_path = stdpath.join(options.crate_path, "lib", "init.luau")
    local linker_path = stdpath.join(options.crate_path, "init.luau")
    if not fs_util.exists(module_path) then
        error(`{module_path} doesn't exist.`)
    end

    if fs.stat(linker_path).kind ~= "none" then
        fs.deleteFile(linker_path)
    end

    local contents = fs.readFile(module_path)
    local linker = io.createBufferSink()
    linker:write("local lib = require(\"@self/lib\")\n")

    local parsed = parser.parseBlock(contents)
    local link_visitor = visitor.createVisitor()

    link_visitor.visitTypeAlias = function(alias: ast_types.AstStatTypeAlias)
        if not alias.export then
            return true
        end

        local stat = table.clone(alias)
        local eof_column = stat.equals.position.column

        local nil_singleton: ast_types.AstTypeReference = {
            tag = "reference",
            name = {
                leadingTrivia = {
                    {
                        tag = "whitespace",
                        location = {
                            begin = {
                                line = 1,
                                column = eof_column + 1,
                            },
                            ["end"] = {
                                line = 1,
                                column = eof_column + 1,
                            },
                        },
                        text = " ",
                    },
                },
                position = {
                    line = 1,
                    column = eof_column + 2,
                },
                text = "nil",
                trailingTrivia = {},
            },
        }
        stat.type = nil_singleton

        local stage1 = printer.printStatement(stat)

        local generics = ""
        if stat.generics then
            for _, generic in stat.generics do
                generics ..= generic.node.name.text
                if generic.separator then
                    generics ..= ", "
                end
            end
        end
        if stat.genericPacks then
            for _, pack in stat.genericPacks do
                generics ..= pack.node.name.text
                generics ..= "..."
                if pack.separator then
                    generics ..= ", "
                end
            end
        end

        local stage2 = if #generics > 0
            then `lib.{alias.name.text}<{generics}>\n`
            else `lib.{alias.name.text}\n`
        local reversed = string.reverse(stage1)
        local replaced = string.gsub(
            reversed,
            string.reverse("nil"),
            string.reverse(stage2),
            1
        )
        local output = string.reverse(replaced)

        linker:write(output)

        return true
    end
    visitor.visitBlock(parsed, link_visitor)

    linker:write("return lib")
    fs.writeFileSync(linker_path, linker:flush())
    linker:close()

    Process.new("stylua"):argument(linker_path):run()
end

return link
