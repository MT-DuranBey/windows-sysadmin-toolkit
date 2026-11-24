#Requires -RunAsAdministrator
<#
.SYNOPSIS
    MT-DuranBey Windows 10/11 & Server CLI Ayar Yoneticisi (20 Ayar)
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$All,

    [Parameter()]
    [int[]]$Ids
)

$ErrorActionPreference = 'Stop'$LogDir  = 'C:\Logs\MT-DuranBey'
$LogFile = Join-Path$LogDir ("WinOpt_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')$line = "[{0:yyyy-MM-dd HH:mm:ss}] [{1}] {2}" -f (Get-Date), $Level,$Message
    Add-Content -Path $LogFile -Value$line -Encoding UTF8
    switch ($Level) {
        'OK'   { Write-Host $line -ForegroundColor Green }
        'WARN' { Write-Host $line -ForegroundColor Yellow }
        'ERR'  { Write-Host $line -ForegroundColor Red }
        default{ Write-Host $line -ForegroundColor Cyan }
    }
}

function Set-RegValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [Microsoft.Win32.RegistryValueKind]$Type = [Microsoft.Win32.RegistryValueKind]::DWord
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    Set-ItemProperty -Path $Path -Name$Name -Value $Value -Type$Type -Force
}

$Actions = @{
    1 = @{
        Name = "Klasik Sag Tik Menusunu Geri Getir (Win11)"
        Run  = {
            $p = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
            New-Item -Path $p -Force | Out-Null
            Set-ItemProperty -Path $p -Name '(Default)' -Value '' -Force
        }
    }
    2 = @{
        Name = "Dosya Uzantilarini Goster"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 }
    }
    3 = @{
        Name = "Gizli Dosya ve Klasorleri Goster"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1 }
    }
    4 = @{
        Name = "Bu Bilgisayar Acilisini Ayarla"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Value 1 }
    }
    5 = @{
        Name = "Gorev Cubugunu Sola Hizala (Win11)"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Value 0 }
    }
    6 = @{
        Name = "Arama Kutusunu Gorev Cubugunda Gizle"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'SearchboxTaskbarMode' -Value 0 }
    }
    7 = @{
        Name = "Gorev Gorunumu (Task View) Dugmesini Gizle"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0 }
    }
    8 = @{
        Name = "Widgets Dugmesini Devre Disi Birak"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0 }
    }
    9 = @{
        Name = "Yapisikan Tuslar Kisayolunu Kapat"
        Run  = { Set-RegValue -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '506' -Type String }
    }
    10 = @{
        Name = "Hizli Baslatmayi (Fast Startup) Devre Disi Birak"
        Run  = { Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 }
    }
    11 = @{
        Name = "Uzak Masastusu (RDP) Baglantisini Etkinlestir"
        Run  = {
            Set-RegValue -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
            Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue | Out-Null
        }
    }
    12 = @{
        Name = "NLA (Network Level Authentication) Aktif Et"
        Run  = { Set-RegValue -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1 }
    }
    13 = @{
        Name = "Telemetri ve Tanilama Verilerini Azalt"
        Run  = { Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 }
    }
    14 = @{
        Name = "Reklam Kimligini (Advertising ID) Kapat"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 }
    }
    15 = @{
        Name = "Otomatik Surucu Guncelleme Politikasini Kontrol Et"
        Run  = { Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' -Value 1 }
    }
    16 = @{
        Name = "Menu Gecikmesini Hizlandir (MenuShowDelay = 100)"
        Run  = { Set-RegValue -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '100' -Type String }
    }
    17 = @{
        Name = "Uygulama Kapanma Bekleme Suresini Hizlandir"
        Run  = { Set-RegValue -Path 'HKCU:\Control Panel\Desktop' -Name 'WaitToKillAppTimeout' -Value '5000' -Type String }
    }
    18 = @{
        Name = "Son Kullanilan Hizli Erisim Dosyalarini Gizle"
        Run  = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowRecent' -Value 0 }
    }
    19 = @{
        Name = "Kilit Ekrani Ipuclarini Kapat"
        Run  = { Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableSoftLanding' -Value 1 }
    }
    20 = @{
        Name = "Gecici Dosyalari (Temp) Temizle ve Explorer Yenile"
        Run  = {
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Stop-Process -Name 'explorer' -Force -ErrorAction SilentlyContinue
        }
    }
}

function Invoke-SelectedActions {
    param([int[]]$TargetIds)
    foreach ($id in ($TargetIds | Sort-Object -Unique)) {
        if (-not $Actions.ContainsKey($id)) {
            Write-Log "Gecersiz ayar numarasi: $id" 'WARN'
            continue
        }
        $item = $Actions[$id]
        try {
            & $item.Run
            Write-Log ("[{0:D2}] {1} -> Tamamlandi" -f $id,$item.Name) 'OK'
        }
        catch {
            Write-Log ("[{0:D2}] {1} -> Hata: {2}" -f $id, $item.Name, $_.Exception.Message) 'ERR'
        }
    }
    Write-Log "Log dosyasi: $LogFile" 'INFO'
}

if ($All) {
    Invoke-SelectedActions -TargetIds (1..20)
    return
}

if ($Ids -and$Ids.Count -gt 0) {
    Invoke-SelectedActions -TargetIds $Ids
    return
}

while ($true) {
    Clear-Host
    Write-Host "==================================================================" -ForegroundColor Green
    Write-Host "   MT-DURANBEY | WINDOWS 10/11 CLI AYAR YONETICISI (20 AYAR)" -ForegroundColor Green
    Write-Host "==================================================================" -ForegroundColor Green
    foreach ($k in ($Actions.Keys | Sort-Object)) {
        Write-Host ("  [{0:D2}] {1}" -f $k, $Actions[$k].Name)
    }
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  [A] Tum 20 Ayari Uygula   |   Ornek Secim: 1,2,10,11   |   [Q] Cikis" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    $choice = (Read-Host "Seciminiz").Trim()

    if ($choice -match '^(q\vert{}Q)$') { break }
    if
