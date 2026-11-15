---
layout: post
title: "Upgrading to ConnectWiseManageAPI 0.5: Breaking Changes and Migration"
short_title: "Upgrading to ConnectWiseManageAPI 0.5"
date: 2026-11-16 10:00:00 -0000
categories: [PowerShell, PSA, ConnectWiseManageAPI]
tags: [PowerShell, ConnectWise, PSA, Manage, API, Migration]
author: Chris Taylor
excerpt: "ConnectWiseManageAPI 0.5 drops Connect-CWM -Version, needs PowerShell 5.1 or later, and moves project tickets to their own cmdlet. This checklist shows you how to find the calls that break in your scripts, fix them, and start using the new features."
description: "How to upgrade your ConnectWise PSA (Manage) PowerShell scripts to ConnectWiseManageAPI 0.5: every breaking change, a script to find affected calls, and before/after fixes."
draft_review: true
---

<!-- REVIEW: verify all code examples against a live server before publishing -->

ConnectWiseManageAPI 0.5.0 is out, and it has breaking changes. Most scripts need one or two small edits. A few need a closer look.

Here's the short version:

- **PowerShell 5.1 or later is required.** PowerShell 7 is now the primary edition.
- **`Connect-CWM -Version` is gone.** The module always uses your server's current API version.
- **Project tickets have their own cmdlet.** `New-CWMTicket` no longer takes `-project` or `-phase`. Use `New-CWMProjectTicket`.
- **`Connect-CWM -MemberID` really impersonates now.** In 0.4.16 it quietly used the API key instead.
- **Some parameters, aliases and positions changed.** Named parameters fix most of it.

The rest of this post is the checklist I'd follow, in order. If you're new to the module, start with [Getting Started with ConnectWiseManageAPI](/powershell/psa/connectwisemanageapi/2024/09/23/getting-started-connectwisemanageapi.html) instead. The [project page](/projects/connectwisemanageapi/) has the overview.

## Before You Upgrade

Don't upgrade the box that runs your production automation first. Install 0.5.0 on a workstation, fix your scripts there, and then roll it out.

`Update-Module` installs the new version next to the old one. It doesn't remove 0.4.16.

```powershell
# See what you have installed
Get-InstalledModule ConnectWiseManageAPI -AllVersions

# Install 0.5.0 alongside it
Update-Module ConnectWiseManageAPI
```

Until a script is migrated, pin it to the old version. Put this at the top of the script:

```powershell
#Requires -Modules @{ ModuleName = 'ConnectWiseManageAPI'; RequiredVersion = '0.4.16' }
```

Remove the line once the script works on 0.5.0.

## Step 1: Check Your PowerShell Version

0.5.0 needs PowerShell 5.1 or later. It used to accept 3.0.

```powershell
$PSVersionTable.PSVersion
```

If a machine is still on Windows Management Framework (WMF) 4.0 or 5.0, you have two options. Upgrade WMF, or keep that machine on 0.4.16. PowerShell 7 is now the primary edition, and it runs on Windows, Linux and macOS. Windows PowerShell 5.1 is still supported and tested.

## Step 2: Find the Calls That Break

You don't need to read every script. Search for the patterns that changed.

### Removed Parameters and Renamed Aliases

This finds removed parameters, renamed aliases and error-handling code that matches on the old error id. Point `-Path` at your scripts folder.

```powershell
$Scripts = Get-ChildItem -Path 'C:\Scripts' -Include '*.ps1', '*.psm1' -Recurse

$Patterns = @(
    'Connect-CWM\b.*-Version\b'
    'New-CWMTicket\b.*-(Version|VersionAutomatic|project|phase|wbsCode|locationId|businessUnitId|dateEntered|enteredBy)\b'
    'Get-CWMTicketAllNote\b.*-id\b'
    'New-CWMMember\b.*-(TimeZoneSetupReference|remotePackage\w*)\b'
    'New-CWMProductCatalog\b.*-dateEntered\b'
    'Remove-CWMDocument\b.*-somethingId\b'
    'Update-CWM(ProductAdjustment|PurchaseOrder)\b.*-catalogId\b'
    'Get-CWMCompanyCountry\b.*-companyId\b'
    'Connect-CWM\b.*-MemberID\b'
    'New-CWMDocument\b'
    'Invoke-CWMWebRequest'
    # Keys in splatting hashtables. These match other code too, so review each hit.
    '^\s*(Version|VersionAutomatic|project|phase|wbsCode|locationId|businessUnitId|MemberID)\s*='
)

$Scripts | Select-String -Pattern $Patterns | Select-Object Path, LineNumber, Line
```

`Select-String` works line by line. If you split a call across lines with backticks, or splat a hashtable, the cmdlet patterns can miss it. The last pattern looks for the old parameter names as hashtable keys, which catches most of those.

### Positional Calls to Changed Cmdlets

Five cmdlets had parameters removed or added, so their positions shifted. A text search can't tell a positional value from a named one, but the PowerShell parser can. This lists every call to those five cmdlets that passes a value without a parameter name in front of it:

```powershell
$ChangedCmdlets = @(
    'Get-CWMTicketAllNote'
    'New-CWMMember'
    'New-CWMProductCatalog'
    'Get-CWMProductAdjustmentDetail'
    'New-CWMProjectTicketConfiguration'
)

Get-ChildItem -Path 'C:\Scripts' -Include '*.ps1', '*.psm1' -Recurse | ForEach-Object {
    $File = $_.FullName
    $Ast = [System.Management.Automation.Language.Parser]::ParseFile($File, [ref]$null, [ref]$null)

    $Calls = $Ast.FindAll({
        param($Node)
        $Node -is [System.Management.Automation.Language.CommandAst] -and
        $Node.GetCommandName() -in $ChangedCmdlets
    }, $true)

    foreach ($Call in $Calls) {
        $Elements = $Call.CommandElements
        for ($Index = 1; $Index -lt $Elements.Count; $Index++) {
            $Element = $Elements[$Index]
            $Previous = $Elements[$Index - 1]

            $IsParameterName = $Element -is [System.Management.Automation.Language.CommandParameterAst]
            $IsSplat = $Element -is [System.Management.Automation.Language.VariableExpressionAst] -and $Element.Splatted
            $FollowsParameterName = $Previous -is [System.Management.Automation.Language.CommandParameterAst] -and -not $Previous.Argument

            if (-not ($IsParameterName -or $IsSplat -or $FollowsParameterName)) {
                [PSCustomObject]@{
                    File = $File
                    Line = $Call.Extent.StartLineNumber
                    Call = $Call.Extent.Text
                }
                break
            }
        }
    }
}
```

It has one blind spot. It treats the value after a switch like `-all` as that switch's argument, so a positional value placed right after a switch won't show up. That's rare, but worth knowing.

## Step 3: Fix Each Breaking Change

Work through whatever the search found. Each change below has the old code and the new code.

### Connect-CWM -Version Is Removed

`Connect-CWM` now reads the version from `/system/info` and pins every request to it. In 0.4.16, if you didn't pass `-Version`, the module sent no version at all.

Before:

```powershell
Connect-CWM @ConnectionInfo -Version '2019.1'
```

After:

```powershell
Connect-CWM @ConnectionInfo
```

This is the change most likely to bite quietly. Responses now follow the server's current API model. If a script reads a field that an older API version returned, check that the field still exists and has the same shape. A quick way is to save the same record from both versions and compare them. Use two separate PowerShell sessions, because one session can't load both versions of the module.

```powershell
# Session 1: the old version
Import-Module ConnectWiseManageAPI -RequiredVersion 0.4.16
Connect-CWM @ConnectionInfo
Get-CWMTicket -id 12345 | ConvertTo-Json -Depth 10 | Set-Content .\ticket-0.4.16.json

# Session 2: the new version
Import-Module ConnectWiseManageAPI -RequiredVersion 0.5.0
Connect-CWM @ConnectionInfo
Get-CWMTicket -id 12345 | ConvertTo-Json -Depth 10 | Set-Content .\ticket-0.5.0.json

# Either session: show the lines that differ
Compare-Object (Get-Content .\ticket-0.4.16.json) (Get-Content .\ticket-0.5.0.json)
```

Do this for each record type your scripts read from: tickets, companies, time entries, and so on.

### Project Tickets Move to New-CWMProjectTicket

`New-CWMTicket` lost `-project`, `-phase` and `-wbsCode`. It posts to `/service/tickets`, which is the wrong place for a project ticket anyway. `New-CWMProjectTicket` posts to `/project/tickets`, so the ticket lands on the project.

Before:

```powershell
New-CWMTicket -summary 'Configure backups' -company @{ id = 250 } -project @{ id = 386 } -phase @{ id = 12 }
```

After:

```powershell
New-CWMProjectTicket -summary 'Configure backups' -project @{ id = 386 } -phase @{ id = 12 }
```

`New-CWMTicket` also dropped `-Version`, `-VersionAutomatic`, `-locationId`, `-businessUnitId`, `-dateEntered` and `-enteredBy`. Remove them. The API sets or ignores those fields. If you need to set the location or department on a ticket, `-location` and `-department` take references like `@{ id = 1 }`.

### Connect-CWM -MemberID Now Impersonates

In 0.4.16, `-MemberID` was accepted and then ignored. Every request ran as the API member. Now every request really runs as that member.

```powershell
Connect-CWM -Server $Server -Company $Company -PubKey $PubKey -PrivateKey $PrivateKey -ClientID $ClientID -MemberID 'jsmith'
```

That's what you probably wanted all along. Still, check what the member is allowed to do before you rely on it. A script that worked as the API member can fail on permissions as a regular member, and records will show that member as the one who changed them.

### Add or Replace Without a Value Now Errors

An `add` or `replace` update with no `-Value` used to send `null`. Now it stops with an error. If you meant to clear a field, say so:

```powershell
Update-CWMTicket -id 12345 -Operation replace -Path 'owner' -Value $null
```

For `remove`, `-Value` is now optional.

### New-CWMDocument Uploads Are Private by Default

The `PrivateFlag` header was malformed in 0.4.16, so the server most likely applied its own default. Now `-Private` (default `$true`) reaches the server. If customers should see a document, say so:

```powershell
New-CWMDocument -recordType Ticket -recordId 12345 -title 'Network diagram' -FilePath 'C:\Temp\diagram.pdf' -Private $false
```

### Positional Parameters Shifted

If the parser search found anything, switch those calls to named parameters. Here's what moved:

- **`Get-CWMTicketAllNote`:** `-id` is gone, so `-condition` and everything after it moved up one position.
- **`New-CWMMember`:** the parameters after `-timeZone` moved up one, and the ones after `-agreementInvoicingDisplayOptions` moved up six.
- **`New-CWMProductCatalog`:** the parameters after `-integrationXRef` moved up one.
- **`Get-CWMProductAdjustmentDetail`:** the new mandatory `-parentId` is position 0, so `-id` is now position 1.
- **`New-CWMProjectTicketConfiguration`:** `-_info` moved from position 2 to 3 because of the new `-deviceIdentifier`.

A named call looks like this, and it binds the same way in every version:

```powershell
Get-CWMTicketAllNote -parentId 12345 -condition "text like '%backup%'" -all
```

Named parameters are worth using everywhere, not just here. They survive the next release too.

### Aliases That Were Wrong

These aliases pointed at the wrong thing and have been fixed or removed:

- **`Remove-CWMDocument`:** `-somethingId` is now `-documentId`.
- **`Update-CWMProductAdjustment`:** `-catalogId` is now `-adjustmentId`.
- **`Update-CWMPurchaseOrder`:** `-catalogId` is now `-purchaseOrderId`.
- **`Get-CWMCompanyCountry`:** the misleading `-companyId` alias is gone.

### Route IDs That Are Now Mandatory

These used to build a broken URL when you left the id out. Now PowerShell asks for it:

- `Get-CWMCompanyTeam -parentId`
- `Get-CWMProductAdjustmentDetail -parentId`
- `New-`, `Update-` and `Remove-CWMProductPickingShippingDetail -parentId`
- `New-CWMMarketingGroupCompany -parentId` (alias `-groupId`)
- `New-CWMMemberToken -memberIdentifier`
- `New-CWMOpportunityForecastItem -id` (it defaulted to 0 and posted to `/forecast/0`)
- The ticket ids of `New-CWMTicketChild`

If a script calls one of these without the id, PowerShell prompts for it, or fails if it runs with `-NonInteractive`. Add the id.

### Parameter Types That Now Match the API

- **`New-CWMCompanyContact -country`** takes a reference such as `@{ id = 1 }`. A country name string no longer binds.
- **`New-CWMProductCatalog -priceAttribute`** takes `FixedFee`, `NotToExceed`, `OverrideRate` or `TimeAndMaterials`. It was an `[int]`, which the API rejected anyway.
- **`New-CWMTicketConfiguration` and `New-CWMProjectTicketConfiguration`:** `-id` is an `[int]`, and `-deviceIdentifier` is its own parameter. It used to be an alias of `-id`.
- **`Get-CWMSSOConfiguration -id`** is an `[int]`.

Before:

```powershell
New-CWMCompanyContact -firstName 'Sarah' -lastName 'Johnson' -company @{ id = 250 } -country 'United States'
```

After:

```powershell
New-CWMCompanyContact -firstName 'Sarah' -lastName 'Johnson' -company @{ id = 250 } -country @{ id = 1 }
```

The country id depends on your server. Look it up in ConnectWise PSA before you hard-code it.

### Removed Parameters the API Never Accepted

These were ignored or rejected by the server, so removing them from your calls changes nothing:

- `New-CWMProductCatalog -dateEntered`
- `New-CWMMember -TimeZoneSetupReference`, `-remotePackage`, `-remotePackagePlatform`, `-remotePackageUserName`, `-remotePackagePassword` and `-remotePackageAccount`
- `Get-CWMTicketAllNote -id`

### Error Handling That Matches the Error Id

Error messages now include the ConnectWise error code, field-level validation errors and the HTTP status. The old wording is kept, but the error id suffix changed. If your `catch` blocks match on it, update them.

Before:

```powershell
catch {
    if ($_.FullyQualifiedErrorId -like '*,Invoke-CWMWebRequest') { $Failed += $TicketId }
}
```

After:

```powershell
catch {
    if ($_.FullyQualifiedErrorId -like '*,Write-CWMWebRequestError') { $Failed += $TicketId }
}
```

## Step 4: Test Without Writing Anything

Every `New-`, `Update-` and `Remove-` cmdlet supports `-WhatIf`. Run your updated write calls with it first. You'll see the URL and the request body without sending anything, and secrets are masked in the output.

```powershell
Update-CWMTicket -id 12345 -Operation replace -Path 'summary' -Value 'Testing 0.5' -WhatIf
```

`Get-` calls still run normally, so your script's lookups work during a dry run.

## Behavior Changes You Don't Have to Fix

These don't break scripts, but you'll notice them:

- **`-all` asks for 1,000 records per page**, the API maximum. It follows the `rel="next"` link, and on Windows PowerShell 5.1 it now returns a flat list instead of one array per page.
- **Retries actually work.** Reads and searches retry on 502, 503 and 504. Every method retries on 429. Writes never retry on a 5xx, so a retry can't create a duplicate. The wait honors `Retry-After`, otherwise it backs off for about 62 seconds over 5 tries. The retry loop in 0.4.16 never ran.
- **Dates are sent as ISO 8601 UTC** on both editions, like `2026-01-02T03:04:05Z`. Local dates such as `Get-Date` are converted to UTC.
- **`Connect-CWM` reconnects on its own** when the server, company, sign-in method or member changes. You only need `-Force` to refresh the same connection.

If you wrote your own retry wrapper, like the one in my [best practices post](/powershell/psa/connectwisemanageapi/2024/10/07/best-practices-connectwisemanageapi.html), you can drop it for reads. Be careful keeping it on writes. A write that fails with a 5xx may have gone through anyway.

## New Features Worth Using

### Several Changes in One Request

Every `Update-CWM*` cmdlet now takes `-PatchOperations`. Instead of one request per field, you send them all at once:

```powershell
Update-CWMTicket -id 12345 -PatchOperations @(
    @{ op = 'replace'; path = 'status'; value = @{ id = 10 } }
    @{ op = 'replace'; path = 'priority'; value = @{ id = 3 } }
    @{ op = 'replace'; path = 'owner'; value = @{ id = 50 } }
    @{ op = 'remove'; path = 'contact' }
)
```

That's one PATCH request instead of four. The old `-Operation`, `-Path` and `-Value` form still works for single changes.

### Project Tickets

`New-CWMProjectTicket` works well with splatting:

```powershell
$ProjectTicket = @{
    summary            = 'Configure backups'
    project            = @{ id = 386 }
    phase              = @{ id = 12 }
    budgetHours        = 4
    initialDescription = 'Set up nightly backups for the new servers.'
}

New-CWMProjectTicket @ProjectTicket
```

It also takes `-workRole`, `-workType`, `-location` and `-department`. `Get-CWMProjectTicketAllNote` reads every note on a project ticket.

### PowerShell 7.4 and "Cannot Follow an Insecure Redirection"

On PowerShell 7.4 and later, create and update calls against some ConnectWise-hosted servers fail with this error. The request has usually already been processed, so the record may exist. Connect with `-AllowInsecureRedirect`:

```powershell
Connect-CWM @ConnectionInfo -AllowInsecureRedirect
```

The module never follows the redirect, so nothing is sent over http. It has no effect on 5.1 or 7.0 through 7.3.

### Everything Else

- **Ticket details:** `Get-CWMTicketTimeEntry`, `Get-CWMTicketScheduleEntry`, `Get-CWMTicketDocument` and `Get-CWMTicketProduct` return full records for a ticket.
- **Knowledge base:** `Get-`, `New-`, `Update-` and `Remove-CWMKnowledgeBaseArticle`.
- **Documents:** `Get-CWMDocument -id 42 -download -OutFile 'C:\Temp\file.pdf'` saves a document to disk.
- **Invoices:** `Get-CWMInvoice`, `New-CWMInvoice` and `Update-CWMInvoice`. `Get-CWMInvoice -id 1001 -pdf -OutFile 'C:\Temp\invoice.pdf'` saves the invoice PDF.
- **Custom fields:** `Get-`, `New-`, `Update-` and `Remove-CWMUserDefinedField`.
- **Help:** every public function has comment-based help. `Get-Help New-CWMProjectTicket -Full` is the fastest way to check a parameter.

The [release notes](https://github.com/christaylorcodes/ConnectWiseManageAPI/releases/tag/v0.5.0) and the [CHANGELOG](https://github.com/christaylorcodes/ConnectWiseManageAPI/blob/master/CHANGELOG.md) have the full list.

## The Checklist

- [ ] Every machine that runs your scripts has PowerShell 5.1 or later
- [ ] Scripts you haven't migrated yet are pinned to 0.4.16 with `#Requires`
- [ ] `-Version` is removed from every `Connect-CWM` call
- [ ] Fields your scripts read are checked against the current API model
- [ ] Project tickets use `New-CWMProjectTicket`
- [ ] Removed `New-CWMTicket` parameters are gone
- [ ] Positional calls to the five changed cmdlets use named parameters
- [ ] Renamed aliases and newly mandatory ids are fixed
- [ ] `-MemberID` scripts are checked against that member's permissions
- [ ] Customer-visible documents pass `-Private $false`
- [ ] `catch` blocks match `Write-CWMWebRequestError`
- [ ] Write calls tested with `-WhatIf`

Most of this is a search, a few edits, and a dry run. If you hit something this post doesn't cover, [open an issue on GitHub](https://github.com/christaylorcodes/ConnectWiseManageAPI/issues) and I'll take a look.

---

**Related:**

- [ConnectWise PSA (Manage) API project page](/projects/connectwisemanageapi/)
- [Getting Started with ConnectWiseManageAPI](/powershell/psa/connectwisemanageapi/2024/09/23/getting-started-connectwisemanageapi.html)
- [Best Practices and Tips for ConnectWiseManageAPI](/powershell/psa/connectwisemanageapi/2024/10/07/best-practices-connectwisemanageapi.html)
- [ConnectWiseManageAPI on the PowerShell Gallery](https://www.powershellgallery.com/packages/ConnectWiseManageAPI)
