Invoke-WebRequest -Uri https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Container/x86_64/images/Fedora-Container-Base-33-1.2.x86_64.tar.xz -OutFile Fedora-Container-Base-33-1.2.x86_64.tar.xz
xz --decompress --force .\Fedora-Container-Base-33-1.2.x86_64.tar.xz
tar tf .\Fedora-Container-Base-33-1.2.x86_64.tar | Where-Object { $_ -Like "*/layer.tar" } | ForEach-Object { tar xf .\Fedora-Container-Base-33-1.2.x86_64.tar --strip-components=1 "$_" }

wsl --import Fedora-33 C:\WSL\Fedora-33 layer.tar
wsl -d Fedora-33 -e dnf -y update
wsl -d Fedora-33 -e dnf -y install sudo passwd

wsl -d Fedora-33 -e bash -c "echo UNIX Username: ; read unixusername ; useradd -G wheel `$unixusername ; passwd `$unixusername"

Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq Fedora-33  | Set-ItemProperty -Name DefaultUid -Value 1000