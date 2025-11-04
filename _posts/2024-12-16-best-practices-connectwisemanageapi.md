---
layout: post
title: "Best Practices and Tips for ConnectWiseManageAPI"
date: 2024-12-16 09:00:00 -0500
categories: [PowerShell, PSA, ConnectWiseManageAPI]
tags: [PowerShell, ConnectWise, Manage, PSA, Best-Practices, Security, Performance, MSP]
author: Chris Taylor
excerpt: "Battle-tested best practices from years of real-world MSP implementations. Learn security patterns, performance optimization, error handling, and production deployment strategies for ConnectWiseManageAPI automation."
---

After years of building automation solutions with ConnectWiseManageAPI across numerous MSP environments, I've learned what works—and what doesn't. This post shares battle-tested best practices, performance optimization tips, and lessons learned from real-world implementations.

## Security Best Practices

### Never Hardcode Credentials

This cannot be stressed enough. API credentials are as sensitive as passwords.

**Bad Practice:**

```powershell
# DON'T DO THIS!
Connect-CWM -Server 'na.myconnectwise.net' `
    -Company 'MyCompany' `
    -pubkey 'ABC123XYZ' `
    -privatekey 'super-secret-key' `
    -clientid 'my-client-id'
```

**Best Practice - Azure Key Vault:**

```powershell
# Retrieve from Azure Key Vault
$VaultName = 'MyMSPVault'
$CWMCreds = @{
    Server     = 'na.myconnectwise.net'
    Company    = 'MyCompany'
    pubkey     = Get-AzKeyVaultSecret -VaultName $VaultName -Name 'CWM-PublicKey' -AsPlainText
    privatekey = Get-AzKeyVaultSecret -VaultName $VaultName -Name 'CWM-PrivateKey' -AsPlainText
    clientid   = Get-AzKeyVaultSecret -VaultName $VaultName -Name 'CWM-ClientID' -AsPlainText
}

Connect-CWM @CWMCreds
```

**Best Practice - Environment Variables:**

```powershell
# Set environment variables securely
# Then reference them in scripts
$CWMCreds = @{
    Server     = $env:CWM_SERVER
    Company    = $env:CWM_COMPANY
    pubkey     = $env:CWM_PUBKEY
    privatekey = $env:CWM_PRIVATEKEY
    clientid   = $env:CWM_CLIENTID
}

Connect-CWM @CWMCreds
```

**Best Practice - Encrypted Configuration File:**

```powershell
# Create encrypted credential file (run once)
$CWMCreds = @{
    Server     = 'na.myconnectwise.net'
    Company    = 'MyCompany'
    pubkey     = 'your-public-key'
    privatekey = 'your-private-key'
    clientid   = 'your-client-id'
}

$CWMCreds | ConvertTo-Json |
    ConvertTo-SecureString -AsPlainText -Force |
    ConvertFrom-SecureString |
    Set-Content 'C:\Secure\CWM-Creds.enc'

# Load in scripts
$EncryptedCreds = Get-Content 'C:\Secure\CWM-Creds.enc' |
    ConvertTo-SecureString |
    ConvertFrom-SecureString -AsPlainText |
    ConvertFrom-Json

Connect-CWM @EncryptedCreds
```

### Use Dedicated API Accounts

Create service accounts specifically for API integrations:

1. Create a member account like "API-Automation" or "PowerShell-Integration"
2. Assign only necessary permissions (principle of least privilege)
3. Generate API keys for this account
4. Document what each API account is used for
5. Rotate credentials regularly

### Audit Your Automation

Use ConnectWise's audit trail to monitor API activity:

```powershell
# Review recent API actions
$AuditTrail = Get-CWMAuditTrail -condition "deviceIdentifier contains 'ConnectWiseManageAPI'" -all

# Look for suspicious patterns
$AuditTrail | Group-Object type | Select-Object Name, Count | Sort-Object Count -Descending
```

## Performance Optimization

### Use the -all Parameter Wisely

The `-all` parameter automatically handles pagination, but it can be slow for large datasets.

**When to Use -all:**

```powershell
# Good: Known small dataset
Get-CWMServiceBoard -all

# Good: Filtered results
Get-CWMTicket -condition "closedDate>'2025-01-01'" -all
```

**When to Paginate Manually:**

```powershell
# Better for processing large datasets in chunks
$PageSize = 100
$Page = 1
$AllTickets = @()

do {
    $Tickets = Get-CWMTicket -page $Page -pageSize $PageSize
    $AllTickets += $Tickets

    # Process this batch before getting more
    foreach ($Ticket in $Tickets) {
        # Do work here
    }

    $Page++
} while ($Tickets.Count -eq $PageSize)
```

### Select Only Required Fields

Reduce bandwidth and improve performance by requesting only needed fields:

**Less Efficient:**

```powershell
# Gets all fields (lots of data)
$Companies = Get-CWMCompany -all
```

**More Efficient:**

```powershell
# Gets only what you need
$Companies = Get-CWMCompany -fields "id,name,city,state,status" -all
```

### Use Conditions to Filter Server-Side

Always filter on the server, not after retrieving data:

**Inefficient:**

```powershell
# Gets ALL tickets, then filters locally
$AllTickets = Get-CWMTicket -all
$OpenTickets = $AllTickets | Where-Object { $_.status.name -eq 'Open' }
```

**Efficient:**

```powershell
# Server filters before returning results
$OpenTickets = Get-CWMTicket -condition "status/name='Open'" -all
```

### Implement Caching for Reference Data

Don't repeatedly query for data that rarely changes:

```powershell
# Cache reference data
$script:BoardCache = @{}

function Get-CWMServiceBoardCached {
    param([int]$BoardID)

    if (-not $script:BoardCache.ContainsKey($BoardID)) {
        $script:BoardCache[$BoardID] = Get-CWMServiceBoard -BoardID $BoardID
    }

    return $script:BoardCache[$BoardID]
}

# Use throughout your script
$Board = Get-CWMServiceBoardCached -BoardID 1
```

### Batch Operations When Possible

Instead of making individual API calls in a loop, batch operations:

**Less Efficient:**

```powershell
# Individual update for each ticket
foreach ($TicketID in $TicketIDs) {
    $Ops = @(@{op='replace'; path='status'; value=@{id=5}})
    Update-CWMTicket -TicketID $TicketID -Operation $Ops
    Start-Sleep -Milliseconds 100  # Rate limiting
}
```

**More Efficient:**

```powershell
# Use a single search and bulk update if applicable
# Or at minimum, remove unnecessary operations inside the loop
$UpdateOps = @(@{op='replace'; path='status'; value=@{id=5}})

$TicketIDs | ForEach-Object -Parallel {
    Update-CWMTicket -TicketID $_ -Operation $using:UpdateOps
} -ThrottleLimit 5
```

## Error Handling Patterns

### Implement Comprehensive Try-Catch Blocks

Always anticipate failures:

```powershell
function Get-CompanySafely {
    param([string]$CompanyName)

    try {
        $Company = Get-CWMCompany -condition "name='$CompanyName'" -ErrorAction Stop |
            Select-Object -First 1

        if (-not $Company) {
            Write-Warning "Company not found: $CompanyName"
            return $null
        }

        return $Company
    }
    catch {
        Write-Error "Failed to retrieve company '$CompanyName': $_"
        Write-Error $_.Exception.Message
        return $null
    }
}
```

### Implement Retry Logic for Transient Failures

Network issues and server problems happen. Implement retry logic:

```powershell
function Invoke-CWMWithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 5
    )

    $Attempt = 1

    while ($Attempt -le $MaxRetries) {
        try {
            $Result = & $ScriptBlock
            return $Result
        }
        catch {
            $ErrorMessage = $_.Exception.Message

            if ($Attempt -eq $MaxRetries) {
                throw "Failed after $MaxRetries attempts: $ErrorMessage"
            }

            # Only retry on specific errors (5xx server errors)
            if ($ErrorMessage -match '5\d{2}') {
                Write-Warning "Attempt $Attempt failed: $ErrorMessage. Retrying in $DelaySeconds seconds..."
                Start-Sleep -Seconds $DelaySeconds
                $Attempt++
                $DelaySeconds *= 2  # Exponential backoff
            }
            else {
                throw "Non-retryable error: $ErrorMessage"
            }
        }
    }
}

# Usage
$Ticket = Invoke-CWMWithRetry {
    Get-CWMTicket -TicketID 12345
}
```

### Log Everything Important

Implement comprehensive logging:

```powershell
function Write-CWMLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Warning', 'Error', 'Debug')]
        [string]$Level = 'Info',
        [string]$LogPath = "C:\Logs\CWM-Automation.log"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"

    # Write to log file
    Add-Content -Path $LogPath -Value $LogEntry

    # Write to console with appropriate color
    $Color = switch ($Level) {
        'Error'   { 'Red' }
        'Warning' { 'Yellow' }
        'Debug'   { 'Gray' }
        default   { 'White' }
    }

    Write-Host $LogEntry -ForegroundColor $Color

    # For errors, also write to error stream
    if ($Level -eq 'Error') {
        Write-Error $Message
    }
}

# Usage throughout your scripts
Write-CWMLog "Starting ticket sync process" -Level Info
Write-CWMLog "Failed to update ticket #12345" -Level Error
```

## Code Organization Best Practices

### Modularize Your Functions

Break complex operations into reusable functions:

```powershell
# Good structure
function Get-CWMCompanyWithContacts {
    param([int]$CompanyID)

    $Company = Get-Company -CompanyID $CompanyID
    $Contacts = Get-CompanyContacts -CompanyID $CompanyID
    $PrimaryContact = Get-PrimaryContact -Contacts $Contacts

    return @{
        Company = $Company
        Contacts = $Contacts
        PrimaryContact = $PrimaryContact
    }
}

function Get-Company {
    param([int]$CompanyID)
    return Get-CWMCompany -CompanyID $CompanyID
}

function Get-CompanyContacts {
    param([int]$CompanyID)
    return Get-CWMContact -condition "company/id=$CompanyID" -all
}

function Get-PrimaryContact {
    param($Contacts)
    return $Contacts | Where-Object { $_.defaultFlag -eq $true } | Select-Object -First 1
}
```

### Use Parameter Validation

Leverage PowerShell's validation attributes:

```powershell
function New-AutomatedTicket {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Summary,

        [Parameter(Mandatory)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$CompanyID,

        [ValidateSet('Low', 'Medium', 'High', 'Critical')]
        [string]$Priority = 'Medium',

        [ValidateScript({Test-Path $_})]
        [string]$LogPath = "C:\Logs\automation.log"
    )

    # Function implementation
}
```

### Create Reusable Script Modules

Organize frequently used functions into a module:

```powershell
# Save as MyMSPAutomation.psm1
function Get-CWMCompanyWithValidation {
    param([string]$CompanyName)
    # Implementation
}

function New-EnrichedTicket {
    param([hashtable]$TicketData)
    # Implementation
}

Export-ModuleMember -Function Get-CWMCompanyWithValidation, New-EnrichedTicket
```

Load it in your scripts:

```powershell
Import-Module "C:\Scripts\Modules\MyMSPAutomation.psm1"
```

## Multi-Tenant Considerations

### Always Consider Client Isolation

In MSP environments, ensure operations are properly scoped:

```powershell
function Update-CompanyTickets {
    param(
        [int]$CompanyID,  # Always require CompanyID
        [string]$StatusName
    )

    # Verify company exists and user has access
    $Company = Get-CWMCompany -CompanyID $CompanyID
    if (-not $Company) {
        throw "Company $CompanyID not found or not accessible"
    }

    # Scope tickets to this company only
    $Tickets = Get-CWMTicket -condition "company/id=$CompanyID and status/name!='$StatusName'" -all

    # Process tickets
}
```

### Test with Multiple Client Scenarios

When building automation for multi-tenant use:

1. Test with clients of different sizes
2. Test with clients on different agreement types
3. Test with varying permission levels
4. Test with special characters in company names
5. Test with companies in different statuses

## Data Validation Tips

### Validate Input Data

Always validate before making changes:

```powershell
function Update-CWMCompanyAddress {
    param(
        [int]$CompanyID,
        [string]$Address,
        [string]$City,
        [string]$State,
        [string]$Zip
    )

    # Validate inputs
    if ($State -notmatch '^[A-Z]{2}$') {
        throw "State must be a 2-letter abbreviation"
    }

    if ($Zip -notmatch '^\d{5}(-\d{4})?$') {
        throw "Invalid ZIP code format"
    }

    # Proceed with update
    $UpdateOps = @(
        @{op='replace'; path='addressLine1'; value=$Address}
        @{op='replace'; path='city'; value=$City}
        @{op='replace'; path='state'; value=$State}
        @{op='replace'; path='zip'; value=$Zip}
    )

    Update-CWMCompany -CompanyID $CompanyID -Operation $UpdateOps
}
```

### Verify Changes After Updates

Always confirm critical changes:

```powershell
# Update ticket
$UpdateOps = @(@{op='replace'; path='status'; value=@{id=5}})
Update-CWMTicket -TicketID 12345 -Operation $UpdateOps

# Verify the change
$UpdatedTicket = Get-CWMTicket -TicketID 12345
if ($UpdatedTicket.status.id -ne 5) {
    Write-Error "Status update failed for ticket 12345"
}
else {
    Write-Host "Successfully updated ticket 12345" -ForegroundColor Green
}
```

## Testing Strategies

### Use Test Companies

Create test companies in your Manage environment:

1. Create a company named "TEST - Automation Testing"
2. Mark it clearly as a test company
3. Use it for all automation development and testing
4. Clean up test data regularly

### Implement Dry-Run Mode

Add a `-WhatIf` capability to your scripts:

```powershell
function Update-BulkTickets {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [int[]]$TicketIDs,
        [hashtable]$UpdateData
    )

    foreach ($TicketID in $TicketIDs) {
        if ($PSCmdlet.ShouldProcess("Ticket $TicketID", "Update with $($UpdateData | ConvertTo-Json -Compress)")) {
            # Perform actual update
            Update-CWMTicket -TicketID $TicketID -Operation $UpdateData
        }
    }
}

# Test run without making changes
Update-BulkTickets -TicketIDs @(123, 456, 789) -UpdateData $UpdateOps -WhatIf
```

### Start Small, Scale Gradually

When deploying new automation:

1. Test with 1 record
2. Test with 10 records
3. Test with 100 records
4. Monitor for issues
5. Scale to production

## Monitoring and Alerting

### Monitor Your Automation

Create health checks for your automation:

```powershell
function Test-CWMAutomationHealth {
    $HealthChecks = @()

    # Check 1: Can we connect?
    try {
        Connect-CWM @CWMCreds
        $HealthChecks += @{Check='Connection'; Status='Pass'}
    }
    catch {
        $HealthChecks += @{Check='Connection'; Status='Fail'; Error=$_.Exception.Message}
    }

    # Check 2: Can we retrieve data?
    try {
        $null = Get-CWMSystemInfo
        $HealthChecks += @{Check='Data Retrieval'; Status='Pass'}
    }
    catch {
        $HealthChecks += @{Check='Data Retrieval'; Status='Fail'; Error=$_.Exception.Message}
    }

    # Check 3: Are scheduled jobs running?
    $LastRun = Get-Content "C:\Logs\last-run.txt" -ErrorAction SilentlyContinue
    if ($LastRun) {
        $LastRunTime = [DateTime]$LastRun
        if ((Get-Date) - $LastRunTime -gt [TimeSpan]::FromHours(25)) {
            $HealthChecks += @{Check='Scheduled Jobs'; Status='Warning'; Error='No run in 25 hours'}
        }
        else {
            $HealthChecks += @{Check='Scheduled Jobs'; Status='Pass'}
        }
    }

    return $HealthChecks
}

# Run health checks and alert if needed
$Health = Test-CWMAutomationHealth
if ($Health | Where-Object Status -ne 'Pass') {
    # Send alert
    Send-MailMessage -To 'ops@msp.com' -Subject 'CWM Automation Health Alert' -Body ($Health | Out-String)
}
```

### Track Automation Metrics

Monitor the effectiveness of your automation:

```powershell
function Write-AutomationMetric {
    param(
        [string]$MetricName,
        [double]$Value,
        [hashtable]$Tags = @{}
    )

    $Metric = [PSCustomObject]@{
        Timestamp = Get-Date -Format "o"
        MetricName = $MetricName
        Value = $Value
        Tags = $Tags
    }

    # Export to your monitoring system
    # Or log to a file for later analysis
    $Metric | ConvertTo-Json -Compress | Add-Content "C:\Logs\metrics.jsonl"
}

# Track metrics in your automation
$StartTime = Get-Date
$TicketsProcessed = Process-Tickets
$Duration = (Get-Date) - $StartTime

Write-AutomationMetric -MetricName "tickets_processed" -Value $TicketsProcessed
Write-AutomationMetric -MetricName "processing_duration_seconds" -Value $Duration.TotalSeconds
```

## Documentation Best Practices

### Document Your Automations

Create README files for each automation project:

```markdown
# Ticket Sync Automation

## Purpose
Synchronizes tickets between ConnectWise Manage and ServiceNow.

## Schedule
Runs every 15 minutes via scheduled task.

## Prerequisites
- ConnectWiseManageAPI module v0.4.16+
- ServiceNow API credentials in Azure Key Vault
- PowerShell 7.0+

## Configuration
Edit config.json for:
- Board mappings
- Status translations
- Field mappings

## Troubleshooting
Check logs at: C:\Logs\TicketSync\

Common issues:
- Rate limiting: Increase delay in config
- Authentication: Check Key Vault access
```

### Comment Complex Logic

Explain the "why," not just the "what":

```powershell
# Good comments explain reasoning
# We need to delay 2 seconds between calls because the CW API
# has undocumented rate limiting that causes 429 errors
# if we exceed 30 calls per minute
Start-Sleep -Seconds 2

# Bad comments just repeat the code
# Sleep for 2 seconds
Start-Sleep -Seconds 2
```

## Conclusion

Building reliable automation with ConnectWiseManageAPI requires attention to security, performance, error handling, and maintainability. By following these best practices, you'll create automation that:

- Runs reliably in production
- Is easy to maintain and update
- Handles errors gracefully
- Performs efficiently at scale
- Is secure and auditable

Remember: start simple, test thoroughly, and iterate based on real-world usage. The best automation is the automation that runs without you thinking about it.

## Quick Reference Checklist

Use this checklist when building new automation:

- [ ] Credentials stored securely (Key Vault, environment variables, encrypted file)
- [ ] Dedicated API account with appropriate permissions
- [ ] Error handling with try-catch blocks
- [ ] Retry logic for transient failures
- [ ] Comprehensive logging
- [ ] Input validation
- [ ] Output verification for critical changes
- [ ] Conditions filter server-side, not client-side
- [ ] Only requested fields are retrieved
- [ ] Reference data is cached when appropriate
- [ ] Multi-tenant scope is enforced
- [ ] Tested with test company before production
- [ ] WhatIf/dry-run capability for destructive operations
- [ ] Health monitoring implemented
- [ ] Documentation created
- [ ] Code is modular and reusable

---

**Series Navigation:**
- Previous: [Advanced Automation Scenarios](/2024/12/09/advanced-automation-connectwisemanageapi.html)
- Start: [Introducing ConnectWiseManageAPI](/2024/11/25/introducing-connectwisemanageapi.html)

**Additional Resources:**
- [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseManageAPI)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/ConnectWiseManageAPI)
- [ConnectWise API Documentation](https://developer.connectwise.com/Products/Manage/REST)
