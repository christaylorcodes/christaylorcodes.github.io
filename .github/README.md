# GitHub Actions Workflows

## Deploy Workflow

**File:** `.github/workflows/deploy.yml`

**Triggers:**
- Push to `main` branch
- Manual dispatch (via Actions tab)

**Jobs:**

1. **build** - Build Jekyll site
   - Checkout code
   - Setup Ruby 3.1
   - Install dependencies
   - Build site with Jekyll
   - Upload artifact

2. **deploy** - Deploy to GitHub Pages
   - Download artifact
   - Deploy to GitHub Pages environment

3. **purge-cloudflare-cache** - Clear Cloudflare cache
   - Call Cloudflare API to purge all cache
   - Runs only after successful deployment

**Required Secrets:**
- `CLOUDFLARE_API_TOKEN` - API token with cache purge permission
- `CLOUDFLARE_ZONE_ID` - Zone ID for christaylor.codes

**Expected Runtime:** 2-3 minutes total

**Monitoring:**
- View runs: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
- Email notifications on failure (configured in GitHub settings)

**Setup Guide:** See `/CLOUDFLARE-SETUP.md` for detailed configuration instructions

---

**Last Updated:** 2025-11-05
