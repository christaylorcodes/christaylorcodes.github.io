---
layout: project
title: ConnectWise PSA (Manage) API
icon: fa-plug
category: ConnectWiseManageAPI
short_description: "Automates the ConnectWise PSA (Manage) REST API from PowerShell: 250+ cmdlets for tickets, companies, time and projects, with paging built in."
description: |
  ConnectWiseManageAPI is a PowerShell module for the ConnectWise PSA (Manage) REST API. Its 250+ cmdlets cover tickets, companies, contacts, time entries, agreements, projects and more, so you don't build URLs, auth headers or JSON by hand. It runs on PowerShell 7 (Windows, Linux and macOS) and on Windows PowerShell 5.1.

  Connect-CWM reads your server's API version and pins every request to it, so the objects you get back match the current ConnectWise PSA API model. Use -all and the module pages through results for you, 1,000 records at a time. Every Update-CWM* cmdlet takes -PatchOperations, so you can change several fields in one request. New-CWMProjectTicket creates tickets directly on a project. Reads retry on 429 and 502/503/504 responses; writes only retry on 429, so a retry can't create a duplicate record. Every function has comment-based help with examples (Get-Help Get-CWMTicket -Full).

  Upgrading from 0.4.x? Version 0.5.0 has breaking changes. Read [Upgrading to ConnectWiseManageAPI 0.5](/powershell/psa/connectwisemanageapi/2026/11/16/upgrading-connectwisemanageapi-0-5.html) before you update anything that runs in production.
tags:
  - PowerShell
  - ConnectWise PSA
  - ConnectWise Manage
  - REST API
  - MSP Tools
github_url: "https://github.com/christaylorcodes/ConnectWiseManageAPI"
powershell_gallery_url: "https://www.powershellgallery.com/packages/ConnectWiseManageAPI"
docs_url: "https://github.com/christaylorcodes/ConnectWiseManageAPI#readme"
image: /assets/images/projects/connectwisemanageapi-hero.svg
screenshots:
  - /assets/images/projects/connectwisemanageapi-terminal.svg
  - /assets/images/projects/connectwisemanageapi-intellisense.svg
  - /assets/images/projects/connectwisemanageapi-example.svg
stars: 127
gallery_downloads: 652295
order: 10
---
