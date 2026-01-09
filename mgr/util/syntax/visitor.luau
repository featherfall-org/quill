--!strict
--[[
    https://github.com/Scythe-Technology/zune-docs/blob/a7e2f38c0081992e08ffde0a442fcdf2169d5016/tools/utils/visitor.luau

    MIT License

    Copyright (c) 2025 Scythe Technology

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    Changes from original: types
]]

local types = require("./types")

local function alwaysVisit(...: any)
    return true
end

export type Visitor = {
    visitBlock: (types.AstStatBlock) -> boolean,
    visitBlockEnd: (types.AstStatBlock) -> (),
    visitIf: (types.AstStatIf) -> boolean,
    visitWhile: (types.AstStatWhile) -> boolean,
    visitRepeat: (types.AstStatRepeat) -> boolean,
    visitReturn: (types.AstStatReturn) -> boolean,
    visitLocalDeclaration: (types.AstStatLocal) -> boolean,
    visitLocalDeclarationEnd: (types.AstStatLocal) -> (),
    visitFor: (types.AstStatFor) -> boolean,
    visitForIn: (types.AstStatForIn) -> boolean,
    visitAssign: (types.AstStatAssign) -> boolean,
    visitCompoundAssign: (types.AstStatCompoundAssign) -> boolean,
    visitFunction: (types.AstStatFunction) -> boolean,
    visitLocalFunction: (types.AstStatLocalFunction) -> boolean,
    visitTypeAlias: (types.AstStatTypeAlias) -> boolean,
    visitStatTypeFunction: (types.AstStatTypeFunction) -> boolean,

    visitExpression: (types.AstExpr) -> boolean,
    vitiExpressionEnd: (types.AstExpr) -> boolean,
    visitLocalReference: (types.AstExprLocal) -> boolean,
    visitGlobal: (types.AstExprGlobal) -> boolean,
    visitCall: (types.AstExprCall) -> boolean,
    visitUnary: (types.AstExprUnary) -> boolean,
    visitBinary: (types.AstExprBinary) -> boolean,
    visitAnonymousFunction: (types.AstExprAnonymousFunction) -> boolean,
    visitTableItem: (types.AstExprTableItem) -> boolean,
    visitTable: (types.AstExprTable) -> boolean,
    visitIndexName: (types.AstExprIndexName) -> boolean,
    visitGroup: (types.AstExprGroup) -> boolean,
    visitInterpolatedString: (types.AstExprInterpString) -> boolean,
    visitTypeAssertion: (types.AstExprTypeAssertion) -> boolean,
    visitIfExpression: (types.AstExprIfElse) -> boolean,

    visitTypeReference: (types.AstTypeReference) -> boolean,
    visitTypeBoolean: (types.AstTypeSingletonBool) -> boolean,
    visitTypeString: (types.AstTypeSingletonString) -> boolean,
    visitTypeTypeof: (types.AstTypeTypeof) -> boolean,
    visitTypeGroup: (types.AstTypeGroup) -> boolean,
    visitTypeUnion: (types.AstTypeUnion) -> boolean,
    visitTypeIntersection: (types.AstTypeIntersection) -> boolean,
    visitTypeArray: (types.AstTypeArray) -> boolean,
    visitTypeTable: (types.AstTypeTable) -> boolean,
    visitTypeFunction: (types.AstTypeFunction) -> boolean,

    visitTypePackExplicit: (types.AstTypePackExplicit) -> boolean,
    visitTypePackGeneric: (types.AstTypePackGeneric) -> boolean,
    visitTypePackVariadic: (types.AstTypePackVariadic) -> boolean,

    visitToken: (types.Token) -> boolean,
    visitNil: (types.AstExprConstantNil) -> boolean,
    visitString: (types.AstExprConstantString) -> boolean,
    visitBoolean: (types.AstExprConstantBool) -> boolean,
    visitNumber: (types.AstExprConstantNumber) -> boolean,
    visitLocal: (types.AstLocal) -> boolean,
    visitVarargs: (types.AstExprVarargs) -> boolean,
}

local defaultVisitor = {
    visitBlock = alwaysVisit :: any,
    visitBlockEnd = alwaysVisit :: any,
    visitIf = alwaysVisit :: any,
    visitWhile = alwaysVisit :: any,
    visitRepeat = alwaysVisit :: any,
    visitReturn = alwaysVisit :: any,
    visitLocalDeclaration = alwaysVisit :: any,
    visitLocalDeclarationEnd = alwaysVisit :: any,
    visitFor = alwaysVisit :: any,
    visitForIn = alwaysVisit :: any,
    visitAssign = alwaysVisit :: any,
    visitCompoundAssign = alwaysVisit :: any,
    visitFunction = alwaysVisit :: any,
    visitLocalFunction = alwaysVisit :: any,
    visitTypeAlias = alwaysVisit :: any,
    visitStatTypeFunction = alwaysVisit :: any,

    visitExpression = alwaysVisit :: any,
    visitExpressionEnd = alwaysVisit :: any,
    visitLocalReference = alwaysVisit :: any,
    visitGlobal = alwaysVisit :: any,
    visitCall = alwaysVisit :: any,
    visitUnary = alwaysVisit :: any,
    visitBinary = alwaysVisit :: any,
    visitAnonymousFunction = alwaysVisit :: any,
    visitTableItem = alwaysVisit :: any,
    visitTable = alwaysVisit :: any,
    visitIndexName = alwaysVisit :: any,
    visitIndexExpr = alwaysVisit :: any,
    visitGroup = alwaysVisit :: any,
    visitInterpolatedString = alwaysVisit,
    visitTypeAssertion = alwaysVisit,
    visitIfExpression = alwaysVisit,

    visitTypeReference = alwaysVisit :: any,
    visitTypeBoolean = alwaysVisit :: any,
    visitTypeString = alwaysVisit :: any,
    visitTypeTypeof = alwaysVisit :: any,
    visitTypeGroup = alwaysVisit :: any,
    visitTypeUnion = alwaysVisit :: any,
    visitTypeIntersection = alwaysVisit :: any,
    visitTypeArray = alwaysVisit :: any,
    visitTypeTable = alwaysVisit :: any,
    visitTypeFunction = alwaysVisit,

    visitTypePackExplicit = alwaysVisit,
    visitTypePackGeneric = alwaysVisit,
    visitTypePackVariadic = alwaysVisit,

    visitToken = alwaysVisit :: any,
    visitNil = alwaysVisit :: any,
    visitString = alwaysVisit :: any,
    visitBoolean = alwaysVisit :: any,
    visitNumber = alwaysVisit :: any,
    visitLocal = alwaysVisit :: any,
    visitVarargs = alwaysVisit :: any,
}

local function exhaustiveMatch(value: never): never
    error(`Unknown value in exhaustive match: {value}`)
end

local function visitToken(token: any, visitor: any)
    visitor.visitToken(token)
end

local function visitPunctuated<T>(list: any, visitor: any, apply: (T, any) -> ())
    for _, item in list do
        apply(item.node, visitor)
        if item.separator then
            visitToken(item.separator, visitor)
        end
    end
end

local function visitLocal(node: any, visitor: any)
    if visitor.visitLocal(node) then
        visitToken(node.name, visitor)
        if node.colon then
            visitToken(node.colon, visitor)
        end
        if node.annotation then
            visitType(node.annotation, visitor)
        end
    end
end

local function visitBlock(block: any, visitor: any)
    if visitor.visitBlock(block) then
        for _, statement in block.statements do
            visitStatement(statement, visitor)
        end

        visitor.visitBlockEnd(block)
    end
end

local function visitIf(node: any, visitor: any)
    if visitor.visitIf(node) then
        visitToken(node.ifKeyword, visitor)
        visitExpression(node.condition, visitor)
        visitToken(node.thenKeyword, visitor)
        visitBlock(node.consequent, visitor)
        for _, elseifNode in node.elseifs do
            visitToken(elseifNode.elseifKeyword, visitor)
            visitExpression(elseifNode.condition, visitor)
            visitToken(elseifNode.thenKeyword, visitor)
            visitBlock(elseifNode.consequent, visitor)
        end
        if node.elseKeyword then
            visitToken(node.elseKeyword, visitor)
        end
        if node.antecedent then
            visitBlock(node.antecedent, visitor)
        end
        visitToken(node.endKeyword, visitor)
    end
end

local function visitWhile(node: any, visitor: any)
    if visitor.visitWhile(node) then
        visitToken(node.whileKeyword, visitor)
        visitExpression(node.condition, visitor)
        visitToken(node.doKeyword, visitor)
        visitBlock(node.body, visitor)
        visitToken(node.endKeyword, visitor)
    end
end

local function visitRepeat(node: any, visitor: any)
    if visitor.visitRepeat(node) then
        visitToken(node.repeatKeyword, visitor)
        visitBlock(node.body, visitor)
        visitToken(node.untilKeyword, visitor)
        visitExpression(node.condition, visitor)
    end
end

local function visitReturn(node: any, visitor: any)
    if visitor.visitReturn(node) then
        visitToken(node.returnKeyword, visitor)
        visitPunctuated(node.expressions, visitor, visitExpression)
    end
end

local function visitLocalStatement(node: any, visitor: any)
    if visitor.visitLocalDeclaration(node) then
        visitToken(node.localKeyword, visitor)
        visitPunctuated(node.variables, visitor, visitLocal)
        if node.equals then
            visitToken(node.equals, visitor)
        end
        visitPunctuated(node.values, visitor, visitExpression)

        visitor.visitLocalDeclarationEnd(node)
    end
end

local function visitFor(node: any, visitor: any)
    if visitor.visitFor(node) then
        visitToken(node.forKeyword, visitor)
        visitLocal(node.variable, visitor)
        visitToken(node.equals, visitor)
        visitExpression(node.from, visitor)
        visitToken(node.toComma, visitor)
        visitExpression(node.to, visitor)
        if node.stepComma then
            visitToken(node.stepComma, visitor)
        end
        if node.step then
            visitExpression(node.step, visitor)
        end
        visitToken(node.doKeyword, visitor)
        visitBlock(node.body, visitor)
        visitToken(node.endKeyword, visitor)
    end
end

local function visitForIn(node: any, visitor: any)
    if visitor.visitForIn(node) then
        visitToken(node.forKeyword, visitor)
        visitPunctuated(node.variables, visitor, visitLocal)
        visitToken(node.inKeyword, visitor)
        visitPunctuated(node.values, visitor, visitExpression)
        visitToken(node.doKeyword, visitor)
        visitBlock(node.body, visitor)
        visitToken(node.endKeyword, visitor)
    end
end

local function visitAssign(node: any, visitor: any)
    if visitor.visitAssign(node) then
        visitPunctuated(node.variables, visitor, visitExpression)
        visitToken(node.equals, visitor)
        visitPunctuated(node.values, visitor, visitExpression)
    end
end

local function visitCompoundAssign(node: any, visitor: any)
    if visitor.visitCompoundAssign(node) then
        visitExpression(node.variable, visitor)
        visitToken(node.operand, visitor)
        visitExpression(node.value, visitor)
    end
end

local function visitGeneric(node: any, visitor: any)
    visitToken(node.name, visitor)
    if node.equals then
        visitToken(node.equals, visitor)
    end
    if node.default then
        visitType(node.default, visitor)
    end
end

local function visitGenericPack(node: any, visitor: any)
    visitToken(node.name, visitor)
    visitToken(node.ellipsis, visitor)
    if node.equals then
        visitToken(node.equals, visitor)
    end
    if node.default then
        visitTypePack(node.default, visitor)
    end
end

local function visitTypeAlias(node: any, visitor: any)
    if visitor.visitTypeAlias(node) then
        if node.export then
            visitToken(node.export, visitor)
        end
        visitToken(node.typeToken, visitor)
        visitToken(node.name, visitor)
        if node.openGenerics then
            visitToken(node.openGenerics, visitor)
        end
        if node.generics then
            visitPunctuated(node.generics, visitor, visitGeneric)
        end
        if node.genericPacks then
            visitPunctuated(node.genericPacks, visitor, visitGenericPack)
        end
        if node.closeGenerics then
            visitToken(node.closeGenerics, visitor)
        end
        visitToken(node.equals, visitor)
        visitType(node.type, visitor)
    end
end

local function visitString(node: any, visitor: any)
    if visitor.visitString(node) then
        visitor.visitToken(node)
    end
end

local function visitNil(node: any, visitor: any)
    if visitor.visitNil(node) then
        visitToken(node, visitor)
    end
end

local function visitBoolean(node: any, visitor: any)
    if visitor.visitBoolean(node) then
        visitToken(node, visitor)
    end
end

local function visitNumber(node: any, visitor: any)
    if visitor.visitNumber(node) then
        visitToken(node, visitor)
    end
end

local function visitLocalReference(node: any, visitor: any)
    if visitor.visitLocalReference(node) then
        visitor.visitToken(node.token)
    end
end

local function visitGlobal(node: any, visitor: any)
    if visitor.visitGlobal(node) then
        visitor.visitToken(node.name)
    end
end

local function visitVarargs(node: any, visitor: any)
    if visitor.visitVarargs(node) then
        visitToken(node, visitor)
    end
end

local function visitCall(node: any, visitor: any)
    if visitor.visitCall(node) then
        visitExpression(node.func, visitor)
        if node.openParens then
            visitToken(node.openParens, visitor)
        end
        visitPunctuated(node.arguments, visitor, visitExpression)
        if node.closeParens then
            visitToken(node.closeParens, visitor)
        end
    end
end

local function visitUnary(node: any, visitor: any)
    if visitor.visitUnary(node) then
        visitToken(node.operator, visitor)
        visitExpression(node.operand, visitor)
    end
end

local function visitBinary(node: any, visitor: any)
    if visitor.visitBinary(node) then
        visitExpression(node.lhsoperand, visitor)
        visitToken(node.operator, visitor)
        visitExpression(node.rhsoperand, visitor)
    end
end

local function visitFunctionBody(node: any, visitor: any)
    if node.openGenerics then
        visitToken(node.openGenerics, visitor)
    end
    if node.generics then
        visitPunctuated(node.generics, visitor, visitGeneric)
    end
    if node.genericPacks then
        visitPunctuated(node.genericPacks, visitor, visitGenericPack)
    end
    if node.closeGenerics then
        visitToken(node.closeGenerics, visitor)
    end
    visitToken(node.openParens, visitor)
    visitPunctuated(node.parameters, visitor, visitLocal)
    if node.vararg then
        visitToken(node.vararg, visitor)
    end
    if node.varargColon then
        visitToken(node.varargColon, visitor)
    end
    if node.varargAnnotation then
        visitTypePack(node.varargAnnotation, visitor)
    end
    visitToken(node.closeParens, visitor)
    if node.returnSpecifier then
        visitToken(node.returnSpecifier, visitor)
    end
    if node.returnAnnotation then
        visitTypePack(node.returnAnnotation, visitor)
    end
    visitBlock(node.body, visitor)
    visitToken(node.endKeyword, visitor)
end

local function visitAttribute(node: any, visitor)
    visitToken(node, visitor)
end

local function visitAnonymousFunction(node: any, visitor: any)
    if visitor.visitAnonymousFunction(node) then
        for _, attribute in node.attributes do
            visitAttribute(attribute, visitor)
        end
        visitToken(node.functionKeyword, visitor)
        visitFunctionBody(node.body, visitor)
    end
end

local function visitFunction(node: any, visitor: any)
    if visitor.visitFunction(node) then
        for _, attribute in node.attributes do
            visitAttribute(attribute, visitor)
        end
        visitToken(node.functionKeyword, visitor)
        visitExpression(node.name, visitor)
        visitFunctionBody(node.body, visitor)
    end
end

local function visitLocalFunction(node: any, visitor: any)
    if visitor.visitLocalFunction(node) then
        for _, attribute in node.attributes do
            visitAttribute(attribute, visitor)
        end
        visitToken(node.localKeyword, visitor)
        visitToken(node.functionKeyword, visitor)
        visitLocal(node.name, visitor)
        visitFunctionBody(node.body, visitor)
    end
end

local function visitStatTypeFunction(node: any, visitor: any)
    if visitor.visitStatTypeFunction(node) then
        if node.export then
            visitToken(node.export, visitor)
        end
        visitToken(node.type, visitor)
        visitToken(node.functionKeyword, visitor)
        visitToken(node.name, visitor)
        visitFunctionBody(node.body, visitor)
    end
end

local function visitTableItem(node: any, visitor: any)
    if visitor.visitTableItem(node) then
        if node.kind == "list" then
            visitExpression(node.value, visitor)
        elseif node.kind == "record" then
            visitToken(node.key, visitor)
            visitToken(node.equals, visitor)
            visitExpression(node.value, visitor)
        elseif node.kind == "general" then
            visitToken(node.indexerOpen, visitor)
            visitExpression(node.key, visitor)
            visitToken(node.indexerClose, visitor)
            visitToken(node.equals, visitor)
            visitExpression(node.value, visitor)
        else
            exhaustiveMatch(node.kind)
        end

        if node.separator then
            visitToken(node.separator, visitor)
        end
    end
end

local function visitTable(node: any, visitor: any)
    if visitor.visitTable(node) then
        visitToken(node.openBrace, visitor)
        for _, item in node.entries do
            visitTableItem(item, visitor)
        end
        visitToken(node.closeBrace, visitor)
    end
end

local function visitIndexName(node: any, visitor: any)
    if visitor.visitIndexName(node) then
        visitExpression(node.expression, visitor)
        visitToken(node.accessor, visitor)
        visitToken(node.index, visitor)
    end
end

local function visitIndexExpr(node: any, visitor: any)
    if visitor.visitIndexExpr(node) then
        visitExpression(node.expression, visitor)
        visitToken(node.openBrackets, visitor)
        visitExpression(node.index, visitor)
        visitToken(node.closeBrackets, visitor)
    end
end

local function visitGroup(node: any, visitor: any)
    if visitor.visitGroup(node) then
        visitToken(node.openParens, visitor)
        visitExpression(node.expression, visitor)
        visitToken(node.closeParens, visitor)
    end
end

local function visitInterpolatedString(node: any, visitor: any)
    if visitor.visitInterpolatedString(node) then
        for i = 1, #node.strings do
            visitToken(node.strings[i], visitor)
            if i <= #node.expressions then
                visitExpression(node.expressions[i], visitor)
            end
        end
    end
end

local function visitTypeAssertion(node: any, visitor: any)
    if visitor.visitTypeAssertion(node) then
        visitExpression(node.operand, visitor)
        visitToken(node.operator, visitor)
        visitType(node.annotation, visitor)
    end
end

local function visitIfExpression(node: any, visitor: any)
    if visitor.visitIfExpression(node) then
        visitToken(node.ifKeyword, visitor)
        visitExpression(node.condition, visitor)
        visitToken(node.thenKeyword, visitor)
        visitExpression(node.consequent, visitor)
        for _, elseifs in node.elseifs do
            visitToken(elseifs.elseifKeyword, visitor)
            visitExpression(elseifs.condition, visitor)
            visitToken(elseifs.thenKeyword, visitor)
            visitExpression(elseifs.consequent, visitor)
        end
        visitToken(node.elseKeyword, visitor)
        visitExpression(node.antecedent, visitor)
    end
end

local function visitTypeOrPack(node: any, visitor: any)
    if
        node.tag == "explicit"
        or node.tag == "generic"
        or node.tag == "variadic"
    then
        visitTypePack(node, visitor)
    else
        visitType(node, visitor)
    end
end

local function visitTypeReference(node: any, visitor: any)
    if visitor.visitTypeReference(node) then
        if node.prefix then
            visitToken(node.prefix, visitor)
        end
        if node.prefixPoint then
            visitToken(node.prefixPoint, visitor)
        end
        visitToken(node.name, visitor)
        if node.openParameters then
            visitToken(node.openParameters, visitor)
        end
        if node.parameters then
            visitPunctuated(node.parameters, visitor, visitTypeOrPack)
        end
        if node.closeParameters then
            visitToken(node.closeParameters, visitor)
        end
    end
end

local function visitTypeBoolean(node: any, visitor: any)
    if visitor.visitTypeBoolean(node) then
        visitToken(node, visitor)
    end
end

local function visitTypeString(node: any, visitor: any)
    if visitor.visitTypeString(node) then
        visitToken(node, visitor)
    end
end

local function visitTypeTypeof(node: any, visitor: any)
    if visitor.visitTypeTypeof(node) then
        visitToken(node.typeof, visitor)
        visitToken(node.openParens, visitor)
        visitExpression(node.expression, visitor)
        visitToken(node.closeParens, visitor)
    end
end

local function visitTypeGroup(node: any, visitor: any)
    if visitor.visitTypeGroup(node) then
        visitToken(node.openParens, visitor)
        visitType(node.type, visitor)
        visitToken(node.closeParens, visitor)
    end
end

local function visitTypeUnion(node: any, visitor: any)
    if visitor.visitTypeUnion(node) then
        if node.leading then
            visitToken(node.leading, visitor)
        end
        visitPunctuated(node.types, visitor, visitType)
    end
end

local function visitTypeIntersection(node: any, visitor: any)
    if visitor.visitTypeIntersection(node) then
        if node.leading then
            visitToken(node.leading, visitor)
        end
        visitPunctuated(node.types, visitor, visitType)
    end
end

local function visitTypeArray(node: any, visitor: any)
    if visitor.visitTypeArray(node) then
        visitToken(node.openBrace, visitor)
        if node.access then
            visitToken(node.access, visitor)
        end
        visitType(node.type, visitor)
        visitToken(node.closeBrace, visitor)
    end
end

local function visitTypeTable(node: any, visitor: any)
    if visitor.visitTypeTable(node) then
        visitToken(node.openBrace, visitor)
        for _, entry in node.entries do
            if entry.access then
                visitToken(entry.access, visitor)
            end
            if entry.kind == "indexer" then
                visitToken(entry.indexerOpen, visitor)
                visitType(entry.key, visitor)
                visitToken(entry.indexerClose, visitor)
            elseif entry.kind == "stringproperty" then
                visitToken(entry.indexerOpen, visitor)
                visitTypeString(entry.key, visitor)
                visitToken(entry.indexerClose, visitor)
            else
                visitToken(entry.key, visitor)
            end
            visitToken(entry.colon, visitor)
            visitType(entry.value, visitor)
            if entry.separator then
                visitToken(entry.separator, visitor)
            end
        end
        visitToken(node.closeBrace, visitor)
    end
end

local function visitTypeFunctionParameter(node: any, visitor)
    if node.name then
        visitToken(node.name, visitor)
    end
    if node.colon then
        visitToken(node.colon, visitor)
    end
    visitType(node.type, visitor)
end

local function visitTypeFunction(node: any, visitor: any)
    if visitor.visitTypeFunction(node) then
        if node.openGenerics then
            visitToken(node.openGenerics, visitor)
        end
        if node.generics then
            visitPunctuated(node.generics, visitor, visitGeneric)
        end
        if node.genericPacks then
            visitPunctuated(node.genericPacks, visitor, visitGenericPack)
        end
        if node.closeGenerics then
            visitToken(node.closeGenerics, visitor)
        end
        visitToken(node.openParens, visitor)
        visitPunctuated(node.parameters, visitor, visitTypeFunctionParameter)
        if node.vararg then
            visitTypePack(node.vararg, visitor)
        end
        visitToken(node.closeParens, visitor)
        visitToken(node.returnArrow, visitor)
        visitTypePack(node.returnTypes, visitor)
    end
end

local function visitTypePackExplicit(node: any, visitor: any)
    if visitor.visitTypePackExplicit(node) then
        if node.openParens then
            visitToken(node.openParens, visitor)
        end
        visitPunctuated(node.types, visitor, visitType)
        if node.tailType then
            visitTypePack(node.tailType, visitor)
        end
        if node.closeParens then
            visitToken(node.closeParens, visitor)
        end
    end
end

local function visitTypePackGeneric(node: any, visitor: any)
    if visitor.visitTypePackGeneric(node) then
        visitToken(node.name, visitor)
        visitToken(node.ellipsis, visitor)
    end
end

local function visitTypePackVariadic(node: any, visitor: any)
    if visitor.visitTypePackVariadic(node) then
        if node.ellipsis then
            visitToken(node.ellipsis, visitor)
        end
        visitType(node.type, visitor)
    end
end

function visitExpression(expression: any, visitor: any)
    if visitor.visitExpression(expression) then
        if expression.tag == "nil" then
            visitNil(expression, visitor)
        elseif expression.tag == "boolean" then
            visitBoolean(expression, visitor)
        elseif expression.tag == "number" then
            visitNumber(expression, visitor)
        elseif expression.tag == "string" then
            visitString(expression, visitor)
        elseif expression.tag == "local" then
            visitLocalReference(expression, visitor)
        elseif expression.tag == "global" then
            visitGlobal(expression, visitor)
        elseif expression.tag == "vararg" then
            visitVarargs(expression, visitor)
        elseif expression.tag == "call" then
            visitCall(expression, visitor)
        elseif expression.tag == "unary" then
            visitUnary(expression, visitor)
        elseif expression.tag == "binary" then
            visitBinary(expression, visitor)
        elseif expression.tag == "function" then
            visitAnonymousFunction(expression, visitor)
        elseif expression.tag == "table" then
            visitTable(expression, visitor)
        elseif expression.tag == "indexname" then
            visitIndexName(expression, visitor)
        elseif expression.tag == "index" then
            visitIndexExpr(expression, visitor)
        elseif expression.tag == "group" then
            visitGroup(expression, visitor)
        elseif expression.tag == "interpolatedstring" then
            visitInterpolatedString(expression, visitor)
        elseif expression.tag == "cast" then
            visitTypeAssertion(expression, visitor)
        elseif expression.tag == "conditional" then
            visitIfExpression(expression, visitor)
        else
            exhaustiveMatch(expression.tag)
        end

        visitor.visitExpressionEnd(expression)
    end
end

function visitStatement(statement: any, visitor: any)
    if statement.tag == "block" then
        visitBlock(statement, visitor)
    elseif statement.tag == "conditional" then
        visitIf(statement, visitor)
    elseif statement.tag == "expression" then
        visitExpression(statement.expression, visitor)
    elseif statement.tag == "local" then
        visitLocalStatement(statement, visitor)
    elseif statement.tag == "return" then
        visitReturn(statement, visitor)
    elseif statement.tag == "while" then
        visitWhile(statement, visitor)
    elseif statement.tag == "break" then
        visitToken(statement, visitor)
    elseif statement.tag == "continue" then
        visitToken(statement, visitor)
    elseif statement.tag == "repeat" then
        visitRepeat(statement, visitor)
    elseif statement.tag == "for" then
        visitFor(statement, visitor)
    elseif statement.tag == "forin" then
        visitForIn(statement, visitor)
    elseif statement.tag == "assign" then
        visitAssign(statement, visitor)
    elseif statement.tag == "compoundassign" then
        visitCompoundAssign(statement, visitor)
    elseif statement.tag == "function" then
        visitFunction(statement, visitor)
    elseif statement.tag == "localfunction" then
        visitLocalFunction(statement, visitor)
    elseif statement.tag == "typealias" then
        visitTypeAlias(statement, visitor)
    elseif statement.tag == "typefunction" then
        visitStatTypeFunction(statement, visitor)
    else
        exhaustiveMatch(statement.tag)
    end
end

function visitType(type: any, visitor: any)
    if type.tag == "reference" then
        visitTypeReference(type, visitor)
    elseif type.tag == "boolean" then
        visitTypeBoolean(type, visitor)
    elseif type.tag == "string" then
        visitTypeString(type, visitor)
    elseif type.tag == "typeof" then
        visitTypeTypeof(type, visitor)
    elseif type.tag == "group" then
        visitTypeGroup(type, visitor)
    elseif type.tag == "union" then
        visitTypeUnion(type, visitor)
    elseif type.tag == "intersection" then
        visitTypeIntersection(type, visitor)
    elseif type.tag == "optional" then
        visitToken(type, visitor)
    elseif type.tag == "array" then
        visitTypeArray(type, visitor)
    elseif type.tag == "table" then
        visitTypeTable(type, visitor)
    elseif type.tag == "function" then
        visitTypeFunction(type, visitor)
    else
        exhaustiveMatch(type.tag)
    end
end

function visitTypePack(type: any, visitor: any)
    if type.tag == "explicit" then
        visitTypePackExplicit(type, visitor)
    elseif type.tag == "generic" then
        visitTypePackGeneric(type, visitor)
    elseif type.tag == "variadic" then
        visitTypePackVariadic(type, visitor)
    else
        exhaustiveMatch(type.tag)
    end
end

local function createVisitor(): any
    return table.clone(defaultVisitor)
end

return {
    createVisitor = createVisitor :: () -> Visitor,
    visitBlock = visitBlock :: (types.AstStatBlock, Visitor) -> (),
    visitStatement = visitStatement :: (types.AstStat, Visitor) -> (),
    visitExpression = visitExpression :: (types.AstExpr, Visitor) -> (),
    visitType = visitType :: (types.AstType, Visitor) -> (),
    visitTypePack = visitTypePack :: (types.AstTypePack, Visitor) -> (),
    visitToken = visitToken :: <T>(types.Token<T>, Visitor) -> (),

    visitPunctuated = visitPunctuated :: <T, Separator>(
        types.Punctuated<T, Separator>,
        Visitor
    ) -> (),
    visitGeneric = visitGeneric :: (types.AstGenericType, Visitor) -> (),
    visitGenericPack = visitGenericPack :: (types.AstGenericTypePack, Visitor) -> (),
    visitTypeOrPack = visitTypeOrPack :: (types.AstType | types.AstTypePack, Visitor) -> (),
    visitTypeFunctionParameter = visitTypeFunctionParameter :: (
        types.AstTypeFunctionParameter,
        Visitor
    ) -> (),
}
