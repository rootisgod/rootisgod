---
categories: proxmox packer k8s kubernetes windows kubevirt
date: "2024-06-04T08:00:00Z"
title: Running Windows VMs in Kubernetes with Kubevirt
draft: true
---

https://www.youtube.com/watch?v=MBvm48v43g0
https://www.youtube.com/watch?v=1nf3WOEFq1Y&t=1197s

https://gist.github.com/usrbinkat/c8b56fb703328147c796bc4356b029b5

This will be a long one. But, it is well worth a try. We will create a QEMU image in packer. Then upload it to a MicroK8S cluster and install kubevirt. Once done, we can create VMs on demand in Kubernetes.

Why? Well, imagine you want to run multiple old school services, that not containerizable. We can use this to host the VMs and benefit from all the Kubernetes ecosystem. Imagine you have a windows service with a SQL Server backend, you can create a new VM per client. If we get a process to set this up, adding a new client to the system is as easy as applying a YAML file. Interesting...

So, in this use case, we have a piece of software and we need to run one VM per client. We want to use Kubernetes and deploy a packer image.


## Packer (optional)

Grab from here

https://developer.hashicorp.com/packer/install?product_intent=packer

Assuming Linux though

```bash
mv packer /usr/local/bin
chmod +x /usr/local/bin
```



## Setup Kubevirt

https://gist.github.com/usrbinkat/c8b56fb703328147c796bc4356b029b5

virt-host-validate qemu

We use KIND (microk8s may have an issue)

https://kubevirt.io/quickstart_kind/

```bash
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind create cluster --name kubevirt
kubectl cluster-info --context kind-kubevirt
```

Install kubevirt (https://kubevirt.io/quickstart_kind/)

```powershell
#  https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt
$VERSION='v1.2.2'
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$($VERSION)/kubevirt-cr.yaml
```

Check it

```bash
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
kubectl get all -n kubevirt
```


Then install virtctl

```powershell
https://github.com/kubevirt/kubevirt/releases
mv virtctl-v1.2.2-windows-amd64.exe c:\windows\system32\virtctl.exe
```

```bash
VERSION=$(kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.observedKubeVirtVersion}")
ARCH=$(uname -s | tr A-Z a-z)-$(uname -m | sed 's/x86_64/amd64/') || windows-amd64.exe
echo ${ARCH}
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${VERSION}/virtctl-${VERSION}-${ARCH}
chmod +x virtctl
sudo install virtctl /usr/local/bin
```

Windows

```powershell
# turn off all wsl instances such as docker-desktop
wsl --shutdown
notepad "$env:USERPROFILE/.wslconfig"
```

```file
[wsl2]
memory=8GB   # Limits VM memory in WSL 2 up to 8GB
processors=4 # Makes the WSL 2 VM use two virtual processors
```

Restart Docker Desktop


Setup a CDI
https://kubevirt.io/labs/kubernetes/lab2

export VERSION=$(basename $(curl -s -w %{redirect_url} https://github.com/kubevirt/containerized-data-importer/releases/latest))
$VERSION='v1.59.0'
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml

kubectl get cdi cdi -n cdi
kubectl get pods -n cdi


Now, we can install and manage vms
https://techviewleo.com/how-to-install-kvm-on-linux-mint/?utm_content=cmp-true
https://kubevirt.io/2020/KubeVirt-VM-Image-Usage-Patterns.html

https://github.com/kubevirt/containerized-data-importer
CDI only supports certain combinations of source and contentType as indicated below:
  http → kubevirt, archive
  registry → kubevirt
  pvc → Not applicable - content is cloned
  upload → kubevirt
  imageio → kubevirt
  vddk → kubevirt


```yml
cat <<EOF > dv_windows2022.yml
apiVersion: cdi.kubevirt.io/v1beta1
kind: DataVolume
metadata:
  name: "win2022"
spec:
  storage:
    resources:
      requests:
        storage: 20Gi
  source:
    http:
      url: "http://localhost/QCOW/QCOW/windows-2022.qcow2"
EOF
```

kubectl create -f kubevirt_win2022_pvc.yml
kubectl get pvc win2022 -o yaml

kubectl create -f kubevirt_win2022_dv.yml
kubectl get dv kubevirt-win2022 -o yaml
kubectl get pod # Make note of the pod name assigned to the import process
kubectl logs -f importer-fedora-pnbqh   # Substitute your importer-fedora pod name here.

 kubectl apply -f kubevirt_win2022_vm.yml
 kubectl get vm vm1  

 Need to install vncviewer...
 Install TightVNC. Don't install the server part. Copy 'C:\Program Files\TightVNC\tnviewer.exe' to 'c:\windows\system32\vncviewer.exe' 

 kubectl vnc vm1