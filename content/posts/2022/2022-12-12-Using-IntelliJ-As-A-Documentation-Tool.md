---
categories: intellij jetbrains vscode mkdocs wiki notes exams study
date: "2022-12-12T08:00:00Z"
title: Using Intellij as a Documentation Tool
draft: false
---

I have been looking to do more studying and IT certifications over the next few months, but before I start studying and taking notes I have been stuck in one of those dreaded loops of finding the right tool for the job. Ideally I would just use Confluence, but:
- I don't want to be locked into a proprietary system, especially regarding data
- Something self hosted and open source could never be taken away
- Git backed updates/commits would be the way to do things nowadays
- Markdown based would be nice, for portability

I initially thought that something like Dokuwiki would do, but it has a glaring error much like many others I tried...

**You cannot copy and paste an image from your clipboard to the page!**

Instead, you have to upload an image file first to a 'media library', and then reference it. This is a severe productivity killer. You cannot meaningfully work, stop, screenshot, save to a file, upload it, reference it and repeat that as often as required. I am used to working with Confluence and this ability alone seems a killer feature that others struggle to match.

## The Available Options

So, I tried the below;
- Dokuwiki - No image copy/paste simplicity
- Wiki JS - Despite all the fanciness, again, same issue (there is a request for it from 2 years ago)
- Many others - Things like Joplin, Notion etc... All leave me a little worried about my data portability or other issues
- Obsidian - It does do this! It uploads the file in the folder for you. But it's not web based, so I need that program on every machine I use. 

Obsidian was pretty close, but it got me thinking...

## Use Your Existing IDE

If I had chosen Obsidian, I would have to install Obsidian on every machine I use... It looks very similar to VSCode... Why dont I just see if my current IDE of choice (IntelliJ) has a plugin to 'clipboard image upload for markdown'? Try googling that BTW. But, it does! It is called 'Markdown Image Support'. Install that, tell it to save 'assets' in a subfolder with a timestamp, and you are done! 

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Using-IntelliJ-As-A-Documentation-Tool/1670838624083.png"><img src="/assets/images/2022/Using-IntelliJ-As-A-Documentation-Tool/1670838624083.png"></a>
{{< /rawhtml >}}

No more manual inserts for me! Who cares what the picture filename is called, Git -> Commit -> Push that thing. I feel dumb for not discovering this earlier. 

As a bonus, if you start your 'Learning' or 'Study' repo structure and sort it like it was an MKDocs website you can have Github build your pages and host it for each push, you then have an anywhere available personal KB. Just dont put passwords or secrets on it. And you can change tools later, you are in total control.

## Benefits

To summarise, the benefits of the above are
- One tool to do everything is always good, as maintaining a different toolset (ie Obsidian) across machines is the real pain
- Use MKDocs to turn it into a Wiki type site
- You can use git to amend your data without various plugins
- You can swapout IntelliJ for VSCode or something very easily (markdown plugins are likely better there, just switch over, nothing can break!)
- You can fallback to Github itself if you want to just look at your Markdown files, or you can use it to do edits when you aren't on your 'real' machine
- If an open source project does a rug pull or folds, you can still access everything you ever did. You cant paint yourself into a corner at all

Apologies if all of this is blindingly obvious, but sometimes an existing workflow with a couple of plugins is all you need. 