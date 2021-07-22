---
categories: linux docker windows prometheus consul monitoring grafana ubuntu
date: "2021-07-22T20:00:00Z"
title: Using Prometheus to Monitor Your VMs and Using Consul For Discovery
draft: true
---

At work we recently had a need to some monitoring of various internal servers and I was trying to avoid going down the 'We can use Zabbix!' route as it seems like Prometheus is becoming a standard of sorts which is simple to setup and easy to mange via config files etc... And it seems to be evolving into a stack of Prometheus for data and Grafana for graphs. So, I thought I would write down the simplest route to getting to a point where everything works and we can inspect the results in a nice simple system which monitors whatever we need. We will also add Consul as a service discovery mechanism which means that we dont have to tell Prometheus about any new machines we add, it will discover them automatically. I'll skip Alertmanager for now as it will add extra steps, but is a simple follow up if you do some googling. 

We will use Docker Compose to get the Prometheus/Grafana (henceforth PG) services in place as quickly as possible. I did try and install Consul as a container but I had trouble with networking, so instead we will install it on the machine running the docker containers instead. Then we will create a windows host to monitor (I like Windows!), install the Windows Exporter, install a consul agent with some labels, and then we should be good. More things to install? Just repeat that process ad-infinitum and things will self-monitor, magic!

**NOTE**
If you want some really good detail on everything prometheus/alertmanager and what to do to get it going, I can highly recommend this book https://www.prometheusbook.com.

# Installing the services

We will use a Linux VM as our host to get a the PG stack running very quickly. None of this is very 'production' but it makes things very simple to setup. Replicating this as native installs if you wish should be simple once you get an idea of the setup.

## Ubuntu Docker VM

Install a fresh Ubuntu 20.04 Server VM (2 CPUs, 8GB RAM and 64GB Disk will be more than plenty for testing) and choose to install Docker as part of the 'System Snaps' setup. Avoid the urge to tick 'Prometheus'!.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/001.png"><img src="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/001.png"></a>
{{< /rawhtml >}}

Take a note of the IP address as you will need this later (run ```ip address``` at the terminal and look for adaptor ```enp1s0```). My examples will use 192.168.1.35 but yours will almost certainly be different so replace it as we go.

## Docker Compose Stack
If you don't know already, Docker Compose lets us have a bunch of services running together but defined as a single config file. It's like a little simplified Kubernetes cluster (and can also be very useful to test your containers work in that simplified setup before going down that rabbit hole...). This guy (https://github.com/danguita/prometheus-monitoring-stack) has a great Docker Compose config file which I am stealing and simplifying for this guide, so thanks goes to him for the base I am working from.

### Prometheus

We need to do a few things first. To start, Prometheus won't run without a ```prometheus.yml``` file defined. This has the config settings required and it can be pretty basic. So, let's create a general folder to host our various configs and make this file. We need to keep this file outside the container or else it will be blanked each time we recreate the container, which isn't good... 

```bash
mkdir prometheus
cd prometheus
mkdir prometheus-config
nano ./prometheus-config/prometheus.yml
```

Enter this simple YAML.  It says we will do checks (scrapes) on machines every 15 seconds, monitor the server (target) itself, and also our upcoming consul machines (multiple targets).

```yaml
global:
    scrape_interval: 15s # By default, scrape targets every 15 seconds.

scrape_configs:
    # Monitor this machine
    - job_name: "prometheus"
      scrape_interval: 30s
      static_configs:
          - targets: ["localhost:9090"]

    # This is how we tell prometheus to ask the consul service for targets
    - job_name: 'consul-discovery'
      consul_sd_configs:
        - server: 'localhost:8500'
          services: []
      relabel_configs:
        - source_labels: [__meta_consul_tags]
          regex: .*,prod,.*
          action: keep
        - source_labels: [__meta_consul_service]
          target_label: job
```

Done. Now we need to define our Docker Compose file to run the services.

### Docker Compose

Create our docker compose file.

```bash
nano docker-compose.yml
```

Then put in this. It should be pretty self-explanatory and creates a grafana and prometheus setup. Note that the ```./prometheus-config/prometheus.yml:/etc/prometheus/prometheus.yml``` line which tells the prometheus container to use the file we created as if it existed on the container itself.

```yaml
version: "3"

services:
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    links:
      - prometheus

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - prometheus_data:/prometheus
      - ./prometheus-config/prometheus.yml:/etc/prometheus/prometheus.yml

volumes:
  prometheus_data:
  grafana_data:
```

And then start our stack. It should complete with no errors.

```bash
sudo docker-compose up -d
```

Check things are running at addresses like below (enter your machines ip address though), but dont do anything just yet.

http://192.168.1.35:9090  - Prometheus
http://192.168.1.35:3000  - Grafana

### Consul

Then, we install consul using the official repo Hashicorp provide.

```bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install consul
```

Consul too needs a config file. So, create one like below.

```bash
mkdir consul-config
nano ./consul-config/server.json
```

Enter this. It really just says to listen on all ports, run in server mode, and also give us the UI.

```YAML
{
  "node_name": "consul-server",
  "server": true,
  "ui_config": {
    "enabled": true
  },
  "data_dir": "/consul/data",
  "addresses": {
    "http": "0.0.0.0"
  },
  "connect": {
    "enabled": true
  }
}
```

We also need to make a little script to start/stop the consul service. 

```bash
nano start-consul.sh
```

If you get any weird error just hardcode the ip address in the **-bind** part and the paths to the consul data and config folders/files, but hopefully this works. It will start the server as a single node (bootstrap-expect=1), so this is defintiely NOT production ready! But okay for testing.

```bash
 consul agent -server -bootstrap-expect=1 -node=prometheus -bind="$(hostname -I | awk '{print $1}')" -data-dir=$HOME/prometheus/consul-data/ -config-dir=$HOME/prometheus/consul-config/
```

And make it executable and run it. 

```bash
chmod +x start-consul.sh
./start-consul.sh
...
==> Starting Consul agent...
           Version: '1.10.0'
           Node ID: 'eaff9710-5742-67f3-11ed-903d8e59f547'
         Node name: 'prometheus'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: true)
       Client Addr: [127.0.0.1] (HTTP: 8500, HTTPS: -1, gRPC: -1, DNS: 8600)
      Cluster Addr: 192.168.1.35 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: false, TLS-Incoming: false, Auto-Encrypt-TLS: false
```

Success! Try going to your machine like (again, change the IP from my example). Note the name is dc1 as this is the default consul server name if one is not supplied.

http://192.168.1.35:8500  - Consul Server

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/005.png"><img src="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/005.png"></a>
{{< /rawhtml >}}

If you want to keep this running permanently then you will have to use systemctl or a cronjob to run it, but for simplicity, we will just start it ourselves in this guide and assume it is always running.

## Prometheus Targets via Consul

By default, Prometheus only monitors itself. Go to the targets page of your prometheus server, like [http://192.168.1.35:9090/targets](http://192.168.1.35:9090/targets) and you will see just the one item.


{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/007.png"><img src="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/007.png"></a>
{{< /rawhtml >}}

But, we have already added Consul Discovery to our Prometheus config, so let's add a new machine to monitor by installing the required pieces.

### Windows System Setup

We will use a Windows machine (I still prefer a nice simple GUI) to install Consul and a Prometheus 'exporter'. The 'exporter' presents metrics that Prometheus can 'scrape' over a simple web page. In Windows land we use the Windows_Exporter. And, for consul discovery, we install Consul on the machine, but in agent mode.

By installing both at the same time we can get the metrics system installed and the machine automatically registered in Prometheus without having to amend the prometheus config settings. When you have to do this to hundreds of machines, it is super efficient. Combine it with something like Ansible and you are almost fully automated.

#### Windows Exporter Install

Install this MSI file from here - https://github.com/prometheus-community/windows_exporter/releases. I would create screenshots but it is honestly just a a Next, Next, Finsh. Once installed, check it is alive and started as a Windows Service called 'Windows Expoerter', and by checking via **http://your_machines_ip:9182/metrics** (ie http://192.168.1.252:9182/metrics). You will see something like this, which is simple data which is scraped by prometheus.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/010.png"><img src="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/010.png"></a>
{{< /rawhtml >}}

It's working, now lets install Consul in agent mode so prometheus can know about it.

#### Consul Install

Grab the latest Windows release from here - https://www.consul.io/downloads

Unzip it to somewhere like c:\consul\consul.exe

We need to create a config file with some required info on where our server is (can consul agents service discover the server? I'd imagine so, i'll need to look more!). If using ansible you could template this. But, for us, create a file called config.json and save it in a folder called ```c:\consul\config\``` as ```config.json```. Note that the ```start_join``` is our Consul server IP address, so adjust as required. The ```data_dir``` folder doesnt have to exist, so just place somewhere reasonable.

```json
{
    "server": false,
    "datacenter": "dc1",
    "data_dir": "c:/consul/data",
    "log_level": "INFO",
    "start_join": ["192.168.1.35"]
}
```
And, we need to give it a couple of 'labels' so that when it runs, there is some metadata of sorts for prometheus to latch onto. So, create another file called webserver.json into the same config folder as before.

```json
{
  "service": {
    "name": "web",
    "tags": [
      "prod"
    ]
  }
}
```

TODO: NSSM service details and make this command better. Also, discovery not working

Then run this to get it registered in the Consul database. Bind to the machines IP and give it a reasonable name (like the machines hostname)

```cmd
.\consul agent -node=nuc -bind="192.168.1.251" -config-dir="c:/consul/config/" -join "192.168.1.35"
```

Then run this (from another terminal) to see if we managed to add it to our list of machines. We have!

```cmd
.\consul.exe members
Node           Address             Status  Type    Build   Protocol  DC   Segment
consul-server  172.19.0.3:8301     alive   server  1.10.0  2         dc1  <all>
nuc            192.168.1.251:8301  alive   client  1.10.0  2         dc1  <default>
```

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/015.png"><img src="/assets/images/2021/Using-Prometheus-to-Monitor-Your-VMs-And-Using-Consul-For-Discovery/015.png"></a>
{{< /rawhtml >}}

Now, lets check prometheus...

Check services

```bash
curl http://192.168.1.35:8500/v1/catalog/services\?pretty
```


LINKS
https://www.robustperception.io/finding-consul-services-to-monitor-with-prometheus
https://medium.com/trendyol-tech/consul-prometheus-monitoring-service-discovery-7190bae50516
https://visibilityspots.github.io/blog/prometheus-consul.html?utm_source=pocket_mylist
https://www.digitalocean.com/community/tutorials/how-to-configure-consul-in-a-production-environment-on-ubuntu-14-04

https://learn.hashicorp.com/tutorials/consul/get-started-create-datacenter?in=consul/getting-started