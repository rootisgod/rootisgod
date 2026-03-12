---
categories:   multipass vms mac windows linux ai llm opus chatgpt
date: "2026-03-10T14:00:00Z"
title: PassGo 2.0 - Multipass Meets AI
---

The [multipass](https://canonical.com/multipass) obsession continues... Using Claude Code I have jazzed up the interface to use the Go BubbleTe library and introduced an AI mode. Just what everyone wanted, right. Right?

So, firstly, it looks much better in my opinion. The same functionality exists to manage instances, mount folders, take snapshots, and generally make life much nicer

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-meets-ai/passgo-tui.png"><img src="/assets/images/2026/multipass-meets-ai/passgo-tui.png"></a>
{{< /rawhtml >}}

Quick demo below

{{< asciinema src="/assets/images/2026/multipass-meets-ai/demo-vm.rec" >}}

And now you can use an LLM connection and ask it questions! I created an MCP server in GO, which is here: https://github.com/rootisgod/multipass-mcp

If you dont have it installed, it will pull it from Github automatically. Then press <SHIFT-L> to enter your openrouter details and API Key and model, like so.

```
https://openrouter.ai/api/v1
API KEY
deepseek/deepseek-v3.2
```

Then, press ? and ask it to do something. It will do it's best to obey. In this example it creates an instance, install apache and creates a test page. Cool!

{{< asciinema src="/assets/images/2026/multipass-meets-ai/demo-llm.rec" >}}