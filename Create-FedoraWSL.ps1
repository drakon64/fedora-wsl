<#
.SYNOPSIS
A script to port Fedora 35 to WSL
.DESCRIPTION
A simple PowerShell script to port Fedora 35 to WSL
.PARAMETER Distribution
What the distro will be called in WSL, by default it will be called Fedora-35
.PARAMETER Path
The Path where the distribution will be installed, by default it will be C:\WSL
.PARAMETER SetDefault
A parameter to toggle whether it will be set to the default WSL distro
.PARAMETER Wslu
Install the wslu package for Windows integration
#>

Param (
	[String] $Distribution = "Fedora-35",
	[System.IO.DirectoryInfo] $Path = "C:\WSL\",
	[Switch] $SetDefault,
	[Switch] $Wslu
)

Invoke-WebRequest -Uri https://dl.fedoraproject.org/pub/fedora/linux/releases/35/Container/x86_64/images/Fedora-Container-Base-35-1.2.x86_64.tar.xz -OutFile Fedora-Container-Base-35-1.2.x86_64.tar.xz

If (Get-Command -Name xz -CommandType Application) {
	xz --decompress --force .\Fedora-Container-Base-35-1.2.x86_64.tar.xz
}
Else {
	$XzZip = New-TemporaryFile
	Invoke-WebRequest -Uri https://tukaani.org/xz/xz-5.2.5-windows.zip -OutFile $XzZip

	Add-Type -AssemblyName System.IO.Compression.FileSystem
	$XzZipFile = [System.IO.Compression.ZipFile]::OpenRead($XzZip)

	$Xz = New-TemporaryFile
	[System.IO.Compression.ZipFileExtensions]::ExtractToFile($XzZipFile.GetEntry("bin_x86-64/xz.exe"), $Xz, $True)
	$XzZipFile.Dispose()

	Start-Process -FilePath $Xz -ArgumentList "--decompress --force .\Fedora-Container-Base-35-1.2.x86_64.tar.xz" -NoNewWindow -Wait
	$XzZip, $Xz | Remove-Item
}
tar tf .\Fedora-Container-Base-35-1.2.x86_64.tar | Where-Object { $_ -Like "*/layer.tar" } | ForEach-Object { tar xf .\Fedora-Container-Base-35-1.2.x86_64.tar --strip-components=1 "$_" }

[String] $Path = $Path.FullName + $Distribution
If (!(Test-Path -Path "$Path" -PathType Container)) {
	New-Item -Path "$Path" -ItemType Directory
}

wsl --import "$Distribution" "$Path" layer.tar
wsl --distribution "$Distribution" --exec mv /etc/yum.repos.d/fedora.repo /etc/yum.repos.d/fedora.repo.rpmsave
wsl --distribution "$Distribution" --exec dnf -y remove fedora-logos fedora-release fedora-release-notes
wsl --distribution "$Distribution" --exec mv /etc/yum.repos.d/fedora.repo.rpmsave /etc/yum.repos.d/fedora.repo
wsl --distribution "$Distribution" --exec dnf -y --releasever 35 install shadow-utils passwd cracklib-dicts sudo generic-logos generic-release generic-release-notes
If ($Wslu) {
	wsl --distribution "$Distribution" --exec dnf -y copr enable wslutilities/wslu fedora-35-x86_64
	wsl --distribution "$Distribution" --exec dnf -y install wslu
}

wsl --distribution "$Distribution" --exec bash -c "printf 'UNIX Username: ' && read unixusername && useradd -G wheel `$unixusername && passwd `$unixusername"

Get-ItemProperty Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Lxss\*\ DistributionName | Where-Object -Property DistributionName -eq "$Distribution" | Set-ItemProperty -Name DefaultUid -Value 1000

If ($SetDefault) {
	wsl --set-default "$Distribution"
}