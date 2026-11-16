---
layout: post
title: "ConnectWise Automate Agent Health Checks with Test-CWAAHealth and Repair-CWAA"
short_title: "Automate Agent Health Checks"
date: 2026-11-15 08:00:00 -0000
categories: [PowerShell, RMM]
tags: [PowerShell, ConnectWise, Automate, RMM, Self-Healing, Health Monitoring, MSP]
author: Chris Taylor
excerpt: "Want self-healing Automate agents without the risk of a script reinstalling 500 machines overnight? Start read-only. This post shows what Test-CWAAHealth checks, how Repair-CWAA escalates from restart to reinstall, how to dry-run it with -WhatIf, schedule it to run on its own, read the event log, and roll it out in safe rings."
description: "Set up safe self-healing for ConnectWise Automate (ConnectWise RMM) agents with PowerShell. Covers Test-CWAAHealth, Repair-CWAA, -WhatIf dry runs, scheduled health checks, event log monitoring, and ring-based rollouts."
---

Here's the short answer if you manage a few hundred Automate agents and want them to fix themselves without fixing themselves into a crater:

1. **Measure first.** Run `Test-CWAAHealth` across the fleet. It's read-only.
2. **Dry-run the fix.** Run `Repair-CWAA -WhatIf` on the unhealthy machines and read what it would do.
3. **Schedule it on a small ring.** Use `Register-CWAAHealthCheckTask` in Checkup mode on machines you own first.
4. **Watch the event log.** Every check and every fix is logged to the Windows Application log.
5. **Widen the rings.** Move to Install mode last, and only where you want an uninstalled agent to come back on its own.

Everything here uses the ConnectWiseAutomateAgent PowerShell module, version 2.0 or later. The current stable release is 2.1.0. If you want the full reference for every function, the [Self-Healing Agents]({% post_url 2024-03-01-self-healing-connectwise-automate-agents %}) post has it. This post is about rolling it out safely. The [project page](/projects/connectwiseautomateagent/) has the module overview.

---

## What You Need

- **ConnectWiseAutomateAgent 2.1.0** installed on each endpoint, for all users
- **An installer token** from your Automate server. Treat it like a password
- **Local admin rights** on the endpoint. The health check task runs as SYSTEM

Install the module from an elevated **Windows PowerShell 5.1** session:

```powershell
# Run elevated in Windows PowerShell 5.1 (powershell.exe), not PowerShell 7
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
Install-Module ConnectWiseAutomateAgent -RequiredVersion 2.1.0 -Scope AllUsers -Force
Import-Module ConnectWiseAutomateAgent
```

Why 5.1? The module works fine in PowerShell 7. But the scheduled task launches `powershell.exe` and runs `Import-Module ConnectWiseAutomateAgent`. If you install from PowerShell 7, the module lands in `C:\Program Files\PowerShell\Modules`, which Windows PowerShell doesn't search. The task would run, fail to find the module, and fix nothing. Quietly.

---

## What Test-CWAAHealth Looks At

`Test-CWAAHealth` never changes the agent, its services, or the registry. You can run it anywhere, any time.

```powershell
Test-CWAAHealth -TestServerConnectivity
```

It returns one object:

| Property | What it tells you |
| --- | --- |
| `AgentInstalled` | The `LTService` service exists |
| `ServicesRunning` | Both `LTService` and `LTSvcMon` are running |
| `LastContact` | When the agent last reported a successful status to the server |
| `LastHeartbeat` | When the agent last sent a heartbeat |
| `ServerAddress` | The server the agent is configured to use |
| `ServerMatch` | Whether that server matches `-Server`, if you passed one. Otherwise null |
| `ServerReachable` | Whether the server answered on `agent.aspx`, if you used `-TestServerConnectivity`. Otherwise null |
| `Healthy` | Installed, both services running, and a `LastContact` value exists |

**Read `Healthy` carefully.** It doesn't check how recent `LastContact` is. An agent that last checked in three weeks ago with both services running still reports `Healthy = True`. If you care about age, and you should, do the math yourself:

```powershell
$health = Test-CWAAHealth -TestServerConnectivity
if ($health.LastContact) {
    $hoursSinceContact = ((Get-Date) - $health.LastContact).TotalHours
    "Last contact was $([math]::Round($hoursSinceContact, 1)) hours ago"
}
else {
    'No contact recorded'
}
```

`Repair-CWAA` does look at age, which is the next section.

---

## How Repair-CWAA Escalates

`Repair-CWAA` checks the agent and applies the lightest fix that should work. Here's the order it actually runs in:

1. **Makes sure WMI is running.** New in 2.1.0. The `winmgmt` service gets set to Automatic and started if it isn't. The agent depends on it.
2. **Unreadable config.** If the agent is installed but its registry settings can't be read, it uninstalls the agent and tells you to reboot and run it again.
3. **Wrong server.** If you passed `-Server` and the agent points somewhere else, it reinstalls against the right server.
4. **Offline for 2+ hours.** If the last contact or heartbeat is older than `-HoursRestart` (default `-2`), it checks that the server is reachable. If the server is down, it stops there. If the server is up, it restarts both services and waits up to 2 minutes for a check-in.
5. **Offline for 5+ days.** If the restart didn't bring it back and the last contact is older than `-HoursReinstall` (default `-120`), it reinstalls with `Redo-CWAA`.
6. **Not installed.** With `-Server`, `-LocationID`, and `-InstallerToken` (Install mode), it does a fresh install. With only `-InstallerToken` (Checkup mode), it tries to reinstall from backup settings. No backup, no install, and it logs an error.

If none of that applies, the agent is healthy and nothing happens.

A few things make this safe to run at scale:

- **Server check before every restart or reinstall.** If your Automate server goes down, 500 agents won't decide to reinstall themselves. They log that the server is unreachable and wait.
- **Probe agents are protected.** The reinstall steps call `Redo-CWAA` without `-Force`, and `Redo-CWAA` refuses to touch a probe agent unless forced.
- **No pile-ups.** `Repair-CWAA` stops any other running `Repair-CWAA` process before it starts. The scheduled task also skips a run if the previous one is still going.
- **Agents with no timestamp count as old.** If `LastContact` can't be read, `Repair-CWAA` treats it as a year old. Those machines go down the restart path, then the reinstall path. Good to know before you look at your baseline.

It returns an object with `ActionTaken` (`None`, `Restart`, `Reinstall`, `Install`, or `Uninstall`), `Success`, and `Message`.

---

## Step 1: Measure Before You Fix

Get a baseline across the fleet before anything runs unattended. This uses PowerShell remoting, but you can push the same script block through Control or your RMM.

```powershell
$computers = Get-Content -Path .\computers.txt

$results = Invoke-Command -ComputerName $computers -ErrorVariable remotingErrors -ErrorAction SilentlyContinue -ScriptBlock {
    Import-Module ConnectWiseAutomateAgent
    $health = Test-CWAAHealth -TestServerConnectivity

    $hoursSinceContact = $null
    if ($health.LastContact) {
        $hoursSinceContact = [math]::Round(((Get-Date) - $health.LastContact).TotalHours, 1)
    }

    [PSCustomObject]@{
        AgentInstalled    = $health.AgentInstalled
        ServicesRunning   = $health.ServicesRunning
        HoursSinceContact = $hoursSinceContact
        ServerReachable   = $health.ServerReachable
        Healthy           = $health.Healthy
    }
}

$results |
    Select-Object PSComputerName, Healthy, AgentInstalled, ServicesRunning, HoursSinceContact, ServerReachable |
    Export-Csv -Path .\agent-health-baseline.csv -NoTypeInformation

"Machines remoting couldn't reach: $($remotingErrors.Count)"
```

Then bucket the results by what `Repair-CWAA` would probably do with them:

```powershell
$results | Group-Object -Property {
    if (-not $_.AgentInstalled) { 'Not installed' }
    elseif ($null -eq $_.HoursSinceContact) { 'No contact recorded' }
    elseif ($_.HoursSinceContact -gt 120) { 'Restart, then reinstall (5+ days)' }
    elseif ($_.HoursSinceContact -gt 2) { 'Restart (2+ hours)' }
    else { 'Leave alone' }
} | Select-Object Count, Name
```

This is a rough preview. `Repair-CWAA` also looks at the heartbeat, and a restart often fixes things before a reinstall is needed. But if 80 machines land in the reinstall bucket, you want to know that now, not from the event log on Monday.

---

## Step 2: Dry-Run with -WhatIf

Every destructive step in `Repair-CWAA` supports `-WhatIf`. Run it on a few machines from the unhealthy buckets:

```powershell
# Checkup mode: what would it do to the agent that's already here?
Repair-CWAA -InstallerToken 'YourInstallerToken' -WhatIf -Verbose
```

```powershell
# Install mode: also shows a reinstall if the agent points at a different server
Repair-CWAA -Server 'https://automate.example.com' -LocationID 42 -InstallerToken 'YourInstallerToken' -WhatIf -Verbose
```

Under `-WhatIf`, it still reads the agent config and tests the server connection. It doesn't restart, reinstall, uninstall, or change the WMI service. The `What if:` lines tell you exactly what it would have done.

**Trust the `What if:` lines, not the returned object.** On a dry run, `ActionTaken` can still say `Restart` with a "services restarted" message, even though nothing was restarted. That's the restart step reporting its plan, not its result.

The Install mode dry run is especially useful during a server migration. If you typo the server URL, `-WhatIf` shows every agent it would reinstall. That's a much better time to find the typo.

If you're working on one machine interactively, `-Confirm` prompts before each step instead.

---

## Step 3: Schedule It

Once the dry runs look right, register the scheduled task. Start with Checkup mode:

```powershell
Register-CWAAHealthCheckTask -InstallerToken 'YourInstallerToken'
```

That creates a task named `AAutomate` that runs `Repair-CWAA -InstallerToken` as SYSTEM. Here's what you get:

- **Runs every 6 hours** by default. Change it with `-IntervalHours` (1 to 168)
- **Random delay up to the interval**, so 500 machines don't all check at the same minute
- **1-hour timeout**, and a new run is skipped if the last one is still going
- **Runs on battery**, so laptops are covered
- **Backs up agent settings** with `New-CWAABackup` before creating the task. Checkup mode needs that backup to reinstall a missing agent

Running it again with the same token does nothing. A new token recreates the task, so rotating the token is one command. Use `-Force` to recreate it regardless. `-WhatIf` works here too.

Check that the task exists and has run:

```powershell
Get-ScheduledTask -TaskName 'AAutomate' | Get-ScheduledTaskInfo |
    Select-Object TaskName, LastRunTime, LastTaskResult, NextRunTime
```

Two things to know before you deploy it widely:

- **Thresholds aren't configurable on the task.** `Register-CWAAHealthCheckTask` doesn't pass `-HoursRestart` or `-HoursReinstall`, so the task always uses the defaults: restart after 2 hours, reinstall after 5 days. If you want different numbers, run `Repair-CWAA` from your own scheduler with those parameters.
- **The installer token is stored in the task.** Anyone with local admin can read it from the task definition. That's the tradeoff for unattended repair. Rotate it if you need to, then re-run `Register-CWAAHealthCheckTask` with the new one.

### Checkup Mode vs. Install Mode

Install mode adds `-Server` and `-LocationID`:

```powershell
Register-CWAAHealthCheckTask -InstallerToken 'YourInstallerToken' -Server 'https://automate.example.com' -LocationID 42
```

Now the task can install the agent from scratch if it's missing. That's great when a user or another tool removes the agent. It's less great when **you** remove it on purpose. `Uninstall-CWAA` doesn't remove the task, so the next run puts the agent right back.

When you're decommissioning a machine, remove the task first:

```powershell
Unregister-CWAAHealthCheckTask
Uninstall-CWAA
```

---

## Step 4: Read the Event Log

Everything lands in the **Application** log under the source **ConnectWiseAutomateAgent**. These are the IDs that matter for health checks:

| Event ID | Type | Meaning |
| --- | --- | --- |
| 4000 | Information | Agent healthy, no action taken |
| 4001 | Warning | Agent offline past the restart threshold |
| 4001 | Information | Agent recovered after a service restart |
| 4002 | Warning / Information | Restart didn't fix it, reinstalling / reinstall done |
| 4003 | Warning / Information | Agent not installed, installing / install done |
| 4004 | Warning / Information | Wrong server detected / reinstalled to the right one |
| 4008 | Error | Server unreachable, nothing done |
| 4009 | Error | Something failed: unreadable config, install, or reinstall |
| 4020 / 4022 | Information / Error | Task created or updated / task creation failed |
| 4030 / 4032 | Information / Error | Task removed / task removal failed |
| 2030 / 2031 / 2032 | Information / Warning / Error | WMI service fixed / set but not running / failed |

On one machine:

```powershell
Get-WinEvent -FilterHashtable @{
    LogName      = 'Application'
    ProviderName = 'ConnectWiseAutomateAgent'
    StartTime    = (Get-Date).AddDays(-7)
} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message
```

Across a ring, skip the "healthy" noise and count what actually happened:

```powershell
$pilotComputers = Get-Content -Path .\ring2.txt

$events = Invoke-Command -ComputerName $pilotComputers -ScriptBlock {
    Get-WinEvent -FilterHashtable @{
        LogName      = 'Application'
        ProviderName = 'ConnectWiseAutomateAgent'
        Id           = 4001, 4002, 4003, 4004, 4008, 4009, 2031, 2032
        StartTime    = (Get-Date).AddDays(-7)
    } -ErrorAction SilentlyContinue
}

$events | Group-Object -Property PSComputerName, Id |
    Sort-Object Count -Descending |
    Select-Object Count, Name
```

What to look for:

- **4002 on lots of machines.** Reinstalls are the expensive step. Find out why before you widen the ring.
- **4008 everywhere.** That's your server, DNS, or firewall, not the agents.
- **4001 warnings on the same machine every run.** The restart isn't sticking. Something on that box keeps killing the agent.
- **Any 4009.** Read the message. It's always worth a look.

If you already forward Windows events to a collector or SIEM, point it at this source and you've got fleet-wide reporting without another script.

---

## Step 5: Roll Out in Rings

Here's how I'd stage it for 500 endpoints:

| Ring | Machines | What runs | Move on when |
| --- | --- | --- | --- |
| 0 | All 500 | `Test-CWAAHealth` only | You've got a baseline and understand the unhealthy list |
| 1 | Your own 5 to 10 machines | Checkup mode task | A week with no surprises in the event log |
| 2 | About 25, spread across clients, laptops and desktops | Checkup mode task | 1 to 2 weeks, reinstall count looks reasonable |
| 3 | Remaining workstations | Checkup mode task | Steady state |
| 4 | Servers, and anything you want in Install mode | Decided per client | Never in a hurry |

Servers get their own ring because a reinstall on a server is a different conversation than a reinstall on a laptop. Some clients will want that automatic. Some won't. Ask.

Push the registration with whatever already runs scripts on those machines: Group Policy, Intune, Control, or Automate itself. Yes, you can use Automate to deploy the thing that fixes Automate. It works right up until the agent is the problem, which is exactly why you want the task already on the box.

A deploy script for one ring:

```powershell
# Runs elevated in Windows PowerShell 5.1 on the endpoint
$moduleVersion  = '2.1.0'
$installerToken = 'YourInstallerToken'

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$installed = Get-Module ConnectWiseAutomateAgent -ListAvailable | Where-Object Version -eq $moduleVersion
if (-not $installed) {
    Install-Module ConnectWiseAutomateAgent -RequiredVersion $moduleVersion -Scope AllUsers -Force
}
Import-Module ConnectWiseAutomateAgent -RequiredVersion $moduleVersion

Register-CWAAHealthCheckTask -InstallerToken $installerToken
```

One more thing about versions. The task imports the newest copy of the module installed on the machine. So the version you install is the version that runs every 6 hours. Treat module updates like any other change: same rings, same watching.

---

## Key Takeaways

- **Start read-only.** `Test-CWAAHealth` changes nothing. Baseline the fleet before anything runs unattended.
- **`Healthy` doesn't mean recent.** Check `LastContact` age yourself.
- **Dry-run with `-WhatIf`** and read the `What if:` lines, not `ActionTaken`.
- **Checkup mode first.** Install mode reinstalls agents you removed on purpose unless you unregister the task first.
- **The event log is your report.** 4002, 4008, and 4009 are the ones to watch.
- **Rings, not a big bang.** Your own machines, then a small pilot, then everyone else, then servers.

For the full function reference, see [Self-Healing Agents]({% post_url 2024-03-01-self-healing-connectwise-automate-agents %}). For install, update, and everything else the module does, see the [ConnectWiseAutomateAgent project page](/projects/connectwiseautomateagent/).

**Getting started:**

```powershell
Install-Module ConnectWiseAutomateAgent -Scope AllUsers
```

Source and docs: [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
