local Process = require("./util/Process")

local function check(options: { source: string })
    Process.new("stylua")
        :argument("--respect-ignores")
        :argument("--check")
        :argument(options.source)
        :inherit_stdout()
        :run()

    Process.new("selene"):argument(options.source):inherit_stdout():run()
end

return check
