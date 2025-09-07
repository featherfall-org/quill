local Process = require("./util/Process")

local function check(options: { source: string })
    Process.new("stylua")
        :argument("--respect-ignores")
        :argument("--check")
        :argument(options.source)
        :option("stdio", "inherit")
        :run()

    Process.new("selene")
        :argument(options.source)
        :option("stdio", "inherit")
        :run()

    --Process.new("zune")
    --    :argument("run")
    --    :argument("tests/unit.luau")
    --    :option("stdio", "inherit")
    --    :run()
end

return check
