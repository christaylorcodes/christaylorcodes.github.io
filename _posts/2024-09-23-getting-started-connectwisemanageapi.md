---
layout: post
title: "Getting Started with ConnectWiseManageAPI: Your First Steps"
short_title: "Getting Started with ConnectWiseManageAPI"
date: 2024-12-02 09:00:00 -0500
categories: [PowerShell, PSA, ConnectWiseManageAPI]
tags: [PowerShell, ConnectWise, Manage, PSA, Tutorial, Getting-Started, MSP, API]
author: Chris Taylor
excerpt: "Step-by-step guide to start automating ConnectWise Manage. Learn how to get API credentials, install the module, connect to your server, and run your first automation tasks with troubleshooting help."
---

In this guide, we'll walk through everything you need to know to start using ConnectWiseManageAPI in your environment. By the end, you'll have the module installed, configured, and you'll have executed your first automation tasks.

## Prerequisites

Before we begin, you'll need:

1. **PowerShell 3.0 or higher** (PowerShell 5.1+ recommended)
2. **A ConnectWise Manage account** with API access
3. **API credentials** from ConnectWise Manage
4. **A Client ID** from the ConnectWise Developer Portal

Don't worry—we'll walk through obtaining all of these.

## Step 1: Obtaining API Credentials

To use the ConnectWise Manage API, you need to generate API keys from your Manage instance.

### Creating API Keys

1. Log into ConnectWise Manage
2. Navigate to **System > Members**
3. Select your member account (or create a dedicated API user)
4. Click on **API Keys** tab
5. Click **Add** to create a new API key pair
6. Enter a description (e.g., "PowerShell Automation")
7. Save the **Public Key** and **Private Key** securely

**Important Security Notes:**
- Treat these keys like passwords—never commit them to source control
- Consider creating a dedicated API user account with appropriate permissions
- Store keys in a secure location like Azure Key Vault
- Rotate keys periodically

### Getting Your Client ID

As of August 2019, ConnectWise requires a Client ID for all API interactions.

1. Visit [https://developer.connectwise.com/ClientID](https://developer.connectwise.com/ClientID)
2. Log in with your ConnectWise credentials
3. Register your application
4. Copy your Client ID

This Client ID is unique to your integration and helps ConnectWise track API usage.

## Step 2: Installing the Module

Installing ConnectWiseManageAPI is straightforward using PowerShell Gallery.

### First-Time Installation

```powershell
Install-Module 'ConnectWiseManageAPI'
```

If you encounter issues accessing PowerShell Gallery, you may need to initialize it first. Check out the [Initialize-PSGallery](https://github.com/christaylorcodes/Initialize-PSGallery) helper script.

### Updating the Module

To update to the latest version:

```powershell
Update-Module 'ConnectWiseManageAPI'
```

### Verifying Installation

Confirm the module is installed and check its version:

```powershell
Get-Module 'ConnectWiseManageAPI' -ListAvailable
```

Import the module:

```powershell
Import-Module 'ConnectWiseManageAPI'
```

View available commands:

```powershell
Get-Command -Module 'ConnectWiseManageAPI'
```

You should see 180+ cmdlets available for use.

## Step 3: Connecting to ConnectWise Manage

Now that you have credentials and the module installed, let's connect to your Manage server.

### Basic Connection

```powershell
$ConnectionInfo = @{
    Server      = 'na.myconnectwise.net'  # Your Manage server URL
    Company     = 'YourCompanyID'          # Your company identifier
    pubkey      = 'your-public-key'        # Public API key
    privatekey  = 'your-private-key'       # Private API key
    clientid    = 'your-client-id'         # Client ID from developer portal
}

Connect-CWM @ConnectionInfo
```

### Secure Credential Storage

For production use, don't hardcode credentials. Here are better approaches:

**Option 1: Using Azure Key Vault**

```powershell
# Retrieve credentials from Azure Key Vault
$pubkey = Get-AzKeyVaultSecret -VaultName 'YourVault' -Name 'CWM-PublicKey' -AsPlainText
$privatekey = Get-AzKeyVaultSecret -VaultName 'YourVault' -Name 'CWM-PrivateKey' -AsPlainText
$clientid = Get-AzKeyVaultSecret -VaultName 'YourVault' -Name 'CWM-ClientID' -AsPlainText

$ConnectionInfo = @{
    Server      = 'na.myconnectwise.net'
    Company     = 'YourCompanyID'
    pubkey      = $pubkey
    privatekey  = $privatekey
    clientid    = $clientid
}

Connect-CWM @ConnectionInfo
```

**Option 2: Using Environment Variables**

```powershell
$ConnectionInfo = @{
    Server      = $env:CWM_SERVER
    Company     = $env:CWM_COMPANY
    pubkey      = $env:CWM_PUBKEY
    privatekey  = $env:CWM_PRIVATEKEY
    clientid    = $env:CWM_CLIENTID
}

Connect-CWM @ConnectionInfo
```

**Option 3: Using a Separate Configuration File**

Create a file `CWMConfig.ps1` (add to .gitignore):

```powershell
# CWMConfig.ps1 (DO NOT COMMIT TO SOURCE CONTROL)
@{
    Server      = 'na.myconnectwise.net'
    Company     = 'YourCompanyID'
    pubkey      = 'your-public-key'
    privatekey  = 'your-private-key'
    clientid    = 'your-client-id'
}
```

Load it in your scripts:

```powershell
$ConnectionInfo = & .\CWMConfig.ps1
Connect-CWM @ConnectionInfo
```

### Verifying Your Connection

After connecting, verify it worked:

```powershell
Get-CWMSystemInfo
```

This should return information about your ConnectWise Manage environment.

## Step 4: Your First Commands

Let's try some basic operations to get familiar with the module.

### Retrieving Companies

Get all companies (this may take a moment if you have many):

```powershell
$Companies = Get-CWMCompany -all
$Companies | Select-Object id, name, city, state | Format-Table
```

Get a specific company by ID:

```powershell
Get-CWMCompany -CompanyID 123
```

Search for companies by condition:

```powershell
Get-CWMCompany -condition "city='Salt Lake City'" -all
```

### Working with Tickets

Get all open tickets:

```powershell
$OpenTickets = Get-CWMTicket -condition "status/name='Open'" -all
$OpenTickets | Select-Object id, summary, company | Format-Table
```

Get tickets for a specific company:

```powershell
Get-CWMTicket -condition "company/id=123" -all
```

Get a single ticket with all details:

```powershell
$Ticket = Get-CWMTicket -TicketID 456
$Ticket
```

### Creating a New Ticket

```powershell
$NewTicketParams = @{
    summary = 'Test ticket from PowerShell'
    company = @{id = 123}
    board = @{id = 1}
    contactName = 'John Smith'
    contactEmailAddress = 'john.smith@example.com'
}

$NewTicket = New-CWMTicket @NewTicketParams
Write-Host "Created ticket $($NewTicket.id)"
```

### Adding a Note to a Ticket

```powershell
$NoteParams = @{
    ticketId = $NewTicket.id
    text = 'This ticket was created via the API for testing purposes.'
    internalAnalysisFlag = $true
}

New-CWMTicketNote @NoteParams
```

### Retrieving Service Boards

Get all service boards:

```powershell
Get-CWMServiceBoard -all
```

Get statuses for a specific board:

```powershell
Get-CWMServiceBoardStatus -BoardID 1 -all
```

### Working with Contacts

Search for contacts:

```powershell
Get-CWMContact -condition "company/id=123" -all
```

Get contact details:

```powershell
Get-CWMContact -ContactID 789
```

## Step 5: Understanding Common Parameters

Most GET functions in ConnectWiseManageAPI support these parameters:

### Filtering with Conditions

The `condition` parameter uses ConnectWise's query syntax:

```powershell
# Simple equality
Get-CWMTicket -condition "status/name='Open'"

# Multiple conditions with AND
Get-CWMTicket -condition "status/name='Open' and priority/id=1"

# Using contains
Get-CWMCompany -condition "name contains 'Tech'"

# Comparison operators
Get-CWMTicket -condition "id > 1000"

# Using OR requires parentheses
Get-CWMTicket -condition "(status/name='Open' or status/name='New')"
```

### Sorting Results

```powershell
Get-CWMTicket -orderBy "id desc" -pageSize 10
```

### Selecting Specific Fields

Reduce data transfer by requesting only needed fields:

```powershell
Get-CWMCompany -fields "id,name,city,state" -all
```

### Pagination

For large datasets, use pagination:

```powershell
# Get first page (25 records by default)
Get-CWMTicket -page 1 -pageSize 25

# Get all results automatically
Get-CWMTicket -all
```

### Getting Record Counts

Just want to know how many records match?

```powershell
Get-CWMTicket -condition "status/name='Open'" -count
```

## Step 6: A Complete Example

Let's put it all together with a practical example: creating a ticket with all the details.

```powershell
# Import the module
Import-Module 'ConnectWiseManageAPI'

# Connect (using secure method)
$ConnectionInfo = @{
    Server      = 'na.myconnectwise.net'
    Company     = 'YourCompanyID'
    pubkey      = $env:CWM_PUBKEY
    privatekey  = $env:CWM_PRIVATEKEY
    clientid    = $env:CWM_CLIENTID
}
Connect-CWM @ConnectionInfo -Verbose

# Get company interactively
$Companies = Get-CWMCompany -all
$Company = $Companies | Select-Object id, name |
    Out-GridView -OutputMode Single -Title 'Select Company'

# Create ticket parameters
$TicketParams = @{
    summary = 'Network connectivity issue in Building A'
    company = @{id = $Company.id}
    board = @{id = 1}
    contactName = 'Sarah Johnson'
    contactPhoneNumber = '555-0123'
    contactEmailAddress = 'sarah.johnson@example.com'
    priority = @{id = 3}  # Assuming 3 is Medium priority
}

# Create the ticket
$Ticket = New-CWMTicket @TicketParams

# Add initial note
$NoteParams = @{
    ticketId = $Ticket.id
    text = "Initial investigation notes:`n- Issue reported at 9:30 AM`n- Affects 5 workstations`n- Network switch shows amber light"
    internalAnalysisFlag = $true
}
New-CWMTicketNote @NoteParams

# Display result
Write-Host "Successfully created ticket #$($Ticket.id)" -ForegroundColor Green
Write-Host "Summary: $($Ticket.summary)"
Write-Host "Company: $($Company.name)"

# Clean up connection
Disconnect-CWM
```

## Getting Help

### Built-in Help

Every function includes comment-based help:

```powershell
Get-Help Get-CWMTicket -Full
Get-Help New-CWMTicket -Examples
```

### Additional Resources

- [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseManageAPI)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/ConnectWiseManageAPI)
- [ConnectWise API Documentation](https://developer.connectwise.com/Products/Manage/REST)

## Troubleshooting Common Issues

### Authentication Failures

**Error:** "401 Unauthorized"

**Solutions:**
- Verify your API keys are correct
- Ensure your Client ID is valid
- Check that the API user account is active
- Confirm the company ID matches your login company

### Connection Timeouts

**Error:** "The operation has timed out"

**Solutions:**
- Verify your server URL is correct (include 'https://' if needed)
- Check network connectivity to the Manage server
- Ensure firewall rules allow outbound HTTPS

### Rate Limiting

**Error:** "429 Too Many Requests"

**Solutions:**
- Implement delays between API calls
- Use the `-all` parameter instead of manual pagination loops
- Consider batching operations

### Empty Results

**Problem:** Query returns no results when you expect data

**Solutions:**
- Verify condition syntax (check for typos)
- Test condition in ConnectWise Manage's API directly
- Check field names are correct (they're case-sensitive)
- Ensure you have permissions to view the data

## Next Steps

Now that you're up and running, you can:

1. **Explore the Examples** - Check out the GitHub repository for more scenarios
2. **Build Your First Automation** - Identify a repetitive task and automate it
3. **Create Custom Reports** - Extract data and create reports tailored to your needs
4. **Integrate Systems** - Connect ConnectWise Manage with your other tools

In the next blog post, we'll explore advanced automation scenarios including building complex integrations, handling bulk operations efficiently, and creating scheduled automation workflows.

---

**Series Navigation:**
- Previous: [Introducing ConnectWiseManageAPI](/2024/11/25/introducing-connectwisemanageapi.html)
- Next: [Advanced Automation Scenarios](/2024/12/09/advanced-automation-connectwisemanageapi.html)
