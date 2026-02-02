---
layout: post
title: "Self-Healing Agents: Automated Health Monitoring for ConnectWise Automate"
short_title: "Self-Healing Automate Agents"
date: 2024-03-01 10:00:00 -0000
categories: [PowerShell, RMM]
tags: [PowerShell, ConnectWise, Automate, RMM, Health Monitoring, Self-Healing, MSP]
author: Chris Taylor
excerpt: "Deploy a scheduled health check that monitors and repairs ConnectWise Automate agents automatically. Escalating remediation restarts services, reinstalls agents, and logs every action to the Windows Event Log for auditing."
---

## What This Covers

The ConnectWiseAutomateAgent module includes a health check and auto-remediation system. You deploy it once per endpoint, and the agent monitors and repairs itself on a schedule. Services hang, it restarts them. Agent gets uninstalled, it reinstalls. Server address changes, it corrects itself. Every action gets logged to the Windows Event Log.

This post walks through the system: what each function does, how to set it up, how the escalation logic works, and how to monitor the results.

---

## The Health Check System

The system is built from five functions that work together:

| Function | Role |
| --- | --- |
| `Test-CWAAHealth` | Read-only health assessment -- checks installation, services, last check-in, server connectivity |
| `Repair-CWAA` | Escalating remediation -- restart, reinstall, or fresh install depending on severity |
| `Register-CWAAHealthCheckTask` | Creates a Windows scheduled task that runs `Repair-CWAA` on an interval |
| `Unregister-CWAAHealthCheckTask` | Removes the scheduled task when you no longer need it |
| `Test-CWAAServerConnectivity` | Verifies the Automate server is online before attempting remediation |

The design is straightforward: check first, then apply the minimum fix needed. A service restart is tried before a reinstall. A reinstall is tried before a fresh install. The system never takes a heavier action than necessary, and every action gets logged to the Windows Event Log for a complete audit trail.

---

## Running a Health Check

`Test-CWAAHealth` is the diagnostic starting point. It's read-only -- it never modifies the agent, services, or registry. Safe to run at any time, from any script, without risk.

```powershell
# Basic health check
Test-CWAAHealth
```

This returns a `PSCustomObject` with these properties:

| Property | Type | Meaning |
| --- | --- | --- |
| `AgentInstalled` | Boolean | `True` if the LTService service exists |
| `ServicesRunning` | Boolean | `True` if both LTService and LTSvcMon are running |
| `LastContact` | DateTime | Timestamp of the agent's last successful status report |
| `LastHeartbeat` | DateTime | Timestamp of the last heartbeat sent to the server |
| `ServerAddress` | String | The server URL(s) the agent is configured to use |
| `ServerMatch` | Boolean/Null | Whether the installed server matches the `-Server` parameter (null if not tested) |
| `ServerReachable` | Boolean/Null | Whether the server responded to a connectivity test (null if not tested) |
| `Healthy` | Boolean | `True` only when installed, running, and has a recent contact timestamp |

The `Healthy` property is the quick answer: `True` means the agent is installed, both services are running, and it has successfully contacted the server at least once. Everything else is detail for when `Healthy` is `False` and you need to know why.

For a more thorough check, add server validation and connectivity testing:

```powershell
# Full health check with server validation and connectivity test
Test-CWAAHealth -Server 'https://automate.domain.com' -TestServerConnectivity
```

The `-Server` parameter compares the provided URL against the agent's configured server and populates the `ServerMatch` property. The `-TestServerConnectivity` switch sends a request to the server's `agent.aspx` endpoint and populates `ServerReachable`. Both add useful context but aren't required for the basic assessment.

Use it in scripts for conditional logic:

```powershell
$health = Test-CWAAHealth -TestServerConnectivity
if (-not $health.Healthy) {
    Write-Warning "Agent unhealthy on $env:COMPUTERNAME"
    Write-Warning "  Installed: $($health.AgentInstalled)"
    Write-Warning "  Services:  $($health.ServicesRunning)"
    Write-Warning "  Last seen: $($health.LastContact)"
}
```

---

## Setting Up Automated Health Checks

Running `Test-CWAAHealth` manually is useful for troubleshooting, but the real value is unattended monitoring. `Register-CWAAHealthCheckTask` creates a Windows scheduled task that runs `Repair-CWAA` at a configurable interval (default: every 6 hours).

### Checkup Mode (Existing Agents)

If the agent is already installed and you want to keep it healthy:

```powershell
Register-CWAAHealthCheckTask -InstallerToken 'abc123def456'
```

This is "Checkup" mode. The scheduled task will restart services or reinstall the agent if it goes offline, but it can't perform a fresh install if the agent is completely removed -- it needs existing configuration or backup settings to work from.

### Install Mode (Full Self-Healing)

For complete self-healing capability, including installing the agent from scratch if it gets uninstalled:

```powershell
Register-CWAAHealthCheckTask -InstallerToken 'abc123def456' `
    -Server 'https://automate.domain.com' `
    -LocationID 42
```

This is "Install" mode. The task has everything it needs to deploy a fresh agent if one isn't found, making the machine truly self-healing.

### Customizing the Schedule

The defaults work for most environments, but you can adjust:

```powershell
Register-CWAAHealthCheckTask -InstallerToken 'abc123def456' `
    -Server 'https://automate.domain.com' `
    -LocationID 42 `
    -IntervalHours 12 `
    -TaskName 'MyHealthCheck'
```

The `-IntervalHours` parameter accepts values from 1 to 168 (one week). The task includes a random delay equal to the interval, so if you deploy this across hundreds of machines, they won't all hit the server at the same time.

Details about the scheduled task:

- **Runs as SYSTEM** with highest privileges -- no stored user credentials to expire
- **1-hour execution timeout** -- prevents stuck tasks from blocking subsequent runs
- **Runs on battery** -- laptops are covered even when unplugged
- **IgnoreNew instance policy** -- if the previous run is still going, the new one is skipped
- **Backs up agent config** via `New-CWAABackup` before registering, so recovery settings are available

If your InstallerToken changes (e.g., token rotation), re-run the command with the new token and the task updates automatically. Use `-Force` to recreate unconditionally.

### Removing the Task

When you no longer need automated monitoring on a machine:

```powershell
Unregister-CWAAHealthCheckTask
```

Or with a custom task name:

```powershell
Unregister-CWAAHealthCheckTask -TaskName 'MyHealthCheck'
```

The function returns a result object with a `Removed` boolean. If the task doesn't exist, it writes a warning and returns gracefully -- no errors thrown.

---

## How Repair-CWAA Escalates

`Repair-CWAA` is the engine behind the scheduled task. It checks the agent's state and applies the minimum remediation needed, escalating only when lighter fixes fail. Here's the decision tree:

### Stage 1: Agent Is Healthy

If the agent is installed, both services are running, and the last check-in is within the `HoursRestart` threshold (default: 2 hours), no action is taken. Event ID 4000 is logged as informational.

### Stage 2: Services Need a Restart

If the last check-in or heartbeat is older than `HoursRestart` (default: 2 hours), the function first verifies the server is reachable using `Test-CWAAServerConnectivity`. If the server is down, remediation is skipped -- no point restarting services when the server isn't there (Event ID 4008).

If the server is reachable, it restarts both services (`LTService` and `LTSvcMon`) and waits up to 2 minutes, polling every 2 seconds for the agent to check in. If it recovers, Event ID 4001 (Information) is logged.

### Stage 3: Full Reinstall

If the restart didn't fix it and the last check-in is older than `HoursReinstall` (default: 120 hours / 5 days), the agent is reinstalled via `Redo-CWAA`. This preserves the agent ID and configuration where possible. Event ID 4002 tracks the escalation.

### Stage 4: Server Mismatch

If a `-Server` parameter was provided and the installed agent points to a different server, the agent is reinstalled with the correct server address. Event ID 4004 logs the mismatch and correction.

### Stage 5: Corrupt Configuration

If `Get-CWAAInfo` fails to read the agent's registry configuration, the agent is uninstalled for a clean reinstall on the next cycle. Event ID 4009 tracks this.

### Stage 6: Agent Not Installed

If no `LTService` service exists at all, the function attempts a fresh install. In Install mode (Server + LocationID + InstallerToken), it has everything needed. In Checkup mode, it tries to recover from backup settings created by `New-CWAABackup`. If no settings are available, it logs an error (Event ID 4009) and reports the failure.

### Custom Thresholds

The defaults (restart after 2 hours, reinstall after 5 days) work for most environments, but you can tune them:

```powershell
# More aggressive: restart after 1 hour, reinstall after 2 days
Repair-CWAA -InstallerToken 'token' -HoursRestart -1 -HoursReinstall -48

# More conservative: restart after 4 hours, reinstall after 10 days
Repair-CWAA -InstallerToken 'token' -HoursRestart -4 -HoursReinstall -240
```

The hour values are expressed as negative numbers (offsets from the current time). `-2` means "2 hours ago."

### Duplicate Process Protection

`Repair-CWAA` kills any existing `Repair-CWAA` PowerShell processes before starting, so overlapping scheduled task runs don't compete with each other. It matches on the process command line and excludes its own PID.

---

## Event Log Integration

Every remediation action is logged to the Windows Event Log under:

- **Log:** Application
- **Source:** ConnectWiseAutomateAgent

This gives you a queryable audit trail that works with your existing Windows monitoring tools -- SIEM, Event Log forwarding, `Get-WinEvent`, whatever you're already using.

### Health Check Event IDs

| Event ID | Entry Type | Meaning |
| --- | --- | --- |
| 4000 | Information | Agent is healthy, no action needed |
| 4001 | Warning/Information | Agent offline, services restarted (Warning). Agent recovered after restart (Information). |
| 4002 | Warning/Information | Restart failed, reinstalling (Warning). Reinstall completed (Information). |
| 4003 | Warning/Information | Agent not installed, attempting install (Warning). Install completed (Information). |
| 4004 | Warning/Information | Server mismatch detected (Warning). Reinstalled with correct server (Information). |
| 4008 | Error | Server unreachable, remediation skipped |
| 4009 | Error | General failure (unreadable config, install failed, reinstall failed) |
| 4020 | Information | Health check scheduled task registered |
| 4022 | Error | Failed to register scheduled task |
| 4030 | Information | Health check scheduled task removed |
| 4032 | Error | Failed to remove scheduled task |

### Querying Health Events

Pull recent health check activity:

```powershell
# All health-related events from the last 7 days
Get-WinEvent -FilterHashtable @{
    LogName   = 'Application'
    ProviderName = 'ConnectWiseAutomateAgent'
    Id        = 4000, 4001, 4002, 4003, 4004, 4008, 4009
    StartTime = (Get-Date).AddDays(-7)
} | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize
```

Filter to just problems:

```powershell
# Only warnings and errors
Get-WinEvent -FilterHashtable @{
    LogName      = 'Application'
    ProviderName = 'ConnectWiseAutomateAgent'
    Level        = 2, 3  # 2 = Error, 3 = Warning
    StartTime    = (Get-Date).AddDays(-30)
} | Format-Table TimeCreated, Id, LevelDisplayName, Message -AutoSize
```

Check if the scheduled task is firing:

```powershell
# Task registration and removal events
Get-WinEvent -FilterHashtable @{
    LogName      = 'Application'
    ProviderName = 'ConnectWiseAutomateAgent'
    Id           = 4020, 4022, 4030, 4032
} | Format-Table TimeCreated, Id, Message -AutoSize
```

These events integrate with Windows Event Log forwarding, so you can aggregate health check results across your fleet into a central collector or SIEM.

---

## Verifying Server Connectivity

Before `Repair-CWAA` attempts any remediation, it checks whether the server is reachable. You can also use `Test-CWAAServerConnectivity` directly for troubleshooting:

```powershell
# Detailed result
Test-CWAAServerConnectivity -Server 'https://automate.domain.com'
```

This returns a `PSCustomObject` per server with `Server`, `Available`, `Version`, and `ErrorMessage` properties. The function queries the server's `/LabTech/agent.aspx` endpoint and validates the response matches the expected version format.

```powershell
# Simple boolean for scripts
Test-CWAAServerConnectivity -Quiet
```

The `-Quiet` switch returns `$True` if the server is reachable, `$False` otherwise. If no `-Server` is provided, it auto-discovers the server from the installed agent's configuration or backup settings.

```powershell
# Pipeline from installed agent
Get-CWAAInfo | Test-CWAAServerConnectivity
```

---

## Complete Setup: Deploy and Enable Self-Healing

Here's a complete script that installs the agent, registers the health check task, and verifies everything is working. This is what a planned deployment looks like when you want self-healing from day one.

```powershell
# --- Configuration ---
$InstallerToken = 'YourGeneratedInstallerToken'
$Server         = 'https://automate.domain.com'
$LocationID     = 42

# --- Load the module ---
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
try {
    $Module = 'ConnectWiseAutomateAgent'
    try { Update-Module $Module -ErrorAction Stop }
    catch { Install-Module $Module -Force -Scope AllUsers -SkipPublisherCheck }

    Get-Module $Module -ListAvailable |
        Sort-Object Version -Descending |
        Select-Object -First 1 |
        Import-Module *>$null
}
catch {
    $URI = 'https://raw.githubusercontent.com/christaylorcodes/ConnectWiseAutomateAgent/main/ConnectWiseAutomateAgent.ps1'
    (New-Object Net.WebClient).DownloadString($URI) | Invoke-Expression
}

# --- Step 1: Install the agent ---
Redo-CWAA -Server $Server -LocationID $LocationID -InstallerToken $InstallerToken

# --- Step 2: Register the health check ---
Register-CWAAHealthCheckTask -InstallerToken $InstallerToken `
    -Server $Server `
    -LocationID $LocationID `
    -IntervalHours 6 `
    -Force

# --- Step 3: Verify ---
$health = Test-CWAAHealth -TestServerConnectivity
if ($health.Healthy) {
    Write-Host "Agent is healthy. Server reachable: $($health.ServerReachable)" -ForegroundColor Green
}
else {
    Write-Warning 'Agent not yet healthy. The scheduled task will remediate automatically.'
}
```

After this runs, the machine is covered:

1. The agent is installed and connected to your server.
2. Every 6 hours, the scheduled task checks if the agent is healthy.
3. If services are hung, they get restarted.
4. If the agent has been offline for 5+ days, it gets reinstalled.
5. If someone uninstalls the agent, it gets reinstalled from scratch.
6. Every action is logged to the Windows Event Log for auditing.

You can deploy this via Group Policy (GPO), Intune, your existing RMM, or any tool that can run PowerShell on endpoints. The health check task handles the rest.

---

## What This Looks Like at Scale

The math here is simple. If you manage 1,000 endpoints and 2% of agents have issues in a given month, that's 20 manual interventions. Each one involves identifying the problem, connecting to the machine, diagnosing, fixing, and verifying. With the health check system, those interventions handle themselves before they become tickets.

What changes in practice:

- **Reduced time to recovery.** An offline agent that would sit unnoticed for days gets restarted within hours. If that doesn't work, it's reinstalled within the week. No human required.
- **Fewer reactive tickets.** The most common agent issue -- hung services -- is the first thing the system tries to fix. A service restart resolves the majority of offline agents, and it happens automatically on the next scheduled check.
- **Complete audit trail.** Every action taken (or skipped) is in the Windows Event Log with a categorized Event ID. When someone asks "what happened to that machine?", you have the answer.
- **Consistent behavior.** The same escalation logic runs on every machine. No variation between technicians, no forgotten steps.
- **Server-aware remediation.** The system checks if the server is reachable before attempting fixes. If the Automate server itself is down, it doesn't waste time restarting agents that can't connect anyway.

The health check system doesn't replace monitoring -- it supplements it. Your Automate server still tracks online/offline status. But now, when it flags an agent as offline, there's already a process running on that endpoint working to bring it back.

---

**Getting started:**

```powershell
Install-Module ConnectWiseAutomateAgent
```

Full function reference and examples: [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
