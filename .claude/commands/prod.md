---
description: Promote dev to production (deploy to main branch)
---

Promote changes from dev branch to production by running the automated promotion script.

Execute the PowerShell promotion script:

```powershell
.\promote-to-main.ps1
```

This script will:
1. Verify you're on dev branch
2. Check for uncommitted changes
3. Ensure dev is up to date with remote
4. Run local Jekyll build for verification
5. Ask for confirmation before promotion
6. Checkout main branch
7. Pull latest main from remote
8. Merge dev into main (fast-forward)
9. Push main to GitHub
10. Return to dev branch

The push to main will trigger the production deployment workflow:
- Jekyll build with production settings
- Deploy to GitHub Pages (christaylor.codes)
- Purge Cloudflare cache
- Total deployment time: 2-3 minutes

Monitor deployment at: https://github.com/christaylorcodes/christaylorcodes.github.io/actions

**Note**: Use `-SkipBuild` parameter to skip build verification if you want faster promotion (less safe).
