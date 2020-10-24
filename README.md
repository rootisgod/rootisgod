# Overview

This repo hosts the jekyll files for the blog https://www.rootisgod.com

## Docker Local Testing

Or, if in IntelliJ/Webstorm, just run the 'Jekyll-Build-And-Serve' job.

If just using a terminal, to test locally, run a command like this;

```bash
docker run -it -p 4000:4000 -v /Users/iaingblack/Code/rootisgod:/site --name jekyll iaingblack/rootisgod-builder:latest /bin/bash
```

Then, serve the jekyll site like so;

```bash
/serve.sh
```

Then go to your localhost to see the site - http://127.0.0.1:4000