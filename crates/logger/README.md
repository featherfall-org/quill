# Logger

A simple, yet powerful logger.<br>
The logger isn't a Quill module, but rather a helper crate, and so it isn't added to Quill and can be used outside of Quill.

## Usage

A logger has an identifier, a subscriber and an optional, supplementary context.
```luau
type LoggerConstructor = (identifier: Identifier, subscriber: Subscriber, context: Context) -> Logger
```

An identifier doesn't have to be unique, and can simply be considered as a name for the logger.
```luau
type Identifier = string
```

A subscriber is called for each logger event, as long as the global log level is at least the level of the event.
```luau
type Subscriber = (Event) -> ()
```

Context is arbitrary user-defined data that can be used to give subscribers more context about an event.<br>
For example, in a Datastore API wrapper, you could put the player's user id and data in it.<br>
Events receive both logger & log context merged into one.
```luau
type Context = { [string]: any }
```

Loggers can be extended with additional context and a new identifier.<br>
Given a base logger `my_logger` with context `{ foo = "bar" }`
```luau
local my_logger = logger.new("my_logger", my_subscriber, { foo = "bar" })
```
you can extend it with additional context `{ hello = "world" }`
```luau
local my_new_logger = logger.new("my_new_logger", { hello = "world" })
```
resulting in logger `my_new_logger` with context `{ foo = "bar", hello = "world" }`.

Events are a table containing the timestamp of the event, its level, message, logger name and context.
```luau
export type Event = {
    timestamp: number,
    level: Level,
    message: string,
    logger: string,
    context: { [string]: any }?,
}
```

Events can be created manually via `logger:event`:
```luau
event: (
    self: Logger,
    level: Level,
    message: string,
    context: { [string]: any }?
) -> (),
```
albeit each logger also exposes a bunch of wrapper functions for each log level:
```luau
logger:trace("This is a trace message!", my_additional_ctx)
logger:debug("This is a debug message!", my_additional_ctx)
-- and so on...
```

The crate exposes two subscribers by default:
- `console_subscriber`, which outputs all events to the console in the format of:
  ```
  {event.logger} - {event.level} @ {event.timestamp}:
  {event.message}
  ```
  while also erroring for any fatal events
- `traceback_subscriber`, which has the same behaviour as `console_subscriber`, while additionally outputting stack traces

You may set a global log level for each logger with `.set_log_level()`, as mentioned earlier, which stops subscribers from listening to any events which aren't at least of that log level.<br>
For example, to only output warn events and above, you'd do:
```luau
logger.set_log_level("warn")
```
