--[[
    https://github.com/checkraisefold/warmluau/blob/dbec4199a1897ccfd02bc3f056365b42e577c8f3/ext/std/syntax/printer.luau

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
local types = require("./types")
local visitor = require("./visitor")

local function exhaustiveMatch(value: never): never
    error(`Unknown value in exhaustive match: {value}`)
end

local function printTrivia(trivia: types.Trivia): string
    if
        trivia.tag == "whitespace"
        or trivia.tag == "comment"
        or trivia.tag == "blockcomment"
    then
        return trivia.text
    else
        return exhaustiveMatch(trivia.tag)
    end
end

local function printTriviaList(trivia: { types.Trivia })
    local result = ""
    for _, trivia in trivia do
        result ..= printTrivia(trivia)
    end
    return result
end

local function printToken(token: types.Token): string
    return printTriviaList(token.leadingTrivia)
        .. token.text
        .. printTriviaList(token.trailingTrivia)
end

local function printString(expr: types.AstExprConstantString): string
    local result = printTriviaList(expr.leadingTrivia)

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

    result ..= printTriviaList(expr.trailingTrivia)
    return result
end

local function printInterpolatedString(expr: types.AstExprInterpString): string
    local result = ""

    for i = 1, #expr.strings do
        result ..= printTriviaList(expr.strings[i].leadingTrivia)
        if i == 1 then
            result ..= "`"
        else
            result ..= "}"
        end
        result ..= expr.strings[i].text

        if i == #expr.strings then
            result ..= "`"
            result ..= printTriviaList(expr.strings[i].trailingTrivia)
        else
            result ..= "{"
            result ..= printTriviaList(expr.strings[i].trailingTrivia)
            result ..= printExpr(expr.expressions[i])
        end
    end

    return result
end

type PrintVisitor = visitor.Visitor & {
    result: buffer,
    cursor: number,
}

local function printVisitor()
    local printer = visitor.createVisitor() :: PrintVisitor

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

    printer.visitToken = function(node: types.Token)
        write(printToken(node))
        return false
    end

    printer.visitString = function(node: types.AstExprConstantString)
        write(printString(node))
        return false
    end

    printer.visitTypeString = function(node: types.AstTypeSingletonString)
        write(printString(node :: any --[[ whatever ]]))
        return false
    end

    printer.visitInterpolatedString = function(node: types.AstExprInterpString)
        write(printInterpolatedString(node))
        return false
    end

    return printer
end

--- Returns a string representation of an AstStatBlock
local function printBlock(block: types.AstStatBlock): string
    local printer = printVisitor()
    visitor.visitBlock(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

--- Returns a string representation of an AstExpr
function printExpr(block: types.AstExpr): string
    local printer = printVisitor()
    visitor.visitExpression(block, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

function printFile(result: { root: types.AstStatBlock, eof: types.Eof }): string
    local printer = printVisitor()
    visitor.visitBlock(result.root, printer)
    visitor.visitToken(result.eof, printer)
    return buffer.readstring(printer.result, 0, printer.cursor)
end

return {
    print = printBlock,
    printexpr = printExpr,
    printfile = printFile,
}
