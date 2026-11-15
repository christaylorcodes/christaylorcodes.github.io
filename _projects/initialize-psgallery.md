---
layout: project
title: PSGallery Initializer
icon: fa-box-open
category: PowerShell
short_description: "Fixes the usual reasons Install-Module fails on Windows: no TLS 1.2, a missing NuGet provider, broken PowerShellGet, or an untrusted PSGallery."
description: |
  When `Install-Module` won't work on a machine, this script fixes the usual causes so you can get on with your day. It's a single function you run before touching the PowerShell Gallery, which makes it handy at the top of Remote Monitoring and Management (RMM) scripts that land on machines you've never seen. It isn't on the Gallery itself, for obvious reasons. Run it straight from GitHub: `Invoke-RestMethod 'https://raw.githubusercontent.com/christaylorcodes/Initialize-PSGallery/main/PSGalleryHelper.ps1' | Invoke-Expression`.

  It checks for PowerShell 3+ and .NET 4.5+, turns on TLS 1.2, and confirms it can reach the Gallery. Then it installs the NuGet provider if it's missing and reinstalls PackageManagement and PowerShellGet if they're broken or below the minimum versions it needs. Last, it registers PSGallery if needed and marks it trusted so installs don't stop for a prompt. Environment cleanup steps like execution policy and PSModulePath are best-effort, so a Group Policy (GPO) lock or a non-admin session won't stop the run.

  The November 2026 update handles machines where PackageManagement is gone entirely, which used to fail before any repair started. The fallback downloads moved off a retired CDN host to the Gallery's own package URLs. Each fallback package is checked against a pinned SHA256 hash and validated before the installed copy is replaced.
tags:
  - PowerShell
  - Automation
  - DevOps
github_url: "https://github.com/christaylorcodes/Initialize-PSGallery"
stars: 21
gallery_downloads: 1
order: 30
---
