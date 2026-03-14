# WIN-STRIP: Lab Provisioning & OS Optimization Utility

**WIN-STRIP** is an advanced, automated PowerShell utility designed for cybersecurity professionals, power users, and system administrators. Its primary purpose is to rapidly provision bare-metal or virtual machine (VM) environments for private cybersecurity practice labs.

By administratively overriding default security protocols, WIN-STRIP permanently disables the Windows Defender suite and locks down Windows Auto-Update services. This prevents unexpected patching and antivirus interventions, creating a static, unfettered environment ideal for vulnerability testing and malware analysis.

## Key Features

* **Security Stripping:** Automatically injects policy overrides into the registry to disable AntiSpyware, Real-Time Monitoring, Behavior Monitoring, and Spynet reporting.
* **Update Lockdown:** Disables the `wuauserv` service, nullifies service recovery actions, and forcefully clears all Update-related Scheduled Tasks to prevent background patching.
* **Remote Execution Ready:** Structured for rapid deployment across multiple machines. It can be executed directly in-memory via the .NET WebClient, bypassing local execution policies.
* **Terminal Native:** Features a custom ANSI-colored 3D block-art banner optimized for modern Windows Terminal environments providing clear, structured visual feedback during execution.

> **⚠️ WARNING: Security Implications**
> 
> This tool intentionally and significantly reduces the security posture of the operating system to create a vulnerable target environment. It should **ONLY** be used in controlled, isolated cybersecurity labs, private testing networks, or by advanced users who strictly manage their own endpoint security. **Do not run this on your primary personal or work computer.**

## Prerequisites

Before running this script, you **MUST** manually disable Tamper Protection in the Windows Security settings, otherwise, Windows will block the registry modifications.

1. Go to **Settings** > **Privacy & security** > **Windows Security** > **Virus & threat protection**.
2. Click **Manage settings**.
3. Toggle **Tamper Protection** to **OFF**.

### Quick Execution

Open an elevated PowerShell window (Run as Administrator) and paste the following command to download and execute the script directly in memory:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; $w=New-Object Net.WebClient; $w.Encoding=[System.Text.Encoding]::UTF8; iex $w.DownloadString("https://raw.githubusercontent.com/bhardwaj-23/WIN-STRIP/main/WIN-STRIP.ps1")
```
