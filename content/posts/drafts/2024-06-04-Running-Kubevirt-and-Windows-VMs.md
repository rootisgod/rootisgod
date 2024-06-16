---
categories: proxmox packer k8s kubernetes windows kubevirt
date: "2024-06-04T08:00:00Z"
title: Running Windows VMs in Kubernetes with Kubevirt
draft: true
---

This will be a long one.

But, it is well worth a try. The basic goal is running a Windows VM inside of a Kubernetes cluster. We will do this by;
 - Creating a QCOW2 Windows image with packer and virtualbox
 - Installing KIND and installing Kubevirt
 - Deploying the VM using a Data Volume and a PVC claim 
 
Once done, we can create VMs on demand in Kubernetes.

Why? Well, imagine you want to run multiple old school services, that not containerizable. We can use this to host the VMs and benefit from all the Kubernetes ecosystem. Imagine you have a windows service with a SQL Server backend, you can create a new VM per client. If we get a process to set this up, adding a new client to the system is as easy as deploying a pod and managing it declaratively.


## Creating a VM Image

To get to the stage of running a Windows machine in Kubernetes, we need a VM image. And for that, we need Virtualbox to create a VM, and Packer to make the image from it.

Note: For this guide, we are using Windows as the base OS to show the steps. It doesnt change things too much if using Linux, but worth noting.


### Installing Packer and Virtualbox

The easiest way to install Virtualbox and Packer we can use chocolatey (or install both programs manually if you know what you are doing). You can install it with these instructions - https://chocolatey.org/install

```powershell
choco install virtualbox packer -y
```

### Windows ISO

We also need a Windows Server 2022 ISO. You can grab an evaluation licence ISO from here: https://www.microsoft.com/en-gb/evalcenter/download-windows-server-2022. I have placed it into a folder on my computer called ```D:\ISOs\windows_server_2022.iso```. Update the location in the code below, ```iso_url```, with wherever yours is located.


### Packer

Now we can think about deploying it with packer. But, first we need to install the following packer plugins like so.

```bash
packer plugins install github.com/hashicorp/vagrant
packer plugins install github.com/hashicorp/virtualbox
```

#### Packer Windows 2022 Template

This is the template we need to run. Save it as a file like ```windows.pkr.hcl```.

```hcl
packer {
  required_plugins {
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

source "virtualbox-iso" "windows" {
  vm_name              = "win2022"
  communicator         = "winrm"
  floppy_files         = ["files/Autounattend.xml", "scripts/enable-winrm.ps1", "scripts/sysprep.bat"]
  guest_additions_mode = "attach"
  guest_os_type        = "Windows2016_64"
  headless             = "false"
  iso_checksum         = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_url              = "d:/ISOs/windows_server_2022.iso"
  disk_size            = "24576"
  shutdown_timeout     = "15m"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "4096"], ["modifyvm", "{{ .Name }}", "--vram", "48"], ["modifyvm", "{{ .Name }}", "--cpus", "4"]]
  winrm_username       = "vagrant"
  winrm_password       = "vagrant"
  winrm_timeout        = "12h"
  keep_registered      = "true"            # Can be handy to manually inspect the VM post creation
  shutdown_command     = "a:/sysprep.bat"
}

build {
  sources = ["source.virtualbox-iso.windows"]

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/customise.ps1"
  }

  provisioner "powershell" {
    elevated_password = "vagrant"
    elevated_user     = "vagrant"
    script            = "scripts/windows-updates.ps1"
  }
}
```

And we need a few files in a couple of folders to take care of an unattended install an some post boot actions.

#### Scripts

The most important file is the ```enable-winrm.ps1``` file. The answer file (below) references this and will run it once windows is installed. It sets up winrm so that Packer can send commands to it once the OS is installed.

```powershell
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow remoteip=any
Set-Service winrm -startuptype "auto"
Restart-Service winrm
```

We also need a ```sysprep.bat``` file in a scripts folder to shutdown the machine and 'randomise' the VM on boot. If you dont want this, just leave in the shutdown command. Packer runs this script when the VM is deployed, configured, and ready to shut down.
```bat
c:\windows\system32\sysprep\sysprep.exe /generalize /mode:vm /oobe 
shutdown /s
```

And we also need a ```customise.ps1``` script to configure some small settings, and install chocolatey and virtio drivers. Add/amend as you require.
```powershell
# Set some Quality of Life Settings
c:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v HideFileExt /t REG_DWORD /d 0 /f
c:\Windows\System32\reg.exe ADD HKCU\Console /v QuickEdit /t REG_DWORD /d 1 /f
c:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v Start_ShowRun /t REG_DWORD /d 1 /f
c:\Windows\System32\reg.exe ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\ /v StartMenuAdminTools /t REG_DWORD /d 1 /f
c:\Windows\System32\reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateFileSizePercent /t REG_DWORD /d 0 /f
c:\Windows\System32\reg.exe ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\ /v HibernateEnabled /t REG_DWORD /d 0 /f
c:\Windows\System32\reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
netsh advfirewall firewall set rule group="remote desktop" new enable=yes

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Chocolatey Seems to cause a non-zero exit, cause a 500MB download, exits with a non-zero code and breaks the build... Lets install ourselves
$url  = 'https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win-guest-tools.exe'
$dest = 'c:\virtio-win-guest-tools.exe'
Invoke-WebRequest -Uri $url -OutFile $dest
c:\virtio-win-guest-tools.exe -s
```

#### Files

And we need an answer file for Windows to skip the install questions. Importantly, this also references and runs the ```enable-winrm.ps1``` script.

```Autounattend.xml```

```xml
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <SetupUILanguage>
                <UILanguage>en-US</UILanguage>
            </SetupUILanguage>
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UILanguageFallback>en-US</UILanguageFallback>
            <UserLocale>en-US</UserLocale>
        </component>
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <CreatePartitions>
                        <CreatePartition wcm:action="add">
                            <Type>Primary</Type>
                            <Order>1</Order>
                            <Size>350</Size>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Type>Primary</Type>
                            <Extend>true</Extend>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Active>true</Active>
                            <Format>NTFS</Format>
                            <Label>boot</Label>
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Format>NTFS</Format>
                            <Label>Windows 2022</Label>
                            <Letter>C</Letter>
                            <Order>2</Order>
                            <PartitionID>2</PartitionID>
                        </ModifyPartition>
                    </ModifyPartitions>
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <Key>/IMAGE/NAME </Key>
                            <Value>Windows Server 2022 SERVERDATACENTER</Value>
                        </MetaData>
                    </InstallFrom>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>2</PartitionID>
                    </InstallTo>
                </OSImage>
            </ImageInstall>
            <UserData>
                <!-- Product Key from http://technet.microsoft.com/en-us/library/jj612867.aspx -->
                <ProductKey>
                    <!-- Do not uncomment the Key element if you are using trial ISOs -->
                    <!-- You must uncomment the Key element (and optionally insert your own key) if you are using retail or volume license ISOs -->
                    <!--<Key>WC2BQ-8NRM3-FDDYY-2BFGV-KHKQY</Key>-->
                    <WillShowUI>OnError</WillShowUI>
                </ProductKey>
                <AcceptEula>true</AcceptEula>
                <FullName>Vagrant</FullName>
                <Organization>Vagrant</Organization>
            </UserData>
        </component>
    </settings>
    <settings pass="specialize">
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OEMInformation>
                <HelpCustomized>false</HelpCustomized>
            </OEMInformation>
            <ComputerName>vagrant-2022</ComputerName>
            <TimeZone>Pacific Standard Time</TimeZone>
            <RegisteredOwner/>
        </component>
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-ServerManager-SvrMgrNc" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DoNotOpenServerManagerAtLogon>true</DoNotOpenServerManagerAtLogon>
        </component>
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-IE-ESC" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <IEHardenAdmin>false</IEHardenAdmin>
            <IEHardenUser>false</IEHardenUser>
        </component>
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-OutOfBoxExperience" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DoNotOpenInitialConfigurationTasksAtLogon>true</DoNotOpenInitialConfigurationTasksAtLogon>
        </component>
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <SkipAutoActivation>true</SkipAutoActivation>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <AutoLogon>
                <Password>
                    <Value>vagrant</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <Username>vagrant</Username>
            </AutoLogon>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>cmd.exe /c C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File a:\enable-winrm.ps1</CommandLine>
                    <Order>1</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <CommandLine>cmd.exe /c wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE</CommandLine>
                    <Order>2</Order>
                    <Description>Disable password expiration for vagrant user</Description>
                </SynchronousCommand>
            </FirstLogonCommands>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <NetworkLocation>Home</NetworkLocation>
                <ProtectYourPC>1</ProtectYourPC>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>vagrant</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>vagrant</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Group>administrators</Group>
                        <DisplayName>Vagrant</DisplayName>
                        <Name>vagrant</Name>
                        <Description>Vagrant User</Description>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <RegisteredOwner/>
        </component>
    </settings>
    <settings pass="offlineServicing">
        <component xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="Microsoft-Windows-LUA-Settings" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <EnableLUA>false</EnableLUA>
        </component>
    </settings>
    <cpi:offlineImage xmlns:cpi="urn:schemas-microsoft-com:cpi" cpi:source="wim:c:/wim/install.wim#Windows Server 2012 R2 SERVERSTANDARD"/>
</unattend>
```

And finally, one to do windows updates.

```windows-updates.ps1```

```powershell
$ProgressPreference='SilentlyContinue'
Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -IgnoreReboot
```

Okay, thats a lot. But you should effectively have this folder structure

```
windows.pkr.hcl
Scripts\enable-winrm.ps1
Scripts\sysprep.bat
Scripts\customise.ps1
Scripts\windows-updates.ps1
Files\Autounattend.xml
```


## KIND

We will use KIND to run the VM as it is supported by the Kubevirt project and can run on Windows using Docker Desktop and WSL2.

### Installation and WSL2

We need WSL2 on Windows. Follow these instructions: https://kind.sigs.k8s.io/docs/user/using-wsl2/

And then, it could be as simple as this though to install KIND, but your mileage may vary. See these instructions if the below fails: https://kind.sigs.k8s.io/docs/user/quick-start

```powershell
choco install kind
```

There is also a tweak in WSL2 we need to perform. The default allocated memory likely will not be enough, so stop WSL and create/amend the ```.wslconfig``` file to something like the below

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

Then restart Docker desktop from its GUI.

We are getting there!

### Setup Kubevirt

We should have the required basic tools installed and can now create a KIND cluster to host our VMs. 

There is a quickstart guide here: https://kubevirt.io/quickstart_kind/

But this is what we will do. 


```powershell
kind create cluster --name kubevirt
choco install kubectl -y
kubectl cluster-info --context kind-kubevirt
```

We should get our cluster info

```
Kubernetes control plane is running at https://127.0.0.1:58905
CoreDNS is running at https://127.0.0.1:58905/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

```

And now we can install Kubevirt into the cluster. There is a guide here: https://kubevirt.io/quickstart_kind/

These are the command I used.

```powershell
#  https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt
$VERSION='v1.2.2'
export VERSION=$(curl -s https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/$($VERSION)/kubevirt-cr.yaml
```

Check it works

```bash
kubectl get kubevirt.kubevirt.io/kubevirt -n kubevirt -o=jsonpath="{.status.phase}"
kubectl get all -n kubevirt
```

We should get a bunch of Kubevirt resources

```
NAME                                   READY   STATUS    RESTARTS        AGE
pod/virt-api-75859b7b7-dn4sd           1/1     Running   5 (4d11h ago)   7d18h
pod/virt-controller-6855b4df79-4m7rn   1/1     Running   5 (4d11h ago)   7d18h
pod/virt-controller-6855b4df79-tzk5v   1/1     Running   5 (4d11h ago)   7d18h
...
```

### Setup Virtctl

Then install we install Virtctl to control VMs. Grab the latest version here and move it insto a system32 folder so it can be seen in our terminal.

```powershell
wget https://github.com/kubevirt/kubevirt/releases/download/v1.2.2/virtctl-v1.2.2-windows-amd64.exe
mv virtctl-v1.2.2-windows-amd64.exe c:\windows\system32\virtctl.exe
```


### Setup a CDI

We also need a CDI (Containerized Data Importer) operator. 

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



## Taskfiles

To try and tame the complexity of the many commands, I created a Taskfile to simplify things. Taskfile is like a modern implementation of make, and is availble for all OS's as a single binary file to install. This file is for Windows machines, but the tasks should be amendable for linux or mac if required. We can install Taskfile like this (or see here: https://taskfile.dev/installation).

```powershell
choco install go-task -y
```

Then, we can create a file like this called ```Taskfile.yml```.


```yaml
version: '3'

tasks:
  build-and-run:
    - task: build-image
    - task: create-vm

  build-image:
    cmds:
      - powershell -command 'if (Test-Path 'output-windows') { Remove-Item -Path 'output-windows' -Recurse -Force }'
      - powershell -command 'if (Test-Path "$env:USERPROFILE\VirtualBox VMs\win2022") { Remove-Item -Path "$env:USERPROFILE\VirtualBox VMs\win2022" -Recurse -Force }'
      - packer build ./windows.pkr.hcl
      - qemu-img convert -f vmdk -O qcow2  ./output-windows/win2022-disk001.vmdk D:/QCOW/windows-2022.qcow2

  create-vm:
    cmds:
      - kubectl apply  -f kubevirt_win2022_pvc.yml
      - kubectl apply  -f kubevirt_win2022_dv.yml
      - kubectl apply  -f kubevirt_win2022_vm.yml

  status-vm:
    cmds:
      - kubectl describe vm win2022-vm

  vnc-vm:
    cmds:
      - virtctl vnc win2022-vm

  stop-vm:
    cmds:
      - virtctl stop win2022-vm

  start-vm:
    cmds:
      - virtctl start win2022-vm

  delete-vm:
    cmds:
      - kubectl delete  -f kubevirt_win2022_pvc.yml
      - kubectl delete  -f kubevirt_win2022_dv.yml
      - kubectl delete  -f kubevirt_win2022_vm.yml
```

Now, to build an image and start a VM, we can run this

```powershell
task build-and-run
```

And to delete it, we can run this

```powershell
task delete-vm
```

There are a couple more, to see what is available (easy to forget) simply run ``` task --list-all```

```
task: Available tasks for this project:
* build-and-run:
* build-image:$env:USERPROFILE
* create-vm:
* delete-vm:
* platforms:
* start-vm:
* status-vm:
* stop-vm:
* test:
* vnc-vm:
```

A very nice simplification, and something I am definitely going to use more of in future.