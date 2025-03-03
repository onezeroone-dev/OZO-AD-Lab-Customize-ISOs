#Requires -Modules @{ModuleName="OZO";ModuleVersion="1.5.1"},OZOLogger -Version 5.1

<#PSScriptInfo
    .VERSION 0.0.1
    .GUID 107291d5-0444-4f57-b173-8578b222576b
    .AUTHOR Andy Lievertz <alievertz@sonichealthcareusa.com>
    .COMPANYNAME One Zero One
    .COPYRIGHT This script is released under the terms of the GNU General Public License ("GPL") version 2.0.
    .TAGS 
    .LICENSEURI https://github.com/onezeroone-dev/OZO-AD-Lab-Customize-ISOs/blob/main/LICENSE
    .PROJECTURI https://github.com/onezeroone-dev/OZO-AD-Lab-Customize-ISOs
    .ICONURI 
    .EXTERNALMODULEDEPENDENCIES
    .REQUIREDSCRIPTS 
    .EXTERNALSCRIPTDEPENDENCIES 
    .RELEASENOTES https://github.com/onezeroone-dev/OZO-AD-Lab-Customize-ISOs/blob/main/CHANGELOG.md
#>

<# 
    .SYNOPSIS
    See description.
    .DESCRIPTION 
    Leverages resources from the One Zero One AD Lab release to customize AlmaLinux and Microsoft installer ISOs.
    .LINK
    https://github.com/onezeroone-dev/OZO-AD-Lab-Customize-ISOs/blob/main/README.md
#>

# PARAMETERS
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory=$false,HelpMessage="Path to the OZO AD Lab directory")][String]$OZOADLabDir = (Join-Path -Path $Env:SystemDrive -ChildPath "ozo-ad-lab")
)

# CLASSES
Class OZOADLCIMain {
    # PROPERTIES: Strings
    [String] $downloadsDirectory = $null
    [String] $ozoADLabDirectory  = $null
    # PROPERTIES: PSCustomObjects
    [PSCustomObject] $ISO    = $null
    [PSCustomObject] $Logger = $null
    # METHODS
    # Constructor method
    OZOADLCIMain($OZOADLabDir) {
        # Set properties
        $this.downloadsDirectory = (Join-Path -Path $Env:USERPROFILE -ChildPath "Downloads")
        $this.ozoADLabDirectory  = $OZOADLabDir
        # Create a logger object
        $this.Logger = (New-OZOLogger)
        # Log a process start message
        $this.Logger.Write("Process starting.","Information")
         # Router
         $this.Logger.Write("Processing the Router ISO.","Information")
         $this.ISO = [OZOADLCIISO]::new(
             "Router", #Build
             "AlmaLinux-9-5-x86_64-dvd", #CustomISOLabel
             (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Linux"), #CustomISOLinuxDir
             (Join-Path -Path $this.downloadsDirectory -ChildPath "OZO-AD-Lab-Router.iso"), #CustomISOMOvePath
             (Join-Path -Path $this.ozoADLabDirectory -ChildPath "OZO-AD-Lab-Router.iso"), #CustomISOOutputPath
             (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\almalinux-boot.iso") #SourceISOPath
         )
         $this.Logger.Write(("Results: " + ($this.ISO.Messages -Join("`r`n"))),"Information")
        # Client
        $this.Logger.Write("Processing the Client ISO.","Information")
        $this.ISO = [OZOADLCIISO]::new(
            "Client", #Build
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Builds\Client"), #CustomISOBUildDir
            "OZO-AD-Lab-Client", #CustomISOLabel
            (Join-Path -Path $this.downloadsDirectory -ChildPath "OZO-AD-Lab-Client.iso"), #CustomISOMovePath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Mount"), #CustomISOMountDir
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\OZO-AD-Lab-Client.iso"), #CustomISOOutputPath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "WIM\Windows 11 Enterprise"), #CustomWIMDir
            1, #SourceIndex
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\microsoft-windows-11-enterprise-evaluation.iso"), #SourceISOPath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\microsoft-windows-11-laof.iso") #SourceLAoFISOPath
        )
        $this.Logger.Write(("Results: " + ($this.ISO.Messages -Join("`r`n"))),"Information")
        # DC
        $this.Logger.Write("Processing the DC ISO.","Information")
        $this.ISO = [OZOADLCIISO]::new(
            "DC",# Build
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Builds\DC"), #CustomISOBuildDir
            "OZO-AD-Lab-DC", #CustomISOLabel
            (Join-Path -Path $this.downloadsDirectory -ChildPath "OZO-AD-Lab-DC.iso"), #CustomISOMovePath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Mount"), #CustomISOMountDir
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\OZO-AD-Lab-DC.iso"), #CustomISOOutputPath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "WIM\Windows Server 2022"), #CustomWIMDir
            2, #SourceIndex
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\microsoft-windows-server-2022-evaluation.iso"), #SourceISOPath
            $null #SourceLAoFISOPath
        )
        $this.Logger.Write(("Results: " + ($this.ISO.Messages -Join("`r`n"))),"Information")
        # Server
        $this.Logger.Write("Processing the Server ISO.","Information")
        $this.ISO = [OZOADLCIISO]::new(
            "Server",# Build
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Builds\Server"), #CustomISOBuildDir
            "OZO-AD-Lab-DC", #CustomISOLabel
            (Join-Path -Path $this.downloadsDirectory -ChildPath "OZO-AD-Lab-Server.iso"), #CustomISOMovePath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "Mount"), #CustomISOMountDir
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\OZO-AD-Lab-Server.iso"), #CustomISOOutputPath
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "WIM\Windows Server 2022"), #CustomWIMDir
            2, #SourceIndex
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\microsoft-windows-server-2022-evaluation.iso"), #SourceISOPath
            $null #SourceLAoFISOPath
        )
        $this.Logger.Write(("Results: " + ($this.ISO.Messages -Join("`r`n"))),"Information")
        # Log a process end message
        $this.Logger.Write("Process complete.","Information")
    }
}

Class OZOADLCIISO {
    # PROPERTIES: Booleans, Int16s, Strings
    [Boolean] $Proceed             = $true
    [Boolean] $Validates           = $true
    [Int16]   $sourceIndex         = $null
    [String]  $Build               = $null
    [String]  $customISOBuildDir   = $null
    [String]  $customISOLabel      = $null
    [String]  $customISOLinuxDir   = $null
    [String]  $customISOMovePath   = $null
    [String]  $customISOMountDir   = $null
    [String]  $customISOOutputPath = $null
    [String]  $customWIMDir        = $null
    [String]  $efisysBinPath       = $null
    [String]  $mountDrive          = $null
    [String]  $oscdimgExePath      = $null
    [String]  $sourceISOPath       = $null
    [String]  $sourceLAoFISOPath   = $null
    # PROPERTIES: Lists
    [System.Collections.Generic.List[String]] $Messages = @()
    # METHODS
    # Constructor method - Linux overload
    OZOADLCIISO($Build,$CustomISOLabel,$CustomISOLinuxDir,$CustomISOMovePath,$CustomISOOutputPath,$SourceISOPath) {
        # Set properties
        $this.Build               = $Build
        $this.customISOLabel      = $CustomISOLabel
        $this.customISOLinuxDir   = $CustomISOLinuxDir
        $this.customISOMovePath   = $CustomISOMovePath
        $this.customISOOutputPath = $CustomISOOutputPath
        $this.oscdimgExePath      = (Join-Path -Path ${Env:ProgramFiles(x86)} -ChildPath "Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe")
        $this.sourceISOPath       = $SourceISOPath
        # Determine if ISO validates
        If ($this.ValidateLinISO() -eq $true) {
            # ISO validates; call ProcessLinISO to create the custom ISO
            $this.ProcessLinISO()
        }
    }
    # Constructor method - Windows overload
    OZOADLCIISO($Build,$CustomISOBuildDir,$CustomISOLabel,$CustomISOMovePath,$CustomISOMountDir,$CustomISOOutputPath,$CustomWIMDir,$SourceIndex,$SourceISOPath,$SourceLAoFISOPath) {
        # Set properties
        $this.Build               = $Build
        $this.customISOBuildDir   = $CustomISOBuildDir
        $this.customISOLabel      = $CustomISOLabel
        $this.customISOMovePath   = $CustomISOMovePath
        $this.customISOMountDir   = $CustomISOMountDir
        $this.customISOOutputPath = $CustomISOOutputPath
        $this.customWIMDir        = $CustomWIMDir
        $this.efisysBinPath       = (Join-Path -Path $this.customISOBuildDir -ChildPath "efi\microsoft\boot\efisys.bin")
        $this.oscdimgExePath      = (Join-Path -Path ${Env:ProgramFiles(x86)} -ChildPath "Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe")
        $this.sourceIndex         = $SourceIndex
        $this.sourceISOPath       = $SourceISOPath
        $this.sourceLAoFISOPath   = $SourceLAoFISOPath
        # Determine if ISO validates
        IF ($this.ValidateWinISO() -eq $true) {
            # ISO validates; call ProcessWinISO to create the custom ISO
            $this.ProcessWinISO()
        }
    }
    # Validate Linux ISO method
    Hidden [Boolean] ValidateLinISO() {
        # Control variable
        [Boolean] $Return = $true
        # Check if WSL Debian is installed
        If ([Boolean](wsl -l | Where-Object {$_.Replace("`0","") -Match '^Debian'}) -eq $false) {
            # Did not find WSL Debian
            $this.Messages.Add("Missing WSL Debian. Please see https://onezeroone.dev/active-directory-lab-part-ii-customization-prerequisites/ for more information.")
            $Return = $false
        }
        # Determine if custom ISO already exists in Downloads directory
        If ((Test-Path -Path $this.customISOMovePath) -eq $true) {
            # Custom ISO already exists
            $this.Messages.Add(("Found " + $this.customISOMovePath + "; skipping."))
            $Return = $false
        }
        # Determine if custom ISO already exists in OZO AD Lab directory
        If ((Test-Path -Path $this.customISOOutputPath) -eq $true) {
            # Custom ISO already exists
            $this.Messages.Add(("Found " + $this.customISOOutputPath + "; skipping."))
            $Return = $false
        }
        # Determine that source ISO does not exist
        If ((Test-Path -Path $this.sourceISOPath) -eq $false) {
            # Source ISO does not exist
            $this.Messages.Add(("Missing " + $this.sourceISOPath + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Process Linux ISO method
    Hidden [Void] ProcessLinISO() {
        # Local variables
        [String] $wslResult         = $null
        [String] $wslKickstartPath  = (New-OZOWSLPathFromWindowsPath -WindowsPath (Join-Path -Path $this.customISOLinuxDir -ChildPath "ozo-ad-lab-router-ks.cfg"))
        [String] $wslSourceISOPath  = (New-OZOWSLPathFromWindowsPath -WindowsPath $this.sourceISOPath)
        [String] $wslTargetISOPath  = (New-OZOWSLPathFromWindowsPath -WindowsPath $this.customISOOutputPath)
        [String] $wslTargetISOLabel = $this.customISOLabel
        [String] $wslScriptPath     = (New-OZOWSLPathFromWindowsPath -WindowsPath (Join-Path -Path $this.customISOLinuxDir -ChildPath "ozo-create-router-iso.sh"))
        # Determine if this ISO is valid
        If ($this.Validates -eq $true) {
            # ISO is valid; use WSL Debian to call the AlmaLinux ISO customization script
            $wslResult = (& wsl --distribution "Debian" --user root KICKSTART_PATH="$wslKickstartPath" SOURCE_ISO_PATH="$wslSourceISOPath" TARGET_ISO_PATH="$wslTargetISOPath" TARGET_ISO_LABEL="$wslTargetISOLabel" $wslScriptPath)
            If ($wslResult -eq "TRUE") {
                # Move the ISO
                If ($this.MoveISO() -eq $true) {
                    # Moved ISO; report success
                    $this.Messages.Add("Success")
                }
            } Else {
                $this.Messages.Add(("Error creating " + $this.customISOOutputPath))
            }
        }
    }
    # Validate Windows ISO method
    Hidden [Boolean] ValidateWinISO() {
        # Control variable
        [Boolean] $Return = $true
        # Determine if oscdimg.exe is not present
        If ((Test-Path -Path $this.oscdimgExePath) -eq $false) {
            # Did not find oscdimg.exe; report
            $this.Logger.Write("Missing oscdimg.exe. Please see https://onezeroone.dev/active-directory-lab-part-ii-customization-prerequisites/ for more information.","Error")
            $Return = $false
        }
        # Determine if the custom ISO already exists in Downloads directory
        If ((Test-Path -Path $this.customISOMovePath) -eq $true) {
            # Custom ISO exists in the Downloads directory
            $this.Messages.Add(("Found " + $this.customISOMovePath + "; skipping."))
            $Return = $false
        }
        # Determine if the custom ISO already exists in the OZO AD Lab directory
        If ((Test-Path -Path $this.customISOOutputPath) -eq $true) {
            # Custom ISO exists in the OZO AD Lab directory
            $this.Messages.Add(("Found " + $this.customISOOutputPath + "; skipping."))
            $Return = $false
        }
        # Determine if the source ISO does not exist
        If ((Test-Path -Path $this.sourceISOPath) -eq $false) {
            # Source ISO does not exist
            $this.Messages.Add(("Missing " + $this.sourceISOPath + "; skipping."))
            $Return = $false
        }
        # Determine that the build directory exists
        If ((Test-Path -Path $this.customISOBuildDir) -eq $false) {
            $this.Messages.Add("Build directory does not exist; skipping.")
            $Return = $false
        }
        # Switch for build-specific criteria
        Switch($this.Build) {
            "Client" {
                # Determine if the Windows 11 Enterprise Languages & Optional Features ISO does not exist
                If ((Test-Path -Path $this.sourceLAoFISOPath) -eq $false) {
                    # LAoF ISO does not exist
                    $this.Messages.Add(("Missing " + $this.sourceLAoFISOPath + "; skipping."))
                    $Return = $false
                }
                break
            }
            "DC" {
                break
            }
            "Server" {
                break
            }
            default {
                break
            }
        }
        # Return
        return $Return
    }
    # Process Windows ISO method
    Hidden [Void] ProcessWinISO() {
        # Mount the source ISO
        If ($this.MountISO($this.sourceISOPath) -eq $true) {
            # Source ISO mount; copy the contents to the build directory
            If ($this.CopyISO((Join-Path -Path $this.mountDrive -ChildPath "*"),$this.customISOBuildDir) -eq $true) {
                # Contents copied; dismount the ISO
                If ($this.DismountISO($this.sourceISOPath) -eq $true) {
                    # ISO dismounted; move the install WIM
                    If ($this.MoveWIM((Join-Path -Path $this.customISOBuildDir -ChildPath "sources\install.wim"),$this.customWIMDir) -eq $true) {
                        # Moved WIM; export the desired Index back to the build directory
                        If ($this.ExportImage((Join-Path -Path $this.customWIMDir -ChildPath "install.wim"),$this.sourceIndex,(Join-Path -Path $this.customISOBuildDir -ChildPath "sources\install.wim")) -eq $true) {
                            # Exported the Index back to install.wim; switch for build-specific steps
                            Switch($this.Build) {
                                "Client" {
                                    # Mount the WIM for customization
                                    If ($this.MountWIM((Join-Path -Path $this.customISOBuildDir -ChildPath "sources\install.wim"),1,$this.customISOMountDir) -eq $true) {
                                        # Mounted the WIM for customization; mount the LAoF ISO
                                        If ($this.MountISO($this.SourceLAoFISOPath) -eq $true) {
                                            # LAoF ISO mounted; Install RSAT
                                            If ($this.InstallRSAT() -eq $true) {
                                                # RSAT installation succeeded
                                                If ($this.DismountWIM($this.customISOMountDir,$true)) {
                                                    If ($this.DismountISO($this.SourceLAoFISOPath) -eq $true) {
                                                        # Create the Windows ISO
                                                        If ($this.CreateWinISO() -eq $true) {
                                                            # Move the ISO
                                                            If ($this.MoveISO() -eq $true) {
                                                                # Moved ISO; report success
                                                                $this.Messages.Add("Success")
                                                            }
                                                        }
                                                    }
                                                }
                                            } Else {
                                                # RSAT installation failed; dismount the WIM (abandoning changes) and the ISO
                                                $this.DismountWIM($this.customISOMountDir,$false)
                                                $this.DismountISO($this.SourceLAoFISOPath)
                                            }
                                        }
                                    }
                                    break
                                }
                                "DC" {
                                    # Create the Windows ISO
                                    If ($this.CreateWinISO() -eq $true) {
                                        # Move the ISO
                                        If ($this.MoveISO() -eq $true) {
                                            # Moved ISO; report success
                                            $this.Messages.Add("Success")
                                        }
                                    }
                                    break
                                }
                                "Server" {
                                    # Create the Windows ISO
                                    If ($this.CreateWinISO() -eq $true) {
                                        # Move the ISO
                                        If ($this.MoveISO() -eq $true) {
                                            # Moved ISO; report success
                                            $this.Messages.Add("Success")
                                        }
                                    }
                                    break
                                }
                                default {
                                    $this.Messages.Add(("Unhandled build: " + $this.Build))
                                    break
                                }
                            }
                        }
                    }
                }
            } Else {
                # Contents not copied; dismount the ISO
                $this.DismountISO($this.sourceISOPath)
            }
        }
    }
    # Copy ISO method
    Hidden [Boolean] CopyISO($SourcePath,$TargetPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to
        Try {
            Copy-Item -Force -Recurse -Path $SourcePath -Destination $TargetPath -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add("Failed to copy source ISO; skipping.")
            $Return = $false
        }
        # Return
        return $Return
    }
    # Move WIM method
    Hidden [Boolean] MoveWIM($SourcePath,$TargetPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to move the WIM
        Try {
            Move-Item -Force -Path $SourcePath -Destination $TargetPath -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to move " + $SourcePath + " to " + $TargetPath + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Export Image method
    Hidden [Boolean] ExportImage($ImagePath,$ImageIndex,$ExportedWIMPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to export the index
        Try {
            Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $ImageIndex -DestinationImagePath $ExportedWIMPath -ErrorAction Stop
            # Success; 
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to export Index " + $ImageIndex.ToString() + " from " + $ImagePath + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Install RSAT method
    Hidden [Boolean] InstallRSAT() {
        # Control variable
        [Boolean] $Return = $true
        # Try to install RSAT
        Try {
            Write-Host "Skipping RSAT"
            #[String] $rsatSource   = (Join-Path -Path $mountDrive -ChildPath "LanguagesAndOptionalFeatures\")
            #[Array]  $rsatPackages = (Get-WindowsCapability -Online -Name "RSAT*" -Source $rsatSource -ErrorAction Stop)
            #(Add-WindowsCapability -Name ($rsatPackages.Name -Join ",") -Source $rsatSource -Path $customMountDir -ErrorAction Stop)
            # Success; 
        } Catch {
            # Failure
            #$this.Logger.Write("Failed to install RSAT; skipping.","Warning")
            $this.Messages.Add(("Failed to install RSAT; skipping. Error message is " + $_))
            $Return = $false
            
        }
        # Return
        return $Return
    }
    # Mount WIM method
    Hidden [Boolean] MountWIM($ImagePath,$ImageIndex,$MountDir) {
        # Control variable
        [Boolean] $Return = $true
        # Try to mount the WIM
        Try {
            Mount-WindowsImage -ImagePath $ImagePath -Index $ImageIndex -Path $MountDir -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to mount " + $ImagePath + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Dismount WIM method
    Hidden [Boolean] DismountWIM($MountDir,$Save) {
        # Control variable
        [Boolean] $Return = $true
        # Try to dismount the WIM
        Try {
            # Determine if the WIM will be saved
            If ($Save -eq $true) {
                # The WIM will be saved
                Dismount-WindowsImage -Path $MountDir -Save -ErrorAction Stop
            } Else {
                # The WIM will not be saved
                Dismount-WindowsImage -Path $MountDir -Discard -ErrorAction Stop
            }
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to dismount " + $MountDir + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Mount ISO method
    Hidden [Boolean] MountISO($ISOPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to mount the ISO
        Try {
            Mount-DiskImage -ImagePath $ISOPath -ErrorAction Stop
            # Success; get the drive letter
            $this.mountDrive = ((Get-DiskImage -ImagePath $ISOPath -ErrorAction Stop | Get-Volume -ErrorAction Stop).DriveLetter + ":")
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to mount " + $ISOPath + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Dismount ISO method
    Hidden [Boolean] DismountISO($ISOPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to dismount the ISO
        Try {
            Dismount-DiskImage -ImagePath $ISOPath -ErrorAction Stop
            # Success; 
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to dismount " + $ISOPath + "; skipping."))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Create Windows ISO method
    Hidden [Boolean] CreateWinISO() {
        # Control variable
        [Boolean] $Return = $true
        # Local variables
        [String] $labl = $this.customISOLabel
        [String] $esbp = $this.efisysBinPath
        [String] $cibd = $this.customISOBuildDir
        [String] $ciop = $this.customISOOutputPath
        # Try to create the ISO
        Try {
            Start-Process -Wait -NoNewWindow -FilePath $this.oscdimgExePath -ArgumentList "-u2 -udfver102 -t -l$labl -b$esbp $cibd $ciop" -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to create the custom ISO; skipping. Error message is: " + $_))
            $Return = $false
        }
        # Return
        return $Return
    }
    # Move ISO method
    Hidden [Boolean] MoveISO() {
        # Control variable
        [Boolean] $Return = $true
        # Try to move the ISO
        Try {
            Move-Item -Path $this.customISOOutputPath -Destination $this.customISOMovePath -ErrorAction Stop
            Unblock-File -Path $this.customISOMovePath -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add("Failed to move the custom ISO to the Downloads directory; skipping.")
            $Return = $false
        }
        # Return
        return $Return
    }
}

# FUNCTIONS
Function New-OZOWSLPathFromWindowsPath {
    param(
        [Parameter(Mandatory=$true,HelpMessage="The Windows path to convert")][String]$WindowsPath
    )
    # Local variables
    return ($WindowsPath.Replace("\","/")).Replace($Env:SystemDrive,("/mnt/" + ($Env:SystemDrive.Split(":"))[0].ToLower()))
}

# Create a Main object
[OZOADLCIMain]::new($OZOADLabDir) | Out-Null
