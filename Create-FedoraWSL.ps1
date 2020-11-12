Param (
	[String] $Distribution = "Fedora-33",
	[System.IO.DirectoryInfo] $Path = "C:\WSL\"
)

Invoke-WebRequest -Uri https://dl.fedoraproject.org/pub/fedora/linux/releases/33/Container/x86_64/images/Fedora-Container-Base-33-1.2.x86_64.tar.xz -OutFile Fedora-Container-Base-33-1.2.x86_64.tar.xz
xz --decompress --force .\Fedora-Container-Base-33-1.2.x86_64.tar.xz
tar tf .\Fedora-Container-Base-33-1.2.x86_64.tar | Where-Object { $_ -Like "*/layer.tar" } | ForEach-Object { tar xf .\Fedora-Container-Base-33-1.2.x86_64.tar --strip-components=1 "$_" }

[String] $Path = $Path.FullName + $Distribution
If (!(Test-Path -Path "$Path" -PathType Container)) {
	New-Item -Path "$Path" -ItemType Directory
}

wsl --import "$Distribution" "$Path" layer.tar
wsl --distribution "$Distribution" --exec sed --in-place 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates.repo
wsl --distribution "$Distribution" --exec sed --in-place 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
wsl --distribution "$Distribution" --exec dnf -y install sudo passwd cracklib-dicts 'dnf-command(config-manager)'
wsl --distribution "$Distribution" --exec dnf config-manager --set-enabled updates --save
wsl --distribution "$Distribution" --exec dnf config-manager --set-enabled updates-modular --save

wsl --distribution "$Distribution" --exec bash -c "printf 'UNIX Username: ' ; read unixusername ; useradd -G wheel `$unixusername ; passwd `$unixusername"

Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq "$Distribution"  | Set-ItemProperty -Name DefaultUid -Value 1000