<#
.SYNOPSIS
Downloads Manrope (OTF) and Plus Jakarta Sans (TTF) files required by pubspec.yaml.

.DESCRIPTION
Run once after cloning: .\scripts\download_fonts.ps1
#>

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$ProgressPreference = "SilentlyContinue"

$FontDir = "assets\fonts"
New-Item -Path $FontDir -ItemType Directory -Force | Out-Null

Write-Host "Downloading Manrope…"
$ManropeBase = "https://github.com/davelab6/manrope/raw/master/web%20font"
Invoke-WebRequest -Uri "$ManropeBase/manrope-regular.otf"  -OutFile "$FontDir\manrope-regular.otf"
Invoke-WebRequest -Uri "$ManropeBase/manrope-semibold.otf" -OutFile "$FontDir\manrope-semibold.otf"
Invoke-WebRequest -Uri "$ManropeBase/manrope-bold.otf"     -OutFile "$FontDir\manrope-bold.otf"

Write-Host "Downloading Plus Jakarta Sans…"
$JakartaBase = "https://github.com/tokotype/PlusJakartaSans/raw/master/fonts/ttf"
Invoke-WebRequest -Uri "$JakartaBase/PlusJakartaSans-Regular.ttf"  -OutFile "$FontDir\PlusJakartaSans-Regular.ttf"
Invoke-WebRequest -Uri "$JakartaBase/PlusJakartaSans-Medium.ttf"   -OutFile "$FontDir\PlusJakartaSans-Medium.ttf"
Invoke-WebRequest -Uri "$JakartaBase/PlusJakartaSans-SemiBold.ttf" -OutFile "$FontDir\PlusJakartaSans-SemiBold.ttf"

Write-Host "✅ All fonts downloaded to $FontDir"