<# WSL 2
    [String]$wslResult = (& wsl --distribution "Debian" --user root KICKSTART_PATH="/mnt/c/ozo-ad-lab/Linux/ozo-ad-lab-router-ks.cfg" SOURCE_ISO_PATH="/mnt/c/ozo-ad-lab/ISO/almalinux-boot.iso" TARGET_ISO_PATH="/mnt/c/ozo-ad-lab/ISO/OZO-AD-Lab-Router.iso" TARGET_ISO_LABEL="AlmaLinux-9-5-x86_64-dvd" /mnt/c/ozo-ad-lab/Linux/ozo-create-router-iso.sh)
    If ($wslResult -eq "TRUE") { 
        Unblock-File "C:\ProgramData\Microsoft\Windows\Virtual Hard Disks\OZO-AD-Lab-Router.iso"
    }
#>

Function New-OZOWSLPathFromWindowsPath {
    param(
        [Parameter(Mandatory=$true,HelpMessage="The Windows path to convert")][String]$WindowsPath
    )
    # Local variables
    return ($WindowsPath.Replace("\","/")).Replace($Env:SystemDrive,("/mnt/" + ($Env:SystemDrive.Split(":"))[0].ToLower()))
}
