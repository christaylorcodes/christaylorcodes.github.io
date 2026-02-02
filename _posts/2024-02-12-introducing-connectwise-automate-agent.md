---
layout: post
title: "Introducing ConnectWiseAutomateAgent: PowerShell Automation for Your RMM"
short_title: "ConnectWiseAutomateAgent"
date: 2024-02-12 10:00:00 -0000
categories: [PowerShell, RMM]
tags: [PowerShell, ConnectWise, Automate, RMM, Automation, MSP]
author: Chris Taylor
excerpt: "ConnectWiseAutomateAgent is a PowerShell module with 30 functions for managing ConnectWise Automate agents on Windows endpoints. It covers the full agent lifecycle from deployment through troubleshooting and maintenance, all from the command line. Open source, MIT licensed, available on the PowerShell Gallery."
---

## What This Is

ConnectWiseAutomateAgent is a PowerShell module for managing the ConnectWise Automate (formerly LabTech) Windows agent. It provides 30 functions covering the full agent lifecycle -- installation, configuration, troubleshooting, and maintenance. Open source, MIT license, available on the PowerShell Gallery.

If you're a Managed Service Provider (MSP) or IT admin managing Automate agents across Windows endpoints, this module puts all of that into PowerShell where it belongs.

---

## Why PowerShell

PowerShell is the go-to for Windows automation. If you're managing endpoints at scale, you're already using it for Active Directory, Group Policy, software deployment, and compliance reporting. ConnectWiseAutomateAgent brings your Remote Monitoring and Management (RMM) agent into that same toolchain.

The agent becomes just another manageable component in your existing automation workflow.

---

## What It Covers

- **Installation** - Deploy agents with a single command
- **Configuration** - Manage settings, proxy configuration, and visibility
- **Troubleshooting** - Access logs, test connectivity, restart services
- **Maintenance** - Update, reinstall, or remove agents programmatically

---

## Real-World Example: Mass Deployment

You just onboarded a new client with 150 workstations. The typical approach:

1. Log into ConnectWise Automate
2. Generate a deployment link for the client's location
3. Push it out via GPO, login script, or your existing deployment tool
4. Wait for agents to check in
5. Track down the ones that failed
6. Troubleshoot and redeploy the failures individually
7. Repeat until you've caught them all

It works. It's also tedious, hard to track, and the failure-handling loop eats more time than the initial deployment.

Here's the same job with ConnectWiseAutomateAgent:

```powershell
# Install the module once
Install-Module ConnectWiseAutomateAgent

# Get list of computers from Active Directory
$computers = Get-ADComputer -Filter * -SearchBase "OU=Workstations,OU=NewClient,DC=domain,DC=com"

# Deploy to all computers in parallel
$computers | ForEach-Object -Parallel {
    Invoke-Command -ComputerName $_.Name -ScriptBlock {
        Install-CWAA -Server "https://automate.yourmsp.com" `
                     -InstallerToken "your-secure-token" `
                     -LocationID 42 `
                     -Hide `
                     -Rename "YourMSP Monitoring"
    }
} -ThrottleLimit 10
```

One script, parallel execution, consistent configuration on every machine. The failures surface immediately in your PowerShell output instead of trickling in over the next few days.

---

## Key Features

### Intelligent Installation

The module handles the details you'd otherwise script yourself:

- Automatically detects and installs .NET Framework 3.5 if missing
- Tests server connectivity before attempting installation
- Handles proxy configurations automatically
- Validates server version compatibility
- Cleans up after itself
- Waits for agent registration before returning success

```powershell
# Configure proxy before installing
Set-CWAAProxy -ProxyServerURL "http://proxy.client.com:8080"

Install-CWAA -Server "https://automate.msp.com" `
             -InstallerToken "abc123" `
             -LocationID 100 `
             -Hide
```

### Troubleshooting

Agent offline? Get answers without remoting in and clicking through the GUI:

```powershell
# Check what's wrong
Get-CWAAInfo | Format-List
Get-CWAAError | Select-Object -Last 50
Test-CWAAPort -Server "https://automate.msp.com"

# Quick fixes
Restart-CWAA
Invoke-CWAACommand -Command "Send Status"

# Nuclear option
Redo-CWAA -Server "https://automate.msp.com" -InstallerToken "abc123"
```

### Stealth Deployment

Some clients don't want their users seeing "LabTech" or "ConnectWise" in Add/Remove Programs:

```powershell
# Hide completely
Hide-CWAAAddRemove

# Or rename to something client-friendly
Rename-CWAAAddRemove -Name "IT Management Agent"
```

### Proxy Support

For clients with strict firewall policies:

```powershell
# Configure proxy for the module
Set-CWAAProxy -ProxyServerURL "http://proxy.client.com:8080"

# Install agent (uses the proxy configured above)
Install-CWAA -Server "https://automate.msp.com" `
             -InstallerToken "abc123" `
             -LocationID 50
```

---

## Installation

```powershell
# From PowerShell Gallery (recommended)
Install-Module ConnectWiseAutomateAgent

# For older systems without Gallery access (downloads and loads the module directly)
Invoke-RestMethod 'https://raw.githubusercontent.com/christaylorcodes/ConnectWiseAutomateAgent/main/ConnectWiseAutomateAgent.ps1' | Invoke-Expression
```

No dependencies. No complicated setup.

---

## Who This Is For

- **MSPs** - Manage agents across multiple clients from PowerShell
- **IT Administrators** - Automate internal agent deployment and maintenance
- **System Engineers** - Integrate RMM agent management into broader automation workflows
- **DevOps Teams** - Include the monitoring agent in infrastructure-as-code pipelines

---

## Practical Use Cases

### Automated Onboarding

Deploy the RMM agent as part of a larger provisioning workflow alongside domain join, software installation, security configuration, and baseline compliance checks.

### Health Monitoring

Build a scheduled task that checks agent status, tests connectivity, restarts stuck agents, and alerts on failures. The module includes a built-in health check and auto-remediation system -- see the [Self-Healing Agents]({% post_url 2024-03-01-self-healing-connectwise-automate-agents %}) post for the full walkthrough.

### Bulk Updates

When ConnectWise releases a critical agent update:

```powershell
Get-ADComputer -Filter * | ForEach-Object {
    Invoke-Command -ComputerName $_.Name -ScriptBlock {
        Update-CWAA
    }
}
```

### Disaster Recovery

Rebuild scenario where you need to redeploy agents quickly:

```powershell
# Import computer list from backup
$computers = Import-Csv "backup-computers.csv"

# Redeploy all agents with original settings
$computers | ForEach-Object {
    Invoke-Command -ComputerName $_.ComputerName -ScriptBlock {
        Install-CWAA -Server $using:_.Server `
                     -LocationID $using:_.LocationID `
                     -InstallerToken $using:Token
    }
}
```

---

## Getting Started

1. **Install the module**
   ```powershell
   Install-Module ConnectWiseAutomateAgent
   ```

2. **See what's available**
   ```powershell
   Get-Command -Module ConnectWiseAutomateAgent
   ```

3. **Get help for any function**
   ```powershell
   Get-Help Install-CWAA -Full
   ```

4. **Deploy your first agent**
   ```powershell
   Install-CWAA -Server "https://automate.yourmsp.com" `
                -InstallerToken "your-token" `
                -LocationID 100
   ```

---

## What's in the Rest of This Series

The other posts in this series go deeper into specific workflows:

- **[Mass Deployment]({% post_url 2024-02-26-mass-agent-deployment-connectwise-automate %})** - Phased rollouts, failure handling, verification at scale
- **[Self-Healing Agents]({% post_url 2024-03-01-self-healing-connectwise-automate-agents %})** - Automated health monitoring and escalating remediation
- **[Troubleshooting Guide]({% post_url 2024-03-04-troubleshooting-connectwise-automate-agents-powershell %})** - Structured diagnostic workflows for common agent issues
- **[Use Cases]({% post_url 2024-03-11-ten-use-cases-connectwise-automate-agent %})** - Practical examples for onboarding, compliance, migration, and more

---

## Open Source

ConnectWiseAutomateAgent is open source under the MIT license. The code is on GitHub, issues and pull requests are welcome.

- **GitHub**: [christaylorcodes/ConnectWiseAutomateAgent](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
- **PowerShell Gallery**: [ConnectWiseAutomateAgent](https://www.powershellgallery.com/packages/ConnectWiseAutomateAgent)

If the module saves you time, consider [supporting the project](https://paypal.me/ChrisTaylorCodes).

---

**Getting started:**

```powershell
Install-Module ConnectWiseAutomateAgent
```

Full function reference and examples: [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseAutomateAgent)
