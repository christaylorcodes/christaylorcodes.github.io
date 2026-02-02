---
layout: post
title: "Troubleshooting ConnectWise Automate Agents with PowerShell"
short_title: "Troubleshooting Automate Agents"
date: 2024-03-04 10:00:00 -0000
categories: [PowerShell, Troubleshooting]
tags: [PowerShell, ConnectWise, Automate, RMM, Troubleshooting, Diagnostics, MSP]
author: Chris Taylor
excerpt: "Structured troubleshooting workflows for ConnectWise Automate agents using PowerShell. Covers offline agents, intermittent connectivity, stopped services, log analysis, bulk health checks, and automated remediation scripts you can run from your workstation."
---

## What This Covers

The ConnectWiseAutomateAgent module includes a set of diagnostic and remediation functions for troubleshooting ConnectWise Automate (CWA) agents. This post walks through the common scenarios -- agent won't come online, connectivity issues, services stopping, log analysis -- and the PowerShell commands that address each one.

These are structured workflows, not emergency procedures. The goal is a repeatable troubleshooting toolkit you can reach for whenever an agent needs attention.

---

## Common Scenarios and Solutions

### Scenario 1: Agent Won't Come Online

**Symptoms:** Agent is installed but not reporting to the Automate console.

The traditional approach involves an RDP session, manually checking services, navigating to `C:\Windows\LTSVC`, opening `LTErrors.txt` in Notepad, and scrolling through thousands of lines looking for something relevant.

The module approach runs the same checks from your workstation in one block:

```powershell
# Quick diagnostic - all from your workstation
Invoke-Command -ComputerName PROBLEM-PC -ScriptBlock {
    # Check service status
    Get-Service LTService, LTSvcMon | Select-Object Name, Status

    # Get agent configuration
    Get-CWAAInfo | Format-List

    # Check recent errors
    Get-CWAAError | Select-Object -Last 50 | Where-Object { $_ -match "ERROR|CRITICAL" }

    # Test connectivity to server
    Test-CWAAPort -Server "https://automate.yourmsp.com"
}
```

That covers services, configuration, recent errors, and port connectivity in a single remote call.

### Scenario 2: Intermittent Connectivity

**Symptoms:** Agent keeps going offline and coming back on its own.

Start with a port check, then look at proxy configuration if the standard ports fail:

```powershell
# Comprehensive connectivity check
$server = "https://automate.yourmsp.com"
$results = Test-CWAAPort -Server $server

# Check all required ports
$results | Format-Table -AutoSize

# If port 70, 80, or 443 fails, check proxy
$proxySettings = Get-CWAAProxy
if ($proxySettings.ProxyServerURL) {
    Write-Host "Proxy configured: $($proxySettings.ProxyServerURL)" -ForegroundColor Yellow

    # Test if proxy is the issue
    Set-CWAAProxy -ResetProxy
    Restart-CWAA
    Start-Sleep 30

    # Retest
    Test-CWAAPort -Server $server
}
```

### Scenario 3: Agent Services Keep Stopping

**Symptoms:** LTService or LTSvcMon stops unexpectedly.

Start with the lightest fix and escalate only if needed:

```powershell
# Restart services
Restart-CWAA

# Check if services stayed running
Start-Sleep 10
Get-Service LTService, LTSvcMon | Format-Table Name, Status, StartType

# If still failing, check the probe errors
Get-CWAAProbeError | Select-Object -Last 100

# Nuclear option: reinstall
$info = Get-CWAAInfo
Redo-CWAA -Server $info.Server `
          -InstallerToken "your-token" `
          -LocationID $info.LocationID
```

### Scenario 4: Checking Multiple Machines

If you need to assess agent health across a fleet, the module's `Test-CWAAHealth` function handles this per-endpoint. For a full walkthrough of bulk health monitoring with automated remediation, see the [Self-Healing Agents]({% post_url 2024-03-01-self-healing-connectwise-automate-agents %}) post -- it covers scheduled health checks, escalation logic, and event log integration.

For a quick ad-hoc sweep across Active Directory (AD), a script like this pulls basic status from each machine:

```powershell
# Get all computers from Active Directory
$computers = Get-ADComputer -Filter * -SearchBase "OU=Workstations,DC=domain,DC=com"

# Check agent health on all of them
$healthReport = $computers | ForEach-Object -Parallel {
    $computer = $_.Name
    try {
        $result = Invoke-Command -ComputerName $computer -ScriptBlock {
            $info = Get-CWAAInfo -ErrorAction Stop
            $services = Get-Service LTService, LTSvcMon -ErrorAction SilentlyContinue

            [PSCustomObject]@{
                Computer = $env:COMPUTERNAME
                AgentID = $info.ID
                Server = $info.Server
                LocationID = $info.LocationID
                LastSuccessfulContact = $info.LastSuccessfulContact
                LTServiceStatus = ($services | Where-Object Name -eq 'LTService').Status
                LTSvcMonStatus = ($services | Where-Object Name -eq 'LTSvcMon').Status
                Status = 'Healthy'
            }
        } -ErrorAction Stop
        $result
    }
    catch {
        [PSCustomObject]@{
            Computer = $computer
            AgentID = 'N/A'
            Server = 'N/A'
            LocationID = 'N/A'
            LastSuccessfulContact = 'N/A'
            LTServiceStatus = 'Unknown'
            LTSvcMonStatus = 'Unknown'
            Status = "Error: $($_.Exception.Message)"
        }
    }
} -ThrottleLimit 20

# Show results
$healthReport | Out-GridView -Title "Agent Health Report"

# Export for analysis
$healthReport | Export-Csv "AgentHealthReport-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv" -NoTypeInformation
```

This is a point-in-time snapshot. For ongoing monitoring, the scheduled health check system in `Register-CWAAHealthCheckTask` is a better fit.

---

## Understanding Agent Logs

### LTErrors.txt

The `Get-CWAAError` function reads the agent's error log so you don't have to open the file manually. A few useful patterns:

```powershell
# Get recent errors with context
Get-CWAAError | Select-Object -Last 100

# Filter for specific issues
Get-CWAAError | Where-Object { $_ -match "heartbeat|timeout|connection" }

# Find patterns
Get-CWAAError | Group-Object | Sort-Object Count -Descending | Select-Object -First 10
```

### Probe Errors

Probe errors come from the agent's internal health checks. Same idea -- pull them and look for patterns:

```powershell
# Probe errors indicate agent health checks
Get-CWAAProbeError | Select-Object -Last 50

# Look for recurring patterns
Get-CWAAProbeError | Select-String "FAIL|ERROR" | Group-Object
```

---

## Advanced Techniques

### Adjusting Log Levels

When the default logs don't show enough detail, temporarily increase verbosity:

```powershell
# Increase logging verbosity
Set-CWAALogLevel -Level Verbose

# Reproduce the issue (wait for it to occur)
Start-Sleep 300

# Check detailed logs
Get-CWAAError | Select-Object -Last 200

# Reset to normal logging
Set-CWAALogLevel -Level Normal
```

Don't forget to set it back. Verbose logging on hundreds of endpoints generates a lot of disk I/O.

### Forcing Agent Commands

You can tell the agent to perform specific actions immediately rather than waiting for its next scheduled cycle:

```powershell
# Force agent to send inventory
Invoke-CWAACommand -Command "Send Inventory"

# Force status update
Invoke-CWAACommand -Command "Send Status"

# Update schedule from server
Invoke-CWAACommand -Command "Update Schedule"

# Available commands:
# - Send Inventory
# - Send Status
# - Update Schedule
# - Agent Update
# - And 14 more...
```

### Comparing Settings

If an agent was working before and isn't now, compare current settings against the backup:

```powershell
# Get current settings
$current = Get-CWAAInfo

# Get backed up settings (from before issues started)
$backup = Get-CWAAInfoBackup

# Compare
Compare-Object $current.PSObject.Properties $backup.PSObject.Properties -Property Name, Value
```

The module creates backups automatically during certain operations. `Get-CWAAInfoBackup` reads from the most recent one.

### Security Decoding

For cases where you need to inspect encrypted agent values:

```powershell
# Decode server password or other encrypted values
$encodedValue = "Base64EncodedValueFromRegistry"
$decoded = ConvertFrom-CWAASecurity -InputString $encodedValue -Key "YourKey"
```

---

## Proactive Monitoring

Rather than waiting for something to break, a scheduled script can sweep your environment daily and flag issues before they become tickets:

```powershell
# Daily agent health check script
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
$issues = @()

foreach ($computer in $computers) {
    try {
        $result = Invoke-Command -ComputerName $computer -ScriptBlock {
            $info = Get-CWAAInfo -ErrorAction Stop
            $services = Get-Service LTService, LTSvcMon -ErrorAction SilentlyContinue

            # Check for issues
            $problems = @()

            if (($services | Where-Object Name -eq 'LTService').Status -ne 'Running') {
                $problems += "LTService not running"
            }

            if (($services | Where-Object Name -eq 'LTSvcMon').Status -ne 'Running') {
                $problems += "LTSvcMon not running"
            }

            # Check last contact (within last 30 minutes)
            $lastContact = [datetime]$info.LastSuccessfulContact
            if ((Get-Date) - $lastContact -gt [timespan]::FromMinutes(30)) {
                $problems += "Last contact: $($lastContact) (over 30 min ago)"
            }

            # Check for recent errors
            $recentErrors = Get-CWAAError | Select-Object -Last 50 | Where-Object { $_ -match "CRITICAL|FATAL" }
            if ($recentErrors) {
                $problems += "Critical errors in log"
            }

            if ($problems.Count -gt 0) {
                [PSCustomObject]@{
                    Computer = $env:COMPUTERNAME
                    Issues = $problems -join '; '
                    AgentID = $info.ID
                }
            }
        } -ErrorAction Stop

        if ($result) {
            $issues += $result
        }
    }
    catch {
        $issues += [PSCustomObject]@{
            Computer = $computer
            Issues = "Unable to connect or get agent info: $($_.Exception.Message)"
            AgentID = 'N/A'
        }
    }
}

# Report issues
if ($issues.Count -gt 0) {
    $issues | Export-Csv "AgentIssues-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

    # Send email alert
    Send-MailMessage -To "alerts@yourmsp.com" `
                     -From "monitoring@yourmsp.com" `
                     -Subject "ConnectWise Automate Agent Issues: $($issues.Count) problems found" `
                     -Body ($issues | Format-Table | Out-String) `
                     -SmtpServer "smtp.yourmsp.com"
}
else {
    Write-Host "All agents healthy!" -ForegroundColor Green
}
```

For automated remediation on top of detection, see `Register-CWAAHealthCheckTask` and the [Self-Healing Agents]({% post_url 2024-03-01-self-healing-connectwise-automate-agents %}) post.

---

## Custom Decision Tree

The module includes `Repair-CWAA`, which handles escalating remediation natively (restart, reinstall, fresh install). If you need custom logic beyond what `Repair-CWAA` provides -- different escalation thresholds, additional diagnostic steps, or environment-specific checks -- you can build your own decision tree:

```powershell
function Repair-CWAAAgent {
    param([string]$ComputerName)

    Write-Host "Diagnosing $ComputerName..." -ForegroundColor Cyan

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        # Step 1: Are services running?
        $services = Get-Service LTService, LTSvcMon -ErrorAction SilentlyContinue
        if ($services.Status -contains 'Stopped') {
            Write-Host "  Issue: Services stopped. Attempting restart..." -ForegroundColor Yellow
            Restart-CWAA
            Start-Sleep 10
            return "Services restarted"
        }

        # Step 2: Can we reach the server?
        $info = Get-CWAAInfo
        $portOutput = Test-CWAAPort -Server $info.Server
        if ($portOutput -match 'Connection failed') {
            Write-Host "  Issue: Connectivity problem detected" -ForegroundColor Yellow

            # Check if proxy needed
            $proxySettings = Get-CWAAProxy
            if (-not $proxySettings.ProxyServerURL) {
                Write-Host "  No proxy configured. May need proxy settings." -ForegroundColor Yellow
                return "Connectivity issue - check firewall/proxy"
            }
        }

        # Step 3: Check for errors
        $errors = Get-CWAAError | Select-Object -Last 50 | Where-Object { $_ -match "ERROR|CRITICAL" }
        if ($errors) {
            Write-Host "  Issue: Errors in log" -ForegroundColor Yellow

            # Common fixable errors
            if ($errors -match "heartbeat") {
                Invoke-CWAACommand -Command "Send Status"
                return "Heartbeat issue - status sent"
            }
        }

        # Step 4: Nothing obvious found
        Write-Host "  Issue unclear. Recommending reinstall." -ForegroundColor Red
        return "Needs manual investigation or reinstall"
    }
}

# Use it
Repair-CWAAAgent -ComputerName "PROBLEM-PC"
```

For most environments, the built-in `Repair-CWAA` with `Register-CWAAHealthCheckTask` handles the common cases without custom scripting.

---

## Multi-Machine Repair Script

When you need to push a restart-then-reinstall sequence to a list of machines:

```powershell
# Emergency Agent Repair Script
param(
    [Parameter(Mandatory)]
    [string[]]$ComputerName,

    [string]$Server = "https://automate.yourmsp.com",
    [string]$InstallerToken
)

foreach ($computer in $ComputerName) {
    Write-Host "`n=== Processing $computer ===" -ForegroundColor Cyan

    try {
        Invoke-Command -ComputerName $computer -ScriptBlock {
            # Quick restart
            Write-Host "Attempting service restart..."
            Restart-CWAA
            Start-Sleep 15

            # Check if it worked
            $services = Get-Service LTService, LTSvcMon
            if ($services.Status -contains 'Stopped') {
                Write-Host "Services still stopped. Attempting full reinstall..." -ForegroundColor Yellow

                Redo-CWAA -Server $using:Server `
                          -InstallerToken $using:InstallerToken `
                          -Force
            }
            else {
                Write-Host "Services running. Forcing status update..." -ForegroundColor Green
                Invoke-CWAACommand -Command "Send Status"
            }
        }

        Write-Host "[OK] $computer processed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] $computer failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

---

**Getting started:**

```powershell
Install-Module ConnectWiseAutomateAgent
```

Full function reference and examples: [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
