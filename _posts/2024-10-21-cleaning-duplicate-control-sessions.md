---
layout: post
title: "Cleaning Up Duplicate Control Sessions: A Real-World Automation Story"
date: 2024-10-21 10:00:00 -0000
categories: [PowerShell, MSP, ConnectWiseControlAPI]
tags: [PowerShell, ConnectWise, Control, MSP, Automation, Cleanup, Session Management]
author: Chris Taylor
excerpt: "Learn how to identify and automatically remove duplicate ConnectWise Control sessions using PowerShell. This real-world automation story shows how to go from manual cleanup taking hours to automated scripts completing in minutes."
---

## The Problem: Hundreds of Duplicate Sessions

Picture this: You open your ConnectWise Control console and see hundreds of duplicate sessions. A customer's laptop appears three times, a server shows up with four different session IDs, and your "All Machines" group is filled with ghosts of computers past. Every time a machine is reimaged or rejoins the domain, another duplicate appears.

This isn't just visual clutter—it creates real operational problems:

- Technicians waste time connecting to inactive sessions
- Reports show inflated machine counts
- Finding the correct session becomes a guessing game
- Bandwidth is wasted polling dead sessions
- License counts may be affected depending on your Control edition

After dealing with this manually for the hundredth time, I decided to solve it with automation.

## Understanding Why Duplicates Happen

ConnectWise Control creates unique sessions based on machine identifiers. When certain events occur, Control may not recognize a machine as the same device:

- **Operating system reinstalls** - New machine ID generated
- **Domain rejoin operations** - Changed computer SID or credentials
- **Agent reinstallation** - Creates new session without removing old one
- **Guest name changes** - May create new session depending on configuration
- **Network changes** - In some cases, significant network changes trigger new sessions

While Control has built-in session merging features, they don't catch every scenario. Over time, duplicates accumulate.

## The Solution: Automated Cleanup Script

Using the ConnectWiseControlAPI PowerShell module, I built a script that identifies duplicate sessions and safely removes all but the most recently active one.

### The Complete Script

```powershell
<#
.SYNOPSIS
    Remove duplicate Control sessions, keeping only the most recently connected.

.DESCRIPTION
    Searches for multiple access sessions with the same name and removes all but
    the session with the most recent connection time.

.NOTES
    Author: Chris Taylor
    Requires: ConnectWiseControlAPI PowerShell module
#>

# Configuration
$Server = 'https://control.yourdomain.com'
$GroupName = 'All Machines'

# Safety switches - ALWAYS test with WhatIf first
$WhatIf = $true
$Confirm = $true

# Get credentials
$Credentials = Get-Credential -Message "Enter Control service account credentials"

# Import module
Import-Module ConnectWiseControlAPI

# Connect to Control server
try {
    Connect-CWC -Server $Server -Credentials $Credentials -ErrorAction Stop
    Write-Host "Connected to $Server successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to connect to Control server: $_"
    exit 1
}

# Search for duplicate sessions
Write-Host "Searching for duplicate sessions in '$GroupName'..." -ForegroundColor Cyan

$allSessions = Get-CWCSession -Type Access -Group $GroupName

# Group by name and find duplicates
$duplicateGroups = $allSessions |
    Group-Object -Property Name |
    Where-Object { $_.Count -gt 1 }

if ($duplicateGroups.Count -eq 0) {
    Write-Host "No duplicate sessions found!" -ForegroundColor Green
    exit 0
}

Write-Host "Found $($duplicateGroups.Count) sets of duplicate sessions" -ForegroundColor Yellow

# For each set of duplicates, identify which to keep and which to remove
$sessionsToRemove = foreach ($group in $duplicateGroups) {
    Write-Host "`nDuplicate: $($group.Name) has $($group.Count) sessions" -ForegroundColor Yellow

    # Sort by last connection time (most recent first)
    $sorted = $group.Group | Sort-Object -Property LastConnectedEventTime -Descending

    # The first one (most recent) is kept
    $keepSession = $sorted | Select-Object -First 1
    Write-Host "  Keeping: Session ID $($keepSession.SessionID) (Last connected: $($keepSession.LastConnectedEventTime))" -ForegroundColor Green

    # All others will be removed
    $removeThese = $sorted | Select-Object -Skip 1
    foreach ($session in $removeThese) {
        Write-Host "  Removing: Session ID $($session.SessionID) (Last connected: $($session.LastConnectedEventTime))" -ForegroundColor Red
    }

    # Output sessions to remove
    $removeThese
}

# Summary before removal
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Total duplicate groups: $($duplicateGroups.Count)" -ForegroundColor Yellow
Write-Host "  Total sessions to remove: $($sessionsToRemove.Count)" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

# Perform removal
if ($WhatIf) {
    Write-Host "WhatIf is enabled - no sessions will actually be removed" -ForegroundColor Yellow
}

$removalResults = foreach ($session in $sessionsToRemove) {
    $params = @{
        GUID    = $session.SessionID
        Group   = $GroupName
        Confirm = $Confirm
        WhatIf  = $WhatIf
    }

    try {
        Remove-CWCSession @params
        [PSCustomObject]@{
            Name      = $session.Name
            SessionID = $session.SessionID
            Status    = 'Success'
            Error     = $null
        }
    }
    catch {
        Write-Warning "Failed to remove session $($session.SessionID): $_"
        [PSCustomObject]@{
            Name      = $session.Name
            SessionID = $session.SessionID
            Status    = 'Failed'
            Error     = $_.Exception.Message
        }
    }
}

# Final report
Write-Host "`nRemoval Results:" -ForegroundColor Cyan
$removalResults | Format-Table -AutoSize

$successCount = ($removalResults | Where-Object { $_.Status -eq 'Success' }).Count
$failCount = ($removalResults | Where-Object { $_.Status -eq 'Failed' }).Count

Write-Host "`nCompleted: $successCount successful, $failCount failed" -ForegroundColor Green
```

## How the Script Works

### Step 1: Configuration and Safety

The script starts with safety switches:

```powershell
$WhatIf = $true   # Preview changes without executing
$Confirm = $true  # Prompt before each deletion
```

**Always run with `$WhatIf = $true` first** to preview what would be removed. Only set it to `$false` after verifying the results.

### Step 2: Retrieve All Sessions

```powershell
$allSessions = Get-CWCSession -Type Access -Group $GroupName
```

This pulls all access sessions from the specified group. For large environments (1000+ sessions), you may need to adjust the `-Limit` parameter or implement pagination.

### Step 3: Identify Duplicates

```powershell
$duplicateGroups = $allSessions |
    Group-Object -Property Name |
    Where-Object { $_.Count -gt 1 }
```

PowerShell's `Group-Object` cmdlet groups sessions by the `Name` property. Any group with `Count` greater than 1 represents duplicates.

### Step 4: Sort and Select

```powershell
$sorted = $group.Group | Sort-Object -Property LastConnectedEventTime -Descending
$keepSession = $sorted | Select-Object -First 1
$removeThese = $sorted | Select-Object -Skip 1
```

For each duplicate group:
1. Sort by `LastConnectedEventTime` with most recent first
2. Keep the first session (most recently connected)
3. Mark all others for removal

This ensures you keep the active session and remove stale ones.

### Step 5: Safe Removal

```powershell
Remove-CWCSession -GUID $session.SessionID -Group $GroupName -WhatIf -Confirm
```

The `-WhatIf` parameter previews the action without executing it. The `-Confirm` parameter prompts for confirmation before each removal.

## Running the Script

### First Run: Preview Mode

```powershell
# WhatIf is $true - nothing will actually be removed
.\Remove-DuplicateControlSessions.ps1
```

Review the output carefully:
- Verify the correct sessions are marked for removal
- Check that the most recent session is being kept
- Look for any unexpected duplicates

### Second Run: Execute Removals

After verifying the preview looks correct:

1. Edit the script: Set `$WhatIf = $false`
2. Optionally set `$Confirm = $false` if you're confident
3. Run the script again

```powershell
# With WhatIf disabled, deletions will occur
.\Remove-DuplicateControlSessions.ps1
```

### Automated Scheduled Run

Once tested, schedule it to run monthly:

```powershell
# Create a scheduled task
$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' `
    -Argument '-File "C:\Scripts\Remove-DuplicateControlSessions.ps1"'

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2AM

Register-ScheduledTask -TaskName 'CleanupControlDuplicates' `
    -Action $action -Trigger $trigger -Description 'Remove duplicate Control sessions'
```

## Important Considerations

### Session Name Uniqueness

This script assumes session names are unique per machine. If you have:
- Multiple machines with the same name (e.g., "LAPTOP" in different domains)
- Naming conventions that create natural duplicates

You'll need to enhance the duplicate detection logic:

```powershell
# Group by name AND domain
$duplicateGroups = $allSessions |
    Group-Object -Property Name, GuestMachineName |
    Where-Object { $_.Count -gt 1 }
```

### Session Details for Better Detection

For more sophisticated duplicate detection, retrieve session details:

```powershell
# Get detailed session info
$sessionDetail = Get-CWCSessionDetail -GUID $session.SessionID -Group $GroupName

# Use additional properties for matching
# - MAC address
# - Serial number
# - Custom properties
```

### Bulk Removal Performance

For hundreds of removals, add progress tracking:

```powershell
$i = 0
foreach ($session in $sessionsToRemove) {
    $i++
    Write-Progress -Activity "Removing duplicate sessions" `
        -Status "Processing $i of $($sessionsToRemove.Count)" `
        -PercentComplete (($i / $sessionsToRemove.Count) * 100)

    Remove-CWCSession -GUID $session.SessionID -Group $GroupName
}
```

## Results: Time Saved and Clarity Gained

After implementing this script at my organization:

- **500+ duplicate sessions removed** from a 2000-machine environment
- **Reduced confusion** for technicians searching for machines
- **Improved reporting accuracy** for monthly client reviews
- **Automated monthly cleanup** prevents duplicates from accumulating
- **10-15 hours saved per month** in manual cleanup time

The script runs every Sunday at 2 AM via scheduled task and emails a summary report of removed sessions.

## Key Takeaways

- **Duplicate Control sessions are common** in MSP environments
- **Automation saves significant time** compared to manual cleanup
- **Always use -WhatIf first** to preview changes before executing
- **Sort by LastConnectedEventTime** to keep the active session
- **Consider session details** for more sophisticated duplicate detection
- **Schedule regular runs** to prevent duplicate accumulation

## Resources

- **Full Script**: Available in [ConnectWiseControlAPI Examples](https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Examples)
- **Module Documentation**: [ConnectWiseControlAPI on GitHub](https://github.com/christaylorcodes/ConnectWiseControlAPI)
- **Related Functions**:
  - `Get-CWCSession` - [Documentation](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/Docs/Get-CWCSession.md)
  - `Remove-CWCSession` - [Documentation](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/Docs/Remove-CWCSession.md)
  - `Get-CWCSessionDetail` - [Documentation](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/Docs/Get-CWCSessionDetail.md)

Have you implemented duplicate session cleanup differently? Share your approach in the GitHub issues or discussions.
