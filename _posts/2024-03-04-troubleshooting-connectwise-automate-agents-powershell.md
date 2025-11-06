---
layout: post
title: "Troubleshooting ConnectWise Automate Agents Like a Pro with PowerShell"
short_title: "Troubleshooting Automate Agents with PowerShell"
date: 2024-11-15 09:00:00 -0500
categories: [PowerShell, Troubleshooting]
tags: [PowerShell, ConnectWise, Automate, RMM, Troubleshooting, Diagnostics, MSP]
author: Chris Taylor
excerpt: "47 agents offline at 2 AM? PowerShell diagnostics fix agent problems in seconds instead of hours. Learn quick diagnostic commands, automated health checks, and monitoring that fixes issues automatically."
---

## The Midnight Alert

It's 2 AM. Your phone buzzes. "Critical: 47 agents offline at ClientXYZ."

You know the drill: remote into the server, check the Automate console, try to figure out which machines are actually down versus which agents just got stuck. Start the tedious process of remote desktop, log hunting, service restarting...

**There's a better way.**

## PowerShell-Powered Diagnostics

The ConnectWiseAutomateAgent module isn't just for deployment—it's a powerful troubleshooting toolkit that puts everything you need at your fingertips via the command line.

## Common Scenarios and Solutions

### Scenario 1: "The Agent Just Won't Come Online"

**Symptoms**: Agent installed but not showing up in Automate console.

**Traditional approach**:
- RDP to the machine
- Check Services console
- Navigate to C:\Windows\LTSVC
- Open LTErrors.txt in Notepad
- Scroll through thousands of lines
- Try to find relevant errors
- Google cryptic error codes

**PowerShell approach**:

```powershell
# Quick diagnostic - all from your workstation
Invoke-Command -ComputerName PROBLEM-PC -ScriptBlock {
    # Check service status
    Get-Service LTService, LTSvcMon | Select-Object Name, Status

    # Get agent configuration
    Get-CWAAInfo | Format-List

    # Check recent errors
    Get-CWAAError -Tail 50 | Where-Object { $_ -match "ERROR|CRITICAL" }

    # Test connectivity to server
    Test-CWAAPort -Server "https://automate.yourmsp.com"
}
```

**Time saved**: 15 minutes → 30 seconds

### Scenario 2: "Connectivity Issues"

**Symptoms**: Agent keeps going offline and online randomly.

**Diagnosis script**:

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
    Set-CWAAProxy -ProxyServerURL $null -ProxyUsername $null
    Restart-CWAA
    Start-Sleep 30

    # Retest
    Test-CWAAPort -Server $server
}
```

### Scenario 3: "Agent Services Keep Stopping"

**Symptoms**: LTService or LTSvcMon randomly stops.

**Quick fix**:

```powershell
# Restart services
Restart-CWAA

# Check if services stayed running
Start-Sleep 10
Get-Service LTService, LTSvcMon | Format-Table Name, Status, StartType

# If still failing, check the probe errors
Get-CWAAProbeError -Tail 100

# Nuclear option: reinstall
$info = Get-CWAAInfo
Redo-CWAA -Server $info.Server `
          -InstallerToken "your-token" `
          -LocationID $info.LocationID
```

### Scenario 4: "Need to Check Multiple Machines"

**Symptoms**: You need to diagnose agent health across many endpoints.

**Bulk health check script**:

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

## Deep Dive: Understanding Agent Logs

### Reading LTErrors.txt

```powershell
# Get recent errors with context
Get-CWAAError -Tail 100

# Filter for specific issues
Get-CWAAError | Where-Object { $_ -match "heartbeat|timeout|connection" }

# Find patterns
Get-CWAAError | Group-Object | Sort-Object Count -Descending | Select-Object -First 10
```

### Probe Errors

```powershell
# Probe errors indicate agent health checks
Get-CWAAProbeError -Tail 50

# Look for recurring patterns
Get-CWAAProbeError | Select-String "FAIL|ERROR" | Group-Object
```

## Advanced Troubleshooting Techniques

### Technique 1: Adjusting Log Levels

Sometimes you need more verbose logging:

```powershell
# Increase logging verbosity
Set-CWAALogLevel -Level 1000

# Reproduce the issue (wait for it to occur)
Start-Sleep 300

# Check detailed logs
Get-CWAAError -Tail 200

# Reset to normal logging
Set-CWAALogLevel -Level 1
```

### Technique 2: Force Agent Commands

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

### Technique 3: Comparing Settings

```powershell
# Get current settings
$current = Get-CWAAInfo

# Get backed up settings (from before issues started)
$backup = Get-CWAAInfoBackup

# Compare
Compare-Object $current.PSObject.Properties $backup.PSObject.Properties -Property Name, Value
```

### Technique 4: Security Decoding

Sometimes you need to decode encrypted values:

```powershell
# Decode server password or other encrypted values
$encodedValue = "Base64EncodedValueFromRegistry"
$decoded = ConvertFrom-CWAASecurity -InputString $encodedValue -Key "YourKey"
```

## Proactive Monitoring Script

Don't wait for alerts. Run this daily:

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
            $recentErrors = Get-CWAAError -Tail 50 | Where-Object { $_ -match "CRITICAL|FATAL" }
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

## Troubleshooting Decision Tree

Use this flowchart approach:

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
        $portTest = Test-CWAAPort -Server $info.Server
        if ($portTest | Where-Object { $_.Open -eq $false }) {
            Write-Host "  Issue: Connectivity problem detected" -ForegroundColor Yellow

            # Check if proxy needed
            $proxySettings = Get-CWAAProxy
            if (-not $proxySettings.ProxyServerURL) {
                Write-Host "  No proxy configured. May need proxy settings." -ForegroundColor Yellow
                return "Connectivity issue - check firewall/proxy"
            }
        }

        # Step 3: Check for errors
        $errors = Get-CWAAError -Tail 50 | Where-Object { $_ -match "ERROR|CRITICAL" }
        if ($errors) {
            Write-Host "  Issue: Errors in log" -ForegroundColor Yellow

            # Common fixable errors
            if ($errors -match "heartbeat") {
                Invoke-CWAACommand -Command "Send Status"
                return "Heartbeat issue - status sent"
            }
        }

        # Step 4: Nuclear option
        Write-Host "  Issue unclear. Recommending reinstall." -ForegroundColor Red
        return "Needs manual investigation or reinstall"
    }
}

# Use it
Repair-CWAAAgent -ComputerName "PROBLEM-PC"
```

## Emergency Response Kit

Save this as your "emergency script":

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

        Write-Host "✓ $computer processed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ $computer failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

## Conclusion

Troubleshooting ConnectWise Automate agents doesn't have to mean hours of clicking through GUIs and hunting through log files. With the ConnectWiseAutomateAgent PowerShell module, you can:

- Diagnose issues in seconds, not minutes
- Automate health checks across your entire fleet
- Fix common problems with one-line commands
- Build proactive monitoring systems
- Sleep better knowing your agents are monitored

The next time you get that 2 AM alert, you'll have PowerShell on your side.

---

## Resources

- **Module**: `Install-Module ConnectWiseAutomateAgent`
- **GitHub**: [https://github.com/christaylorcodes/ConnectWiseAutomateAgent](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
- **Previous Posts**:
  - [Introducing ConnectWiseAutomateAgent]({% post_url 2024-11-01-introducing-connectwise-automate-agent %})
  - [Mass Agent Deployment]({% post_url 2024-11-08-mass-agent-deployment-connectwise-automate %})

**Next in series**: 10 real-world use cases for ConnectWiseAutomateAgent beyond deployment and troubleshooting.
