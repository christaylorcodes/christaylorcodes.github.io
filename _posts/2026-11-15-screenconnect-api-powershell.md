---
layout: post
title: "ScreenConnect API with PowerShell: MFA, API Secrets and ConnectWiseControlAPI 0.5"
short_title: "ScreenConnect API with PowerShell"
date: 2026-11-15 08:00:00 -0000
categories: [PowerShell, MSP, ConnectWiseControlAPI]
tags: [PowerShell, ScreenConnect, ConnectWise, Control, MSP, Automation, API, MFA]
author: Chris Taylor
excerpt: "ConnectWise renamed Control back to ScreenConnect, and ConnectWiseControlAPI 0.5 is out. You can now sign in with MFA, run unattended scripts with a TOTP secret, or use an API secret instead of a user account. Here's how each sign-in works, a few practical examples, and what to check before you upgrade from 0.4."
description: "Use the ScreenConnect API from PowerShell with ConnectWiseControlAPI 0.5: MFA and TOTP sign-in, RESTful API Manager secrets, practical examples, and an upgrade checklist for scripts written for 0.4."
---

ConnectWiseControlAPI 0.5.0 is out. It's the first big update since 0.4, and it fixes the thing people asked about most: **you can now sign in with an account that uses multi-factor authentication (MFA)**. The module went from 21 commands to 35, and it has a second way to authenticate that doesn't use a ScreenConnect user at all.

Also, ConnectWise renamed Control back to ScreenConnect. The module keeps its name and its `CWC` command names, so your scripts don't need a find-and-replace. The product changed its name. The module didn't. One of us had to stay consistent.

If you're new to the module, start with [Getting Started with ConnectWiseControlAPI]({% post_url 2023-03-22-getting-started-connectwisecontrolapi %}) and come back here. If you already run 0.4 scripts on a schedule, read the [upgrade checklist](#upgrading-from-04-checklist) before you update.

## Install or update

Install from the PowerShell Gallery:

```powershell
Install-Module -Name ConnectWiseControlAPI -Scope CurrentUser
```

If you already have 0.4 installed from the Gallery, update it and check the version:

```powershell
Update-Module -Name ConnectWiseControlAPI
Get-Module -Name ConnectWiseControlAPI -ListAvailable | Select-Object -Property Name, Version
```

You should see `0.5.0`. Version numbers have three parts now, so don't go looking for `0.5.0.0`.

A few things to know:

- **It's tested on Windows PowerShell 5.1 and PowerShell 7**
- **Your ScreenConnect server must use HTTPS.** If you pass `https://` in `-Server`, the module strips it off
- **There's a built-in overview now.** Run `Get-Help about_ConnectWiseControlAPI` for the sign-in options, error IDs and upgrade notes

## The three ways to sign in

You still run `Connect-CWC` once per PowerShell session, and every other command uses that connection. What's new is how you sign in.

| Method | Parameters | Commands available | Expires |
| --- | --- | --- | --- |
| Account without MFA | `-Credentials` | All except `Find-CWCSession` | No |
| Account with MFA | `-Credentials` plus `-Mfa`, `-OneTimeCode` or `-TotpSecret` | All except `Find-CWCSession` | Yes, the server expires the login |
| API secret | `-ApiSecret` | 8 session commands | No |

### Account without MFA

This is how 0.4 worked, and it still works:

```powershell
Connect-CWC -Server 'screenconnect.example.com' -Credentials (Get-Credential)
```

It uses Basic authentication and never expires. The catch is the account has to have MFA turned off. If that's a service account you created because the old module needed it, you can probably retire it now.

### Account with MFA

Add one of three parameters, depending on where the code comes from.

**`-Mfa` asks for the code at the console.** It works with authenticator apps, email codes and SMS codes. Use this when you're at the keyboard:

```powershell
Connect-CWC -Server 'screenconnect.example.com' -Credentials (Get-Credential) -Mfa
```

**`-OneTimeCode` takes the code as a parameter.** Reading it with `Read-Host` keeps it out of your command history:

```powershell
Connect-CWC -Server 'screenconnect.example.com' -Credentials $Credential -OneTimeCode (Read-Host 'One-time code')
```

**`-TotpSecret` computes the code for you.** This is for unattended scripts, and it gets its own section below.

The module signs in the same way the web page does and keeps the login cookie. It doesn't keep your password. The server expires that login after a while. When it does, commands fail with a permission error that says the login may have expired, and you run `Connect-CWC` again.

### API secret

The third option skips user accounts entirely. Install the **RESTful API Manager** extension on your server, set its `RESTfulAuthenticationSecret` setting to a long random value, and pass that value to `-ApiSecret`:

```powershell
$Secret = Read-Host -AsSecureString -Prompt 'RESTful API secret'
Connect-CWC -Server 'screenconnect.example.com' -ApiSecret $Secret
```

This works on servers where every account requires MFA. It only covers the commands the extension supports:

- `Find-CWCSession`
- `New-CWCSession`
- `Get-CWCSessionDetail`
- `Update-CWCSessionName`
- `Invoke-CWCCommand` (it queues the command but doesn't return the output)
- `Add-CWCSessionNote`
- `Send-CWCSessionMessage`
- `Send-CWCToolboxItem`

Anything else returns an error that tells you which sign-in method it needs.

Two warnings. **The secret ignores ScreenConnect's role permissions and session groups**, so it can act on every session on the server. Treat it like an administrator password. And if you've set the extension's `RESTfulAllowedOrigin` setting, pass a matching `-Origin` or the server will turn you away.

### Which one should you use

- **Working interactively:** `-Mfa`
- **Scheduled script that only touches sessions** (find, notes, messages, Toolbox items, fire-and-forget commands): `-ApiSecret`
- **Scheduled script that needs everything else** (command output, users, audit log, session groups): `-TotpSecret`
- **An account without MFA:** only if you've got nothing else. It's the one I'd retire first

## Unattended sign-in with a TOTP secret

`-TotpSecret` takes the account's authenticator-app secret, the same value you'd scan into an authenticator app as a QR code. The module computes the current six-digit code at each login. It accepts the `ms:...` form ScreenConnect stores or plain Base32, and it doesn't store the secret.

Keep the credential and the secret in a secret store. This example uses Microsoft.PowerShell.SecretManagement:

```powershell
$Credential = Get-Secret -Name 'CWC-Login'
Connect-CWC -Server 'screenconnect.example.com' -Credentials $Credential -TotpSecret (Get-Secret -Name 'CWC-TOTP')
```

Run that again before each batch of work. If the cached login is still good, it costs one check call. If it's expired, the module signs in again.

Let's be honest about the tradeoff. **A TOTP secret stored next to the password turns MFA back into a single factor.** Anyone who can read both can sign in. Keep them in separate vaults where you can, use `-ApiSecret` when its commands are enough, and replace the secret if the machine running the script is ever compromised.

`-TotpSecret` only works with authenticator-app codes. Email and SMS codes need a person.

If you're creating the service account from scratch, `New-CWCMFA` generates a secret in the `ms:` form and you pass it to `New-CWCUser` or `Update-CWCUser`. Note that it also returns a QR code link hosted on quickchart.io that contains the secret. Only open it if you're fine sending the secret to that service.

### Handling sign-in errors

MFA sign-ins are never retried automatically, because every attempt counts toward the server's login limits. Failures carry an error ID you can branch on:

```powershell
try {
    Connect-CWC -Server 'screenconnect.example.com' -Credentials $Credential -TotpSecret (Get-Secret -Name 'CWC-TOTP') -ErrorAction Stop
}
catch {
    switch -Wildcard ($_.FullyQualifiedErrorId) {
        'CWC.LoginThrottled*' { Write-Warning 'Too many sign-in attempts. Wait before trying again.' }
        'CWC.MfaCodeRejected*' { Write-Warning 'The code was rejected. Check the TOTP secret and the clock on this machine.' }
        default { throw }
    }
}
```

The others are `CWC.MfaRequired` and `CWC.LoginFailed`. Regular API calls carry IDs too: `CWC.NotConnected`, `CWC.AuthModeMismatch`, `CWC.Http<status>` and `CWC.NoResponse`.

## Scripts that delete things now ask first

This is the change most likely to bite you. **`Remove-CWCSession`, `Remove-CWCSessionNote`, `Remove-CWCHostFromSession` and `Remove-CWCToolboxItem` ask for confirmation by default.** So does `Send-CWCToolboxItem` when you use `-Elevated` or `-Silent`.

At the console that's a nice safety net. In a scheduled task it's a problem:

- A session started with `-NonInteractive` fails at the prompt and does nothing
- Other unattended hosts may sit at the prompt, or take the default answer, which is Yes

Unattended scripts need `-Confirm:$false`:

```powershell
# Preview first
Remove-CWCSession -GUID $SessionID -Group 'All Machines' -WhatIf

# Then run it without the prompt
Remove-CWCSession -GUID $SessionID -Group 'All Machines' -Confirm:$false
```

`Remove-CWCSession` also got a new `-Uninstall` switch. With it, the Access client is uninstalled before the session is deleted. Without it, only the session record is deleted and the client stays on the machine.

## Practical examples

These assume you've already run `Connect-CWC`.

### Find a session

With a user account, search the same way the web UI's session list does:

```powershell
$Session = Get-CWCSession -Type Access -Search 'DESKTOP-01' -Limit 1
$Session.SessionID
```

That `SessionID` is the `-GUID` every other session command takes.

With an API secret, use `Find-CWCSession`. It searches every session of every type and takes a name, an ID, or a ScreenConnect session filter:

```powershell
Find-CWCSession -Name 'DESKTOP-01'
Find-CWCSession -Filter "GuestOperatingSystemName LIKE '*Server*'"
```

### Run a command and read the output

```powershell
Invoke-CWCCommand -GUID $Session.SessionID -Command 'Get-Service Spooler' -PowerShell -TimeOut 30000
```

That runs a PowerShell command on the machine and waits up to 30 seconds for the output. Leave off `-PowerShell` to run it in cmd.exe instead. On an API-secret connection the command is queued, but you don't get the output back.

### Send a Toolbox item

List what's in the Toolbox, then queue an item on the session:

```powershell
Get-CWCToolbox | Where-Object { -not $_.IsFolder } | Select-Object -Property Path

Send-CWCToolboxItem -GUID $Session.SessionID -Name 'Cleanup.cmd'
```

For an unattended run with admin rights, use `-Silent` and skip the prompt:

```powershell
Send-CWCToolboxItem -GUID $Session.SessionID -Name 'Cleanup.cmd' -Silent -Confirm:$false
```

Use `-Silent` rather than `-Elevated` for unattended work. In testing, an `-Elevated` item didn't start on a machine with no host connected.

One gotcha. The machine opens the item the way Windows opens a file, so use something that runs when opened: `.exe`, `.msi`, `.cmd` or `.bat`. A `.ps1` opens in its default program, usually Notepad, which is a very calm way to not run a script.

You can also leave a trail on the session while you're at it:

```powershell
Add-CWCSessionNote -GUID $Session.SessionID -Note 'Ran Cleanup.cmd from the nightly script'
```

### Get a launch URL

There are two kinds of launch URL, and they're for different jobs.

**To join a session with the Host client**, use `Enter-CWCSession`. It opens the client on Windows. `-UrlOnly` gives you the URL instead, for macOS, Linux or your own launcher:

```powershell
Get-CWCSession -Type Access -Search 'DESKTOP-01' -Limit 1 | Enter-CWCSession

$Url = Enter-CWCSession -GUID $Session.SessionID -UrlOnly
```

This needs a user-account connection and the JoinSession permission. The URL carries an access token, so treat it like a password.

**For Remote Workforce**, use `Get-CWCRemoteWorkforceLaunchURL`. It only returns a URL for machines assigned to the user you signed in as. An administrator can't get launch URLs for other people's machines:

```powershell
Get-CWCRemoteWorkforceSession | Get-CWCRemoteWorkforceLaunchURL
```

It replaces `Get-CWCLauncURL`. Yes, that old name was missing an "h" for years. The old command still works but shows a deprecation warning, ignores every parameter except `-GUID`, and goes away in 1.0.

## Upgrading from 0.4 checklist

Check these before you update a machine that runs scheduled scripts:

- **Add `-Confirm:$false`** to every `Remove-CWC*` call in unattended scripts, and to `Send-CWCToolboxItem` when it uses `-Elevated` or `-Silent`
- **Replace `Get-CWCLauncURL`** with `Get-CWCRemoteWorkforceLaunchURL`
- **`Connect-CWC` switches connections now.** Calling it for a different server, sign-in method or user connects to that one, even without `-Force`. In 0.4 it quietly kept the old connection
- **`Get-CWCLastContact` returns an error** when it can't find a connection event. In 0.4 it returned the current time, so a machine with no connection history looked like it had just checked in
- **`Get-CWCAuditLog` covers the last 24 hours** unless you pass `-StartDate` and `-EndDate`
- **`Get-CWCSession -Type Support` and `-Type Meeting`** without `-Group` now read `All Sessions` and `All Meetings`. In 0.4 they read `All Machines`, which holds Access sessions
- **HTTP 500 retries.** Reads and "set to value" updates retry three times (after 2, 4 and 8 seconds) before failing. Commands, wakes, deletes and user creation are never retried, so one request can't act twice
- **Consider turning MFA back on** for the service account and switching to `-TotpSecret` or `-ApiSecret`

This finds the scripts most likely to need a look:

```powershell
Get-ChildItem -Path 'C:\Scripts' -Filter '*.ps1' -Recurse |
    Select-String -Pattern 'Remove-CWC|Get-CWCLauncURL|Get-CWCLastContact|Get-CWCAuditLog|-Type (Support|Meeting)' |
    Select-Object -Property Path, LineNumber, Line
```

## Where to go next

- [ConnectWiseControlAPI project page](/projects/connectwisecontrolapi/)
- [Getting Started with ConnectWiseControlAPI]({% post_url 2023-03-22-getting-started-connectwisecontrolapi %}) for install, first commands and troubleshooting
- [Changelog](https://github.com/christaylorcodes/ConnectWiseControlAPI/blob/master/CHANGELOG.md) for the full list of changes and fixes
- [Command reference](https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Docs) for every command and parameter
- `Get-Help about_ConnectWiseControlAPI` from your own console

If something doesn't work against your server, please [open an issue on GitHub](https://github.com/christaylorcodes/ConnectWiseControlAPI/issues). Include your ScreenConnect version and the error ID if there is one.
