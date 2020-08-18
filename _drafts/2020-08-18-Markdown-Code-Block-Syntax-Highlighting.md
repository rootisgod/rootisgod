---
layout: post
title:  "Markdown Code Block Syntax Highlighting. Who knew?"
date:   2020-08-18 09:55:00 +0100
categories: markdown
---

I just discovered this. If you usually add a code block in markdown  like;

`` ``` ``

`const strippedString = originalString.replace(/(<([^>]+)>)/gi, "");`

`` ``` ``

You get something like this;

```
const strippedString = originalString.replace(/(<([^>]+)>)/gi, "");
```

But, if you do;

`` ```javascript ``

`const strippedString = originalString.replace(/(<([^>]+)>)/gi, "");`

`` ``` ``

You get this!

```javascript
const strippedString = originalString.replace(/(<([^>]+)>)/gi, "");
```

Way better!

This seems to be the official languages supported so far: [https://github.com/github/linguist/blob/master/lib/linguist/languages.yml]. Just search for yours to see if it exists, but coverage seems excellent. Even powershell is there!