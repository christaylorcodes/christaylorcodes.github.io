---
layout: post
title: "Mass Agent Deployment: Deploying ConnectWise Automate Agents at Scale"
short_title: "Mass Agent Deployment with PowerShell"
date: 2024-02-26 10:00:00 -0000
categories: [PowerShell, Deployment]
tags: [PowerShell, ConnectWise, Automate, RMM, Deployment, Automation, MSP]
author: Chris Taylor
excerpt: "Deploy ConnectWise Automate agents to hundreds of machines in parallel using PowerShell remoting. Covers inventory, phased rollouts, failure handling, verification, and integration with GPO and PDQ Deploy."
---

## What This Covers

The ConnectWiseAutomateAgent module handles mass deployment of ConnectWise Automate agents via PowerShell remoting. You build an inventory from Active Directory (AD), run parallel installations across your target machines, retry failures, and verify the results -- all from a single console.

This post walks through a full deployment: preparation, the deployment script, failure handling, verification, and a few advanced patterns for staged rollouts and integration with other tools.

---

## Why Script It

Deploying a Remote Monitoring and Management (RMM) agent to a handful of machines is straightforward. Deploying to hundreds is where the usual approaches start to fall apart:

- GPO deployments that fail silently
- Login scripts that run... sometimes
- Email campaigns with download links (chaos)
- Sneakernet USB drives (it's 2025, really?)
- One-by-one remote installations (enjoy your weekend)

PowerShell remoting gives you parallel execution, per-machine error handling, and a CSV report at the end. The ConnectWiseAutomateAgent module provides the installation, configuration, and verification functions. Together, they turn a multi-day project into a scripted operation.

---

## Scenario: Multi-Site Client Onboarding

The examples below use a representative scenario. Adjust the values to match your environment.

**Infrastructure:**
- 500 Windows 10/11 workstations
- 50 Windows Servers (mix of 2016/2019/2022)
- 3 office locations (each with different proxy requirements)
- Active Directory environment
- Some machines behind restrictive firewalls

**Requirements:**
- Agent must be hidden from Add/Remove Programs
- Custom display name: "SecureWatch Monitoring"
- Different LocationIDs per office
- Proxy configuration for Site B
- No user disruption during deployment
- Complete within business hours

---

## Phase 1: Preparation

### Install the Module

First, install on your deployment machine (or server):

```powershell
# Install from PowerShell Gallery
Install-Module ConnectWiseAutomateAgent -Force

# Verify installation
Get-Command -Module ConnectWiseAutomateAgent
```

### Gather Information

You'll need:
- **Server URL**: `https://automate.yourmsp.com`
- **Installer Token**: Get from ConnectWise Automate (more secure than passwords)
- **LocationIDs**:
  - Site A (HQ): 100
  - Site B (Warehouse): 101
  - Site C (Remote Office): 102

### Create Computer Inventory

```powershell
# Export computers from Active Directory
$siteA = Get-ADComputer -Filter * -SearchBase "OU=Workstations,OU=SiteA,DC=client,DC=com" |
    Select-Object @{N='ComputerName';E={$_.Name}},
                  @{N='LocationID';E={100}},
                  @{N='Proxy';E={$null}}

$siteB = Get-ADComputer -Filter * -SearchBase "OU=Workstations,OU=SiteB,DC=client,DC=com" |
    Select-Object @{N='ComputerName';E={$_.Name}},
                  @{N='LocationID';E={101}},
                  @{N='Proxy';E={'http://proxy.siteb.client.com:8080'}}

$siteC = Get-ADComputer -Filter * -SearchBase "OU=Workstations,OU=SiteC,DC=client,DC=com" |
    Select-Object @{N='ComputerName';E={$_.Name}},
                  @{N='LocationID';E={102}},
                  @{N='Proxy';E={$null}}

# Combine all sites
$allComputers = $siteA + $siteB + $siteC

# Export for tracking
$allComputers | Export-Csv "Deployment-Inventory.csv" -NoTypeInformation

Write-Host "Total machines to deploy: $($allComputers.Count)" -ForegroundColor Cyan
```

---

## Phase 2: Deployment Script

### The Master Deployment Script

```powershell
<#
.SYNOPSIS
    Mass deployment script for ConnectWise Automate agents

.DESCRIPTION
    Deploys agents to multiple computers in parallel with full error handling
    and reporting.

.PARAMETER ComputerList
    Path to CSV file with columns: ComputerName, LocationID, Proxy

.PARAMETER Server
    ConnectWise Automate server URL

.PARAMETER InstallerToken
    Installer token from ConnectWise Automate

.PARAMETER ThrottleLimit
    Number of parallel deployments (default: 20)

.EXAMPLE
    .\Deploy-Agents.ps1 -ComputerList "Deployment-Inventory.csv" -Server "https://automate.msp.com" -InstallerToken "abc123"
#>

param(
    [Parameter(Mandatory)]
    [string]$ComputerList,

    [Parameter(Mandatory)]
    [string]$Server,

    [Parameter(Mandatory)]
    [string]$InstallerToken,

    [int]$ThrottleLimit = 20
)

# Import computer list
$computers = Import-Csv $ComputerList
Write-Host "Starting deployment to $($computers.Count) computers..." -ForegroundColor Green
Write-Host "Parallel deployments: $ThrottleLimit" -ForegroundColor Yellow

# Create results tracking
$results = $computers | ForEach-Object -Parallel {
    $computer = $_.ComputerName
    $locationID = $_.LocationID
    $proxy = $_.Proxy
    $server = $using:Server
    $token = $using:InstallerToken

    $result = [PSCustomObject]@{
        ComputerName = $computer
        LocationID = $locationID
        Status = 'Unknown'
        Message = ''
        Duration = 0
        AgentID = ''
        Timestamp = Get-Date
    }

    try {
        # Test connectivity first
        if (-not (Test-Connection -ComputerName $computer -Count 1 -Quiet)) {
            $result.Status = 'Offline'
            $result.Message = 'Computer not reachable'
            return $result
        }

        # Deploy agent
        $startTime = Get-Date

        Invoke-Command -ComputerName $computer -ScriptBlock {
            param($srv, $tok, $loc, $prx)

            # Import module
            Import-Module ConnectWiseAutomateAgent -ErrorAction Stop

            # Configure proxy if specified (proxy is set at module level, not on Install-CWAA)
            if ($prx) {
                Set-CWAAProxy -ProxyServerURL $prx
            }

            # Build installation parameters
            $installParams = @{
                Server = $srv
                InstallerToken = $tok
                LocationID = $loc
                Hide = $true
                Rename = "SecureWatch Monitoring"
                ErrorAction = 'Stop'
            }

            # Install
            Install-CWAA @installParams

            # Get agent info
            Start-Sleep 5
            $info = Get-CWAAInfo

            return $info.ID

        } -ArgumentList $server, $token, $locationID, $proxy -ErrorAction Stop

        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds

        $result.Status = 'Success'
        $result.Message = 'Agent deployed successfully'
        $result.Duration = [math]::Round($duration, 0)

    }
    catch {
        $result.Status = 'Failed'
        $result.Message = $_.Exception.Message
    }

    # Progress output
    $status = if ($result.Status -eq 'Success') { '✓' } else { '✗' }
    Write-Host "$status $computer - $($result.Status) ($($result.Duration)s)" -ForegroundColor $(
        if ($result.Status -eq 'Success') { 'Green' } else { 'Red' }
    )

    return $result

} -ThrottleLimit $ThrottleLimit

# Generate report
Write-Host "`n=== Deployment Summary ===" -ForegroundColor Cyan
Write-Host "Total: $($results.Count)"
Write-Host "Success: $(($results | Where-Object Status -eq 'Success').Count)" -ForegroundColor Green
Write-Host "Failed: $(($results | Where-Object Status -eq 'Failed').Count)" -ForegroundColor Red
Write-Host "Offline: $(($results | Where-Object Status -eq 'Offline').Count)" -ForegroundColor Yellow

# Export results
$reportFile = "Deployment-Results-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
$results | Export-Csv $reportFile -NoTypeInformation
Write-Host "`nDetailed results: $reportFile" -ForegroundColor Cyan

# Show failures
$failures = $results | Where-Object { $_.Status -ne 'Success' }
if ($failures) {
    Write-Host "`n=== Failed Deployments ===" -ForegroundColor Red
    $failures | Format-Table ComputerName, Status, Message -AutoSize
}

# Calculate average deployment time
$successTimes = $results | Where-Object Status -eq 'Success' | Measure-Object -Property Duration -Average
if ($successTimes.Count -gt 0) {
    Write-Host "`nAverage deployment time: $([math]::Round($successTimes.Average, 0)) seconds" -ForegroundColor Green
}
```

### Run the Deployment

```powershell
.\Deploy-Agents.ps1 -ComputerList "Deployment-Inventory.csv" `
                    -Server "https://automate.yourmsp.com" `
                    -InstallerToken "your-secure-token-here" `
                    -ThrottleLimit 25
```

**Expected output**:
```
Starting deployment to 500 computers...
Parallel deployments: 25
✓ WKS001 - Success (45s)
✓ WKS002 - Success (43s)
✗ WKS003 - Failed (Connection timeout)
✓ WKS004 - Success (47s)
...

=== Deployment Summary ===
Total: 500
Success: 487
Failed: 8
Offline: 5

Average deployment time: 44 seconds
```

---

## Phase 3: Handling Failures

Some machines won't succeed on the first pass. Common reasons: machine was powered off, WinRM wasn't enabled, or a firewall rule blocked the connection. The deployment script exports a CSV with per-machine results, so retrying is straightforward.

### Retry Failed Deployments

```powershell
# Load previous results
$previousResults = Import-Csv "Deployment-Results-20251103-140522.csv"

# Get failures
$failures = $previousResults | Where-Object { $_.Status -ne 'Success' }

# Create retry list
$retryList = $failures | Select-Object ComputerName, LocationID, Proxy

# Export retry list
$retryList | Export-Csv "Deployment-Retry.csv" -NoTypeInformation

# Run deployment again on failures only
.\Deploy-Agents.ps1 -ComputerList "Deployment-Retry.csv" `
                    -Server "https://automate.yourmsp.com" `
                    -InstallerToken "your-secure-token-here" `
                    -ThrottleLimit 10
```

### Manual Investigation

For machines that fail repeatedly, this script checks the basics -- network reachability, WinRM status, and whether an agent is already installed:

```powershell
$problemComputers = Import-Csv "Deployment-Retry.csv" |
    Where-Object { $_.Status -eq 'Failed' }

foreach ($pc in $problemComputers) {
    Write-Host "`n=== Investigating $($pc.ComputerName) ===" -ForegroundColor Yellow

    # Check connectivity
    if (Test-Connection $pc.ComputerName -Count 1 -Quiet) {
        Write-Host "  Online" -ForegroundColor Green

        # Check WinRM
        try {
            Invoke-Command -ComputerName $pc.ComputerName -ScriptBlock { $env:COMPUTERNAME } -ErrorAction Stop
            Write-Host "  WinRM: OK" -ForegroundColor Green
        }
        catch {
            Write-Host "  WinRM: FAILED - $($_.Exception.Message)" -ForegroundColor Red
        }

        # Check if agent already installed
        try {
            $existing = Invoke-Command -ComputerName $pc.ComputerName -ScriptBlock {
                Get-Service LTService -ErrorAction Stop
            }
            Write-Host "  Agent already installed: $($existing.Status)" -ForegroundColor Yellow
        }
        catch {
            Write-Host "  Agent not installed" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  Offline" -ForegroundColor Red
    }
}
```

---

## Phase 4: Verification

After deployment completes, verify independently that agents are installed and reporting. Don't just trust the deployment script's output -- confirm it.

### Verify All Deployments

```powershell
# Verification script
$computers = Import-Csv "Deployment-Inventory.csv"

$verification = $computers | ForEach-Object -Parallel {
    $computer = $_.ComputerName

    try {
        $info = Invoke-Command -ComputerName $computer -ScriptBlock {
            Import-Module ConnectWiseAutomateAgent -ErrorAction Stop
            Get-CWAAInfo
        } -ErrorAction Stop

        [PSCustomObject]@{
            ComputerName = $computer
            AgentInstalled = $true
            AgentID = $info.ID
            LocationID = $info.LocationID
            LastContact = $info.LastSuccessfulContact
            Version = $info.Version
            Status = 'Verified'
        }
    }
    catch {
        [PSCustomObject]@{
            ComputerName = $computer
            AgentInstalled = $false
            AgentID = 'N/A'
            LocationID = 'N/A'
            LastContact = 'N/A'
            Version = 'N/A'
            Status = 'Not Verified'
        }
    }
} -ThrottleLimit 30

# Report
Write-Host "`n=== Verification Results ===" -ForegroundColor Cyan
$verified = ($verification | Where-Object Status -eq 'Verified').Count
$total = $verification.Count
Write-Host "Verified: $verified / $total ($([math]::Round($verified/$total*100,1))%)" -ForegroundColor Green

# Export
$verification | Export-Csv "Deployment-Verification-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

# Check-in with ConnectWise Automate
Write-Host "`nCheck your ConnectWise Automate console for agent check-ins..."
```

---

## Advanced Techniques

### Staged Rollout

Deploying everything at once is tempting but risky. A staged rollout lets you validate the process on a small group before committing to the full inventory.

```powershell
# Deploy to 10% first (pilot group)
$pilot = $allComputers | Select-Object -First 50
$pilot | Export-Csv "Wave1-Pilot.csv" -NoTypeInformation

# After pilot success, deploy to 50%
$wave2 = $allComputers | Select-Object -Skip 50 -First 225
$wave2 | Export-Csv "Wave2-Main.csv" -NoTypeInformation

# Finally deploy remainder
$wave3 = $allComputers | Select-Object -Skip 275
$wave3 | Export-Csv "Wave3-Final.csv" -NoTypeInformation
```

Run each wave through the same `Deploy-Agents.ps1` script and review the results before moving on. If your pilot wave surfaces a consistent failure (wrong LocationID, firewall rule, etc.), you can fix it before it affects 450 machines instead of 50.

### Integration with PDQ Deploy

```powershell
# Create PDQ Deploy package that runs:
powershell.exe -ExecutionPolicy Bypass -Command "& {
    Install-Module ConnectWiseAutomateAgent -Force
    Install-CWAA -Server 'https://automate.msp.com' `
                 -InstallerToken 'token' `
                 -LocationID 100 `
                 -Hide `
                 -Rename 'SecureWatch Monitoring'
}"
```

### Group Policy Startup Script

Save this as a startup script:

```powershell
# GPO-Agent-Install.ps1
$marker = "C:\Windows\Temp\CWAAInstalled.txt"

if (-not (Test-Path $marker)) {
    try {
        # Determine LocationID based on OU
        $computerDN = ([ADSI]"LDAP://$env:COMPUTERNAME").distinguishedName
        $locationID = switch -Regex ($computerDN) {
            'OU=SiteA' { 100 }
            'OU=SiteB' { 101 }
            'OU=SiteC' { 102 }
            default { 100 }
        }

        # Install module
        Install-Module ConnectWiseAutomateAgent -Force -Scope AllUsers

        # Install agent
        Install-CWAA -Server 'https://automate.msp.com' `
                     -InstallerToken 'your-token' `
                     -LocationID $locationID `
                     -Hide `
                     -Rename 'SecureWatch Monitoring'

        # Mark as installed
        "Installed $(Get-Date)" | Out-File $marker
    }
    catch {
        "Failed: $($_.Exception.Message)" | Out-File "C:\Windows\Temp\CWAAInstallError.txt"
    }
}
```

---

## What to Expect at Scale

The numbers you'll see depend on your environment -- network speed, WinRM configuration, server load, and how many machines are actually online. As a rough guide for a 500-machine deployment with 20-25 parallel threads:

- **Total time**: Under an hour for the deployment pass
- **Success rate**: 95%+ if WinRM is pre-configured and machines are online
- **Per-machine install time**: 40-50 seconds on average
- **Common failures**: WinRM not enabled, machine powered off, firewall blocking the connection

The remaining 2-5% typically need one retry pass or manual attention (enable WinRM, power on the machine, open a firewall port). The retry workflow in Phase 3 handles most of these.

For comparison, manual deployment of 500 agents at 3-5 minutes each is roughly 25-40 hours of technician time. The scripted approach compresses that into under an hour of execution plus review time.

---

## Best Practices

- **Test on a pilot group first.** Deploy to 5-10% before the full rollout.
- **Enable WinRM ahead of time.** Use GPO to enable PowerShell remoting across the target environment.
- **Stagger your deployments.** Don't send 500 simultaneous installs at your Automate server.
- **Monitor server load.** Keep an eye on your Automate server's resources during large deployments.
- **Keep installer tokens secure.** Don't commit them to Git. Use a credential vault or pass them as parameters.
- **Verify check-ins.** Confirm agents appear in the Automate console after deployment, not just in your script output.
- **Document LocationIDs.** Maintain a mapping of sites to IDs. You'll reference it every time you onboard a new site.
- **Save deployment reports.** The CSV exports are useful for billing, documentation, and troubleshooting later.

---

## Troubleshooting Common Issues

### Issue: "Access Denied" Errors

**Cause**: WinRM not enabled or insufficient permissions on the target machine.

```powershell
# Enable WinRM via GPO or run on each machine:
Enable-PSRemoting -Force
```

### Issue: "Module Not Found" on Remote Machines

**Cause**: The module isn't installed on the target. `Invoke-Command` runs on the remote machine, so the module needs to be there.

```powershell
# Pre-install module via GPO or:
Invoke-Command -ComputerName $computers -ScriptBlock {
    Install-Module ConnectWiseAutomateAgent -Force -Scope AllUsers
}
```

### Issue: Proxy Authentication Failures

**Cause**: The target machine needs proxy configuration before the installer can reach the Automate server. Proxy is set at the module level, not as a parameter on `Install-CWAA`.

```powershell
# Set proxy at the module level (proxy is not a parameter of Install-CWAA)
$proxyPass = ConvertTo-SecureString "password" -AsPlainText -Force
Set-CWAAProxy -ProxyServerURL "http://proxy:8080" `
              -ProxyUsername "domain\user" `
              -ProxyPassword $proxyPass

Install-CWAA -Server $server `
             -InstallerToken $token `
             -LocationID $loc
```

---

**Getting started:**

```powershell
Install-Module ConnectWiseAutomateAgent
```

Full function reference and examples: [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
