local testing = zune.testing
local test, expect, describe = testing.test, testing.expect, testing.describe

describe("quill core", function()
    test("test testcase", function()
        print("abc")
        expect("abc").toBe("abc")
    end)
end)
