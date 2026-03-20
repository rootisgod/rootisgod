---
categories:   multipass vms mac windows linux ai llm opus chatgpt mcp
date: "2026-03-20T06:00:00Z"
title: Multipass MCP Server
draft: false
---

Oh yeah.

{{< multipass-logo-banner >}}

We have a fully-fledged MCP server for Multipass. Let me show you how it works in Claude Code. We will create a 3 node microk8s cluster from a paragraph. A PARAGRAPH!

First, I'll assume you have Claude Code and Multipass installed and set up.

Then, we need to install the MCP server, which is a Go binary (and very simple to install) and then hook it up to Claude Code. We also have a Skill which helps smooth Claude's usage of the MCP plugin. Here is a cheat sheet on installation.

{{< rawhtml >}}
<table>
<thead>
<tr><th>Step</th><th>macOS</th><th>Linux</th><th>Windows</th></tr>
</thead>
<tbody>
<tr>
<td>Install MCP server (<a href="https://brew.sh">Brew</a>)</td>
<td><code>brew install rootisgod/tap/multipass-mcp</code></td>
<td><code>brew install rootisgod/tap/multipass-mcp</code></td>
<td><code>go install github.com/rootisgod/multipass-mcp@latest</code></td>
</tr>
<tr>
<td>Register with Claude</td>
<td><code>claude mcp add multipass-mcp -- multipass-mcp</code></td>
<td><code>claude mcp add multipass-mcp -- multipass-mcp</code></td>
<td><code>claude mcp add multipass-mcp -- multipass-mcp</code></td>
</tr>
<tr>
<td>Install skill (optional)</td>
<td>
<code>git clone https://github.com/rootisgod/multipass-mcp.git /tmp/multipass-mcp</code><br>
<code>cp -r /tmp/multipass-mcp/skill/multipass ~/.claude/skills/multipass</code><br>
<code>rm -rf /tmp/multipass-mcp</code>
</td>
<td>Same as macOS</td>
<td>
<code>git clone https://github.com/rootisgod/multipass-mcp.git %TEMP%\multipass-mcp</code><br>
<code>xcopy /E /I %TEMP%\multipass-mcp\skill\multipass %USERPROFILE%\.claude\skills\multipass</code><br>
<code>rmdir /S /Q %TEMP%\multipass-mcp</code>
</td>
</tr>
<tr>
<td>Verify</td>
<td><code>claude mcp list</code></td>
<td><code>claude mcp list</code></td>
<td><code>claude mcp list</code></td>
</tr>
</tbody>
</table>
{{< /rawhtml >}}

The verify step should print out something like this

```
multipass-mcp: multipass-mcp  - ✓ Connected
```

Then, we can simply ask Claude something like this

`Using the multipass-mcp server, please create 3 multipass instances and then create a multinode microk8s cluster. Each instance can be a worker and a control plane.  Add the connection details to my kubeconfig as multipass-mcp-microk8s`

Off it goes...

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/claude-code-prompt.png"><img src="/assets/images/2026/multipass-mcp/claude-code-prompt.png"></a>
{{< /rawhtml >}}

We can see the instances being created!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/passgo-cluster-creation.png"><img src="/assets/images/2026/multipass-mcp/passgo-cluster-creation.png"></a>
{{< /rawhtml >}}

And then the Cluster was visible in k9s!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/k9s-nodes.png"><img src="/assets/images/2026/multipass-mcp/k9s-nodes.png"></a>
{{< /rawhtml >}}

What can we do with it? Well, sometimes with the MCP plugin, it can be too helpful. I asked it for a command to show a deployment across 3 nodes, and it just did it. Hmmm.... Now I feel redundant.

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/nginx-install.png"><img src="/assets/images/2026/multipass-mcp/nginx-install.png"></a>
{{< /rawhtml >}}

But I had to tell it to make a MetalLB IP address so I can get to the page as a Load Balanced cluster. Human in the loop still wins ;)

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/metallb-suggestion.png"><img src="/assets/images/2026/multipass-mcp/metallb-suggestion.png"></a>
{{< /rawhtml >}}

And then make sure this is Load Balanced (it is!).

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/metallb-lb.png"><img src="/assets/images/2026/multipass-mcp/metallb-lb.png"></a>
{{< /rawhtml >}}

Success!

{{< rawhtml >}}
<a data-fancybox="gallery" href="/assets/images/2026/multipass-mcp/nginx-metallb.png"><img src="/assets/images/2026/multipass-mcp/nginx-metallb.png"></a>
{{< /rawhtml >}}

Turn off a couple nodes and it still works, but I won't bore you with more screenshots.


## The Gory Details

Here is the full Claude Code output for the Multipass MCP cluster deployment in case you want to see the efforts it went to accomplish this. It took about 15 minutes. Not too bad. I have entire blog posts on this and it would take much longer. I2Ops (Intelligence and Intent Operations) is real. I made a new term, sue me!

```
╭─── Claude Code v2.1.80 ───────────────────────────────────────────────────────────────────────────────────╮
│                                                   │ Tips for getting started                              │
│                Welcome back Iain!                 │ Run /init to create a CLAUDE.md file with instructions│
│                                                   │ ───────────────────────────────────────────────────── │
│                      ▐▛███▜▌                      │ Recent activity                                       │
│                     ▝▜█████▛▘                     │ No recent activity                                    │
│                       ▘▘ ▝▝                       │                                                       │
│       Opus 4.6 (1M context) · Claude Max ·        │                                                       │
│       iain@rootisgod.com's Organization           │                                                       │
│              ~/Code/Github/rootisgod              │                                                       │
╰───────────────────────────────────────────────────────────────────────────────────────────────────────────╯

❯ Using the multipass-mcp server, please create 3 multipass instances and then create a multinode microk8s   
cluster. Each instance can be a worker and a control plane.  Add the connection details to my kubeconfig as  
multipass-mcp-microk8s                                                                                       

⏺ I'll start by fetching the Multipass MCP tools and checking what instances already exist.

⏺ Let me check existing instances first.

⏺ multipass-mcp - list_instances (MCP)
  ⎿  {
       "list": []
     }

⏺ No existing instances. I'll launch 3 VMs in parallel — MicroK8s needs decent resources.

⏺ multipass-mcp - launch (MCP)(name: "mk8s-node1", cpus: 2, memory: "2G", disk: "10G", image: "22.04")
  ⎿  Creating mk8s-node1  / Configuring mk8s-node1  /
      Starting mk8s-node1 
     … +3 lines (ctrl+o to expand)

⏺ multipass-mcp - launch (MCP)(name: "mk8s-node2", cpus: 2, memory: "2G", disk: "10G", image: "22.04")
  ⎿  Creating mk8s-node2  / Configuring mk8s-node2  /
      Starting mk8s-node2 
     … +4 lines (ctrl+o to expand)

⏺ multipass-mcp - launch (MCP)(name: "mk8s-node3", cpus: 2, memory: "2G", disk: "10G", image: "22.04")
  ⎿  Creating mk8s-node3  / Configuring mk8s-node3  /
      Starting mk8s-node3
     … +3 lines (ctrl+o to expand)

⏺ All 3 VMs launched. Now I'll install MicroK8s on all 3 nodes in parallel.

⏺ multipass-mcp - run_script (MCP)(name: "mk8s-node1", script: "\nsudo snap install microk8s --classic
                                  --channel=1.31/stable\nsudo usermod -a -G microk8s ubuntu\nsudo microk8s
                                  status --wait-ready\n")
  ⎿  microk8s (1.31/stable) v1.31.14 from Canonical** installed
     microk8s is running
     high-availability: no
     … +20 lines (ctrl+o to expand)

⏺ multipass-mcp - run_script (MCP)(name: "mk8s-node2", script: "\nsudo snap install microk8s --classic
                                  --channel=1.31/stable\nsudo usermod -a -G microk8s ubuntu\nsudo microk8s
                                  status --wait-ready\n")
  ⎿  microk8s (1.31/stable) v1.31.14 from Canonical** installed
     microk8s is running
     high-availability: no
     … +20 lines (ctrl+o to expand)

⏺ multipass-mcp - run_script (MCP)(name: "mk8s-node3", script: "\nsudo snap install microk8s --classic
                                  --channel=1.31/stable\nsudo usermod -a -G microk8s ubuntu\nsudo microk8s
                                  status --wait-ready\n")
  ⎿  microk8s (1.31/stable) v1.31.14 from Canonical** installed
     microk8s is running
     high-availability: no
     … +20 lines (ctrl+o to expand)

⏺ MicroK8s is running on all 3 nodes. Now I'll generate a join token on node1 and join nodes 2 and 3 to the
  cluster.

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command:
                                    ["sudo","microk8s","add-node","--format","short"])
  ⎿  microk8s join 192.168.2.99:25000/8a3844a77b6a4a4368e6b05a6fd190a3/111ea709d75e
     microk8s join fd03:7a6f:f9f6:70a2:5054:ff:feb4:c20b:25000/8a3844a77b6a4a4368e6b05a6fd190a3/111ea709
     d75e

⏺ Got the join token. Joining node2 now.

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node2", command: ["sudo","microk8s","join","192.168.2.99:250
                                    00/8a3844a77b6a4a4368e6b05a6fd190a3/111ea709d75e"])
  ⎿  Contacting cluster at 192.168.2.99
     Waiting for this node to finish joining the cluster. .. .. .. ..
     Successfully joined the cluster.

⏺ Node2 joined. Now I need a new token for node3 (tokens are single-use).

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command:
                                    ["sudo","microk8s","add-node","--format","short"])
  ⎿  microk8s join 192.168.2.99:25000/6866c9110a95c1cb17631d879f33a300/111ea709d75e
     microk8s join fd03:7a6f:f9f6:70a2:5054:ff:feb4:c20b:25000/6866c9110a95c1cb17631d879f33a300/111ea709
     d75e

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node3", command: ["sudo","microk8s","join","192.168.2.99:250
                                    00/6866c9110a95c1cb17631d879f33a300/111ea709d75e"])
  ⎿  Contacting cluster at 192.168.2.99
     Waiting for this node to finish joining the cluster. .. .. .. .
     Successfully joined the cluster.

⏺ All 3 nodes joined. Let me verify the cluster and check HA status.

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command:
                                    ["sudo","microk8s","kubectl","get","nodes","-o","wide"])
  ⎿  NAME         STATUS   ROLES    AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE
       KERNEL-VERSION       CONTAINER-RUNTIME
     mk8s-node1   Ready    <none>   6m48s   v1.31.14   192.168.2.99    <none>        Ubuntu 22.04.5 LTS
     … +3 lines (ctrl+o to expand)

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command: ["sudo","microk8s","status"])
  ⎿  microk8s is running
     high-availability: yes
       datastore master nodes: 192.168.2.99:19001 192.168.2.100:19001 192.168.2.101:19001
     … +19 lines (ctrl+o to expand)

⏺ The cluster is up with high-availability: yes and all 3 datastore master nodes. Node3 is still registering
  in kubectl (it just joined) but is already a datastore master. Now I'll extract the kubeconfig and add it
  locally.

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command:
                                    ["sudo","microk8s","kubectl","get","nodes","-o","wide"])
  ⎿  NAME         STATUS   ROLES    AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE
       KERNEL-VERSION       CONTAINER-RUNTIME
     mk8s-node1   Ready    <none>   6m54s   v1.31.14   192.168.2.99    <none>        Ubuntu 22.04.5 LTS
     … +3 lines (ctrl+o to expand)

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command: ["sudo","microk8s","config"])
  ⎿  apiVersion: v1
     clusters:
     - cluster:
     … +53 lines (ctrl+o to expand)

⏺ All 3 nodes are Ready. Now I'll write the kubeconfig with the context name multipass-mcp-microk8s and merge
   it into your existing kubeconfig.

⏺ Write(/tmp/multipass-mcp-microk8s-kubeconfig.yaml)
  ⎿  Wrote 19 lines to ../../../../../tmp/multipass-mcp-microk8s-kubeconfig.yaml
       1 apiVersion: v1
       2 clusters:
       3 - cluster:
       4     certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUREekNDQWZlZ0F3SUJBZ
         0lVVEt0cTBVS3dDM0g2Q25RbmRHZmozb1pKMTJVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0Z6RVZNQk1HQTFVRUF3d01NVE
         F1TVRVeUxqRTRNeTR4TUI0WERUSTJNRE15TURBMk16Y3pORm9YRFRNMgpNRE14TnpBMk16Y3pORm93RnpFVk1CTUdBMVV
         FQXd3TU1UQXVNVFV5TGpFNE15NHhNSUlCSWpBTkJna3Foa2lHCjl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUEwbXp0
         NnZpWVd3bklaVGtoUkFyY3Z4VmM5ei84MU1POUV4TkwKeU5qVG8zemVCTTZGdlNRZlNkVTVSOWEwR01uSlpuWnRvOTM2Z
         zBJRFYyNEVhL29LcHhsRHdOR0ZBaTRkdlR5SAp5S3ZtajdqbFpxaFpMMHJxVy9HdmswUGVPcnNRdy81bUQ1UE5xUk44Wk
         kvR3l4N00ydmtBdytrNk0wS2NyVW1ZClhsTkZTQk9uQU1mQVZCSU9jQXIyQ1d5S2lNSmtXRFJreGdsUEFJMmFDbElvRkh
         lelhJVENhdlZMNTgzMFJKcTkKK3YzQXoyblhESWk4WkU0a1Y3SE83VEwxT0hLcFlaWXVuM2dUSUpLNWtOdEVheHRQWjls
         OUpzbmZTWFlmTm0vdgpCWndYNWRVMTZRZmRXQnBxWFNtSlhsVzVWRytmenN4ZXRIYmp0ZTZ2Wk9PdnNMMitud0lEQVFBQ
         m8xTXdVVEFkCkJnTlZIUTRFRmdRVStIOFNUK2s5Qkp6d2NocGRnSUxJdG9COEZvOHdId1lEVlIwakJCZ3dGb0FVK0g4U1
         QrazkKQkp6d2NocGRnSUxJdG9COEZvOHdEd1lEVlIwVEFRSC9CQVV3QXdFQi96QU5CZ2txaGtpRzl3MEJBUXNGQUFPQwp
         BUUVBa2hHOVU5NThQZ09yUnU4aVpTOEs3T2p4RFQ0UnM5anpNNjBudmh2L0xRZVFyTHFoUHRwa0FWWVl3T0ZkCk13MHhN
         U2cyUVhQVFl0SHJxMXo1YlVZOTFuRHp2MVdjRE1EYmI1ZnJLcDViNmZzRlY3UEt5R1NPcys0RVM2TmQKamlSb1NoSWl6Q
         lpKZXA1dmFMbE1VYndXcUs3WWVyMGlnQmJXa25LSjVSQkhzTnhjaFg4TGhqdkNyblN0RlpMdQpDbjMwdmV1U01uem9XM1
         kwWjExOUYrSHRBM1QxNWkvSm4wQ2ZaVXNwWXNNdFZ3TWJ3QW1vM0hlRlVzdWFIczRaClRnczdHR3hBUDBaRVBRZ2dTR09
         aRDNORnMxVzFJTnlOZFkxUTJyUmUyUnBtZzNnanBqMHJ2NmlpbEVqMEkyOEkKTDRCZnZ2V2pqa0xFeVh2NmFIdkdZdE9V
         c3c9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
       5     server: https://192.168.2.99:16443
       6   name: multipass-mcp-microk8s
       7 contexts:
       8 - context:
       9     cluster: multipass-mcp-microk8s
      10     user: multipass-mcp-microk8s-admin
     … +9 lines (ctrl+o to expand)

⏺ Now I'll merge this into your existing kubeconfig.

⏺ Bash(KUBECONFIG="$HOME/.kube/config:/tmp/multipass-mcp-microk8s-kubeconfig.yaml" kubectl config view
      --flatten > /tmp/merged-kubeconfig.yaml && cp "$HOME/.kube/confi…)
  ⎿  (No output)

⏺ Bash(kubectl config get-contexts)
  ⎿  CURRENT   NAME                     CLUSTER                  AUTHINFO                       NAMESPAC
     E
     *         mp-clster                mp-clster                mp-clster-admin
     … +2 lines (ctrl+o to expand)

⏺ Let me verify connectivity to the new cluster.

⏺ Bash(kubectl --context multipass-mcp-microk8s get nodes -o wide)
  ⎿  Error: Exit code 1
     error: tls: failed to parse private key

⏺ The key data may have gotten corrupted during copy. Let me re-extract the config directly to a file and
  merge cleanly.

⏺ multipass-mcp - run_script (MCP)(name: "mk8s-node1", script: "\nsudo microk8s config | sed \\\n  -e
                                  's/microk8s-cluster/multipass-mcp-microk8s/g' \\\n  -e 's/name:
                                  microk8s$/name: multipass-mcp-microk8s/' \\\n  -e 's/current-context:
                                  microk8s/current-context: multipass-mcp-microk8s/' \\\n  -e 's/name:
                                  admin$/name: multipass-mcp-microk8s-admin/' \\\n  -e 's/user: admin$/user:
                                  multipass-mcp-microk8s-admin/'\n")
  ⎿  apiVersion: v1
     clusters:
     - cluster:
     … +54 lines (ctrl+o to expand)

⏺ Good, got the clean config directly from the node. Let me write it and re-merge.

⏺ Write(/tmp/multipass-mcp-microk8s-kubeconfig.yaml)
  ⎿  

⏺ Bash(cp "$HOME/.kube/config.bak."* /tmp/kubeconfig-original-backup.yaml 2>/dev/null; ls
      "$HOME/.kube/config.bak."* 2>/dev/null | head -1 | xargs -I{} cp {} "$HOME/.k…)
  ⎿  (No output)

⏺ Bash(kubectl --context multipass-mcp-microk8s get nodes -o wide)
  ⎿  Error: Exit code 1
     error: tls: failed to parse private key

⏺ The base64 data is likely getting corrupted when passing through the MCP tool output. Let me transfer the
  file directly instead.

⏺ multipass-mcp - exec_command (MCP)(name: "mk8s-node1", command: ["sudo","microk8s","config"])
  ⎿  apiVersion: v1
     clusters:
     - cluster:
     … +53 lines (ctrl+o to expand)

⏺ Let me write the config inside the VM and transfer the file directly to avoid any encoding issues.

⏺ multipass-mcp - run_script (MCP)(name: "mk8s-node1", script: "sudo microk8s config >
                                  /home/ubuntu/kubeconfig.yaml")
  ⎿  

⏺ multipass-mcp - transfer (MCP)(source: "mk8s-node1:/home/ubuntu/kubeconfig.yaml", destination:
                                "/tmp/mk8s-raw-kubeconfig.yaml")
  ⎿  

⏺ Good, file transferred. Now I'll rename the context/cluster/user to multipass-mcp-microk8s and merge it.

⏺ Bash(sed -i '' \
        -e 's/name: microk8s-cluster/name: multipass-mcp-microk8s/' \…)
  ⎿  apiVersion: v1
     clusters:
     - cluster:
     … +54 lines (ctrl+o to expand)

⏺ Now restore the original kubeconfig and re-merge with the transferred file.

⏺ Bash(BACKUP=$(ls -t "$HOME/.kube/config.bak."* 2>/dev/null | head -1) && cp "$BACKUP" "$HOME/.kube/config"
      && KUBECONFIG="$HOME/.kube/config:/tmp/mk8s-raw-kubeconfig…)
  ⎿  (No output)

⏺ Bash(kubectl --context multipass-mcp-microk8s get nodes -o wide)
  ⎿  NAME         STATUS   ROLES    AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE
       KERNEL-VERSION       CONTAINER-RUNTIME
     mk8s-node1   Ready    <none>   10m     v1.31.14   192.168.2.99    <none>        Ubuntu 22.04.5 LTS
     … +5 lines (ctrl+o to expand)

⏺ All working. Let me verify the final state.

⏺ Bash(kubectl config get-contexts)
  ⎿  CURRENT   NAME                     CLUSTER                  AUTHINFO                       NAMESPAC
     E
     *         mp-clster                mp-clster                mp-clster-admin
     … +2 lines (ctrl+o to expand)

⏺ Done. Here's a summary:

  3 Multipass VMs created:
  - mk8s-node1 — 192.168.2.99
  - mk8s-node2 — 192.168.2.100
  - mk8s-node3 — 192.168.2.101

  MicroK8s cluster:
  - All 3 nodes are Ready and running MicroK8s v1.31.14
  - High-availability: yes — all 3 nodes are datastore masters (Dqlite HA)
  - Each node is both control plane and worker

  Kubeconfig:
  - Context multipass-mcp-microk8s added to ~/.kube/config
  - Access via: kubectl --context multipass-mcp-microk8s get nodes

✻ Sautéed for 13m 56s
```



