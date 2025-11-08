# GitHub Actions Workflows

This directory contains automated workflows for the christaylor.codes website.

## Workflows

### 1. Build and Deploy Jekyll Site (`deploy.yml`)

**Trigger:** Push to `main` branch or manual dispatch

**Purpose:** Builds the Jekyll site, deploys to GitHub Pages, and purges Cloudflare cache.

**Jobs:**
1. **build** - Compiles Jekyll site with Ruby 3.3 and production settings
2. **deploy** - Deploys compiled site to GitHub Pages
3. **purge-cloudflare-cache** - Purges Cloudflare CDN cache for fresh content delivery

**Configuration Required:**
- GitHub Secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ZONE_ID`
- GitHub Pages source: Set to "GitHub Actions"

**Deployment Time:** 2-3 minutes

**Documentation:** [CLOUDFLARE-SETUP.md](../CLOUDFLARE-SETUP.md)

---

### 2. Update Project Stats (`update-project-stats.yml`)

**Trigger:** 
- Weekly on Mondays at 9 AM UTC (1 AM PST / 2 AM PDT)
- Manual dispatch

**Purpose:** Automatically updates GitHub star counts and PowerShell Gallery download counts for all projects.

**Jobs:**
1. **update-stats** - Single job that:
   - Fetches current star counts from GitHub API for all project repositories
   - Fetches current download counts from PowerShell Gallery API
   - Updates `_data/project-stats.yml` with fresh statistics
   - Updates individual project front matter files
   - Commits changes if stats have changed
   - Triggers deployment workflow via commit to `main`

**What Gets Updated:**
- `_data/project-stats.yml` - Centralized statistics file
- `_projects/*.md` - Individual project files (front matter)
- Commit message includes timestamp and source of updates

**Manual Trigger:**
1. Go to Actions tab in GitHub
2. Select "Update Project Stats" workflow
3. Click "Run workflow" → "Run workflow"

**Local Alternative:**
```powershell
# Update PowerShell Gallery stats only (manual GitHub stars update required)
.\scripts\sync-project-stats.ps1 -FetchGalleryStats

# Preview changes without committing
.\scripts\sync-project-stats.ps1 -FetchGalleryStats -WhatIf
```

**Dependencies:**
- `scripts/sync-project-stats.ps1` - PowerShell script for updating project files
- `_data/project-stats.yml` - Centralized stats file
- GitHub API access via `GITHUB_TOKEN` (automatically provided)
- PowerShell Gallery public API (no auth required)

**Execution Time:** 1-2 minutes

---

## Permissions

Both workflows use specific permissions following the principle of least privilege:

**deploy.yml:**
- `contents: read` - Read repository files
- `pages: write` - Deploy to GitHub Pages
- `id-token: write` - Required for GitHub Pages deployment

**update-project-stats.yml:**
- `contents: write` - Read files and commit changes
- `pull-requests: write` - Reserved for future PR-based updates

---

## Monitoring

**View workflow runs:**
https://github.com/christaylorcodes/christaylorcodes.github.io/actions

**Check workflow status:**
- Green checkmark = Success
- Red X = Failed (check logs for details)
- Yellow dot = In progress

**Common Issues:**

**deploy.yml failures:**
- Check Jekyll build errors in logs
- Verify Cloudflare secrets are configured
- Ensure GitHub Pages source is "GitHub Actions"

**update-project-stats.yml failures:**
- GitHub API rate limits (unlikely with weekly schedule)
- PowerShell Gallery API unavailable (retry workflow)
- Merge conflicts (manually resolve and re-run)

---

## Security

**Secrets Storage:**
- All sensitive data stored in GitHub Secrets (encrypted)
- Secrets never logged or exposed in workflow output
- API tokens scoped to minimum required permissions

**Automated Commits:**
- Stats update workflow commits directly to `main` using `github-actions[bot]` user
- Commit messages clearly indicate automated updates
- Can be reverted like any other commit if needed

---

## Future Enhancements

Potential improvements to consider:

1. **Pull Request Flow:** Change stats update to create PR instead of direct commit
2. **Notification:** Send notification if stats update fails
3. **Metrics Dashboard:** Track star/download growth over time
4. **Conditional Deploy:** Only deploy if content changes, skip for stats-only updates

---

**Last Updated:** 2025-11-05  
**Workflow Versions:** deploy.yml v1.0, update-project-stats.yml v1.0
