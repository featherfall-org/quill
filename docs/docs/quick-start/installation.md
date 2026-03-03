---
description: Install Quill for your Roblox project.
---

import Tabs from "@theme/Tabs";
import TabItem from "@theme/TabItem";

# Installation

## Quill

Quill is available on [Pesde](https://pesde.dev/packages/featherfall/quill_core) and [Wally](https://wally.run):

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
