---
layout: project
title: ConnectWiseAutomateAgent
icon: fa-plug
category: PowerShell
short_description: Installs, repairs, and monitors ConnectWise Automate agents from PowerShell, with health checks, escalating self-repair, and scheduled checkups.
description: |
  ConnectWiseAutomateAgent manages the ConnectWise Automate (formerly LabTech) Windows agent from PowerShell. You can install, uninstall, reinstall, and update the agent with `Install-CWAA`, `Uninstall-CWAA`, `Redo-CWAA`, and `Update-CWAA`, using an installer token instead of the server password. It also reads agent settings and error logs, tests server ports, manages proxy settings, sends commands to the agent service, and hides or renames the agent in Add/Remove Programs.

  Version 2 adds health checks and self-repair. `Test-CWAAHealth` is read-only: it reports whether the agent is installed, whether its services are running, when it last checked in, and whether the server is reachable. `Repair-CWAA` fixes what it finds in steps, starting with a service restart, then a reinstall, then a fresh install if the agent is missing. It checks that the server is reachable before it touches anything. `Register-CWAAHealthCheckTask` runs that repair as a SYSTEM scheduled task every 6 hours by default, and every action lands in the Windows Application event log. Destructive commands support `-WhatIf` and `-Confirm`.

  Commands now use the `CWAA` prefix. All 32 original `LT` aliases, like `Install-LTService` and `Get-LTServiceInfo`, still work, so older scripts run unchanged. The module is tested on Windows PowerShell 5.1 and PowerShell 7, MIT licensed, and available on the PowerShell Gallery.
tags:
  - PowerShell
  - ConnectWise
  - Automation
  - MSP Tools
github_url: "https://github.com/christaylorcodes/ConnectWiseAutomateAgent"
powershell_gallery_url: "https://www.powershellgallery.com/packages/ConnectWiseAutomateAgent"
image: /assets/images/projects/connectwiseautomateagent-hero.svg
screenshots:
  - /assets/images/projects/connectwiseautomateagent-install.svg
  - /assets/images/projects/connectwiseautomateagent-repair.svg
  - /assets/images/projects/connectwiseautomateagent-config.svg
stars: 12
gallery_downloads: 2338212
order: 50
---
