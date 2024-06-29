---
categories: terraform octopusdeploy iac opentofu
date: "2024-06-29T00:00:00Z"
title: Downloading All Terraform Versions
draft: false
---

I recently had a problem at work where I needed a quick way to get a different version of terraform for multiple projects I was on. Now, I know about [tfenv](https://github.com/tfutils/tfenv) but I would rather just have them all downloaded and ready to go from a path I knew the location of.

Also, we are starting to use [Octopus Deploy](https://octopus.com) to do our Terraform deployment, but to override the Terraform version that is bundled with the worker image, you need to [specify the location](https://octopus.com/docs/deployments/terraform#special-variables) of a folder with the Terraform binary in it, so it can reach it. And so given I dont really know the versions required ahead of time, I need them all, and for Linux or Windows. And maybe for ARM later etc etc...

So, I decided to write a script that would do the hard part of downloading them all for me.

# The Script

The script is written in powershell to make it multi-platform, and our Octopus Server runs on windows so it made it an easier fit. For Ubuntu, a simple ```snap install powershell --classic``` is all you need to do.

## Some hints

 - You specfy the OS, one of these: darwin_amd64, darwin_arm64, freebsd_386, freebsd_amd64, freebsd_arm,
linux_386, linux_amd64, linux_arm, linux_arm64, openbsd_386, openbsd_amd64, solaris_amd64, windows_386, windows_amd64
 - You specify an OutputDir for where the files should end up. For Windows, you can specify a folder like '/TerraformBinaries' and it will resolve to the drive you are running the script from and become 'C:/TerraformBinaries'. Or pass a full path.
 - If the terraform file already exists it won't attempt to re-download it. You can rerun the script to get newer versions
 - If only downloads V1 versions of Terraform, and no RC, beta etc versions
 - Some versions arent available for certain OS's, the script will just error and carry on, dont worry about it
 - You could probably use the outout folder with a web server to serve the versions much like the Terraform wesbite, but they are unzipped and ready to go for you. This could also be useful if you have bad internet (like me).

So, something like this will download all the versions for Windows 64 bit and place them in a folder called ```/root/terraform/linux_amd64```.

```powershell
.\TerraformDownloader.ps1 -OS linux_amd64 -OutputDir '/root/terraform'
```

You'll get output like the below. Easy.


```
Terraform /root/terraform/linux_amd64/1.0.0/terraform Does Not Exist                                                    
https://releases.hashicorp.com/terraform/1.0.0/terraform_1.0.0_windows_amd64.zip
Downloading Terraform 1.0.0...                                                                                          
Unzipping Terraform 1.0.0...
Terraform /root/terraform/linux_amd64/1.0.1/terraform Does Not Exist                                                    
https://releases.hashicorp.com/terraform/1.0.1/terraform_1.0.1_windows_amd64.zip
Downloading Terraform 1.0.1...
Unzipping Terraform 1.0.1...

```

Run for each OS you need. Windows could be like this

```powershell
```powershell
.\TerraformDownloader.ps1 -OS windows_amd64 -OutputDir 'c:/terraform'
```

## Full Script

Here is the full script

```powershell
 param (
    [Parameter(Mandatory = $false)]
    [ValidateSet(
        "darwin_amd64",
        "darwin_arm64",
        "freebsd_386",
        "freebsd_amd64",
        "freebsd_arm",
        "linux_386",
        "linux_amd64",
        "linux_arm",
        "linux_arm64",
        "openbsd_386",
        "openbsd_amd64",
        "solaris_amd64",
        "windows_386",
        "windows_amd64"
    )]
    [string]$OS = "windows_amd64",

    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "/Terraform"
)

if ($OS -like 'windows*') {
    $terraformBinaryName = 'terraform.exe'
}
else {
    $terraformBinaryName = 'terraform'
}

# Define the base URL for Terraform releases
$baseUrl = "https://releases.hashicorp.com/terraform"
$outputDir = "$OutputDir/$OS" # Change this to your desired directory

# Create the output directory if it doesn't exist
if (-Not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Get the list of available versions
$versionsPage = Invoke-WebRequest -Uri $baseUrl
$versionLinks = ($versionsPage.Links | Where-Object { $_.href -match "terraform/\d+\.\d+\.\d+/$" }).href

# Filter out pre-release versions (beta, rc, etc.)
$releasedVersions = @()
foreach ($versionLink in $versionLinks) {
    $version = $versionLink -replace "terraform/", "" -replace "/$", ""
    if ($version -notmatch "(beta|rc|alpha|pre)") {
        $releasedVersions += $version
    }
}

# Output the released versions
$releasedVersions = $releasedVersions | Sort-Object
$releasedVersions = $releasedVersions | ForEach-Object { $_.Substring(1) }
# Remove 0.x.x versions
$releasedVersions = $releasedVersions | Where-Object { $_ -notmatch "^0\." }

# Create Download Links
foreach ($releasedVersion in $releasedVersions) {
    if (Test-Path $outputDir\$releasedVersion\$terraformBinaryName) {
        Write-Output "Terraform $outputDir/$releasedVersion/$terraformBinaryName Exists"
    }
    else {
        Write-Output "Terraform $outputDir/$releasedVersion/$terraformBinaryName Does Not Exist"
        $downloadUrl = "$baseURL/$releasedVersion/terraform_${releasedVersion}_$OS.zip"
        $downloadUrl
        $response = Invoke-WebRequest -Uri $downloadUrl -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            $zipFilePath = "$outputDir\terraform_${releasedVersion}_$OS.zip"
            $extractPath = "$outputDir\$releasedVersion"

            Write-Output "Downloading Terraform $OS $releasedVersion..."
            Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFilePath

            Write-Output "Unzipping Terraform $OS $releasedVersion..."
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath

            # Remove the zip file after extraction
            Remove-Item -Path $zipFilePath
        } else {
            Write-Output "$OS $releasedVersion not Found..."
        }
    }
}

Write-Output "All Terraform versions for $OS have been downloaded and unzipped."
```
