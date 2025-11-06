---
layout: post
title: "Automating ConnectWise Automate Agent Management Through Control"
short_title: "Agent Management Through Control"
date: 2024-02-19 10:00:00 -0000
categories: [PowerShell, MSP, ConnectWiseControlAPI]
tags: [PowerShell, ConnectWise, Control, Automate, MSP, Integration, Agent Management, Automation]
author: Chris Taylor
excerpt: "When Automate agents fail, use Control to reach machines and fix them remotely. This post shows how to connect both tools and automate agent maintenance that used to take hours."
---

## The MSP Tech Stack Integration Challenge

Most MSPs run ConnectWise Control alongside ConnectWise Automate (formerly LabTech). Control provides fast remote access, while Automate handles monitoring, patching, and automation. But when Automate agents fail or need reinstallation, you need a way to reach the machine—and that's where Control becomes critical.

The classic scenario: An Automate agent stops checking in. The machine is online (you can see it in Control), but you've lost your monitoring and automation capabilities. Manually connecting through Control, opening a command prompt, and reinstalling the agent works... once. When you're facing dozens of failed agents across multiple clients, manual intervention doesn't scale.

This article demonstrates how to combine ConnectWiseControlAPI with remote command execution to automate agent maintenance tasks at scale.

## The Architecture: Why Control is the Perfect Delivery Mechanism

ConnectWise Control excels at:
- **Fast connection establishment** - Agents connect immediately on boot
- **Firewall-friendly** - Uses outbound connections on port 443
- **Cross-platform support** - Windows, Mac, Linux
- **Command execution** - Run scripts without interactive desktop

Even when Automate agents fail, Control agents typically remain connected. This makes Control an ideal mechanism for delivering repair commands to machines with failed automation agents.

## Use Case: Automated Automate Agent Reinstallation

When an Automate agent fails, the standard fix is:

1. Connect to the machine via Control
2. Open command prompt or PowerShell
3. Download the Automate installer
4. Run the installer with appropriate parameters
5. Verify agent checks in successfully

With ConnectWiseControlAPI, this entire process becomes scriptable.

### The Manual Process (Old Way)

```
1. Log into Control web interface
2. Search for machine name
3. Click "Connect" on the session
4. Wait for connection
5. Open command prompt
6. Type: powershell -Command "iwr https://... | iex; Install-LTAgent..."
7. Wait for completion
8. Close connection
9. Repeat for next machine...
```

For one machine: 5-10 minutes. For 50 machines: **4+ hours of tedious work**.

### The Automated Process (New Way)

```powershell
# Find all machines with failed Automate agents
$failedAgents = Get-FailedAutomateAgents  # Your detection logic

# For each failed agent, find in Control and reinstall
$failedAgents | ForEach-Object {
    $session = Get-CWCSession -Search $_.ComputerName -Limit 1

    if ($session) {
        # Reinstall Automate agent via Control
        Invoke-AutomateReinstall -SessionID $session.SessionID -InstallerToken $token
    }
}
```

For 50 machines: **5-10 minutes of script execution** (unattended).

## The Complete Solution

### Step 1: Identify Failed Agents

First, identify which machines need agent reinstallation. This might come from:

- Automate's own reporting (agents not checking in)
- ConnectWise Manage tickets
- Custom monitoring dashboards
- Scheduled reports

For this example, assume you have a list of computer names:

```powershell
# Machines identified as having failed Automate agents
$failedMachines = @(
    'CLIENT-A-PC01',
    'CLIENT-B-SERVER01',
    'CLIENT-C-LAPTOP05'
)
```

### Step 2: Locate Machines in Control

```powershell
# Connect to Control
Connect-CWC -Server 'https://control.yourdomain.com' -Credential $cred

# Find each machine in Control
$controlSessions = foreach ($machine in $failedMachines) {
    Write-Host "Searching for $machine in Control..."

    $session = Get-CWCSession -Type Access -Search $machine -Limit 1

    if ($session) {
        Write-Host "  Found: Session ID $($session.SessionID)" -ForegroundColor Green
        $session
    }
    else {
        Write-Warning "  Not found in Control: $machine"
    }
}

Write-Host "`nFound $($controlSessions.Count) of $($failedMachines.Count) machines in Control"
```

### Step 3: Build the Reinstall Command

ConnectWise Automate provides installer tokens for agent deployment. Your command needs:

```powershell
# Automate installer command (PowerShell)
$installerToken = 'YOUR-INSTALLER-TOKEN-HERE'
$automateServer = 'automate.yourdomain.com'

$reinstallCommand = @"
# Download Automate installer script
iwr -UseBasicParsing "https://bit.ly/LTPoSh" | iex

# Run reinstall (preserves existing configuration where possible)
Redo-LTService -InstallerToken '$installerToken' -Server '$automateServer' -Backup
"@
```

**Command Breakdown:**

- `iwr -UseBasicParsing` - Download installer script (works on older PowerShell versions)
- `| iex` - Execute downloaded script
- `Redo-LTService` - Function from downloaded script that handles reinstallation
- `-InstallerToken` - Authenticates to Automate server
- `-Server` - Specifies Automate server URL
- `-Backup` - Backs up existing agent settings before reinstall

### Step 4: Execute Reinstallation via Control

```powershell
# Execute reinstallation for each session
$results = foreach ($session in $controlSessions) {
    Write-Host "Reinstalling Automate on $($session.Name)..."

    try {
        $commandResult = Invoke-CWCCommand `
            -GUID $session.SessionID `
            -Command $reinstallCommand `
            -PowerShell `
            -TimeOut 300000  # 5 minute timeout for installation

        [PSCustomObject]@{
            ComputerName = $session.Name
            SessionID    = $session.SessionID
            Status       = 'Success'
            Result       = $commandResult
            Error        = $null
        }

        Write-Host "  Completed successfully" -ForegroundColor Green
    }
    catch {
        Write-Warning "  Failed: $_"

        [PSCustomObject]@{
            ComputerName = $session.Name
            SessionID    = $session.SessionID
            Status       = 'Failed'
            Result       = $null
            Error        = $_.Exception.Message
        }
    }
}

# Summary
$successCount = ($results | Where-Object { $_.Status -eq 'Success' }).Count
Write-Host "`nCompleted: $successCount successful, $($results.Count - $successCount) failed"
```

### Step 5: Verification and Reporting

After execution, verify agents check back in:

```powershell
# Wait for agents to check in (typically 2-5 minutes)
Write-Host "Waiting 5 minutes for agents to check in..."
Start-Sleep -Seconds 300

# Check Automate for new check-ins
# (This would use ConnectWiseAutomateAPI or similar)
$verifiedAgents = Verify-AutomateAgentCheckIn -ComputerNames $controlSessions.Name

# Generate report
$report = $results | ForEach-Object {
    $checkInStatus = if ($_.ComputerName -in $verifiedAgents) { 'Checked In' } else { 'Not Verified' }

    [PSCustomObject]@{
        ComputerName  = $_.ComputerName
        InstallStatus = $_.Status
        CheckInStatus = $checkInStatus
        Error         = $_.Error
    }
}

# Export for review
$report | Export-Csv -Path "AutomateReinstall_$(Get-Date -Format 'yyyy-MM-dd_HHmm').csv" -NoTypeInformation

# Display summary
$report | Format-Table -AutoSize
```

## The Complete Automated Script

Here's the full solution packaged as a reusable function:

```powershell
function Invoke-AutomateAgentReinstallViaControl {
    <#
    .SYNOPSIS
        Reinstall Automate agents using Control for delivery

    .DESCRIPTION
        Locates machines in ConnectWise Control and executes Automate agent
        reinstallation commands remotely.

    .PARAMETER ComputerName
        Computer names to reinstall Automate agent on

    .PARAMETER InstallerToken
        ConnectWise Automate installer token

    .PARAMETER AutomateServer
        Automate server URL (e.g., 'automate.domain.com')

    .PARAMETER ControlServer
        Control server URL (e.g., 'https://control.domain.com')

    .PARAMETER Credential
        Control authentication credentials

    .EXAMPLE
        Invoke-AutomateAgentReinstallViaControl `
            -ComputerName 'PC01','PC02','PC03' `
            -InstallerToken 'abc123' `
            -AutomateServer 'automate.domain.com' `
            -ControlServer 'https://control.domain.com' `
            -Credential (Get-Credential)
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory = $true)]
        [string]$InstallerToken,

        [Parameter(Mandatory = $true)]
        [string]$AutomateServer,

        [Parameter(Mandatory = $true)]
        [string]$ControlServer,

        [Parameter(Mandatory = $true)]
        [PSCredential]$Credential
    )

    # Connect to Control
    try {
        Connect-CWC -Server $ControlServer -Credential $Credential
        Write-Verbose "Connected to Control: $ControlServer"
    }
    catch {
        throw "Failed to connect to Control: $_"
    }

    # Build reinstall command
    $reinstallCommand = @"
iwr -UseBasicParsing "https://bit.ly/LTPoSh" | iex
Redo-LTService -InstallerToken '$InstallerToken' -Server '$AutomateServer' -Backup
"@

    # Process each computer
    $results = foreach ($computer in $ComputerName) {
        Write-Verbose "Processing $computer..."

        # Find in Control
        $session = Get-CWCSession -Type Access -Search $computer -Limit 1

        if (!$session) {
            Write-Warning "$computer not found in Control"
            [PSCustomObject]@{
                ComputerName = $computer
                Status       = 'NotFound'
                Error        = 'Session not found in Control'
            }
            continue
        }

        # Execute reinstall
        try {
            $result = Invoke-CWCCommand `
                -GUID $session.SessionID `
                -Command $reinstallCommand `
                -PowerShell `
                -TimeOut 300000

            [PSCustomObject]@{
                ComputerName = $computer
                SessionID    = $session.SessionID
                Status       = 'Success'
                Error        = $null
            }
        }
        catch {
            Write-Warning "Failed to reinstall on $computer: $_"
            [PSCustomObject]@{
                ComputerName = $computer
                SessionID    = $session.SessionID
                Status       = 'Failed'
                Error        = $_.Exception.Message
            }
        }
    }

    return $results
}
```

### Usage

```powershell
# Load module
Import-Module ConnectWiseControlAPI

# Define parameters
$params = @{
    ComputerName    = @('PC01', 'SERVER02', 'LAPTOP03')
    InstallerToken  = 'your-installer-token'
    AutomateServer  = 'automate.yourdomain.com'
    ControlServer   = 'https://control.yourdomain.com'
    Credential      = Get-Credential
}

# Execute reinstallation
$results = Invoke-AutomateAgentReinstallViaControl @params

# Review results
$results | Format-Table -AutoSize
```

## Advanced Considerations

### Handling Different Client Environments

MSPs manage multiple clients with different Automate locations:

```powershell
# Client-specific installer tokens
$clientConfig = @{
    'ClientA' = @{
        InstallerToken = 'token-a-123'
        LocationID     = 1
    }
    'ClientB' = @{
        InstallerToken = 'token-b-456'
        LocationID     = 2
    }
}

# Detect client from computer name and use appropriate token
$clientID = $computerName.Split('-')[0]  # e.g., 'CLIENTA-PC01' -> 'CLIENTA'
$token = $clientConfig[$clientID].InstallerToken
```

### Logging and Audit Trail

For compliance and troubleshooting:

```powershell
# Log all operations
$logEntry = [PSCustomObject]@{
    Timestamp    = Get-Date
    ComputerName = $computer
    Action       = 'AutomateReinstall'
    SessionID    = $session.SessionID
    Status       = $status
    ExecutedBy   = $env:USERNAME
}

$logEntry | Export-Csv -Path 'C:\Logs\AutomateReinstalls.csv' -Append -NoTypeInformation
```

### Scheduled Automatic Remediation

Combine with scheduled tasks for proactive remediation:

```powershell
# Detect failed agents (from your monitoring system)
$failedAgents = Get-FailedAutomateAgents -DaysOffline 1

if ($failedAgents.Count -gt 0) {
    # Attempt automated remediation
    $results = Invoke-AutomateAgentReinstallViaControl -ComputerName $failedAgents.Name

    # Alert on failures
    $failures = $results | Where-Object { $_.Status -ne 'Success' }
    if ($failures) {
        Send-MailMessage -Subject "Automate Remediation Failures" -Body ($failures | ConvertTo-Html)
    }
}
```

## Real-World Results

After implementing automated agent reinstallation via Control:

- **Reduced MTTR** (Mean Time To Repair) from hours to minutes
- **Eliminated manual connection overhead** for bulk agent issues
- **Improved agent uptime** from ~95% to ~99.5%
- **Freed up ~10 hours per week** of technician time
- **Enabled proactive remediation** through scheduled automation

## Important Considerations

### Security

- **Protect installer tokens** - Store securely, rotate regularly
- **Audit all operations** - Log who executed what and when
- **Use dedicated service accounts** - Don't use personal credentials
- **Review before bulk execution** - Test on a few machines first

### Testing

Before deploying to production:

1. Test command manually in Control interface
2. Test script against 1-2 non-critical machines
3. Verify agent check-in after reinstallation
4. Review logs for errors or unexpected behavior
5. Document any edge cases discovered

### Error Handling

Not all reinstallations succeed. Common failures:

- **Machine offline** - Control session shows online but is unresponsive
- **Permissions issues** - Command needs elevation or different credentials
- **Network problems** - Can't download installer script
- **Conflicting software** - Security software blocks execution

Build retry logic and manual escalation for persistent failures.

## Key Takeaways

- **Control provides reliable command delivery** even when Automate agents fail
- **Automation scales manual processes** from hours to minutes
- **Integration between tools** multiplies their individual value
- **Proper error handling** is critical for production automation
- **Security and auditing** must be built in from the start

## Resources

- **ConnectWiseControlAPI**: [GitHub](https://github.com/christaylorcodes/ConnectWiseControlAPI)
- **Automate Installer Documentation**: Check your Automate server's help docs
- **Related Functions**:
  - `Get-CWCSession` - [Docs](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/Docs/Get-CWCSession.md)
  - `Invoke-CWCCommand` - [Docs](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/Docs/Invoke-CWCCommand.md)
- **Example Script**: See [ReinstallAutomate.ps1](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/Examples/ReinstallAutomate.ps1)

Have you automated agent management differently? Share your approaches in the GitHub discussions.
