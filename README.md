# Overview

This repo hosts the jekyll files for the blog https://www.rootisgod.com

## Docker Local Testing

Or, if in IntelliJ/Webstorm, just run the 'Jekyll-Build-And-Serve' job.

Or, run this to build it

```bash
docker build . -t iaingblack/rootisgod-builder:latest
docker tag iaingblack/rootisgod-builder:latest iaingblack/rootisgod-builder:20210411
```

And push

```bash
docker push iaingblack/rootisgod-builder:latest
docker push iaingblack/rootisgod-builder:20210411
```

If just using a terminal, to test locally, run a command like this;

```bash
docker run -it -p 4000:4000 -v /Users/iaingblack/Code/rootisgod:/site --name jekyll iaingblack/rootisgod-builder:latest /bin/bash
```

Then, serve the jekyll site like so;

```bash
/serve.sh
```

Then go to your localhost to see the site - http://127.0.0.1:4000

# Hugo

Notes on the migration. Works, but not front page of table of contents etc...

```bash
git submodule add https://github.com/ba11b0y/lekh.git themes/lekh
theme: "lekh"
```