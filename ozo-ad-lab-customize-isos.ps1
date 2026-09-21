#Requires -Modules @{ModuleName="OZO";ModuleVersion="1.5.1"},OZOLogger -Version 5.1

<#PSScriptInfo
    .VERSION 1.0.0
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
    Customizes Microsoft installer ISOs for user with the One Zero One AD Lab.
    .PARAMETER OZOADLabDir
    Location of the "ozo-ad-lab" directory. Defaults to $Env:SystemDrive\ozo-ad-lab.
    .LINK
    https://github.com/onezeroone-dev/OZO-AD-Lab-Customize-ISOs/blob/main/README.md
#>

# PARAMETERS
[CmdletBinding(SupportsShouldProcess = $true)] Param(
    [Parameter(Mandatory=$false,HelpMessage="Path to the OZO AD Lab directory")][String]$OZOADLabDir = (Join-Path -Path $Env:SystemDrive -ChildPath "ozo-ad-lab")
)

# CLASSES
Class Main {
    # PROPERTIES: Strings
    [String] $downloadsDirectory = $null
    [String] $ozoADLabDirectory  = $null
    # PROPERTIES: PSCustomObjects
    [PSCustomObject] $ozoLogger = $null
    # PROPERTIES: PSCustomObject Lists
    [System.Collections.Generic.List[PSCustomObject]] $ozoISOs = @()
    # METHODS: Constructor method
    Main($OZOADLabDir) {
        # Set properties
        $this.downloadsDirectory = (Join-Path -Path $Env:USERPROFILE -ChildPath "Downloads")
        $this.ozoADLabDirectory  = $OZOADLabDir
        # Create a ozoLogger object
        $this.ozoLogger = (New-OZOLogger)
        # Log a process start message
        $this.ozoLogger.Write("Process starting.","Information")
        # Process the client ISO
        $this.ozoISOs.Add(([OzoISO]::new(
            "OZO-AD-Lab-Client",                                                                                # CustomISOLabel
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "Builds\Client"),                              # CustomISOBUildDir
            (Join-Path -Path $this.downloadsDirectory -ChildPath "OZO-AD-Lab-Client.iso"),                      # CustomISOMovePath
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "Mount"),                                      # CustomISOMountDir
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "ISO\OZO-AD-Lab-Client.iso"),                  # CustomISOOutputPath
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "WIM\Windows Client"),                         # CustomWIMDir
            1,                                                                                                  # SourceIndex
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\microsoft-windows-client-evaluation.iso")  # SourceISOPath
        )))
        # Process the server ISO
        $this.ozoISOs.Add(([OzoISO]::new(
            "OZO-AD-Lab-Server",                                                                                # CustomISOLabel
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "Builds\Server"),                              # CustomISOBuildDir
            (Join-Path -Path $this.downloadsDirectory -ChildPath "OZO-AD-Lab-Server.iso"),                      # CustomISOMovePath
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "Mount"),                                      # CustomISOMountDir
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "ISO\OZO-AD-Lab-Server.iso"),                  # CustomISOOutputPath
            (Join-Path -Path $this.ozoADLabDirectory  -ChildPath "WIM\Windows Server"),                         # CustomWIMDir
            2,                                                                                                  # SourceIndex
            (Join-Path -Path $this.ozoADLabDirectory -ChildPath "ISO\microsoft-windows-server-evaluation.iso")  # SourceISOPath
        )))
        # Iterate over ISOs
        ForEach ($ozoISO in $this.ozoISOs) {
            # Log the results for the current ISO
            $this.ozoLogger.Write(($ozoISO.CustomIsoLabel + " results: " + ($ozoISO.Messages -Join(";"))),"Information")
        }
        # Log a process end message
        $this.ozoLogger.Write("Process complete.","Information")
    }
}

Class OzoISO {
    # PROPERTIES: Booleans
    [Boolean] $Proceed = $true
    [Boolean] $Validates = $true
    # PROPERTIES: Int16s
    [Int16] $sourceIndex = $null
    # PROPERTIES: Strings
    [String]  $customISOLabel      = $null
    [String]  $mountDrive          = $null
    # PROPERTIES: Lists
    [System.Collections.Generic.List[String]] $Messages = @()
    # METHODS: Constructor method
    OzoISO($CustomISOLabel,$CustomISOBuildDir,$CustomISOMovePath,$CustomISOMountDir,$CustomISOOutputPath,$CustomWIMDir,$SourceIndex,$SourceISOPath) {
        # Set properties
        $this.customISOLabel = $CustomISOLabel
        # Local variables
        [String] $OscdImgExePath = (Join-Path -Path ${Env:ProgramFiles(x86)} -ChildPath "Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe")
        # Determine if ISO validates
        If ($this.ValidateISO($CustomISOBuildDir,$CustomISOMovePath,$CustomISOOutputPath,$OscdImgExePath,$SourceISOPath) -eq $true) {
            # ISO validates; mount the source ISO
            If ($this.MountISO($SourceISOPath) -eq $true) {
                # Source ISO mount; copy the contents to the build directory
                If ($this.CopyISO((Join-Path -Path $this.mountDrive -ChildPath "*"),$CustomISOBuildDir) -eq $true) {
                    # Contents copied; dismount the ISO
                    If ($this.DismountISO($SourceISOPath) -eq $true) {
                        # ISO dismounted; move the install WIM
                        If ($this.MoveWIM((Join-Path -Path $CustomISOBuildDir -ChildPath "sources\install.wim"),$CustomWIMDir) -eq $true) {
                            # Moved WIM; export the desired Index back to the build directory
                            If ($this.ExportImage((Join-Path -Path $CustomWIMDir -ChildPath "install.wim"),$SourceIndex,(Join-Path -Path $CustomISOBuildDir -ChildPath "sources\install.wim")) -eq $true) {
                                # Create the Windows ISO
                                If ($this.CreateISO($CustomISOLabel,$CustomISOBuildDir,$CustomISOOutputPath,$OscdImgExePath) -eq $true) {
                                    # Move the ISO
                                    If ($this.MoveISO($CustomISOOutputPath,$CustomISOMovePath) -eq $true) {
                                        # Moved ISO; report success
                                        $this.Messages.Add("Success")
                                    }
                                }
                            }
                        }
                    }
                } Else {
                    # Contents not copied; dismount the ISO
                    $this.DismountISO($SourceISOPath)
                }
            }
        }
    }
    # METHODS: Validate ISO method
    Hidden [Boolean] ValidateISO($CustomISOBuildDir,$CustomISOMovePath,$CustomISOOutputPath,$OscdImgExePath,$SourceISOPath) {
        # Control variable
        [Boolean] $Return = $true
        # Determine if oscdimg.exe is not present
        If ((Test-Path -Path $OscdImgExePath) -eq $false) {
            # Did not find oscdimg.exe; report
            $this.Messages.Add(($OscdImgExePath + " not found. Please see https://onezeroone.dev/active-directory-lab-part-ii-customization-prerequisites/ for more information"))
            $Return = $false
        }
        # Determine if the custom ISO already exists in Downloads directory
        If ((Test-Path -Path $CustomISOMovePath) -eq $true) {
            # Custom ISO exists in the Downloads directory
            $this.Messages.Add(($CustomISOMovePath + " exists"))
            $Return = $false
        }
        # Determine if the custom ISO already exists in the OZO AD Lab directory
        If ((Test-Path -Path $CustomISOOutputPath) -eq $true) {
            # Custom ISO exists in the OZO AD Lab directory
            $this.Messages.Add(($CustomISOOutputPath + " exists"))
            $Return = $false
        }
        # Determine if the source ISO does not exist
        If ((Test-Path -Path $SourceISOPath) -eq $false) {
            # Source ISO does not exist
            $this.Messages.Add(($SourceISOPath + " does not exist"))
            $Return = $false
        }
        # Determine that the build directory exists
        If ((Test-Path -Path $CustomISOBuildDir) -eq $false) {
            $this.Messages.Add(($CustomISOBuildDir + " does not exist"))
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Mount ISO method
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
            $this.Messages.Add(("Failed to mount " + $ISOPath))
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Copy ISO method
    Hidden [Boolean] CopyISO($SourcePath,$TargetPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to
        Try {
            Copy-Item -Force -Recurse -Path $SourcePath -Destination $TargetPath -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add("Failed to copy source ISO")
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Move WIM method
    Hidden [Boolean] MoveWIM($SourcePath,$TargetPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to move the WIM
        Try {
            Move-Item -Force -Path $SourcePath -Destination $TargetPath -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to move " + $SourcePath + " to " + $TargetPath))
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Dismount ISO method
    Hidden [Boolean] DismountISO($ISOPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to dismount the ISO
        Try {
            Dismount-DiskImage -ImagePath $ISOPath -ErrorAction Stop
            # Success; 
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to dismount " + $ISOPath))
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Export Image method
    Hidden [Boolean] ExportImage($ImagePath,$ImageIndex,$ExportedWIMPath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to export the index
        Try {
            Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $ImageIndex -DestinationImagePath $ExportedWIMPath -ErrorAction Stop
            # Success; 
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to export Index " + $ImageIndex.ToString() + " from " + $ImagePath))
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Create Windows ISO method
    Hidden [Boolean] CreateISO($CustomISOLabel,$CustomISOBuildDir,$CustomISOOutputPath,$OscdImgExePath) {
        # Control variable
        [Boolean] $Return = $true
        # Local variables
        [String] $labl = $CustomISOLabel
        [String] $esbp = (Join-Path -Path $CustomISOBuildDir -ChildPath "efi\microsoft\boot\efisys.bin")
        [String] $cibd = $CustomISOBuildDir
        [String] $ciop = $CustomISOOutputPath
        # Try to create the ISO
        Try {
            Start-Process -Wait -NoNewWindow -FilePath $OscdimgExePath -ArgumentList "-u2 -udfver102 -t -l$labl -b$esbp $cibd $ciop" -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to create the custom ISO with error " + $_))
            $Return = $false
        }
        # Return
        return $Return
    }
    # METHODS: Move ISO method
    Hidden [Boolean] MoveISO($CustomISOOutputPath,$CustomISOMovePath) {
        # Control variable
        [Boolean] $Return = $true
        # Try to move the ISO
        Try {
            Move-Item -Path $CustomISOOutputPath -Destination $CustomISOMovePath -ErrorAction Stop
            Unblock-File -Path $CustomISOMovePath -ErrorAction Stop
            # Success
        } Catch {
            # Failure
            $this.Messages.Add(("Failed to move the custom ISO from " + $CustomISOOutputPath + " to " + $CustomISOMovePath))
            $Return = $false
        }
        # Return
        return $Return
    }
}

# Create a Main object
[Main]::new($OZOADLabDir) | Out-Null
