local pretty_print = require("@self/pretty_print")
export type Level = "trace" | "debug" | "info" | "warn" | "error" | "fatal"
export type Event = {
    timestamp: number,
    level: Level,
    message: string,
    logger: string,
    context: { [string]: any }?,
}

export type Logger = {
    --- The logger's identifier.
    _identifier: string,
    --- The logger's context.\
    --- Included in every single event.
    _context: { [string]: any }?,
    --- The logger's subscriber.
    _subscriber: (Event) -> (),

    --- Creates a new logger which inherits this logger's subscriber and context in addition to any new passed context.
    extend: (self: Logger, context: { [string]: any }) -> Logger,
    --- Creates an event with the given level and message for the current system time.\
    --- Accepts additional context which the logger's context will be merged into.
    event: (
        self: Logger,
        level: Level,
        message: string,
        context: { [string]: any }?
    ) -> (),

    --- Creates a trace event with the specified message.\
    --- Accepts additional context which the logger's context will be merged into.
    trace: (self: Logger, message: string, context: { [string]: any }?) -> (),
    --- Creates a debug event with the specified message.\
    --- Accepts additional context which the logger's context will be merged into.
    debug: (self: Logger, message: string, context: { [string]: any }?) -> (),
    --- Creates a info event with the specified message.\
    --- Accepts additional context which the logger's context will be merged into.
    info: (self: Logger, message: string, context: { [string]: any }?) -> (),
    --- Creates a warn event with the specified message.\
    --- Accepts additional context which the logger's context will be merged into.
    warn: (self: Logger, message: string, context: { [string]: any }?) -> (),
    --- Creates an error event with the specified message.\
    --- Accepts additional context which the logger's context will be merged into.
    error: (self: Logger, message: string, context: { [string]: any }?) -> (),
    --- Creates a fatal event with the specified message.\
    --- Accepts additional context which the logger's context will be merged into.
    fatal: (self: Logger, message: string, context: { [string]: any }?) -> (),
}

local LEVELS: { [Level]: number } = {
    trace = 1,
    debug = 2,
    info = 3,
    warn = 4,
    error = 5,
    fatal = 6,
}

local LOG_LEVEL = 1

local Logger = {}
local mt = { __index = Logger }

--- Constructs a new logger.
local function constructor(
    identifier: string,
    subscriber: (Event) -> (),
    context: { [string]: any }?
): Logger
    return setmetatable({
        _identifier = identifier,
        _context = context,
        _subscriber = subscriber,
    }, mt) :: Logger
end

--- Sets the global log level, default being trace.\
--- Any events below this level won't be logged.
local function set_log_level(level: Level)
    LOG_LEVEL = LEVELS[level]
end

function Logger.extend(
    self: Logger,
    identifier: string,
    context: { [string]: any }
): Logger
    local new_context = table.clone(self._context or {})
    for key, value in context do
        new_context[key] = value
    end

    return setmetatable({
        _identifier = identifier,
        _context = new_context,
        _subscriber = self._subscriber,
    }, mt) :: Logger
end

function Logger.event(
    self: Logger,
    level: Level,
    message: string,
    context: { [string]: any }?
)
    if LEVELS[level] < LOG_LEVEL then
        return
    end

    local final_context = self._context
    if final_context and context then
        final_context = table.clone(final_context)
        for key, value in context do
            final_context[key] = value
        end
    end

    local event: Event = {
        timestamp = os.time(),
        level = level,
        message = message,
        logger = self._identifier,
        context = final_context,
    }

    local ok, result = pcall(self._subscriber, event)

    if not ok then
        warn(`Error in subscriber: {result}`)
    end
end

function Logger.trace(
    self: Logger,
    message: string,
    context: { [string]: any }?
)
    self:event("trace", message, context)
end

function Logger.debug(
    self: Logger,
    message: string,
    context: { [string]: any }?
)
    self:event("debug", message, context)
end

function Logger.info(self: Logger, message: string, context: { [string]: any }?)
    self:event("info", message, context)
end

function Logger.warn(self: Logger, message: string, context: { [string]: any }?)
    self:event("warn", message, context)
end

function Logger.error(
    self: Logger,
    message: string,
    context: { [string]: any }?
)
    self:event("error", message, context)
end

function Logger.fatal(
    self: Logger,
    message: string,
    context: { [string]: any }?
)
    self:event("fatal", message, context)
end

local function is_table_empty<T>(tbl: T & {}): boolean
    for _ in tbl :: any do
        return false
    end
    return true
end

local function console_subscriber(event: Event)
    local message =
        `{event.logger} - {event.level} @ {event.timestamp}:\n{event.message}`

    local level = LEVELS[event.level]
    if level < 4 then
        print(message)
    elseif level < 6 then
        warn(message)
    else
        error(message)
    end
end

local function traceback_subscriber(event: Event)
    local traceback = debug.traceback(nil, 5)
    local message =
        `{event.logger} - {event.level} @ {event.timestamp}:\n{event.message}\n{traceback}`

    local level = LEVELS[event.level]
    if level < 4 then
        print(message)
    elseif level < 6 then
        warn(message)
    else
        error(message)
    end
end

local function context_subscriber(event: Event)
    local traceback = debug.traceback(nil, 5)
    local message = if event.context and not is_table_empty(event.context)
        then `{event.logger} - {event.level} @ {event.timestamp}:\n{event.message}\n{pretty_print(
            event.context
        )}\n{traceback}`
        else `{event.logger} - {event.level} @ {event.timestamp}:\n{event.message}\n{traceback}`

    local level = LEVELS[event.level]
    if level < 4 then
        print(message)
    elseif level < 6 then
        warn(message)
    else
        error(message)
    end
end

local logger = table.freeze {
    new = constructor,
    set_log_level = set_log_level,

    console_subscriber = console_subscriber,
    traceback_subscriber = traceback_subscriber,
    context_subscriebr = context_subscriber,
}

return logger
