---
layout: project
title: UnifiAPI
icon: fa-wifi
category: PowerShell
short_description: Manages Ubiquiti UniFi controllers from PowerShell 7 with 68 functions for sites, devices, clients, WLANs, firewall rules, firmware, and backups.
description: |
  UnifiAPI lets you run your Ubiquiti UniFi network from PowerShell instead of clicking through the controller UI. It ships 68 functions covering sites, devices, clients, wireless networks (WLANs), firewall rules and groups, firmware, admins, RADIUS, rogue AP detection, logs, and site backup and restore. It works with UniFi Controller 5.x through 8.x.

  The functions are built for the pipeline. `Get-UnifiSites | Get-UnifiDevices` pulls every device across every site in one line. When a function doesn't exist for what you need, `Invoke-UnifiApi` calls any controller endpoint directly, with optional pagination for large result sets.

  Anything that changes or deletes something supports `-WhatIf` and `-Confirm`, so you can see what a firmware push or WLAN change will do before it happens. MAC and IP inputs are validated before they hit the API. It requires PowerShell 7.0 or later. Windows PowerShell 5.1 isn't supported.
tags:
  - PowerShell
  - UniFi
  - API Wrapper
  - Networking
github_url: "https://github.com/christaylorcodes/UnifiAPI"
powershell_gallery_url: "https://www.powershellgallery.com/packages/UnifiAPI"
docs_url: "https://github.com/christaylorcodes/UnifiAPI/blob/main/docs/en-US/UnifiAPI.md"
stars: 1
gallery_downloads: 10049
order: 82
---
