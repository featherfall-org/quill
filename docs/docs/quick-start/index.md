---
description: Get started with the basics of using Quill.
slug: /
---

import Tabs from "@theme/Tabs";
import TabItem from "@theme/TabItem";

# Quick Start

_Quill_ is a strictly and fully typed framework that lets you use providers (or services and controllers) as well as components. It is the first framework on Roblox ever to have fully typed components with full intellisense and autocomplete.

## Installation

All Quill crates are available on Pesde and Wally:

<Tabs>
<TabItem value="Pesde" default>

```bash title="Terminal"
pesde add featherfall/quill_[CRATE] # Replace [CRATE] with your crate of choice, for example featherfall/quill_core
```

</TabItem>
<TabItem value="Wally">

```toml title="wally.toml"
[dependencies]
quill = "featherfall-org/quill-[CRATE]@LATEST" # Replace LATEST with your desired version & [CRATE] with your crate of choice, for example featherfall-org/quill-core
```

</TabItem>
</Tabs>

## Start using Quill

You're now ready to use Quill! While most module loaders simply bootstrap services and controllers, Quill allows you to use both **providers** and **components**. Let's start with a simple provider to begin with.

```lua showLineNumbers title="provider.luau"
local provider = {}

function provider.init(self: self)
  -- Initialize your properties and everything that other providers may depend on here.
  -- For example, you'd initialize your datastore wrapper or signals in this function.
end

function provider.start(self: self)
  -- Run your providers' logic here.
  -- For example, you'd put a game loop here.
end

-- Allows for easy typechecking of any properties and methods.
export type self = typeof(provider)
return provider
```

Now, assuming you've placed your new provider in a folder under a bootstrapper script, you can start Quill!

```lua showLineNumbers title="bootstrapper.luau"
local quill = require("@pkg/quill")

quill.new()
  :with_modules(script.providers:GetChildren())
  :write()
```
