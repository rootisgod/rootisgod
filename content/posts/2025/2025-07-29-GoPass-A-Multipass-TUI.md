---
categories:  multipass go tui vms mac windows linux
date: "2025-09-07T14:00:00Z"
title: GoPass - A Multiplatform Multipass TUI
draft: false
---

I admit to having a slight obsession with Multipass, and have written a few posts on it before. But, the thing that I think it is truly missing is a simple UI. I attempted a [GUI](https://www.rootisgod.com/2023/MultiManage-A-Multiplatform-GUI-for-Multipass) in Python but the framework PySimpleGUI went closed sourced so it's now dead. So we have this now

But it made me realise that generally, you don't really want a GUI because if you have a Linux server you may not have a desktop. And so, a TUI (Text User Interface) is a much better idea. So, I vibe coded one in Go.


{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2025/gopass/menu.png"><img src="/assets/images/2025/gopass/menu.png"></a>
{{< /rawhtml >}}


{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2025/gopass/snapshots.png"><img src="/assets/images/2025/gopass/snapshots.png"></a>
{{< /rawhtml >}}


I barely wrote a line of it, but have a general idea of how it works. I did it in one day with Cursor. Crazy. The reason I abandoned Python and went for Go is because of some key things
 - It creates binaries for all platforms in a simple way (no more PyInstaller!)
 - Dependencies are managed in a sane way (no more virtualenv!)
 - It is strongly typed (no more crashes at random times!)

The binaries are here: https://github.com/rootisgod/passgo/releases

Just download and run. Unfortunately, because they aren't code signed, Windows gives you a hefty warning about downloading an exe, so ignore the warnings. There are no viruses etc, check the code, its a couple of files.

Enjoy!
