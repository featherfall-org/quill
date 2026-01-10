--!strict
--!optimize 2
--[[
    https://github.com/Scythe-Technology/zune-lib/blob/059ce17dbe4d3e379f53e55522e313080abffebc/std/ansi.luau

    MIT License

    Copyright (c) 2025 Scythe Technology

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

return {
    black = "\x1b[30m",
    red = "\x1b[31m",
    green = "\x1b[32m",
    yellow = "\x1b[33m",
    blue = "\x1b[34m",
    magenta = "\x1b[35m",
    cyan = "\x1b[36m",
    white = "\x1b[37m",
    bright_black = "\x1b[90m",
    bright_red = "\x1b[91m",
    bright_green = "\x1b[92m",
    bright_yellow = "\x1b[93m",
    bright_blue = "\x1b[94m",
    bright_magenta = "\x1b[95m",
    bright_cyan = "\x1b[96m",
    bright_white = "\x1b[97m",

    bg = {
        black = "\x1b[40m",
        red = "\x1b[41m",
        green = "\x1b[42m",
        yellow = "\x1b[43m",
        blue = "\x1b[44m",
        magenta = "\x1b[45m",
        cyan = "\x1b[46m",
        white = "\x1b[47m",
        bright_black = "\x1b[100m",
        bright_red = "\x1b[101m",
        bright_green = "\x1b[102m",
        bright_yellow = "\x1b[103m",
        bright_blue = "\x1b[104m",
        bright_magenta = "\x1b[105m",
        bright_cyan = "\x1b[106m",
        bright_white = "\x1b[107m",
    },

    dim = "\x1b[2m",
    bold = "\x1b[1m",
    italic = "\x1b[3m",
    underline = "\x1b[4m",
    blink = "\x1b[5m",
    inverse = "\x1b[7m",
    hidden = "\x1b[8m",
    strikethrough = "\x1b[9m",

    reset = "\x1b[0m",
    reset_bold = "\x1b[22m",
    reset_dim = "\x1b[22m",
    reset_italic = "\x1b[23m",
    reset_underline = "\x1b[24m",
    reset_blink = "\x1b[25m",
    reset_inverse = "\x1b[27m",
    reset_hidden = "\x1b[28m",
    reset_strikethrough = "\x1b[29m",
    reset_color = "\x1b[39m",
    reset_bgcolor = "\x1b[49m",
}
