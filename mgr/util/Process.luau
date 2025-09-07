local process = zune.process
local task = zune.task

local Process = {}
local mt = { __index = Process }

type Properties = {
    command: string,
    args: { string },
    options: ProcessOptions,
}
export type Identity = setmetatable<Properties, typeof(mt)>

local function constructor(command: string): Identity
    local self: Properties = {
        command = command,
        args = {},
        options = {},
    }

    return setmetatable(self, mt)
end

function Process.argument(self: Identity, argument: string): Identity
    table.insert(self.args, argument)
    return self
end

function Process.option(
    self: Identity,
    option: keyof<ProcessOptions>,
    value: index<ProcessOptions, keyof<ProcessOptions>>
): Identity
    (self.options :: any)[option] = value
    return self
end

function Process.create(self: Identity): ProcessChild
    return process.create(self.command, self.args, self.options)
end

function Process.run(self: Identity, carry_exit: boolean?): ProcessRunResult
    local result = process.run(self.command, self.args, self.options)
    if not result.ok and (carry_exit == nil or carry_exit == true) then
        error(result.code)
    end
    return result
end

function Process.spawn(self: Identity): thread
    return task.spawn(process.run, self.command, self.args, self.options)
end

return {
    new = constructor,
}
