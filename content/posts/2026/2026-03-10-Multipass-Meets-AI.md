---
categories:   multipass vms mac windows linux ai llm opus chatgpt
date: "2026-03-10T14:00:00Z"
title: PassGo AI Edition
draft: false
---

The [multipass](https://canonical.com/multipass) obsession continues... Using Claude Code I have jazzed up the interface to use the Go Bubble Tea library and introduced an AI mode. Just what everyone wanted, right. Right?

## Updated Look

So, firstly, it looks much better in my opinion. The same functionality exists to manage instances, mount folders, take snapshots, and generally make life much nicer

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-meets-ai/passgo-tui.png"><img src="/assets/images/2026/multipass-meets-ai/passgo-tui.png"></a>
{{< /rawhtml >}}

Quick demo below

{{< asciinema src="/assets/images/2026/multipass-meets-ai/demo-vm.rec" >}}

## LLM Integration

And now you can use an LLM to ask it to do things! To enable this functionality I created a Multipass MCP server in Go, which is here: https://github.com/rootisgod/multipass-mcp

If you don't have it installed, it will pull it from GitHub automatically and start it. Then press <SHIFT-L> to get the LLM setup page. Enter your [OpenRouter](https://openrouter.ai/models) details, API Key and model. Like so.

---
```
https://openrouter.ai/api/v1
sk-or-YOUR-API-KEY
deepseek/deepseek-v3.2
```
---

You can use Ollama if you wish, but it seemed pretty dumb on Qwen3.5:9b which was a shame... I recommend Deepseek v3.2 as it is very cheap and capable, but feel free to go straight to Opus!

Then, press `?` and ask it to do something. It will do its best to obey. In this example it creates an instance, installs Apache, and creates a test page. Cool! The demo below used deepseek and cost $0.02 to run.

{{< asciinema src="/assets/images/2026/multipass-meets-ai/demo-llm.rec" >}}

The website!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-meets-ai/demo-multipass-llm-site.png"><img src="/assets/images/2026/multipass-meets-ai/demo-multipass-llm-site.png"></a>
{{< /rawhtml >}}

You can ask it to do more complicated things, like Install Docker, KIND, and set up a K8S cluster and give you the token. The MCP server can manage VMs, run scripts, transfer files and more. It should be pretty capable. Enjoy!