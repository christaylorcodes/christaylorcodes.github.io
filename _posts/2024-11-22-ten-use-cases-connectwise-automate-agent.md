---
layout: post
title: "10 Real-World Use Cases for ConnectWiseAutomateAgent"
date: 2024-11-22 09:00:00 -0500
categories: [PowerShell, Automation]
tags: [PowerShell, ConnectWise, Automate, RMM, Use Cases, Automation, MSP]
author: Chris Taylor
excerpt: "Beyond basic installation: 10 real-world use cases that solve everyday MSP challenges. From automated provisioning to compliance reporting, disaster recovery to multi-tenant management."
---

## Beyond Basic Installation

Most people think of the ConnectWiseAutomateAgent module as just an installation tool. While it excels at deploying agents, its real power comes from solving everyday MSP challenges through automation.

Here are 10 real-world use cases that will change how you work with ConnectWise Automate.

---

## Use Case 1: Automated New Hire Provisioning

**Scenario**: Your client onboards new employees weekly. Each new hire needs a workstation with the RMM agent installed, configured, and reporting.

**Traditional approach**: HR notifies IT → IT provisions machine → IT manually installs agent → Agent appears in Automate... eventually

**PowerShell solution**:

```powershell
# Integrated onboarding script
param(
    [string]$EmployeeName,
    [string]$Department
)

# Determine LocationID based on department
$locationMap = @{
    'Sales' = 100
    'Engineering' = 101
    'Support' = 102
    'Management' = 103
}
$locationID = $locationMap[$Department]

# Provision new computer (your existing process)
$computer = New-ADComputer -Name "WKS-$EmployeeName" -Path "OU=$Department,DC=company,DC=com" -PassThru

# Wait for computer to come online
Wait-Computer -ComputerName $computer.Name

# Install RMM agent
Invoke-Command -ComputerName $computer.Name -ScriptBlock {
    Install-Module ConnectWiseAutomateAgent -Force
    Install-CWAA -Server 'https://automate.msp.com' `
                 -InstallerToken $using:token `
                 -LocationID $using:locationID `
                 -Hide `
                 -Rename "Company IT Services"
}

# Verify
Start-Sleep 30
$agentInfo = Invoke-Command -ComputerName $computer.Name -ScriptBlock {
    Get-CWAAInfo
}

# Update ticket/notification
Send-MailMessage -To "it@company.com" `
                 -Subject "New Hire Setup Complete: $EmployeeName" `
                 -Body "Computer: $($computer.Name)`nAgent ID: $($agentInfo.ID)`nLocation: $Department"
```

**Result**: Fully automated provisioning from AD computer creation to RMM monitoring in minutes.

---

## Use Case 2: Compliance Reporting

**Scenario**: Monthly compliance reports require knowing which machines have RMM agents and which don't.

**PowerShell solution**:

```powershell
# Monthly compliance check
$allComputers = Get-ADComputer -Filter * -SearchBase "DC=company,DC=com"
$complianceReport = @()

foreach ($computer in $allComputers) {
    try {
        $agentInfo = Invoke-Command -ComputerName $computer.Name -ScriptBlock {
            Get-CWAAInfo
        } -ErrorAction Stop

        $complianceReport += [PSCustomObject]@{
            ComputerName = $computer.Name
            HasAgent = $true
            AgentID = $agentInfo.ID
            LastContact = $agentInfo.LastSuccessfulContact
            Version = $agentInfo.Version
            Compliant = $true
        }
    }
    catch {
        $complianceReport += [PSCustomObject]@{
            ComputerName = $computer.Name
            HasAgent = $false
            AgentID = 'N/A'
            LastContact = 'N/A'
            Version = 'N/A'
            Compliant = $false
        }
    }
}

# Generate report
$complianceReport | Export-Csv "Compliance-$(Get-Date -Format 'yyyy-MM').csv" -NoTypeInformation

# Email non-compliant systems
$nonCompliant = $complianceReport | Where-Object { -not $_.Compliant }
if ($nonCompliant) {
    $body = $nonCompliant | ConvertTo-Html | Out-String
    Send-MailMessage -To "compliance@company.com" `
                     -Subject "RMM Compliance Alert: $($nonCompliant.Count) systems need attention" `
                     -Body $body `
                     -BodyAsHtml
}
```

**Result**: Automated monthly compliance reporting with alerts for non-compliant systems.

---

## Use Case 3: Disaster Recovery Testing

**Scenario**: Quarterly DR tests require removing and reinstalling agents to simulate disaster scenarios.

**PowerShell solution**:

```powershell
# DR Test: Backup, remove, and restore agent configurations
param([string[]]$TestComputers)

foreach ($computer in $TestComputers) {
    Write-Host "Testing DR for $computer..." -ForegroundColor Cyan

    Invoke-Command -ComputerName $computer -ScriptBlock {
        # Backup current configuration
        $backup = New-CWAABackup
        $backup | Export-Clixml "C:\Temp\AgentBackup-$(Get-Date -Format 'yyyyMMdd').xml"

        # Simulate disaster - remove agent
        Uninstall-CWAA -Force

        # Wait
        Start-Sleep 10

        # Restore from backup
        $restoredSettings = Import-Clixml "C:\Temp\AgentBackup-$(Get-Date -Format 'yyyyMMdd').xml"

        Install-CWAA -Server $restoredSettings.Server `
                     -LocationID $restoredSettings.LocationID `
                     -InstallerToken $using:token

        # Verify
        $newInfo = Get-CWAAInfo
        if ($newInfo.ID -and $newInfo.LocationID -eq $restoredSettings.LocationID) {
            Write-Host "DR Test PASSED for $env:COMPUTERNAME" -ForegroundColor Green
        }
        else {
            Write-Host "DR Test FAILED for $env:COMPUTERNAME" -ForegroundColor Red
        }
    }
}
```

**Result**: Automated DR testing with verification that agents can be restored to correct configurations.

---

## Use Case 4: Agent Version Audit and Update

**Scenario**: Critical vulnerability found in agent version 11.1.2345. Need to identify and update all affected agents immediately.

**PowerShell solution**:

```powershell
# Find and update vulnerable agents
$vulnerableVersion = '11.1.2345'
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

$affectedSystems = $computers | ForEach-Object -Parallel {
    try {
        $info = Invoke-Command -ComputerName $_ -ScriptBlock {
            Get-CWAAInfo
        } -ErrorAction Stop

        if ($info.Version -eq $using:vulnerableVersion) {
            [PSCustomObject]@{
                Computer = $_
                CurrentVersion = $info.Version
                NeedsUpdate = $true
            }
        }
    }
    catch {
        # Skip offline/inaccessible machines
    }
} -ThrottleLimit 20

# Report affected systems
Write-Host "Found $($affectedSystems.Count) systems with vulnerable version" -ForegroundColor Yellow
$affectedSystems | Export-Csv "VulnerableAgents.csv" -NoTypeInformation

# Update all affected systems
$affectedSystems | ForEach-Object -Parallel {
    Invoke-Command -ComputerName $_.Computer -ScriptBlock {
        Import-Module ConnectWiseAutomateAgent
        Update-CWAA
    }
} -ThrottleLimit 10

Write-Host "Updates deployed to $($affectedSystems.Count) systems" -ForegroundColor Green
```

**Result**: Rapid identification and patching of vulnerable agents across entire infrastructure.

---

## Use Case 5: Multi-Tenant Client Segregation

**Scenario**: MSP managing 50+ clients, each needs agents deployed to correct locations with proper naming.

**PowerShell solution**:

```powershell
# Client configuration database
$clientConfig = @(
    @{ ClientName = 'Acme Corp'; LocationID = 100; Server = 'https://automate.msp.com'; Token = 'token1'; DisplayName = 'Acme IT Services' }
    @{ ClientName = 'Globex Inc'; LocationID = 200; Server = 'https://automate.msp.com'; Token = 'token2'; DisplayName = 'Globex Monitoring' }
    @{ ClientName = 'Initech LLC'; LocationID = 300; Server = 'https://automate.msp.com'; Token = 'token3'; DisplayName = 'Initech IT Support' }
)

# Deploy based on client
function Deploy-ClientAgent {
    param(
        [string]$ComputerName,
        [string]$ClientName
    )

    $config = $clientConfig | Where-Object { $_.ClientName -eq $ClientName } | Select-Object -First 1

    if (-not $config) {
        Write-Error "Client $ClientName not found in configuration"
        return
    }

    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
        Install-CWAA -Server $using:config.Server `
                     -InstallerToken $using:config.Token `
                     -LocationID $using:config.LocationID `
                     -Rename $using:config.DisplayName `
                     -Hide
    }

    Write-Host "Deployed agent for $ClientName to $ComputerName" -ForegroundColor Green
}

# Usage
Deploy-ClientAgent -ComputerName "ACME-WKS001" -ClientName "Acme Corp"
```

**Result**: Standardized, error-free agent deployment with proper client segregation and branding.

---

## Use Case 6: Proxy Configuration Management

**Scenario**: Client changes proxy server. Need to update all 300 agents immediately.

**PowerShell solution**:

```powershell
# Update proxy on all agents
param(
    [string]$NewProxyURL = "http://newproxy.client.com:8080",
    [string]$ClientLocationID = 100
)

# Get all computers for this client
$computers = Invoke-RestMethod -Uri "https://automate.msp.com/api/computers?locationId=$ClientLocationID"

# Update proxy on each
$results = $computers | ForEach-Object -Parallel {
    $computer = $_.ComputerName

    try {
        Invoke-Command -ComputerName $computer -ScriptBlock {
            Import-Module ConnectWiseAutomateAgent
            Set-CWAAProxy -ProxyServerURL $using:NewProxyURL
            Restart-CWAA
        }

        [PSCustomObject]@{
            Computer = $computer
            Status = 'Updated'
        }
    }
    catch {
        [PSCustomObject]@{
            Computer = $computer
            Status = "Failed: $($_.Exception.Message)"
        }
    }
} -ThrottleLimit 25

# Report
$results | Export-Csv "ProxyUpdate-Results.csv" -NoTypeInformation
Write-Host "Updated proxy on $(($results | Where-Object Status -eq 'Updated').Count) computers" -ForegroundColor Green
```

**Result**: Instant proxy configuration change across entire client infrastructure.

---

## Use Case 7: Pre-Migration Agent Removal

**Scenario**: Migrating client from ConnectWise Automate to different RMM. Need clean agent removal from 400 endpoints.

**PowerShell solution**:

```powershell
# Mass agent removal with verification
$computers = Get-ADComputer -Filter * -SearchBase "OU=Client,DC=domain,DC=com"

$removalResults = $computers | ForEach-Object -Parallel {
    $computer = $_.Name

    try {
        Invoke-Command -ComputerName $computer -ScriptBlock {
            Import-Module ConnectWiseAutomateAgent
            Uninstall-CWAA -Force

            # Verify removal
            Start-Sleep 10
            $service = Get-Service LTService -ErrorAction SilentlyContinue
            if ($service) {
                throw "Service still present after uninstall"
            }

            # Verify registry cleaned
            $reg = Get-ItemProperty "HKLM:\SOFTWARE\LabTech\Service" -ErrorAction SilentlyContinue
            if ($reg) {
                throw "Registry keys still present"
            }
        }

        [PSCustomObject]@{
            Computer = $computer
            Status = 'Removed'
            Message = 'Agent fully removed and verified'
        }
    }
    catch {
        [PSCustomObject]@{
            Computer = $computer
            Status = 'Failed'
            Message = $_.Exception.Message
        }
    }
} -ThrottleLimit 15

# Report
$removalResults | Export-Csv "AgentRemoval-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
$successful = ($removalResults | Where-Object Status -eq 'Removed').Count
Write-Host "Successfully removed agents from $successful / $($computers.Count) computers" -ForegroundColor Green
```

**Result**: Clean, verified removal of agents from entire client infrastructure.

---

## Use Case 8: Network Segmentation Testing

**Scenario**: Testing firewall rules for new office. Need to verify RMM connectivity from test subnet.

**PowerShell solution**:

```powershell
# Network connectivity verification script
param(
    [string[]]$TestComputers,
    [string]$Server = "https://automate.msp.com"
)

$testResults = foreach ($computer in $TestComputers) {
    Invoke-Command -ComputerName $computer -ScriptBlock {
        Import-Module ConnectWiseAutomateAgent

        # Test all required ports
        $portTests = Test-CWAAPort -Server $using:Server

        # Get detailed results
        [PSCustomObject]@{
            Computer = $env:COMPUTERNAME
            Subnet = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch 'Loopback' } | Select-Object -First 1).IPAddress
            Port70 = ($portTests | Where-Object Port -eq 70).Open
            Port80 = ($portTests | Where-Object Port -eq 80).Open
            Port443 = ($portTests | Where-Object Port -eq 443).Open
            Port8002 = ($portTests | Where-Object Port -eq 8002).Open
            AllPortsOpen = -not ($portTests | Where-Object { -not $_.Open })
        }
    }
}

# Report
$testResults | Format-Table -AutoSize
$failures = $testResults | Where-Object { -not $_.AllPortsOpen }

if ($failures) {
    Write-Host "`nFirewall issues detected on $($failures.Count) computers:" -ForegroundColor Red
    $failures | Format-Table Computer, Subnet, Port70, Port80, Port443, Port8002
}
else {
    Write-Host "All network connectivity tests passed!" -ForegroundColor Green
}
```

**Result**: Automated firewall rule verification before agent deployment.

---

## Use Case 9: Scheduled Health Monitoring

**Scenario**: Daily health check of all agents with automatic remediation of common issues.

**PowerShell solution**:

```powershell
# Daily agent health check with auto-remediation
# Run as scheduled task at 6 AM daily

$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
$issues = @()

foreach ($computer in $computers) {
    try {
        $health = Invoke-Command -ComputerName $computer -ScriptBlock {
            Import-Module ConnectWiseAutomateAgent

            $info = Get-CWAAInfo
            $services = Get-Service LTService, LTSvcMon

            # Check for issues
            $problems = @()

            # Issue 1: Services stopped
            if ($services.Status -contains 'Stopped') {
                Restart-CWAA
                $problems += "Services were stopped - restarted"
            }

            # Issue 2: Old last contact (> 1 hour)
            $lastContact = [datetime]$info.LastSuccessfulContact
            if ((Get-Date) - $lastContact -gt [timespan]::FromHours(1)) {
                Invoke-CWAACommand -Command "Send Status"
                $problems += "Stale last contact - forced status update"
            }

            # Issue 3: Critical errors in logs
            $errors = Get-CWAAError -Tail 100 | Where-Object { $_ -match "CRITICAL|FATAL" }
            if ($errors) {
                $problems += "Critical errors in log: $($errors.Count) entries"
            }

            if ($problems.Count -gt 0) {
                [PSCustomObject]@{
                    Computer = $env:COMPUTERNAME
                    Issues = $problems -join '; '
                    Remediated = $true
                }
            }
        }

        if ($health) {
            $issues += $health
        }
    }
    catch {
        $issues += [PSCustomObject]@{
            Computer = $computer
            Issues = "Unable to connect: $($_.Exception.Message)"
            Remediated = $false
        }
    }
}

# Send daily report
if ($issues.Count -gt 0) {
    $htmlReport = $issues | ConvertTo-Html -Title "Daily Agent Health Report" | Out-String

    Send-MailMessage -To "ops@msp.com" `
                     -From "monitoring@msp.com" `
                     -Subject "Daily Agent Health Report: $($issues.Count) issues found" `
                     -Body $htmlReport `
                     -BodyAsHtml `
                     -SmtpServer "smtp.msp.com"

    $issues | Export-Csv "HealthReport-$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
}
```

**Result**: Proactive monitoring and auto-remediation of common agent issues before they become tickets.

---

## Use Case 10: Custom Agent Branding Per Department

**Scenario**: Large enterprise wants different agent display names per department for charge-back reporting.

**PowerShell solution**:

```powershell
# Department-based agent naming
$departmentMap = @{
    'OU=Sales' = 'Sales Department IT'
    'OU=Engineering' = 'Engineering Services'
    'OU=HR' = 'Human Resources IT'
    'OU=Finance' = 'Finance Department IT'
}

$computers = Get-ADComputer -Filter * -Properties DistinguishedName

foreach ($computer in $computers) {
    # Determine department from DN
    $department = $departmentMap.Keys | Where-Object { $computer.DistinguishedName -match $_ } | Select-Object -First 1
    $displayName = $departmentMap[$department]

    if ($displayName) {
        Invoke-Command -ComputerName $computer.Name -ScriptBlock {
            Import-Module ConnectWiseAutomateAgent
            Rename-CWAAAddRemove -Name $using:displayName
        }

        Write-Host "Updated $($computer.Name) to '$displayName'" -ForegroundColor Green
    }
}
```

**Result**: Automated agent branding based on organizational structure for accurate charge-back.

---

## Common Patterns Across Use Cases

These use cases all leverage common patterns:

1. **Parallel execution** - Process many machines simultaneously
2. **Error handling** - Graceful failure management
3. **Reporting** - CSV exports and email notifications
4. **Verification** - Always confirm actions succeeded
5. **Integration** - Work with AD, ticketing, monitoring systems

## Building Your Own Use Cases

The ConnectWiseAutomateAgent module provides the building blocks. Combine functions to solve your unique challenges:

```powershell
# Template for custom use cases
param([string[]]$Computers)

$results = $Computers | ForEach-Object -Parallel {
    try {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            Import-Module ConnectWiseAutomateAgent

            # Your logic here
            # - Get-CWAAInfo
            # - Set-CWAAProxy
            # - Restart-CWAA
            # - etc.
        }

        # Success
        [PSCustomObject]@{
            Computer = $_
            Status = 'Success'
        }
    }
    catch {
        # Failure
        [PSCustomObject]@{
            Computer = $_
            Status = 'Failed'
            Error = $_.Exception.Message
        }
    }
} -ThrottleLimit 20

# Report results
$results | Export-Csv "Results.csv" -NoTypeInformation
```

## Conclusion

ConnectWiseAutomateAgent isn't just an installation tool—it's a comprehensive automation framework for RMM management. Whether you're provisioning new hires, ensuring compliance, managing disasters, or solving unique business challenges, the module provides the tools you need.

What use case will you automate next?

---

## Resources

- **Install Module**: `Install-Module ConnectWiseAutomateAgent`
- **GitHub**: [https://github.com/christaylorcodes/ConnectWiseAutomateAgent](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
- **Series Posts**:
  - [Introducing ConnectWiseAutomateAgent]({% post_url 2024-11-01-introducing-connectwise-automate-agent %})
  - [Mass Agent Deployment]({% post_url 2024-11-08-mass-agent-deployment-connectwise-automate %})
  - [Troubleshooting Guide]({% post_url 2024-11-15-troubleshooting-connectwise-automate-agents-powershell %})

**Share your use case**: If you've built something cool with this module, submit it as a GitHub issue tagged "Community Use Case" and we'll feature it!
