---
layout: project
title: DNSFilterAPI
icon: fa-shield-alt
category: PowerShell
short_description: Automates DNSFilter organizations, networks, policies, and IP addresses from PowerShell 5.1 or 7, with thread-safe sessions for parallel jobs.
description: |
  DNSFilterAPI wraps the DNSFilter REST API so you can manage DNS filtering from PowerShell instead of the dashboard. It's built for Managed Service Providers (MSPs) and admins who run DNSFilter across a lot of customer organizations. It runs on Windows PowerShell 5.1 and PowerShell 7.

  The module has 26 functions. You can create, update, and remove organizations, networks, policies, and IP addresses. It also handles network secret keys, local domains and resolvers, user agents, applications, billing, and invoices. Updates use PATCH, so fields you don't pass are left alone. Anything that creates, changes, or deletes supports `-WhatIf` and `-Confirm`.

  Every function takes an optional `-Session`. Capture it from `Connect-DNSFilter` and pass it into `ForEach-Object -Parallel` to work through every customer organization at once without the runspaces stepping on each other.
tags:
  - PowerShell
  - DNSFilter
  - API Wrapper
  - MSP Tools
github_url: "https://github.com/christaylorcodes/DNSFilterAPI"
powershell_gallery_url: "https://www.powershellgallery.com/packages/DNSFilterAPI"
stars: 0
gallery_downloads: 7224
order: 86
---
