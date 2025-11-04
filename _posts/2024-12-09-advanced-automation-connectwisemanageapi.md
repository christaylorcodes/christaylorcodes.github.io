---
layout: post
title: "Advanced Automation Scenarios with ConnectWiseManageAPI"
date: 2024-12-09 09:00:00 -0500
categories: [PowerShell, PSA, ConnectWiseManageAPI]
tags: [PowerShell, ConnectWise, Manage, PSA, Automation, Advanced, Integration, MSP]
author: Chris Taylor
excerpt: "Real-world automation scenarios that transform MSP operations. Learn how to build automated ticket enrichment, bulk time entries, data quality monitoring, custom reporting, and system integrations with ConnectWiseManageAPI."
---

Now that you're comfortable with the basics, let's explore some advanced automation scenarios that can transform your MSP operations. These examples demonstrate real-world use cases that save hours of manual work and improve service delivery.

## Scenario 1: Automated Ticket Enrichment from RMM

One of the most powerful integrations is connecting your RMM monitoring to ConnectWise Manage. When an alert fires, automatically create a ticket with all relevant context.

### The Challenge

When monitoring alerts trigger, technicians often need to gather information manually:
- What is the device configuration?
- What's the recent uptime history?
- Are there related open tickets?
- What's the maintenance history?

### The Solution

```powershell
function New-EnrichedCWMTicket {
    param(
        [string]$AlertMessage,
        [string]$DeviceName,
        [string]$CompanyName,
        [hashtable]$MonitoringData
    )

    # Get company from Manage
    $Company = Get-CWMCompany -condition "name='$CompanyName'" | Select-Object -First 1

    if (-not $Company) {
        Write-Error "Company not found: $CompanyName"
        return
    }

    # Get device configuration
    $Configuration = Get-CWMCompanyConfiguration -condition "name='$DeviceName' and company/id=$($Company.id)" |
        Select-Object -First 1

    # Check for similar open tickets
    $ExistingTickets = Get-CWMTicket -condition "company/id=$($Company.id) and status/name!='Closed' and summary contains '$DeviceName'" -all

    # Build enriched ticket description
    $Description = @"
Alert: $AlertMessage
Device: $DeviceName
Time: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

=== Device Information ===
Configuration ID: $($Configuration.id)
Device Type: $($Configuration.type.name)
Last Updated: $($Configuration._info.lastUpdated)

=== Monitoring Data ===
$(($MonitoringData.GetEnumerator() | ForEach-Object { "- $($_.Key): $($_.Value)" }) -join "`n")

=== Related Tickets ===
$( if ($ExistingTickets) {
    ($ExistingTickets | ForEach-Object { "- Ticket #$($_.id): $($_.summary)" }) -join "`n"
} else {
    "No related open tickets found."
})
"@

    # Create the ticket
    $TicketParams = @{
        summary = "[$DeviceName] $AlertMessage"
        company = @{id = $Company.id}
        board = @{id = 1}  # Adjust to your monitoring board
        priority = @{id = switch ($MonitoringData.Severity) {
            'Critical' { 1 }
            'High'     { 2 }
            'Medium'   { 3 }
            'Low'      { 4 }
            default    { 3 }
        }}
    }

    if ($Configuration) {
        $TicketParams.Add('configurations', @(@{id = $Configuration.id}))
    }

    $Ticket = New-CWMTicket @TicketParams

    # Add detailed note
    New-CWMTicketNote -ticketId $Ticket.id -text $Description -internalAnalysisFlag $true

    Write-Output "Created enriched ticket #$($Ticket.id)"
    return $Ticket
}

# Example usage
$MonitoringData = @{
    Severity = 'High'
    CPUUsage = '95%'
    MemoryUsage = '87%'
    DiskSpace = '12% free'
    Uptime = '127 days'
}

New-EnrichedCWMTicket -AlertMessage "High CPU Usage Detected" `
    -DeviceName "SERVER-WEB-01" `
    -CompanyName "Acme Corporation" `
    -MonitoringData $MonitoringData
```

### Key Benefits

- Tickets are created with full context
- Related tickets are identified automatically
- Configuration items are linked
- Priority is set based on severity
- Technicians have everything they need to start troubleshooting

## Scenario 2: Bulk Time Entry Creation

Many MSPs struggle with time tracking, especially for activities performed in bulk across multiple clients.

### The Challenge

You spent 4 hours reviewing and updating security policies across 20 client companies. Manually creating 20 time entries is tedious and error-prone.

### The Solution

```powershell
function New-BulkTimeEntries {
    param(
        [int]$MemberID,
        [string]$Activity,
        [double]$HoursPerCompany,
        [string]$WorkRole,
        [string[]]$CompanyNames,
        [string]$Notes
    )

    $Results = @()
    $StartTime = (Get-Date).AddHours(-($HoursPerCompany * $CompanyNames.Count))

    foreach ($CompanyName in $CompanyNames) {
        # Get company
        $Company = Get-CWMCompany -condition "name='$CompanyName'" | Select-Object -First 1

        if (-not $Company) {
            Write-Warning "Company not found: $CompanyName. Skipping."
            continue
        }

        # Find or create agreement for time entry
        $Agreement = Get-CWMAgreement -condition "company/id=$($Company.id) and cancelled=false" |
            Where-Object { $_.workRole -eq $WorkRole } |
            Select-Object -First 1

        if (-not $Agreement) {
            Write-Warning "No active agreement found for $CompanyName. Skipping."
            continue
        }

        # Create time entry
        $TimeEntryParams = @{
            company = @{id = $Company.id}
            member = @{id = $MemberID}
            workRole = @{name = $WorkRole}
            workType = @{name = $Activity}
            timeStart = $StartTime | ConvertTo-CWMTime -Raw
            timeEnd = $StartTime.AddHours($HoursPerCompany) | ConvertTo-CWMTime -Raw
            notes = "$Notes - Company: $CompanyName"
            agreement = @{id = $Agreement.id}
        }

        try {
            $TimeEntry = New-CWMTimeEntry @TimeEntryParams
            $Results += [PSCustomObject]@{
                Company = $CompanyName
                TimeEntryID = $TimeEntry.id
                Hours = $HoursPerCompany
                Status = 'Success'
            }
            Write-Host "Created time entry for $CompanyName" -ForegroundColor Green
        }
        catch {
            $Results += [PSCustomObject]@{
                Company = $CompanyName
                TimeEntryID = $null
                Hours = $HoursPerCompany
                Status = "Failed: $($_.Exception.Message)"
            }
            Write-Warning "Failed to create time entry for $CompanyName: $_"
        }

        # Update start time for next entry
        $StartTime = $StartTime.AddHours($HoursPerCompany)
    }

    return $Results
}

# Example usage
$Companies = @(
    'Acme Corporation',
    'TechStart Inc',
    'Global Manufacturing Co',
    'Healthcare Solutions LLC'
)

$Results = New-BulkTimeEntries -MemberID 123 `
    -Activity 'Security Review' `
    -HoursPerCompany 0.5 `
    -WorkRole 'Senior Network Engineer' `
    -CompanyNames $Companies `
    -Notes 'Quarterly security policy review and updates'

$Results | Format-Table -AutoSize
```

### Key Benefits

- Create multiple time entries in seconds
- Consistent formatting and notes
- Automatic agreement detection
- Error handling with clear reporting
- Accurate time tracking without manual effort

## Scenario 3: Scheduled Data Quality Monitoring

Maintain clean data in your PSA by regularly scanning for issues and either fixing them automatically or creating tickets for review.

### The Challenge

Over time, data quality degrades:
- Companies without primary contacts
- Contacts missing email addresses
- Tickets with no assigned resources
- Missing configuration items

### The Solution

```powershell
function Invoke-CWMDataQualityCheck {
    param(
        [switch]$AutoFix,
        [string]$NotificationEmail
    )

    $Issues = @()

    Write-Host "Running data quality checks..." -ForegroundColor Cyan

    # Check 1: Companies without primary contacts
    Write-Host "Checking for companies without primary contacts..."
    $AllCompanies = Get-CWMCompany -all
    foreach ($Company in $AllCompanies) {
        $PrimaryContact = Get-CWMContact -condition "company/id=$($Company.id) and defaultFlag=true" |
            Select-Object -First 1

        if (-not $PrimaryContact) {
            $Issues += [PSCustomObject]@{
                IssueType = 'Missing Primary Contact'
                CompanyID = $Company.id
                CompanyName = $Company.name
                Details = 'No default contact set'
                AutoFixable = $false
            }
        }
    }

    # Check 2: Contacts missing email addresses
    Write-Host "Checking for contacts without email addresses..."
    $AllContacts = Get-CWMContact -condition "email=null" -all
    foreach ($Contact in $AllContacts) {
        $Issues += [PSCustomObject]@{
            IssueType = 'Missing Email'
            CompanyID = $Contact.company.id
            CompanyName = $Contact.company.name
            Details = "Contact: $($Contact.firstName) $($Contact.lastName) (ID: $($Contact.id))"
            AutoFixable = $false
        }
    }

    # Check 3: Open tickets without assigned resources
    Write-Host "Checking for unassigned open tickets..."
    $UnassignedTickets = Get-CWMTicket -condition "status/name!='Closed' and resources=null" -all
    foreach ($Ticket in $UnassignedTickets) {
        $Issues += [PSCustomObject]@{
            IssueType = 'Unassigned Ticket'
            CompanyID = $Ticket.company.id
            CompanyName = $Ticket.company.name
            Details = "Ticket #$($Ticket.id): $($Ticket.summary)"
            AutoFixable = $AutoFix
        }

        # Auto-fix: Assign to default team member for the board
        if ($AutoFix) {
            try {
                $DefaultMember = Get-CWMSystemMember -condition "defaultFlag=true" | Select-Object -First 1
                if ($DefaultMember) {
                    $UpdateOps = @(
                        @{
                            op = 'replace'
                            path = 'owner'
                            value = @{id = $DefaultMember.id}
                        }
                    )
                    Update-CWMTicket -TicketID $Ticket.id -Operation $UpdateOps
                    Write-Host "  Auto-fixed: Assigned ticket #$($Ticket.id) to $($DefaultMember.identifier)" -ForegroundColor Green
                }
            }
            catch {
                Write-Warning "  Failed to auto-fix ticket #$($Ticket.id): $_"
            }
        }
    }

    # Check 4: Companies without configurations
    Write-Host "Checking for companies without configurations..."
    foreach ($Company in $AllCompanies) {
        $Configs = Get-CWMCompanyConfiguration -condition "company/id=$($Company.id)" -count
        if ($Configs -eq 0) {
            $Issues += [PSCustomObject]@{
                IssueType = 'No Configurations'
                CompanyID = $Company.id
                CompanyName = $Company.name
                Details = 'Company has no configuration items'
                AutoFixable = $false
            }
        }
    }

    # Generate report
    $Report = @"
ConnectWise Manage Data Quality Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Total Issues Found: $($Issues.Count)

=== Summary by Issue Type ===
$($Issues | Group-Object IssueType |
    Select-Object Name, Count |
    Format-Table -AutoSize |
    Out-String)

=== Detailed Issues ===
$($Issues | Format-Table -AutoSize | Out-String)
"@

    Write-Host $Report

    # Export to CSV
    $ReportPath = ".\CWM_DataQuality_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $Issues | Export-Csv -Path $ReportPath -NoTypeInformation
    Write-Host "Report exported to: $ReportPath" -ForegroundColor Green

    # Send notification email if configured
    if ($NotificationEmail) {
        # Integrate with your email system here
        Write-Host "Notification email would be sent to: $NotificationEmail"
    }

    return $Issues
}

# Schedule this to run daily
Invoke-CWMDataQualityCheck -AutoFix -NotificationEmail 'ops@msp.com'
```

### Scheduling the Script

Create a scheduled task to run this daily:

```powershell
$Action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
    -Argument '-File "C:\Scripts\CWM-DataQuality.ps1"'

$Trigger = New-ScheduledTaskTrigger -Daily -At 6:00AM

$Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable `
    -DontStopIfGoingOnBatteries `
    -AllowStartIfOnBatteries

Register-ScheduledTask -TaskName "CWM Data Quality Check" `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -Description "Daily ConnectWise Manage data quality monitoring"
```

## Scenario 4: Custom Reporting with Multi-Source Data

Combine data from ConnectWise Manage with other systems to create comprehensive reports.

### The Challenge

Management wants a monthly report showing:
- Ticket volume by company
- Average resolution time
- Time entries and billable hours
- Revenue from agreements
- Client satisfaction scores (from external survey system)

### The Solution

```powershell
function New-MonthlyClientReport {
    param(
        [DateTime]$StartDate = (Get-Date).AddMonths(-1).Date,
        [DateTime]$EndDate = (Get-Date).Date
    )

    $Report = @()

    # Get all active companies
    $Companies = Get-CWMCompany -condition "status/name='Active'" -all

    foreach ($Company in $Companies) {
        Write-Progress -Activity "Generating report" `
            -Status "Processing $($Company.name)" `
            -PercentComplete (($Report.Count / $Companies.Count) * 100)

        # Get ticket metrics
        $Tickets = Get-CWMTicket -condition "company/id=$($Company.id) and closedDate>='$($StartDate.ToString('yyyy-MM-dd'))' and closedDate<='$($EndDate.ToString('yyyy-MM-dd'))'" -all

        $TicketCount = $Tickets.Count

        $AvgResolutionTime = if ($Tickets) {
            ($Tickets | ForEach-Object {
                $Entered = [DateTime]$_.enteredDate
                $Closed = [DateTime]$_.closedDate
                ($Closed - $Entered).TotalHours
            } | Measure-Object -Average).Average
        } else { 0 }

        # Get time entries
        $TimeEntries = Get-CWMTimeEntry -condition "company/id=$($Company.id) and timeStart>='$($StartDate.ToString('yyyy-MM-dd'))' and timeStart<='$($EndDate.ToString('yyyy-MM-dd'))'" -all

        $TotalHours = ($TimeEntries | Measure-Object -Property actualHours -Sum).Sum
        $BillableHours = ($TimeEntries | Where-Object { $_.billableOption -eq 'Billable' } | Measure-Object -Property actualHours -Sum).Sum

        # Get agreements
        $Agreements = Get-CWMAgreement -condition "company/id=$($Company.id) and cancelled=false" -all
        $MonthlyRecurring = ($Agreements | Measure-Object -Property agreementAmount -Sum).Sum

        # Add to report
        $Report += [PSCustomObject]@{
            CompanyName = $Company.name
            TicketCount = $TicketCount
            AvgResolutionHours = [Math]::Round($AvgResolutionTime, 2)
            TotalHours = [Math]::Round($TotalHours, 2)
            BillableHours = [Math]::Round($BillableHours, 2)
            BillablePercentage = if ($TotalHours -gt 0) { [Math]::Round(($BillableHours / $TotalHours) * 100, 2) } else { 0 }
            MonthlyRecurring = $MonthlyRecurring
        }
    }

    # Export report
    $ReportPath = ".\ClientReport_$($StartDate.ToString('yyyyMMdd'))_to_$($EndDate.ToString('yyyyMMdd')).csv"

    # Create summary
    $Summary = [PSCustomObject]@{
        ReportPeriod = "$($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))"
        TotalCompanies = $Report.Count
        TotalTickets = ($Report | Measure-Object -Property TicketCount -Sum).Sum
        TotalHours = ($Report | Measure-Object -Property TotalHours -Sum).Sum
        TotalBillableHours = ($Report | Measure-Object -Property BillableHours -Sum).Sum
        TotalMRR = ($Report | Measure-Object -Property MonthlyRecurring -Sum).Sum
    }

    # Display summary
    Write-Host "`nReport Summary:" -ForegroundColor Cyan
    $Summary | Format-List

    Write-Host "`nTop 10 Companies by Ticket Volume:" -ForegroundColor Cyan
    $Report | Sort-Object TicketCount -Descending | Select-Object -First 10 | Format-Table

    # Export to CSV
    $Report | Export-Csv -Path $ReportPath -NoTypeInformation
    Write-Host "`nFull report exported to: $ReportPath" -ForegroundColor Green

    return $Report
}

# Generate report
$Report = New-MonthlyClientReport
```

## Best Practices for Advanced Automation

### Error Handling

Always implement robust error handling:

```powershell
try {
    $Result = Get-CWMTicket -TicketID 12345
}
catch {
    Write-Error "Failed to retrieve ticket: $_"
    # Log to your logging system
    # Send notification
    # Implement retry logic if appropriate
}
```

### Logging

Create detailed logs for troubleshooting:

```powershell
function Write-AutomationLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )

    $LogEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path "C:\Logs\CWMAutomation.log" -Value $LogEntry

    switch ($Level) {
        'Warning' { Write-Warning $Message }
        'Error'   { Write-Error $Message }
        default   { Write-Host $Message }
    }
}
```

### Rate Limiting

Be mindful of API rate limits:

```powershell
function Invoke-CWMWithRateLimit {
    param(
        [scriptblock]$ScriptBlock,
        [int]$DelayMilliseconds = 100
    )

    $Result = & $ScriptBlock
    Start-Sleep -Milliseconds $DelayMilliseconds
    return $Result
}
```

### Testing

Always test with a small dataset first:

```powershell
# Test with one company before running on all
$TestCompany = Get-CWMCompany -CompanyID 123
# Run your automation on $TestCompany
# Verify results
# Then run on all companies
```

## Conclusion

These advanced scenarios demonstrate the power of automating ConnectWise Manage with PowerShell. By combining multiple functions, integrating with other systems, and implementing proper error handling, you can build robust automation that saves time and improves accuracy.

Remember to:
- Start small and iterate
- Test thoroughly before production use
- Implement logging and monitoring
- Handle errors gracefully
- Document your automations

In the next post, we'll cover best practices, performance optimization, and tips from years of real-world usage.

---

**Series Navigation:**
- Previous: [Getting Started with ConnectWiseManageAPI](/2024/12/02/getting-started-connectwisemanageapi.html)
- Next: [Best Practices and Tips](/2024/12/16/best-practices-connectwisemanageapi.html)
