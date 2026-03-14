<#
.SYNOPSIS
    WIN-STRIP: Base OS Optimization Utility.
.DESCRIPTION
    Strips away Windows Defender and Auto-Update services for a leaner, manual environment.
    PREREQUISITE: Tamper Protection must be manually disabled in Windows Settings.
#>

function Show-Banner {
    $G  = [char]27 + "[1;32m"
    $W  = [char]27 + "[1;37m"
    $NC = [char]27 + "[0m"

    Clear-Host
    Write-Host ""
    Write-Host "$G ██╗    ██╗██╗███╗   ██╗     $W ███████╗████████╗██████╗ ██╗██████╗ $NC"
    Write-Host "$G ██║    ██║██║████╗  ██║     $W ██╔════╝╚══██╔══╝██╔══██╗██║██╔══██╗$NC"
    Write-Host "$G ██║ █╗ ██║██║██╔██╗ ██║     $W ███████╗   ██║   ██████╔╝██║██████╔╝$NC"
    Write-Host "$G ██║███╗██║██║██║╚██╗██║     $W ╚════██║   ██║   ██╔══██╗██║██╔═══╝ $NC"
    Write-Host "$G ╚███╔███╔╝██║██║ ╚████║     $W ███████║   ██║   ██║  ██║██║██║     $NC"
    Write-Host "$G  ╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝     $W ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝     $NC"
    Write-Host ""
    Write-Host "             >> BASE OS OPTIMIZATION & STRIPPING <<              " -ForegroundColor Cyan
    Write-Host "                DEFENDER & UPDATE BYPASS UTILITY                 " -ForegroundColor Gray
    Write-Host ""
    Write-Host "                                         by @PiyushBhardwaj" -ForegroundColor DarkGray
    Write-Host "https://github.com/bhardwaj-23" -ForegroundColor DarkGray
    Write-Host ""
}

# --- Check for Administrator privileges ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "CRITICAL: This script MUST be run as Administrator!"
    Exit
}

# Display the banner
Show-Banner

Write-Host "[!] ACTION REQUIRED: Disable Tamper Protection in Settings first." -ForegroundColor Red
Write-Host "[*] Initiating WIN-STRIP protocols..." -ForegroundColor Green

# -------------------------------------------------------------------------
# Part 1: Strip Windows Defender
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[+] Stripping Windows Defender Registry..." -ForegroundColor Yellow

$defenderBase = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
$subKeys = @("", "Real-Time Protection", "Signature Update", "Spynet")

foreach ($key in $subKeys) {
    $path = if ($key) { Join-Path $defenderBase $key } else { $defenderBase }
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
}

$defenderValues = @(
    @{ Path = $defenderBase; Name = "DisableAntiSpyware"; Value = 1 },
    @{ Path = $defenderBase; Name = "DisableAntiVirus"; Value = 1 },
    @{ Path = $defenderBase; Name = "DisableSpecialRunningModes"; Value = 1 },
    @{ Path = $defenderBase; Name = "DisableRoutinelyTakingAction"; Value = 1 },
    @{ Path = $defenderBase; Name = "ServiceKeepAlive"; Value = 1 },
    @{ Path = "$defenderBase\Real-Time Protection"; Name = "DisableBehaviorMonitoring"; Value = 1 },
    @{ Path = "$defenderBase\Real-Time Protection"; Name = "DisableOnAccessProtection"; Value = 1 },
    @{ Path = "$defenderBase\Real-Time Protection"; Name = "DisableRealtimeMonitoring"; Value = 1 },
    @{ Path = "$defenderBase\Real-Time Protection"; Name = "DisableScanOnRealtimeEnable"; Value = 1 },
    @{ Path = "$defenderBase\Signature Update"; Name = "ForceUpdateFromMU"; Value = 1 },
    @{ Path = "$defenderBase\Spynet"; Name = "DisableBlockAtFirstSeen"; Value = 1 }
)

foreach ($item in $defenderValues) {
    try {
        New-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -PropertyType DWORD -Force -ErrorAction Stop | Out-Null
        Write-Host "    [OK] $($item.Name)" -ForegroundColor Green
    } catch {
        Write-Host "    [FAILED] $($item.Name). Check Tamper Protection." -ForegroundColor Red
    }
}

# -------------------------------------------------------------------------
# Part 2: Strip Windows Update
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[+] Stripping Windows Update Services..." -ForegroundColor Yellow

$auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
if (!(Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
New-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 1 -PropertyType DWORD -Force | Out-Null

Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Set-Service -Name "wuauserv" -StartupType Disabled

# Kill service recovery
& sc.exe failure wuauserv reset= 999 actions= "" | Out-Null
Write-Host "    [OK] Update Service Disabled & Locked." -ForegroundColor Green

# -------------------------------------------------------------------------
# Part 3: Task Scheduler Cleanup
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[+] Disabling Update Scheduled Tasks..." -ForegroundColor Yellow
$taskPath = "\Microsoft\Windows\WindowsUpdate\"
Get-ScheduledTask -TaskPath $taskPath -ErrorAction SilentlyContinue | ForEach-Object {
    Disable-ScheduledTask -TaskName $_.TaskName -TaskPath $taskPath -ErrorAction SilentlyContinue | Out-Null
    Write-Host "    [-] Task Disabled: $($_.TaskName)" -ForegroundColor Gray
}

# -------------------------------------------------------------------------
# Part 4: Refresh
# -------------------------------------------------------------------------
Write-Host ""
Write-Host "[*] Refreshing Environment..." -ForegroundColor Cyan
Stop-Process -Name explorer -Force

Write-Host ""
Write-Host "[COMPLETED] WIN-STRIP has successfully minimized your OS." -ForegroundColor Green
Write-Host "[!] RESTART SYSTEM TO FINALIZE." -ForegroundColor Yellow
