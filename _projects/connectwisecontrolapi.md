---
layout: project
title: "ScreenConnect API (ConnectWiseControlAPI)"
icon: fa-plug
category: ConnectWiseControlAPI
short_description: Automates ScreenConnect from PowerShell. Find sessions, run commands, send Toolbox items and manage users, with MFA or API secret login.
description: |
  ConnectWiseControlAPI is a PowerShell module for the ScreenConnect web API (formerly ConnectWise Control). Install it from the PowerShell Gallery, run `Connect-CWC` once, and the module's other 34 commands use that connection. ConnectWise renamed the product, but the module name and the `CWC` command names stayed the same, so your scripts don't need renaming.

  Version 0.5.0 gives you three ways to sign in. Use a user account without MFA, an account with MFA (type the code, pass it in, or compute it from the authenticator secret for unattended scripts), or the secret from the RESTful API Manager extension. The API secret works on servers where every account needs MFA, but only for the session commands that extension supports.

  You can find sessions, run commands and read their output, send Toolbox items, chat messages and notes, rename sessions and set custom properties, wake machines, join a session from the console, manage users and MFA secrets, read the audit log, and set up Remote Workforce. Commands that delete things ask first, and safe reads retry when the server returns HTTP 500.
tags:
  - PowerShell
  - ScreenConnect
  - ConnectWise
  - API Wrapper
  - MSP Tools
github_url: "https://github.com/christaylorcodes/ConnectWiseControlAPI"
powershell_gallery_url: "https://www.powershellgallery.com/packages/ConnectWiseControlAPI"
docs_url: "https://github.com/christaylorcodes/ConnectWiseControlAPI/tree/master/Docs"
stars: 85
gallery_downloads: 1732867
order: 20
---
