---
categories: intellij jetbrains vscode mkdocs wiki notes exams study
date: "2022-12-12T08:00:00Z"
title: Using Intellij As A Documentation Tool
draft: false
---

I have been trying to do more studying and IT certifications, but before I started studying I have been stuck in one of those dreaded loops of finding the right tool for the job. I initially thought that something like Dokuwiki would do, but it has a glaring error much like many others I tried.

**You cannot copy and paste an image from your clipboard to the page!**

Instead, you have to upload an image file first and then reference it. This is a severe productivity killer. I am used to Confluence at work and that ability alone seems a killer feature that others struggle to match. You want to be able to just type, screenshot, paste and upload as you go. 

My requirements are also fairly strict in that I want the data to be preferably in markdown and 'gittable'. 

So, after trying the below;
- Dokuwiki - No image copy/paste simplicity
- Wiki JS - Despite all the fanciness, again, same issue
- Many others - Things like Joplin, Notion etc... All leave me a little worried about my data portability or other issues
- Obsidian - It does do this! It uploads the file in the folder for you. But, it got me thinking...

I would have to install obsidian on every machine I use... It looks very similar to vscode... Why dont I just see if my current IDE of choice (IntelliJ) has an image upload markdown plugin? It does! It is called 'Markdown Image Support'. Install that, tell it to save 'assets' in a subfolder with a timestamp, and you are done! 

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2022/Using-IntelliJ-As-A-Documentation-Tool/1670838624083.png"><img src="/assets/images/2022/Using-IntelliJ-As-A-Documentation-Tool/1670838624083.png"></a>
{{< /rawhtml >}}

I've using it just now! No more photo uploads and manually linking in blog posts either, the same principle applies. I feel dumb for not discovering this earlier. 

As a bonus, if you start your 'Learning' repo site as an MKDocs one, simply use Github actions to build your pages and host it, you then have something almost as good as confluence as a knowledge repo (without direct editing obviously). And, it means you can change tools later, even just use github (which annoyingly has the clipboard image to upload feature too! it just sends it to a random URL and references it).

## Benefits

Anyway, the benefits of the above are
- One tool to do everything is always good as maintaining the toolset (ie Obsidian) across machines is the real pain
- Use MKDocs to turn it into a Wiki
- You can use git to amend your data without various plugins
- You can swapout IntelliJ for VSCode or something very easily (markdown plugins are likely better there)
- You can fallback to Github itself if you want to dom something web based