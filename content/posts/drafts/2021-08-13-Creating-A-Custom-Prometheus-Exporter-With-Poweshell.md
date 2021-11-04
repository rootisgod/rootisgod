---
categories: linux docker microk8s kubernetes k8s ubuntu jenkins
date: "2021-08-13T21:05:00Z"
title: Creating A Custom Prometheus Exporter With Powershell
draft: true
---

https://4sysops.com/archives/building-a-web-server-with-powershell/
https://gist.github.com/19WAS85/5424431

```powershell
# Note: To end the loop you have to kill the powershell terminal. ctrl-c wont work
param (
    $listen_port  = '8080',
    $metrics_file = 'metrics.txt'
)

# Create Http Server Object, listen on port 8080 and start
$http = [System.Net.HttpListener]::new()
$http.Prefixes.Add("http://localhost:$($listen_port)/")
$http.Start()

# INFINTE LOOP - Used to listen for requests
while ($http.IsListening) {
    # When a request is made in a web browser the GetContext() method will return a request object
    $context = $http.GetContext()
    # Listen on a patch called /metrics
    if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/metrics') {
        # the html/data you want to send to the browser
        [string]$html = Get-Content $metrics_file -Raw
        #resposed to the request
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($html) # convert htmtl to bytes
        $context.Response.ContentLength64 = $buffer.Length
        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length) #stream to broswer
        $context.Response.OutputStream.Close() # close the response
    }
}
```

Have a bit about types of metrics, gauges, quantiles and something else

Metrics File called metrics.txt

```
files_in_folder 10
```
