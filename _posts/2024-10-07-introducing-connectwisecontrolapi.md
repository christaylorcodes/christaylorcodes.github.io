---
layout: post
title: "Automating ConnectWise Control: A PowerShell Module for MSPs"
short_title: "ConnectWiseControlAPI: PowerShell for MSPs"
date: 2024-10-07 10:00:00 -0000
categories: [PowerShell, MSP, ConnectWiseControlAPI]
tags: [PowerShell, ConnectWise, Control, ScreenConnect, MSP, Automation, API]
author: Chris Taylor
excerpt: "Automate ConnectWise Control with PowerShell instead of clicking through web interfaces. This module handles session management, user administration, and remote commands. Turn hours of manual work into seconds of scripted automation."
---

## The Problem with Manual Remote Management

If you're managing hundreds or thousands of endpoints through ConnectWise Control (formerly ScreenConnect), you've likely faced this scenario: duplicate sessions cluttering your console, the need to update custom properties across dozens of machines, or having to execute the same command across multiple client environments. Doing this manually through the Control interface is time-consuming and error-prone.

As an MSP professional with 20+ years in the industry, I've seen automation transform what used to take hours into tasks that complete in seconds. That's why I built **ConnectWiseControlAPI**, a PowerShell module that wraps the Control REST API and makes automation accessible to anyone comfortable with PowerShell.

## What ConnectWiseControlAPI Does

This module provides a comprehensive set of PowerShell cmdlets for interacting with ConnectWise Control. Instead of clicking through the web interface, you can now script and automate:

- **Session Management** - Find, update, rename, or remove sessions programmatically
- **User Administration** - Create, update, and remove Control users
- **Command Execution** - Run PowerShell or batch commands against remote sessions
- **Audit Services** - Pull audit logs and session history
- **Custom Properties** - Bulk update session properties for better organization
- **Access Tokens** - Generate session access tokens for support technicians

The module currently includes 21 functions covering the most common Control operations, with more being added based on community needs.

## Why PowerShell?

PowerShell remains the automation language of choice for MSPs managing Windows environments. It's:

- **Already installed** on every Windows machine you manage
- **Pipeline-friendly** for processing multiple objects efficiently
- **Credential-aware** with built-in secure credential handling
- **Community-supported** with thousands of modules available

By wrapping the Control API in PowerShell, automation becomes accessible without requiring developers to understand REST APIs, authentication headers, or JSON parsing.

## A Quick Example

Here's how simple it becomes to find and clean up redundant sessions. Instead of manually searching and clicking delete in the Control interface:

```powershell
# Connect to your Control server
Connect-CWC -Server 'https://control.yourdomain.com' -Credential (Get-Credential)

# Find all duplicate sessions (same name, multiple entries)
$duplicates = Get-CWCSession -Type Access -Group 'All Machines' |
    Group-Object -Property Name |
    Where-Object { $_.Count -gt 1 } |
    ForEach-Object {
        # Keep only the most recently connected session
        $_.Group | Sort-Object -Property LastConnectedEventTime | Select-Object -Skip 1
    }

# Remove the redundant sessions
$duplicates | ForEach-Object {
    Remove-CWCSession -GUID $_.SessionID -Group 'All Machines' -WhatIf
}
```

This script identifies sessions with duplicate names, sorts by last connection time, and removes all but the most recent session. The `-WhatIf` parameter lets you preview changes before executing them—critical when working in production environments.

## Real-World Use Cases

MSPs using ConnectWiseControlAPI have automated:

### Automated Maintenance

Execute agent reinstallation commands across multiple machines during maintenance windows:

```powershell
# Find all servers in a specific group
$servers = Get-CWCSession -Type Access -Group 'Production Servers'

# Execute a maintenance command
$servers | ForEach-Object {
    Invoke-CWCCommand -GUID $_.SessionID -Command 'Update-WindowsDefender' -PowerShell
}
```

### Bulk Property Updates

Update custom properties for better organization and reporting:

```powershell
# Tag all sessions in a client group with client identifier
$sessions = Get-CWCSession -Group 'Client ABC'
$sessions | ForEach-Object {
    Update-CWCCustomProperty -GUID $_.SessionID -Property 'ClientID' -Value 'ABC-001'
}
```

### Session Discovery and Reporting

Generate reports about your Control environment:

```powershell
# Find all sessions that haven't connected in 30 days
$stale = Get-CWCSession -Type Access -Group 'All Machines' |
    Where-Object { (Get-Date) - $_.LastConnectedEventTime -gt (New-TimeSpan -Days 30) }

# Export to CSV for review
$stale | Export-Csv -Path 'StaleControlSessions.csv' -NoTypeInformation
```

## Installation and Getting Started

The module is available on the PowerShell Gallery, making installation a single command:

```powershell
Install-Module -Name ConnectWiseControlAPI
```

Authentication requires a Control user account **without MFA enabled**. For security, create a dedicated service account with appropriate permissions, and use a complex username and password. Your Control server must use HTTPS.

Basic usage follows a simple pattern:

```powershell
# Import the module
Import-Module ConnectWiseControlAPI

# Connect to your server (credentials are cached for the session)
Connect-CWC -Server 'https://control.yourdomain.com' -Credential (Get-Credential)

# Start using Control cmdlets
Get-CWCSession -Limit 10
```

## Why Open Source?

ConnectWiseControlAPI is open source (MIT license) and hosted on GitHub. The MSP community benefits when we share solutions to common problems. By making this freely available:

- **MSPs save time** by not having to build their own integrations
- **The module improves** through community contributions and feedback
- **Innovation accelerates** as people build on existing work
- **Knowledge spreads** through examples and shared use cases

The project has 81+ stars on GitHub and is actively used by MSPs worldwide. Community contributions have added features like Remote Workforce support, MFA helper functions, and additional session management capabilities.

## What's Next

The module continues to evolve based on community needs. Upcoming enhancements include:

- Additional session detail operations
- Enhanced reporting functions
- Better pipeline support for bulk operations
- Improved error handling and logging

If you need functionality that doesn't exist yet, the project welcomes contributions. All the code is on GitHub, and the contribution guidelines make it easy to add new features.

## Key Takeaways

- **ConnectWiseControlAPI wraps the Control REST API in PowerShell cmdlets**
- **Automate repetitive Control tasks** instead of clicking through the interface
- **Free and open source** under MIT license
- **Active community** with 81+ GitHub stars and ongoing development
- **Production-ready** with proper error handling and security considerations
- **Easy to install** from PowerShell Gallery

## Resources

- **GitHub Repository**: [christaylorcodes/ConnectWiseControlAPI](https://github.com/christaylorcodes/ConnectWiseControlAPI)
- **PowerShell Gallery**: [ConnectWiseControlAPI](https://www.powershellgallery.com/packages/ConnectWiseControlAPI)
- **Function Documentation**: Available in the [Docs folder](https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Docs)
- **Examples**: [Working code examples](https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Examples)

## Get Involved

If you're using ConnectWise Control and PowerShell, give ConnectWiseControlAPI a try. Star the project on GitHub if you find it useful, submit issues for bugs or feature requests, and consider contributing if you've built functions you'd like to share.

Questions or feedback? Open an issue on GitHub or reach out through the repository.
