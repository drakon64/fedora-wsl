Param (
	[String] $Distribution = "Fedora-33",
	[System.IO.DirectoryInfo] $Path = "C:\WSL\"
)

Invoke-WebRequest -Uri https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Container/x86_64/images/Fedora-Container-Base-33-1.2.x86_64.tar.xz -OutFile Fedora-Container-Base-33-1.2.x86_64.tar.xz
xz --decompress --force .\Fedora-Container-Base-33-1.2.x86_64.tar.xz
tar tf .\Fedora-Container-Base-33-1.2.x86_64.tar | Where-Object { $_ -Like "*/layer.tar" } | ForEach-Object { tar xf .\Fedora-Container-Base-33-1.2.x86_64.tar --strip-components=1 "$_" }

If (!(Test-Path -Path "$Path"\"$Distribution" -PathType Container)) {
	New-Item -Path "$Path"\"$Distribution" -ItemType Directory
}

wsl --import "$Distribution" "$Path"\"$Distribution" layer.tar
wsl -d "$Distribution" -e sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates.repo
wsl -d "$Distribution" -e sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
wsl -d "$Distribution" -e dnf -y install sudo passwd cracklib-dicts 'dnf-command(config-manager)'
wsl -d "$Distribution" -e dnf config-manager --set-enabled updates --save
wsl -d "$Distribution" -e dnf config-manager --set-enabled updates-modular --save

wsl -d "$Distribution" -e bash -c "printf 'UNIX Username: ' ; read unixusername ; useradd -G wheel `$unixusername ; passwd `$unixusername"

Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq "$Distribution"  | Set-ItemProperty -Name DefaultUid -Value 1000