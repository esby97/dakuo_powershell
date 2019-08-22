<#
.SYNOPSIS
   Change Lock Screen and Desktop Background in Windows 10 Pro.
.DESCRIPTION
   This script allows you to change logon screen and desktop background in Windows 10 Professional using GPO startup script.
.PARAMETER LockScreenSource (Optional)
   Path to the Lock Screen image to copy locally in computer.
    Example: "\\SERVER-FS01\LockScreen.jpg"
.PARAMETER BackgroundSource (Optional)
   Path to the Desktop Background image to copy locally in computer.
    Example: "\\SERVER-FS01\BackgroundScreen.jpg"
.PARAMETER LogPath (Optional)
    Path where save log file. If it's not specified no log is recorded.
.EXAMPLE
    Set Lock Screen and Desktop Wallpaper with logs:
    Set-Screen -LockScreenSource "\\SERVER-FS01\LockScreen.jpg" -BackgroundSource "\\SERVER-FS01\BackgroundScreen.jpg" -LogPath "\\SERVER-FS01\Logs"
.EXAMPLE
    Set Lock Screen and Desktop Wallpaper without logs:
    Set-Screen -LockScreenSource "\\SERVER-FS01\LockScreen.jpg" -BackgroundSource "\\SERVER-FS01\BackgroundScreen.jpg"
.EXAMPLE
    Set Lock Screen only:
    Set-Screen -LockScreenSource "\\SERVER-FS01\LockScreen.jpg" -LogPath "\\SERVER-FS01\Logs"
.EXAMPLE
   Set Desktop Wallpaper only:
    Set-Screen -BackgroundSource "\\SERVER-FS01\BackgroundScreen.jpg" -LogPath "\\SERVER-FS01\Logs"
.NOTES 
   Author: Juan Granados 
   Date:   September 2018
#>

$url = "http://pds21.egloos.com/pds/201104/07/37/c0001937_4d9dc561e2556.jpg"
$url2 = "http://img2.ruliweb.com/img/img_link7/282/281369_4.jpg"

function back([string]$desktopImage)
{
    set-itemproperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value $desktopImage
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
}

$webclient = New-Object System.Net.WebClient


$file_name= "\test1.jpg"
$file_path = "$env:TEMP$file_name"
$webclient.DownloadFile($url, $file_path);
$file_name= "\test2.jpg"
$file_path = "$env:TEMP$file_name"
$webclient.DownloadFile($url2, $file_path);

for ($i = 0; $i -lt 50; $i++) 
{

$file_path = "C:\Users\PSJ\Desktop\aaa.jpg"
back($file_path); 
}





if (-not [string]::IsNullOrWhiteSpace($LogPath)) {
    Start-Transcript -Path "$($LogPath)\$($env:COMPUTERNAME).log" | Out-Null
}

$ErrorActionPreference = "Stop"

$RegKeyPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

$DesktopPath = "DesktopImagePath"
$DesktopStatus = "DesktopImageStatus"
$DesktopUrl = "DesktopImageUrl"
$LockScreenPath = "LockScreenImagePath"
$LockScreenStatus = "LockScreenImageStatus"
$LockScreenUrl = "LockScreenImageUrl"

$StatusValue = "1"
$file_name = "\test2.jpg"
$path = $env:TEMP+$file_name
#$path = "C:\Users\PSJ\Desktop\aaa.jpg"
$DesktopImageValue = $env:TEMP + "\Desktop.jpg"
$LockScreenImageValue = $env:TEMP + "\LockScreen.jpg"
#$DesktopImageValue = "C:\Windows\System32\Desktop.jpg"
#$LockScreenImageValue = "C:\Windows\System32\LockScreen.jpg"
$LockScreenSource = $path
#$BackgroundSource = $path

if (!$LockScreenSource -and !$BackgroundSource) 
{
    Write-Host "Either LockScreenSource or BackgroundSource must has a value."
}
else 
{
    if(!(Test-Path $RegKeyPath)) {
        Write-Host "Creating registry path $($RegKeyPath)."
        New-Item -Path $RegKeyPath -Force | Out-Null
    }
    if ($LockScreenSource) {
        Write-Host "Copy Lock Screen image from $($LockScreenSource) to $($LockScreenImageValue)."
        Copy-Item $LockScreenSource $LockScreenImageValue -Force
        Write-Host "Creating registry entries for Lock Screen"
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenPath -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $LockScreenUrl -Value $LockScreenImageValue -PropertyType STRING -Force | Out-Null
    }
    if ($BackgroundSource) {
        Write-Host "Copy Desktop Background image from $($BackgroundSource) to $($DesktopImageValue)."
        Copy-Item $BackgroundSource $DesktopImageValue -Force
        Write-Host "Creating registry entries for Desktop Background"
        New-ItemProperty -Path $RegKeyPath -Name $DesktopStatus -Value $StatusValue -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $DesktopPath -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
        New-ItemProperty -Path $RegKeyPath -Name $DesktopUrl -Value $DesktopImageValue -PropertyType STRING -Force | Out-Null
    }  
}