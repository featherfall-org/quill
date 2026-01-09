--!strict
--[[
    https://github.com/Scythe-Technology/zune-docs/blob/a7e2f38c0081992e08ffde0a442fcdf2169d5016/tools/utils/printer.luau

    MIT License

    Copyright (c) 2025 Scythe Technology

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    Changes from original: types
]]

local ast_types = require("./types")
local typeforge = require("./typeforge")
local visitor = require("./visitor")

type PrinterOptions = {
    comments: boolean?,
}

local printBlock, printExpr, printStatement, printType, printTypePack

local function exhaustiveMatch(value: never): never
    error(`Unknown value in exhaustive match: {value}`)
end

local function printTrivia(
    trivia: ast_types.Trivia,
    opts: PrinterOptions
): string
    if trivia.tag == "whitespace" then
        return trivia.text
    elseif trivia.tag == "comment" or trivia.tag == "blockcomment" then
        if opts.comments then
            return trivia.text
        else
            return ""
        end
    else
        return exhaustiveMatch(trivia.tag)
    end
end

local function printTriviaList(
    trivias: { ast_types.Trivia },
    opts: PrinterOptions
): string
    local result = {}
    for _, trivia in trivias do
        if
            not opts.comments
            and (trivia.tag == "comment" or trivia.tag == "blockcomment")
        then
            local last_trivia = trivias[#trivias]
            local last_comment
            for _, t in trivias do
                if t.tag ~= "whitespace" then
                    last_comment = t
                end
            end
            local trailing = if (trivia.tag == "comment")
                then "\n"
                elseif last_comment then last_comment.text:match(
                    "([%s]*)$"
                ) or ""
                else ""
            return trailing
                .. (
                    if (last_trivia and last_trivia ~= last_comment)
                        then last_trivia.text:match("([%s]*)$") or ""
                        else ""
                )
        end
        table.insert(result, printTrivia(trivia, opts))
    end
    return table.concat(result, "")
end

local function printToken<T>(
    token: ast_types.Token<T>,
    opts: PrinterOptions
): string
    return printTriviaList(token.leadingTrivia, opts)
        .. token.text :: string
        .. printTriviaList(token.trailingTrivia, opts)
end

local function printString(
    expr: ast_types.AstExprConstantString,
    opts: PrinterOptions
): string
    local result = printTriviaList(expr.leadingTrivia, opts)

    if expr.quoteStyle == "single" then
        result ..= `'{expr.text}'`
    elseif expr.quoteStyle == "double" then
        result ..= `"{expr.text}"`
    elseif expr.quoteStyle == "block" then
        local equals = string.rep("=", expr.blockDepth)
        result ..= `[{equals}[{expr.text}]{equals}]`
    elseif expr.quoteStyle == "interp" then
        result ..= "`" .. expr.text .. "`"
    else
        return exhaustiveMatch(expr.quoteStyle)
    end

    result ..= printTriviaList(expr.trailingTrivia, opts)
    return result
end

local function printInterpolatedString(
    expr: ast_types.AstExprInterpString,
    opts: PrinterOptions
): string
    local result = ""

    for i = 1, #expr.strings do
        result ..= printTriviaList(expr.strings[i].leadingTrivia, opts)
        if i == 1 then
            result ..= "`"
        else
            result ..= "}"
        end
        result ..= expr.strings[i].text

        if i == #expr.strings then
            result ..= "`"
            result ..= printTriviaList(expr.strings[i].trailingTrivia, opts)
        else
            result ..= "{"
            result ..= printTriviaList(expr.strings[i].trailingTrivia, opts)
            result ..= printExpr(expr.expressions[i])
        end
    end

    return result
end

export type Printer = typeforge.extend<visitor.Visitor, {
    result: buffer,
    cursor: number,
}>

local function printVisitor(overlap: visitor.Visitor?, opts: PrinterOptions?)
    opts = opts or { comments = true }
    local printer = visitor.createVisitor() :: Printer

    printer.result = buffer.create(1024)
    printer.cursor = 0

    local function write(str: string)
        local totalSize = printer.cursor + #str
        local bufferSize = buffer.len(printer.result)

        if totalSize >= bufferSize then
            repeat
                bufferSize *= 2
            until bufferSize >= totalSize

            local newBuffer = buffer.create(bufferSize)
            buffer.copy(newBuffer, 0, printer.result)
            printer.result = newBuffer
        end

        buffer.writestring(printer.result, printer.cursor, str)
        printer.cursor = totalSize
    end
    printer.visitToken = function(node: any)
        write(printToken(node, opts :: PrinterOptions))
        return false
    end
    printer.visitString = function(node: any)
        write(printString(node, opts :: PrinterOptions))
        return false
    end
    printer.visitTypeString = function(node: any)
        write(printString(node, opts :: PrinterOptions))
        return false
    end
    printer.visitInterpolatedString = function(node: any)
        write(printInterpolatedString(node, opts :: PrinterOptions))
        return false
    end
    if overlap then
        for overlap, fn in overlap :: any do
            (printer :: any)[overlap] = function(node)
                return fn(node, printer)
            end
        end
    end
    return printer
end

function printBlock(
    node: ast_types.AstStatBlock,
    overlap: visitor.Visitor?,
    opts: PrinterOptions?
): string
    local printer = printVisitor(overlap, opts)
    visitor.visitBlock(node, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printExpr(
    node: ast_types.AstExpr,
    overlap: visitor.Visitor?,
    opts: PrinterOptions?
): string
    local printer = printVisitor(overlap, opts)
    visitor.visitExpression(node, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printStatement(
    node: ast_types.AstStat,
    overlap: visitor.Visitor?,
    opts: PrinterOptions?
): string
    local printer = printVisitor(overlap, opts)
    visitor.visitStatement(node, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printType(
    node: ast_types.AstType,
    overlap: visitor.Visitor?,
    opts: PrinterOptions?
): string
    local printer = printVisitor(overlap, opts)
    visitor.visitType(node, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printTypePack(
    node: ast_types.AstTypePack,
    overlap: visitor.Visitor?,
    opts: PrinterOptions?
): string
    local printer = printVisitor(overlap, opts)
    visitor.visitTypePack(node, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

return {
    printVisitor = printVisitor,
    printBlock = printBlock,
    printExpr = printExpr,
    printStatement = printStatement,
    printType = printType,
    printTypePack = printTypePack,
    printToken = printToken,
    printString = printString,
    printInterpolatedString = printInterpolatedString,
}
