# Overview

This repo hosts the hugo files for the blog https://www.rootisgod.com

## Docker Local Testing

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

If just using a terminal, to test locally, download hugp locally and run a command like this;

```bash
hugo serve -e draft
```

Then go to your localhost to see the site - http://127.0.0.1:1313
