# OZO AD Lab Customize ISOs

## Description
An interactive script that automates [part](https://onezeroone.dev/active-directory-lab-part-ii-customize-the-installer-isos/) of a One Zero One [series](https://onezeroone.dev/active-directory-lab-part-i-introduction/) that illustrates how to automate the process of deploying an AD Lab. It leverages resources from the [One zero One AD Lab resources](https://github.com/onezeroone-dev/OZO-AD-Lab/releases/tag/v0.0.3) to customize AlmaLinux and Microsoft installer ISOs. If a customized ISO is found, it is skipped.

## Prerequisites
To use this script you must first implement the [Active Directory Lab Part II: Customization Prerequisites](https://onezeroone.dev/active-directory-lab-part-ii-customization-prerequisites/).

## Installation
This script is published to [PowerShell Gallery](https://learn.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-5.1). Ensure your system is configured for this repository then execute the following in an _Administrator_ PowerShell:

```powershell
Install-Script ozo-ad-lab-customize-isos
```

## Usage
```powershell
ozo-ad-lab-customize-isos
    -OZOADLabDir <String>
```

## Parameters
|Parameter|Description|
|---------|-----------|
|`OZOADLabDir`|Location of the `ozo-ad-lab` directory. Defaults to `$Env:SystemDrive\ozo-ad-lab`.|

## Examples
### Example 1
When the [OZO AD Lab resources](https://github.com/onezeroone-dev/OZO-AD-Lab/releases/tag/v0.0.3) have been downloaded and extracted to the root of your system drive (typically `C`) and all prerequisites described in [Active Directory Lab Part II: Customization Prerequisites](https://onezeroone.dev/active-directory-lab-part-ii-customization-prerequisites/) are satisfied, you can run this script with no parameters:
```powershell
ozo-ad-lab-customize-isos
```
### Example 2
If your [OZO AD Lab resources](https://github.com/onezeroone-dev/OZO-AD-Lab/releases/tag/v0.0.3) are located elsewhere, you can specify the directory, e.g, if they are extracted to `C:\Temp\ozo-ad-lab`:
```powershell
ozo-ad-lab-customize-isos -OZOADLabDir "C:\Temp\ozo-ad-lab"
```

## Notes
Run this script in an _Administrator_ PowerShell.

## Acknowledgements
Special thanks to my employer, [Sonic Healthcare USA](https://sonichealthcareusa.com), who has supported the growth of my PowerShell skillset and enabled me to contribute portions of my work product to the PowerShell community.
