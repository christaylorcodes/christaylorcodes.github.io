---
layout: project
title: PSAnthropic
icon: fa-robot
category: PowerShell
short_description: Sends messages to the Anthropic Messages API from PowerShell 7 with streaming, tool calling, and images. Works with Claude and local Ollama.
description: |
  PSAnthropic is a PowerShell 7 client for the Anthropic Messages API. Point it at Anthropic's cloud to use Claude, at a local Ollama server through its Anthropic compatibility layer, or at any other compatible endpoint. Connection settings can come from parameters or the `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`, and `ANTHROPIC_MODEL` environment variables.

  You get 23 cmdlets covering messages and conversations, streaming over Server-Sent Events (SSE), image input for vision models, and extended thinking. Tool calling is built in. `New-AnthropicToolFromCommand` turns an existing PowerShell command into a tool definition, and a set of standard tools handles file reads, edits, searches, and shell commands. Shell access runs at a safety level you choose, from Restricted up to Unsafe, with sandboxed execution in ConstrainedLanguage mode.

  A model router sends each request to a different model based on task type, so code questions can go to a coding model and chat to something lighter. Routing decisions are logged so you can see what went where.
tags:
  - PowerShell
  - AI
  - Anthropic
  - Ollama
github_url: "https://github.com/christaylorcodes/PSAnthropic"
powershell_gallery_url: "https://www.powershellgallery.com/packages/PSAnthropic"
docs_url: "https://github.com/christaylorcodes/PSAnthropic/tree/main/docs"
stars: 1
gallery_downloads: 9262
order: 84
---
