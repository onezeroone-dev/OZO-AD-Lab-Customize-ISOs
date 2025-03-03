[String] $ozoADLabDirectory   = (Join-Path -Path $Env:SystemDrive -ChildPath "ozo-ad-lab")
[String] $customBuildDir      = (Join-Path -Path $ozoADLabDirectory -ChildPath "Builds\Client")
[String] $oscdimgExePath      = (Join-Path -Path ${Env:ProgramFiles(x86)} -ChildPath "Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Oscdimg\oscdimg.exe")
[String] $efisysBinPath       = (Join-Path -Path $customBuildDir -ChildPath "efi\microsoft\boot\efisys.bin")
[String] $customISOOutputPath = (Join-Path -Path $ozoADLabDirectory -ChildPath "ISO\OZO-AD-Lab-Client.iso")
Start-Process -Wait -NoNewWindow -FilePath $oscdimgExePath -ArgumentList "-u2 -udfver102 -t -lAD-Lab-Client -b$efisysBinPath $customBuildDir $customISOOutputPath"
