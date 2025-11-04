---
layout: post
title: "Building PowerShell API Wrappers: Lessons from ConnectWiseControlAPI"
date: 2024-10-28 10:00:00 -0000
categories: [PowerShell, Development, ConnectWiseControlAPI]
tags: [PowerShell, API, Module Development, Best Practices, Lessons Learned, Software Engineering]
author: Chris Taylor
excerpt: "Architectural decisions, mistakes, and best practices learned from building and maintaining ConnectWiseControlAPI. A comprehensive guide to wrapping REST APIs in PowerShell for operations teams."
---

## Why Build API Wrappers?

After 20+ years in MSP operations, I've built PowerShell wrappers for several REST APIs—ConnectWise Manage, ConnectWise Control, and various other vendor platforms. Each time, the goal is the same: make complex APIs accessible to operations teams who need automation but don't want to become API experts.

ConnectWiseControlAPI, with 81+ GitHub stars and active production use across multiple MSPs, represents several years of learning what works (and what doesn't) when wrapping REST APIs in PowerShell. This article shares the architectural decisions, mistakes, and best practices learned through building and maintaining this module.

## Core Design Decisions

### Decision 1: Private vs Public Function Separation

The module uses a clear separation between private helper functions and public cmdlets:

```
ConnectWiseControlAPI/
├── Private/
│   ├── Invoke-CWCWebRequest.ps1    # Internal API call handler
│   └── Join-Url.ps1                 # Internal URL builder
└── Public/
    ├── Authentication/
    ├── PageService/
    └── SecurityService/
```

**Why This Matters:**

Private functions handle the messy details—authentication headers, JSON serialization, error parsing, URL construction. Public functions expose clean, PowerShell-idiomatic interfaces.

```powershell
# Public function - clean interface
function Get-CWCSession {
    param(
        [string]$Search,
        [int]$Limit = 100
    )

    # Build the URI
    $URI = "$($global:CWCServerConnection.Server)/Services/PageService.ashx/GetSessionDetails"

    # Build request body
    $Body = @{
        searchText = $Search
        limit      = $Limit
    } | ConvertTo-Json

    # Private function handles authentication, headers, error handling
    Invoke-CWCWebRequest -Method 'POST' -Uri $URI -Body $Body
}
```

The private `Invoke-CWCWebRequest` function handles:
- Authentication header injection
- Timeout management
- HTTP error code translation
- JSON content type headers
- SSL/TLS configuration

Public functions focus on business logic and user-facing parameters.

### Decision 2: Connection State Management

Early versions required passing server URL and credentials to every function call. This was tedious:

```powershell
# Bad: Repetitive and error-prone
Get-CWCSession -Server $server -Credential $cred
Remove-CWCSession -Server $server -Credential $cred -SessionID 12345
Update-CWCUser -Server $server -Credential $cred -UserID 67890
```

The solution: cache connection information in a global variable after initial connection:

```powershell
# Good: Connect once, use everywhere
Connect-CWC -Server 'https://control.domain.com' -Credential $cred

# All subsequent calls use cached connection
Get-CWCSession
Remove-CWCSession -SessionID 12345
Update-CWCUser -UserID 67890
```

**Implementation:**

```powershell
function Connect-CWC {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,

        [Parameter(Mandatory = $true)]
        [PSCredential]$Credential
    )

    # Test connection
    $testUri = "$Server/Services/PageService.ashx/GetHostSessionID"

    try {
        $response = Invoke-WebRequest -Uri $testUri -Credential $Credential -UseBasicAuth
    }
    catch {
        throw "Failed to connect to Control server: $_"
    }

    # Cache connection info globally
    $global:CWCServerConnection = [PSCustomObject]@{
        Server     = $Server
        Credential = $Credential
        Connected  = Get-Date
    }

    Write-Verbose "Connected to $Server successfully"
}
```

All subsequent functions check for this global variable:

```powershell
function Get-CWCSession {
    # Verify connection exists
    if (!$global:CWCServerConnection) {
        throw "Not connected to a CWC Server. Use Connect-CWC to establish a connection."
    }

    # Proceed with API call...
}
```

**Lessons Learned:**

- Global state is typically discouraged, but for API sessions it's practical
- Clear error messages when not connected improve user experience
- Consider adding `Disconnect-CWC` to clear cached credentials

### Decision 3: Parameter Naming and Consistency

ConnectWise Control's API uses inconsistent parameter names across endpoints. Some use `SessionID`, others use `sessionGuid`, some use `GUID`.

Rather than expose this inconsistency, the wrapper normalizes it:

```powershell
# API endpoint A expects: sessionGuid
# API endpoint B expects: SessionID
# API endpoint C expects: guid

# Wrapper consistently uses: GUID
function Get-CWCSessionDetail {
    param([string]$GUID)  # User sees consistent naming

    # Internally map to whatever the API expects
    $Body = @{ sessionGuid = $GUID } | ConvertTo-Json
}

function Remove-CWCSession {
    param([string]$GUID)  # Same parameter name

    # Different API endpoint, different internal name
    $Body = @{ SessionID = $GUID } | ConvertTo-Json
}
```

**Why This Matters:**

Users shouldn't need to memorize API quirks. PowerShell wrappers should provide a consistent, intuitive interface.

### Decision 4: PowerShell Best Practices Integration

The module follows PowerShell conventions:

#### Approved Verbs

```powershell
Get-CWCSession      # Get (retrieve data)
New-CWCUser         # New (create)
Update-CWCUser      # Update (modify)
Remove-CWCSession   # Remove (delete)
Invoke-CWCCommand   # Invoke (execute)
```

#### Pipeline Support

```powershell
# Objects flow through pipeline
Get-CWCSession -Group 'Servers' |
    Where-Object { $_.GuestOperatingSystemName -like '*Windows Server*' } |
    ForEach-Object {
        Update-CWCCustomProperty -GUID $_.SessionID -Property 'Type' -Value 'Server'
    }
```

#### Common Parameters

Support `-WhatIf`, `-Confirm`, `-Verbose`:

```powershell
function Remove-CWCSession {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$GUID
    )

    if ($PSCmdlet.ShouldProcess("Session $GUID", "Remove session")) {
        # Perform removal
        Invoke-CWCWebRequest -Method 'DELETE' -Uri $URI
    }
}
```

Users can now safely preview and confirm:

```powershell
# Preview without executing
Remove-CWCSession -GUID 12345 -WhatIf

# Prompt for confirmation
Remove-CWCSession -GUID 12345 -Confirm
```

## Common Challenges and Solutions

### Challenge 1: API Documentation Quality

ConnectWise Control's API documentation is... minimal. Endpoints are documented primarily through the API interface itself, which requires authentication and experimentation.

**Solution: Documentation Through Usage**

Document what you discover in comprehensive comment-based help:

```powershell
function Get-CWCSession {
    <#
    .SYNOPSIS
        Retrieves session information from ConnectWise Control.

    .DESCRIPTION
        Queries the Control server for session details. Can search by name,
        filter by type (Access or Support), limit results, and filter by group.

    .PARAMETER Search
        Search term to filter sessions by name. Supports partial matching.

    .PARAMETER Type
        Filter by session type. Valid values: 'Access', 'Support'

    .PARAMETER Limit
        Maximum number of sessions to return. Default: 100

    .PARAMETER Group
        Filter sessions by session group name.

    .EXAMPLE
        Get-CWCSession -Search 'SERVER01' -Limit 1
        Find a session with name matching 'SERVER01'

    .EXAMPLE
        Get-CWCSession -Type Access -Group 'Production Servers' -Limit 500
        Get up to 500 access sessions from the 'Production Servers' group

    .NOTES
        API Endpoint: /Services/PageService.ashx/GetSessionDetails
        Requires: Active connection via Connect-CWC

    .LINK
        https://github.com/christaylorcodes/ConnectWiseControlAPI
    #>

    # Function implementation...
}
```

Every function includes:
- Clear synopsis and description
- All parameters documented
- Multiple realistic examples
- Notes about requirements and API endpoints

### Challenge 2: API Rate Limiting and Performance

Bulk operations can hit API rate limits or timeout:

```powershell
# Bad: Sequential calls are slow
$sessions = Get-CWCSession -Limit 1000
foreach ($session in $sessions) {
    $detail = Get-CWCSessionDetail -GUID $session.SessionID  # 1000 API calls!
    # Process detail...
}
```

**Solution: Batch operations and timeout configuration**

Provide timeout parameters for long-running operations:

```powershell
function Invoke-CWCCommand {
    param(
        [string]$GUID,
        [string]$Command,
        [int]$TimeOut = 120000  # Default 2 minutes, configurable
    )

    $Body = @{
        sessionGuid = $GUID
        command     = $Command
        timeout     = $TimeOut
    } | ConvertTo-Json

    Invoke-CWCWebRequest -Method 'POST' -Uri $URI -Body $Body -TimeoutMs $TimeOut
}
```

Users can adjust for long-running commands:

```powershell
# Allow 10 minutes for Windows Update installation
Invoke-CWCCommand -GUID $id -Command $updateScript -TimeOut 600000
```

### Challenge 3: Error Handling and User Feedback

REST APIs return various HTTP status codes and error formats. Raw errors aren't helpful:

```
Invoke-WebRequest : {"ErrorMessage":"Session not found","ErrorCode":404}
```

**Solution: Parse and translate API errors**

```powershell
function Invoke-CWCWebRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [string]$Body
    )

    try {
        $response = Invoke-WebRequest `
            -Method $Method `
            -Uri $Uri `
            -Body $Body `
            -Credential $global:CWCServerConnection.Credential `
            -ContentType 'application/json'

        return $response.Content | ConvertFrom-Json
    }
    catch {
        # Parse API error response
        $errorDetails = $null
        if ($_.ErrorDetails.Message) {
            try {
                $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
            }
            catch {
                # Not JSON, use raw message
                $errorDetails = $_.ErrorDetails.Message
            }
        }

        # Construct helpful error message
        $errorMessage = "API call failed: "
        if ($errorDetails.ErrorMessage) {
            $errorMessage += $errorDetails.ErrorMessage
        }
        else {
            $errorMessage += $_.Exception.Message
        }

        throw $errorMessage
    }
}
```

Now users see clear, actionable errors:

```powershell
Get-CWCSession -Search 'NONEXISTENT'
# Error: "API call failed: Session not found"
```

### Challenge 4: Authentication Security

Storing and handling credentials securely is critical. The module supports:

**Interactive credential prompts:**

```powershell
Connect-CWC -Server $server -Credential (Get-Credential)
```

**Secure credential storage:**

```powershell
# Save (encrypted per-user, per-machine)
$cred = Get-Credential
$cred | Export-Clixml -Path 'C:\Secure\cwc-cred.xml'

# Retrieve in scripts
$cred = Import-Clixml -Path 'C:\Secure\cwc-cred.xml'
Connect-CWC -Server $server -Credential $cred
```

**Never** log or expose credentials:

```powershell
# Bad: Credentials in verbose output
Write-Verbose "Connecting with password: $($Credential.GetNetworkCredential().Password)"

# Good: No credential exposure
Write-Verbose "Connecting to $Server as $($Credential.UserName)"
```

## Module Publishing and Maintenance

### Publishing to PowerShell Gallery

The module is published to the PowerShell Gallery, making installation a single command. Key steps:

1. **Manifest Accuracy** - Ensure `.psd1` has correct version, functions list, dependencies
2. **Testing** - Run Pester tests before publishing
3. **Semantic Versioning** - Follow major.minor.patch.build convention
4. **Release Notes** - Document changes in each version

```powershell
# Test manifest
Test-ModuleManifest ./ConnectWiseControlAPI.psd1

# Publish (requires API key from PowerShellGallery.com)
Publish-Module -Path ./ConnectWiseControlAPI -NuGetApiKey $apiKey
```

### Automated Testing with Pester

Basic tests verify module structure and function availability:

```powershell
Describe "ConnectWiseControlAPI Module" {
    It "Module imports successfully" {
        { Import-Module ConnectWiseControlAPI -Force } | Should -Not -Throw
    }

    It "All public functions are exported" {
        $functions = Get-Command -Module ConnectWiseControlAPI
        $functions.Count | Should -BeGreaterThan 0
    }

    It "Connect-CWC function exists" {
        Get-Command Connect-CWC -Module ConnectWiseControlAPI | Should -Not -BeNull
    }
}
```

### Documentation Generation with PlatyPS

Auto-generate markdown documentation from comment-based help:

```powershell
# Install PlatyPS
Install-Module -Name PlatyPS

# Import module
Import-Module ./ConnectWiseControlAPI.psd1 -Force

# Generate documentation
New-MarkdownHelp -Module ConnectWiseControlAPI -OutputFolder ./Docs -Force

# Update existing docs after changes
Update-MarkdownHelp -Path ./Docs
```

This creates markdown files for each function, enabling:
- GitHub documentation browsing
- Consistent formatting
- Easy updates when functions change

## What I'd Do Differently

After several years of maintaining this module, here's what I'd change:

### 1. Comprehensive Logging

Add structured logging from the start:

```powershell
# Future enhancement: Logging support
function Invoke-CWCWebRequest {
    param(
        [string]$Method,
        [string]$Uri,
        [string]$Body,
        [string]$LogPath = "$env:TEMP\CWCApi.log"
    )

    # Log request (sanitized)
    $logEntry = @{
        Timestamp = Get-Date
        Method    = $Method
        Uri       = $Uri -replace 'api-key=.*', 'api-key=REDACTED'
        BodySize  = $Body.Length
    }
    $logEntry | ConvertTo-Json | Add-Content -Path $LogPath

    # Make API call...
}
```

### 2. Better Type Safety

Define custom classes for common objects:

```powershell
# Current: Generic PSCustomObject
$session = Get-CWCSession  # Returns [PSCustomObject]

# Better: Strongly-typed objects
class CWCSession {
    [string]$SessionID
    [string]$Name
    [string]$SessionType
    [datetime]$LastConnectedEventTime
    [string]$GuestOperatingSystemName
}

function Get-CWCSession {
    # Return [CWCSession[]]
}
```

Benefits:
- IntelliSense support
- Type validation
- Self-documenting code

### 3. Response Pagination

Large environments hit API limits. Support pagination:

```powershell
function Get-CWCSession {
    param(
        [int]$Limit = 100,
        [int]$Offset = 0,
        [switch]$All  # Automatically page through all results
    )

    if ($All) {
        # Recursive pagination
        $results = @()
        $offset = 0
        do {
            $batch = Get-CWCSession -Limit 100 -Offset $offset
            $results += $batch
            $offset += 100
        } while ($batch.Count -eq 100)
        return $results
    }

    # Regular limited query...
}
```

### 4. Connection Profiles

Support multiple simultaneous connections:

```powershell
# Connect to multiple Control servers
Connect-CWC -Server 'https://control1.com' -ProfileName 'Prod'
Connect-CWC -Server 'https://control-test.com' -ProfileName 'Test'

# Use specific profile
Get-CWCSession -ProfileName 'Prod'
Get-CWCSession -ProfileName 'Test'
```

## Key Takeaways

**Architectural Decisions:**
- Separate private (API handling) from public (user interface) functions
- Cache connection state to avoid repetitive parameter passing
- Normalize inconsistent API naming for user convenience
- Follow PowerShell best practices (approved verbs, pipeline support, common parameters)

**Implementation Best Practices:**
- Comprehensive comment-based help with realistic examples
- Proper error handling with helpful, actionable messages
- Support for `-WhatIf` and `-Confirm` on destructive operations
- Configurable timeouts for long-running operations
- Secure credential handling without exposure in logs

**Maintenance and Distribution:**
- Publish to PowerShell Gallery for easy installation
- Automated testing with Pester
- Auto-generate documentation with PlatyPS
- Semantic versioning with clear release notes

**Future Enhancements:**
- Structured logging capability
- Strong typing with custom classes
- Automatic response pagination
- Multiple connection profile support

## Resources

- **ConnectWiseControlAPI**: [GitHub Repository](https://github.com/christaylorcodes/ConnectWiseControlAPI)
- **PowerShell Gallery**: [Module Page](https://www.powershellgallery.com/packages/ConnectWiseControlAPI)
- **PlatyPS**: [Documentation Generator](https://github.com/PowerShell/platyPS)
- **Pester**: [PowerShell Testing Framework](https://pester.dev/)
- **PowerShell Best Practices**: [Style Guide](https://poshcode.gitbook.io/powershell-practice-and-style/)

Building API wrappers is iterative. Start with core functionality, gather feedback, and continuously improve. The goal is making complex APIs accessible to operations teams who need automation without becoming API experts.

Have you built PowerShell API wrappers? What challenges did you face? Share your experiences in the GitHub discussions.
