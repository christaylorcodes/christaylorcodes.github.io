---
description: Run local Jekyll build with live reload
---

Run the local development build process for the Jekyll website.

Execute the PowerShell build script with default settings (serve mode with live reload):

```powershell
.\build.ps1
```

This will:
- Verify Ruby and Bundler installation
- Install/update dependencies if needed
- Build the Jekyll site
- Start local server at http://localhost:4000 with live reload
- Watch for file changes and rebuild automatically

The server will continue running until stopped with Ctrl+C.
