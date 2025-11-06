---
layout: post
title: "Getting Started with ConnectWiseControlAPI: A Step-by-Step Guide"
short_title: "Getting Started with ConnectWiseControlAPI"
date: 2023-03-22 10:00:00 -0000
categories: [PowerShell, MSP, ConnectWiseControlAPI]
tags: [PowerShell, ConnectWise, Control, Tutorial, MSP, Automation, Getting Started]
author: Chris Taylor
excerpt: "Complete tutorial for installing and using ConnectWiseControlAPI. Learn how to connect to your server, retrieve session information, run remote commands, and troubleshoot common issues. No programming experience required."
---

## What You'll Learn

This tutorial walks you through everything needed to start automating ConnectWise Control with PowerShell. By the end, you'll be able to:

- Install and configure the ConnectWiseControlAPI module
- Authenticate to your Control server
- Retrieve session information programmatically
- Execute basic automation tasks
- Troubleshoot common issues

## Prerequisites

Before starting, ensure you have:

- **PowerShell 3.0 or higher** (Windows PowerShell or PowerShell Core)
- **ConnectWise Control server** running with HTTPS enabled
- **Control user account** without MFA (create a dedicated service account)
- **Basic PowerShell knowledge** (how to run commands, work with objects)
- **Internet access** to download from PowerShell Gallery

## Step 1: Install the Module

The ConnectWiseControlAPI module is published to the PowerShell Gallery, making installation straightforward.

### Option A: Install for All Users (Requires Admin)

```powershell
# Run PowerShell as Administrator
Install-Module -Name ConnectWiseControlAPI -Scope AllUsers
```

### Option B: Install for Current User Only (No Admin Required)

```powershell
# No elevation needed
Install-Module -Name ConnectWiseControlAPI -Scope CurrentUser
```

If this is your first time installing from PowerShell Gallery, you may be prompted to trust the repository. Answer **Yes** to continue.

### Verify Installation

```powershell
# Confirm the module installed successfully
Get-Module -Name ConnectWiseControlAPI -ListAvailable

# Expected output shows version and available commands
```

You should see module information including version 0.3.5.0 or higher.

## Step 2: Import the Module

Before using any module functions, import it into your PowerShell session:

```powershell
Import-Module ConnectWiseControlAPI
```

### View Available Commands

```powershell
# See all functions provided by the module
Get-Command -Module ConnectWiseControlAPI

# Get detailed help for a specific function
Get-Help Connect-CWC -Full
```

The module includes 21 functions across several categories:
- Authentication: `Connect-CWC`
- Session Management: `Get-CWCSession`, `Remove-CWCSession`, `Update-CWCSessionName`
- User Management: `New-CWCUser`, `Update-CWCUser`, `Remove-CWCUser`
- Commands: `Invoke-CWCCommand`, `Invoke-CWCWake`
- And more...

## Step 3: Prepare Your Control Server Account

For security and auditability, create a dedicated service account in Control rather than using a personal account.

### Security Considerations

- **No MFA**: The API requires an account without multi-factor authentication
- **Complex Credentials**: Use a strong, random password (25+ characters recommended)
- **Appropriate Permissions**: Grant only the permissions needed for your automation tasks
- **Unique Username**: Use something descriptive like `svc-api-automation`

### Recommended Account Setup

In your ConnectWise Control admin interface:

1. Navigate to **Administration > Security > Users**
2. Create a new user: `svc-api-automation@yourdomain.com`
3. Generate a strong password (use a password manager)
4. **Do not enable MFA** for this account
5. Assign appropriate permissions (Administrator or custom role)
6. Document the account in your password manager

## Step 4: Connect to Your Control Server

The `Connect-CWC` function establishes a connection and caches credentials for subsequent commands.

### Interactive Connection (Credential Prompt)

```powershell
# You'll be prompted for username and password
Connect-CWC -Server 'https://control.yourdomain.com' -Credential (Get-Credential)
```

When the credential prompt appears:
- **Username**: Your service account username
- **Password**: The service account password

### Stored Credential Connection (For Scripts)

For automated scripts, store credentials securely:

```powershell
# Create and save credential (run once)
$credential = Get-Credential
$credential | Export-Clixml -Path 'C:\Secure\CWC-Credential.xml'

# Use saved credential in scripts
$credential = Import-Clixml -Path 'C:\Secure\CWC-Credential.xml'
Connect-CWC -Server 'https://control.yourdomain.com' -Credential $credential
```

**Important**: Credential files are encrypted per-user, per-machine. They only work for the same user on the same computer where they were created.

### Verify Connection

After connecting, the module stores connection information in a global variable:

```powershell
# Check connection status
$global:CWCServerConnection

# Expected output shows Server URL and credential information
```

## Step 5: Your First Automation - Find Sessions

Now that you're connected, retrieve session information from your Control server.

### Get All Sessions (Limited)

```powershell
# Get first 10 sessions
$sessions = Get-CWCSession -Limit 10

# View the results
$sessions | Format-Table Name, SessionID, SessionType, GuestOperatingSystemName
```

### Search for a Specific Computer

```powershell
# Find a session by computer name
$computer = Get-CWCSession -Type Access -Search 'SERVER01' -Limit 1

# Display the session details
$computer
```

### Filter by Session Group

```powershell
# Get all sessions in a specific group
$clientSessions = Get-CWCSession -Type Access -Group 'Client ABC' -Limit 100

# Count sessions in the group
$clientSessions.Count

# View session details
$clientSessions | Select-Object Name, SessionID, GuestLastSeen
```

### Get Session Detail Information

For more comprehensive information about a session:

```powershell
# Get basic session info
$session = Get-CWCSession -Search 'WORKSTATION42' -Limit 1

# Get detailed session information
$detail = Get-CWCSessionDetail -GUID $session.SessionID -Group 'All Machines'

# View all available properties
$detail | Get-Member
```

## Step 6: Execute a Command Against a Session

One of the most powerful features is remote command execution.

### Find the Target Machine

```powershell
# Locate the session
$target = Get-CWCSession -Type Access -Search 'SERVER01' -Limit 1

if (!$target) {
    Write-Error "Session not found"
    return
}
```

### Execute a Simple Command

```powershell
# Run a basic command
Invoke-CWCCommand -GUID $target.SessionID -Command 'ipconfig /all'
```

### Execute PowerShell Commands

For PowerShell commands, use the `-PowerShell` switch:

```powershell
# Run a PowerShell command
$command = 'Get-Service | Where-Object {$_.Status -eq "Running"} | Select-Object -First 5'

Invoke-CWCCommand -GUID $target.SessionID -Command $command -PowerShell
```

### Set Timeout for Long-Running Commands

Some commands take longer to execute:

```powershell
# Allow 5 minutes for command completion
Invoke-CWCCommand `
    -GUID $target.SessionID `
    -Command 'Windows Update installation command here' `
    -PowerShell `
    -TimeOut 300000  # Timeout in milliseconds (5 minutes)
```

## Step 7: Update Session Properties

Custom properties help organize and categorize sessions.

### Update a Custom Property

```powershell
# Find session
$session = Get-CWCSession -Search 'LAPTOP15' -Limit 1

# Update a custom property
Update-CWCCustomProperty `
    -GUID $session.SessionID `
    -Property 'ClientID' `
    -Value 'CLIENT-ABC-001'
```

### Bulk Update Properties

Update properties for multiple sessions:

```powershell
# Get all sessions in a group
$sessions = Get-CWCSession -Group 'New Client Onboarding'

# Update each session's property
$sessions | ForEach-Object {
    Update-CWCCustomProperty `
        -GUID $_.SessionID `
        -Property 'OnboardingStatus' `
        -Value 'In Progress'
}
```

## Step 8: Practical Automation Examples

### Example 1: Find Your Current Machine

```powershell
# Find the current computer in Control
$thisPC = Get-CWCSession -Type Access -Search $env:COMPUTERNAME -Limit 1

if ($thisPC) {
    Write-Host "Found this computer: $($thisPC.Name)"
    Write-Host "Session ID: $($thisPC.SessionID)"

    # Get last contact time
    $lastContact = Get-CWCLastContact -GUID $thisPC.SessionID
    Write-Host "Last Contact: $lastContact"
} else {
    Write-Host "This computer not found in Control"
}
```

### Example 2: Generate Session Access Token

Create an access URL for a technician to connect:

```powershell
# Find the session
$session = Get-CWCSession -Search 'CUSTOMER-PC' -Limit 1

# Generate access token
$token = New-CWCAccessToken -GUID $session.SessionID -Type View

# Build access URL
$accessUrl = "https://control.yourdomain.com/Host#Access/Join/$($token.Token)"

# Send to technician
Write-Host "Access URL: $accessUrl"
```

### Example 3: List Stale Sessions

Find sessions that haven't connected recently:

```powershell
# Get all access sessions
$allSessions = Get-CWCSession -Type Access -Limit 1000

# Filter for sessions not seen in 60 days
$staleSessions = $allSessions | Where-Object {
    $_.GuestLastSeen -and
    ((Get-Date) - [DateTime]$_.GuestLastSeen).TotalDays -gt 60
}

# Export to CSV
$staleSessions |
    Select-Object Name, SessionID, GuestLastSeen |
    Export-Csv -Path "StaleControlSessions_$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation

Write-Host "Found $($staleSessions.Count) stale sessions"
```

## Troubleshooting Common Issues

### Issue: "Unable to connect to Control server"

**Possible Causes:**
- Server URL is incorrect (must include `https://`)
- Control server is not accessible from your network
- Firewall blocking connection

**Solution:**
```powershell
# Test connection
Test-NetConnection -ComputerName 'control.yourdomain.com' -Port 443

# Verify URL format (must be HTTPS)
Connect-CWC -Server 'https://control.yourdomain.com' -Credential $cred
```

### Issue: "Authentication failed"

**Possible Causes:**
- Incorrect username or password
- Account has MFA enabled
- Account lacks necessary permissions

**Solution:**
- Verify credentials work in Control web interface
- Ensure MFA is disabled for the service account
- Check account permissions in Control admin

### Issue: "Session not found"

**Possible Causes:**
- Session doesn't exist with that search term
- Session is in a different group than specified
- Search is case-sensitive in some cases

**Solution:**
```powershell
# Use partial matching
Get-CWCSession -Type Access | Where-Object { $_.Name -like '*PARTIAL*' }

# Check all groups
Get-CWCSession -Type Access -Limit 1000 | Where-Object { $_.Name -eq 'EXACTNAME' }
```

### Issue: Module won't import

**Possible Causes:**
- PowerShell execution policy restriction
- Module not installed correctly

**Solution:**
```powershell
# Check execution policy
Get-ExecutionPolicy

# Set execution policy (if allowed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Verify installation
Get-Module -Name ConnectWiseControlAPI -ListAvailable
```

## Best Practices

### Always Use -WhatIf for Destructive Operations

Before removing sessions or users, test with `-WhatIf`:

```powershell
# Preview what would be removed
Remove-CWCSession -GUID $sessionID -Group 'All Machines' -WhatIf

# Only run without -WhatIf after verifying
```

### Store Credentials Securely

Never hardcode passwords in scripts:

```powershell
# NEVER DO THIS
$password = ConvertTo-SecureString 'PlainTextPassword' -AsPlainText -Force

# DO THIS INSTEAD
$credential = Get-Credential  # Prompt user
# OR
$credential = Import-Clixml -Path 'C:\Secure\saved-credential.xml'
```

### Use Verbose Output for Debugging

Most functions support `-Verbose` for troubleshooting:

```powershell
Get-CWCSession -Search 'SERVER01' -Verbose
```

### Handle Errors Gracefully

Wrap API calls in try/catch blocks:

```powershell
try {
    $session = Get-CWCSession -Search 'COMPUTERNAME' -Limit 1
    if (!$session) {
        Write-Warning "Session not found"
        return
    }
    # Continue with automation...
}
catch {
    Write-Error "Failed to retrieve session: $_"
}
```

## Next Steps

Now that you understand the basics, explore more advanced scenarios:

- **Automated Reporting**: Generate daily reports of session status
- **Bulk Operations**: Update hundreds of sessions with a single script
- **Integration**: Combine with other PowerShell modules (like ConnectWiseManageAPI)
- **Scheduled Tasks**: Run automation scripts on a schedule with Task Scheduler

## Key Takeaways

- **Install from PowerShell Gallery** with `Install-Module ConnectWiseControlAPI`
- **Create a dedicated service account** without MFA for API access
- **Connect once per session** with `Connect-CWC`, credentials are cached
- **Start with read operations** like `Get-CWCSession` before trying destructive actions
- **Use -WhatIf** to preview changes before executing
- **Store credentials securely** using `Export-Clixml` and `Import-Clixml`
- **Check the documentation** with `Get-Help` for detailed parameter information

## Resources

- **Module Documentation**: [Function Reference](https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Docs)
- **Code Examples**: [Examples Folder](https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Examples)
- **GitHub Issues**: [Report bugs or request features](https://github.com/christaylorcodes/ConnectWiseControlAPI/issues)
- **PowerShell Gallery**: [Module Page](https://www.powershellgallery.com/packages/ConnectWiseControlAPI)

Have questions? Open an issue on GitHub or contribute your own examples to help others get started.
