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

$ErrorActionPreference = 'Stop'
$LogDir  = 'C:\Logs\MT-DuranBey'
$LogFile = Join-Path $LogDir ("WinOpt_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

if (-not (Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = 'INFO'
    )
    $line = "[{0:yyyy-MM-dd HH:mm:ss}] [{1}] {2}" -f (Get-Date), $Level, $Message
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    switch ($Level) {
        'OK'    { Write-Host $line -ForegroundColor Green }
        'WARN'  { Write-Host $line -ForegroundColor Yellow }
        'ERR'   { Write-Host $line -ForegroundColor Red }
        default { Write-Host $line -ForegroundColor Cyan }
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
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type -Force
}

$Actions = @{
    1 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Klasik Sag Tik Menusunu Geri Getir (Win11)"
        Run      = {
            $p = 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'
            New-Item -Path $p -Force | Out-Null
            Set-ItemProperty -Path $p -Name '(Default)' -Value '' -Force
        }
    }
    2 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Dosya Uzantilarini Goster"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Value 0 }
    }
    3 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Gizli Dosya ve Klasorleri Goster"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1 }
    }
    4 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Bu Bilgisayar Acilisini Ayarla"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'LaunchTo' -Value 1 }
    }
    5 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Gorev Cubugunu Sola Hizala (Win11)"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAl' -Value 0 }
    }
    6 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Arama Kutusunu Gorev Cubugunda Gizle"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'SearchboxTaskbarMode' -Value 0 }
    }
    7 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Gorev Gorunumu (Task View) Dugmesini Gizle"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Value 0 }
    }
    8 = @{
        Category = "Arayuz ve Gorev Cubugu"
        Name     = "Widgets Dugmesini Devre Disi Birak"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarDa' -Value 0 }
    }
    9 = @{
        Category = "Sistem, Guc ve Erisilebilirlik"
        Name     = "Yapisikan Tuslar Kisayolunu Kapat"
        Run      = { Set-RegValue -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Value '506' -Type String }
    }
    10 = @{
        Category = "Sistem, Guc ve Erisilebilirlik"
        Name     = "Hizli Baslatmayi (Fast Startup) Devre Disi Birak"
        Run      = { Set-RegValue -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' -Name 'HiberbootEnabled' -Value 0 }
    }
    11 = @{
        Category = "Uzak Masastusu (RDP) ve Ag"
        Name     = "Uzak Masastusu (RDP) Baglantisini Etkinlestir"
        Run      = {
            Set-RegValue -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
            Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue | Out-Null
        }
    }
    12 = @{
        Category = "Uzak Masastusu (RDP) ve Ag"
        Name     = "NLA (Network Level Authentication) Aktif Et"
        Run      = { Set-RegValue -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 1 }
    }
    13 = @{
        Category = "Gizlilik, Telemetri ve Guncelleme"
        Name     = "Telemetri ve Tanilama Verilerini Azalt"
        Run      = { Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value 0 }
    }
    14 = @{
        Category = "Gizlilik, Telemetri ve Guncelleme"
        Name     = "Reklam Kimligini (Advertising ID) Kapat"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 }
    }
    15 = @{
        Category = "Gizlilik, Telemetri ve Guncelleme"
        Name     = "Otomatik Surucu Guncelleme Politikasini Kontrol Et"
        Run      = { Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' -Name 'ExcludeWUDriversInQualityUpdate' -Value 1 }
    }
    16 = @{
        Category = "Performans ve Temizlik"
        Name     = "Menu Gecikmesini Hizlandir (MenuShowDelay = 100)"
        Run      = { Set-RegValue -Path 'HKCU:\Control Panel\Desktop' -Name 'MenuShowDelay' -Value '100' -Type String }
    }
    17 = @{
        Category = "Performans ve Temizlik"
        Name     = "Uygulama Kapanma Bekleme Suresini Hizlandir"
        Run      = { Set-RegValue -Path 'HKCU:\Control Panel\Desktop' -Name 'WaitToKillAppTimeout' -Value '5000' -Type String }
    }
    18 = @{
        Category = "Performans ve Temizlik"
        Name     = "Son Kullanilan Hizli Erisim Dosyalarini Gizle"
        Run      = { Set-RegValue -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' -Name 'ShowRecent' -Value 0 }
    }
    19 = @{
        Category = "Performans ve Temizlik"
        Name     = "Kilit Ekrani Ipuclarini Kapat"
        Run      = { Set-RegValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' -Name 'DisableSoftLanding' -Value 1 }
    }
    20 = @{
        Category = "Performans ve Temizlik"
        Name     = "Gecici Dosyalari (Temp) Temizle ve Explorer Yenile"
        Run      = {
            Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
            Stop-Process -Name 'explorer' -Force -ErrorAction SilentlyContinue
        }
    }
}

function Show-MenuHeader {
    $hostName = $env:COMPUTERNAME
    $osCaption = (Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
    if (-not $osCaption) { $osCaption = "Windows" }

    Write-Host ""
    Write-Host "+==============================================================================+" -ForegroundColor DarkCyan
    Write-Host "|  MT-DURANBEY  |  WINDOWS 10 / 11 & SERVER CLI AYAR YONETICISI (20 AYAR)    |" -ForegroundColor Green
    Write-Host ("|  Hedef: {0,-22} |  Sistem: {1,-35} |" -f $hostName, $osCaption.Substring(0, [Math]::Min($osCaption.Length, 35))) -ForegroundColor Cyan
    Write-Host "+==============================================================================+" -ForegroundColor DarkCyan
}

function Show-Menu {
    Show-MenuHeader
    $lastCategory = ""
    foreach ($k in ($Actions.Keys | Sort-Object)) {
        $item = $Actions[$k]
        if ($item.Category -ne $lastCategory) {
            Write-Host ""
            Write-Host ("  -- {0} " -f $item.Category).PadRight(78, '-') -ForegroundColor DarkYellow
            $lastCategory = $item.Category
        }
        Write-Host "    [" -NoNewline -ForegroundColor DarkGray
        Write-Host ("{0:D2}" -f $k) -NoNewline -ForegroundColor Yellow
        Write-Host "] " -NoNewline -ForegroundColor DarkGray
        Write-Host $item.Name -ForegroundColor White
    }
    Write-Host ""
    Write-Host "+------------------------------------------------------------------------------+" -ForegroundColor DarkCyan
    Write-Host "  [A] Tum 20 Ayar   |   Secimli: 1,2,10,11   |   Log: C:\Logs\MT-DuranBey   |   [Q] Cikis" -ForegroundColor Magenta
    Write-Host "+------------------------------------------------------------------------------+" -ForegroundColor DarkCyan
}

function Invoke-SelectedActions {
    param([int[]]$TargetIds)
    Write-Host ""
    foreach ($id in ($TargetIds | Sort-Object -Unique)) {
        if (-not $Actions.ContainsKey($id)) {
            Write-Log "Gecersiz ayar numarasi: $id" 'WARN'
            continue
        }
        $item = $Actions[$id]
        try {
            & $item.Run
            Write-Log ("[{0:D2}] {1} -> Tamamlandi" -f $id, $item.Name) 'OK'
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

if ($Ids -and $Ids.Count -gt 0) {
    Invoke-SelectedActions -TargetIds $Ids
    return
}

while ($true) {
    Clear-Host
    Show-Menu
    Write-Host ""
    Write-Host "  Seciminiz" -NoNewline -ForegroundColor Green
    $choice = (Read-Host " ").Trim()

    if ($choice -match '^(q|Q)$') { break }
    if ($choice -match '^(a|A)$') {
        Invoke-SelectedActions -TargetIds (1..20)
        Write-Host ""
        Read-Host "  Devam etmek icin Enter'a basin" | Out-Null
        continue
    }

    $parsed = @()
    foreach ($part in ($choice -split '[,\s]+')) {
        if ($part -match '^\d+$') { $parsed += [int]$part }
    }
    if ($parsed.Count -gt 0) {
        Invoke-SelectedActions -TargetIds $parsed
        Write-Host ""
        Read-Host "  Devam etmek icin Enter'a basin" | Out-Null
    }
}
