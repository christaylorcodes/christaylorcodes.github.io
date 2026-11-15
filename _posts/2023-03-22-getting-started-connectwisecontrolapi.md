---
layout: post
title: "Getting Started with ConnectWiseControlAPI: A Step-by-Step Guide to the ScreenConnect (Control) API"
short_title: "Getting Started with ConnectWiseControlAPI"
date: 2023-03-22 10:00:00 -0000
categories: [PowerShell, MSP, ConnectWiseControlAPI]
tags: [PowerShell, ConnectWise, Control, ScreenConnect, Tutorial, MSP, Automation, Getting Started]
author: Chris Taylor
excerpt: "Complete tutorial for installing and using ConnectWiseControlAPI. Learn how to connect to your server, retrieve session information, run remote commands, and troubleshoot common issues. No programming experience required."
description: "Step-by-step guide to the ConnectWise ScreenConnect (formerly Control) API in PowerShell: install ConnectWiseControlAPI, connect to your server, find sessions, run remote commands and troubleshoot common issues."
---

> **Update (November 2026):** ConnectWise renamed Control back to ScreenConnect, and ConnectWiseControlAPI 0.5.0 is out. The module and its `CWC` command names didn't change. What did: you no longer need an account without MFA (`Connect-CWC` now supports `-Mfa`, `-OneTimeCode`, `-TotpSecret` and `-ApiSecret`), and `Remove-CWCSession` asks for confirmation by default, so unattended scripts need `-Confirm:$false`. I've updated this guide for 0.5.0 and fixed examples that never worked as written: `Get-CWCSession` needs `-Type`, `Update-CWCCustomProperty -Property` takes the property's number, the connection isn't stored in a global variable, and the access-token example now uses `Enter-CWCSession -UrlOnly`. For the new sign-in options and an upgrade checklist, read {% assign sc_post = site.posts | where: "slug", "screenconnect-api-powershell" | first %}{% if sc_post %}[ScreenConnect API with PowerShell: MFA, API Secrets and ConnectWiseControlAPI 0.5]({{ sc_post.url }}){% else %}the upcoming ScreenConnect API post{% endif %}.

## What You'll Learn

This tutorial walks you through everything needed to start automating ConnectWise ScreenConnect (formerly Control) with PowerShell. By the end, you'll be able to:

- Install and configure the ConnectWiseControlAPI module
- Authenticate to your ScreenConnect server
- Retrieve session information programmatically
- Execute basic automation tasks
- Troubleshoot common issues

## Prerequisites

Before starting, ensure you have:

- **Windows PowerShell 5.1 or PowerShell 7** (the versions 0.5.0 is tested on)
- **ScreenConnect server** running with HTTPS enabled
- **A way to sign in**: a ScreenConnect user account (with or without MFA), or the RESTful API Manager extension's secret
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

You should see module information including version 0.5.0 or higher. If you have an older version, run `Update-Module -Name ConnectWiseControlAPI`.

## Step 2: Import the Module

Before using any module functions, import it into your PowerShell session:

```powershell
Import-Module ConnectWiseControlAPI
```

### View Available Commands

```powershell
# See all functions provided by the module
Get-Command -Module ConnectWiseControlAPI

# Overview of sign-in options, error IDs and upgrade notes
Get-Help about_ConnectWiseControlAPI

# Get detailed help for a specific function
Get-Help Connect-CWC -Full
```

The module includes 35 functions across several categories:
- Authentication: `Connect-CWC`
- Session Management: `Get-CWCSession`, `Find-CWCSession`, `New-CWCSession`, `Remove-CWCSession`, `Update-CWCSessionName`
- User Management: `New-CWCUser`, `Update-CWCUser`, `Remove-CWCUser`
- Commands: `Invoke-CWCCommand`, `Invoke-CWCWake`, `Send-CWCToolboxItem`
- And more...

## Step 3: Prepare Your ScreenConnect Server Account

For security and auditability, create a dedicated service account in ScreenConnect rather than using a personal account.

### Security Considerations

- **MFA**: Supported since 0.5.0. Keep it on and sign in with `-Mfa` (interactive) or `-TotpSecret` (unattended)
- **Complex Credentials**: Use a strong, random password (25+ characters recommended)
- **Appropriate Permissions**: Grant only the permissions needed for your automation tasks
- **Unique Username**: Use something descriptive like `svc-api-automation`

### Recommended Account Setup

In your ScreenConnect admin interface:

1. Navigate to **Administration > Security > Users**
2. Create a new user: `svc-api-automation@yourdomain.com`
3. Generate a strong password (use a password manager)
4. Set up MFA with an authenticator app, and store the secret in a separate vault if scripts will use `-TotpSecret`
5. Assign appropriate permissions (Administrator or custom role)
6. Document the account in your password manager

If every account on your server requires MFA and your scripts only work with sessions, the RESTful API Manager extension's secret (`Connect-CWC -ApiSecret`) is another option. It covers a smaller set of commands. {% assign sc_post = site.posts | where: "slug", "screenconnect-api-powershell" | first %}{% if sc_post %}The [0.5 post]({{ sc_post.url }}){% else %}The upcoming 0.5 post{% endif %} explains when to use which.

## Step 4: Connect to Your ScreenConnect Server

The `Connect-CWC` function establishes a connection and caches it for subsequent commands.

### Interactive Connection (Credential Prompt)

```powershell
# You'll be prompted for username and password
Connect-CWC -Server 'screenconnect.yourdomain.com' -Credentials (Get-Credential)

# If the account uses MFA, add -Mfa and you'll be asked for the code
Connect-CWC -Server 'screenconnect.yourdomain.com' -Credentials (Get-Credential) -Mfa
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
Connect-CWC -Server 'screenconnect.yourdomain.com' -Credentials $credential
```

**Important**: Credential files are encrypted per-user, per-machine. They only work for the same user on the same computer where they were created.

### Verify Connection

The module keeps the connection inside the module, not in a variable you can read. The simplest check is a small read:

```powershell
# Returns one Access session if the connection works
Get-CWCSession -Type Access -Limit 1
```

## Step 5: Your First Automation - Find Sessions

Now that you're connected, retrieve session information from your ScreenConnect server.

### Get Sessions (Limited)

```powershell
# Get first 10 Access sessions
$sessions = Get-CWCSession -Type Access -Limit 10

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
$clientSessions | Select-Object Name, SessionID, GuestOperatingSystemName
```

### Get Session Detail Information

For more comprehensive information about a session:

```powershell
# Get basic session info
$session = Get-CWCSession -Type Access -Search 'WORKSTATION42' -Limit 1

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

Custom properties help organize and categorize sessions. `-Property` takes the property's number, as it's numbered in your server's session settings.

### Update a Custom Property

```powershell
# Find session
$session = Get-CWCSession -Type Access -Search 'LAPTOP15' -Limit 1

# Set custom property 1 (for example, your client ID)
Update-CWCCustomProperty `
    -GUID $session.SessionID `
    -Property 1 `
    -Value 'CLIENT-ABC-001'
```

### Bulk Update Properties

Update properties for multiple sessions:

```powershell
# Get all Access sessions in a group
$sessions = Get-CWCSession -Type Access -Group 'New Client Onboarding'

# Set custom property 2 (for example, onboarding status) on each session
$sessions | ForEach-Object {
    Update-CWCCustomProperty `
        -GUID $_.SessionID `
        -Property 2 `
        -Value 'In Progress' `
        -Group 'New Client Onboarding'
}
```

## Step 8: Practical Automation Examples

### Example 1: Find Your Current Machine

```powershell
# Find the current computer in ScreenConnect
$thisPC = Get-CWCSession -Type Access -Search $env:COMPUTERNAME -Limit 1

if ($thisPC) {
    Write-Host "Found this computer: $($thisPC.Name)"
    Write-Host "Session ID: $($thisPC.SessionID)"

    # Get last contact time (0.5.0 returns an error if there's no connection history)
    $lastContact = Get-CWCLastContact -GUID $thisPC.SessionID
    Write-Host "Last Contact: $lastContact"
} else {
    Write-Host "This computer not found in ScreenConnect"
}
```

### Example 2: Get a Join URL for a Session

Get a URL that opens the ScreenConnect Host client joined to a session:

```powershell
# Find the session
$session = Get-CWCSession -Type Access -Search 'CUSTOMER-PC' -Limit 1

# Get the launch URL instead of opening the client
$joinUrl = Enter-CWCSession -GUID $session.SessionID -UrlOnly
```

The URL carries an access token, so treat it like a password. Without `-UrlOnly`, `Enter-CWCSession` opens the installed Host client directly on Windows.

### Example 3: List Stale Sessions

Find sessions that haven't connected recently. `LastConnectedEventTime` is the number of seconds since the last connection:

```powershell
# Get all access sessions
$allSessions = Get-CWCSession -Type Access -Limit 1000

# Filter for sessions not seen in 60 days
$staleSessions = $allSessions | Where-Object {
    $_.LastConnectedEventTime -gt (60 * 86400)
}

# Export to CSV
$staleSessions |
    Select-Object Name, SessionID, @{ Name = 'DaysSinceLastConnected'; Expression = { [math]::Round($_.LastConnectedEventTime / 86400) } } |
    Export-Csv -Path "StaleSessions_$(Get-Date -Format 'yyyy-MM-dd').csv" -NoTypeInformation

Write-Host "Found $($staleSessions.Count) stale sessions"
```

## Troubleshooting Common Issues

### Issue: "Unable to connect to ScreenConnect server"

**Possible Causes:**
- Server name is incorrect
- ScreenConnect server is not accessible from your network
- Firewall blocking connection

**Solution:**
```powershell
# Test connection
Test-NetConnection -ComputerName 'screenconnect.yourdomain.com' -Port 443

# Pass the host name. The module always uses HTTPS and strips a leading https://
Connect-CWC -Server 'screenconnect.yourdomain.com' -Credentials $cred
```

### Issue: "Authentication failed" or "Needs permission"

**Possible Causes:**
- Incorrect username or password. The server doesn't reject these with a 401; the request runs as an anonymous user and fails with "Needs permission"
- Account has MFA enabled, but you didn't pass `-Mfa`, `-OneTimeCode` or `-TotpSecret`
- Account lacks necessary permissions
- An MFA login has expired

**Solution:**
- Verify credentials work in the ScreenConnect web interface
- Add `-Mfa` if the account uses MFA
- Check account permissions in ScreenConnect admin
- Run `Connect-CWC` again with `-Force` to get a fresh login

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

# Since 0.5.0 this asks for confirmation. Unattended scripts need -Confirm:$false
Remove-CWCSession -GUID $sessionID -Group 'All Machines' -Confirm:$false
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
Get-CWCSession -Type Access -Search 'SERVER01' -Verbose
```

### Handle Errors Gracefully

Wrap API calls in try/catch blocks. Most commands write non-terminating errors, so add `-ErrorAction Stop`:

```powershell
try {
    $session = Get-CWCSession -Type Access -Search 'COMPUTERNAME' -Limit 1 -ErrorAction Stop
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
- **Create a dedicated service account** and keep MFA on; 0.5.0 supports it
- **Connect once per session** with `Connect-CWC`, the connection is cached
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
