# Cloudflare Integration Setup Guide

This guide walks you through setting up automated Cloudflare cache purging for the GitHub Pages deployment.

## Prerequisites

- Cloudflare account with christaylor.codes domain
- GitHub repository admin access
- Cloudflare API token with cache purge permissions

## Step 1: Create Cloudflare API Token

1. **Log in to Cloudflare Dashboard**
   - Go to https://dash.cloudflare.com

2. **Navigate to API Tokens**
   - Click your profile icon (top right)
   - Select "My Profile"
   - Click "API Tokens" tab
   - Click "Create Token"

3. **Configure Token Permissions**
   - Click "Create Custom Token"
   - **Token name**: `GitHub Pages Cache Purge`
   - **Permissions**:
     - Zone → Cache Purge → Purge
   - **Zone Resources**:
     - Include → Specific zone → christaylor.codes
   - **TTL**: Leave as default (no expiration) or set to your preference

4. **Create and Save Token**
   - Click "Continue to summary"
   - Review permissions
   - Click "Create Token"
   - **IMPORTANT**: Copy the token immediately - you won't see it again!
   - Store it securely (you'll add it to GitHub secrets next)

## Step 2: Get Cloudflare Zone ID

1. **Open Cloudflare Dashboard**
   - Go to https://dash.cloudflare.com

2. **Select Your Domain**
   - Click on "christaylor.codes" from your domains list

3. **Find Zone ID**
   - On the Overview page, scroll down to the right sidebar
   - Look for the "API" section
   - Copy the **Zone ID** (format: `abc123def456...`)

## Step 3: Add Secrets to GitHub

1. **Navigate to Repository Settings**
   - Go to https://github.com/christaylorcodes/christaylorcodes.github.io
   - Click "Settings" tab
   - Click "Secrets and variables" → "Actions" (left sidebar)

2. **Add CLOUDFLARE_API_TOKEN**
   - Click "New repository secret"
   - **Name**: `CLOUDFLARE_API_TOKEN`
   - **Value**: Paste the API token from Step 1
   - Click "Add secret"

3. **Add CLOUDFLARE_ZONE_ID**
   - Click "New repository secret"
   - **Name**: `CLOUDFLARE_ZONE_ID`
   - **Value**: Paste the Zone ID from Step 2
   - Click "Add secret"

## Step 4: Enable GitHub Pages with Actions

1. **Navigate to Pages Settings**
   - Go to repository Settings → Pages (left sidebar)

2. **Configure Source**
   - **Source**: Select "GitHub Actions"
   - This allows our custom workflow to deploy the site

## Step 5: Test the Workflow

1. **Commit and Push Changes**
   ```bash
   git add .github/workflows/deploy.yml
   git commit -m "Add automated Cloudflare cache purging to deployment"
   git push origin main
   ```

2. **Monitor the Deployment**
   - Go to the "Actions" tab in your GitHub repository
   - Watch the "Build and Deploy Jekyll Site" workflow run
   - You should see three jobs:
     1. ✅ build (builds Jekyll site)
     2. ✅ deploy (deploys to GitHub Pages)
     3. ✅ purge-cloudflare-cache (purges Cloudflare cache)

3. **Verify Success**
   - All three jobs should complete successfully
   - The site should be accessible at https://christaylor.codes
   - Changes should be visible immediately (no cache delays)

## Workflow Overview

The `.github/workflows/deploy.yml` workflow:

1. **Triggers**: Runs on every push to `main` branch
2. **Build**: Compiles Jekyll site with production settings
3. **Deploy**: Publishes to GitHub Pages
4. **Cache Purge**: Purges all Cloudflare cache for the zone

**Benefits:**
- Automated cache invalidation after every deployment
- No manual Cloudflare dashboard access needed
- Changes visible immediately after deployment
- Failed cache purge doesn't block deployment

## Troubleshooting

### Cache Purge Job Fails

**Error**: `401 Unauthorized`
- **Cause**: Invalid or missing API token
- **Solution**: Verify `CLOUDFLARE_API_TOKEN` secret is correct

**Error**: `403 Forbidden`
- **Cause**: API token lacks cache purge permission
- **Solution**: Recreate token with correct permissions (see Step 1)

**Error**: `Zone not found`
- **Cause**: Invalid Zone ID
- **Solution**: Verify `CLOUDFLARE_ZONE_ID` secret is correct (see Step 2)

### Manual Cache Purge (Fallback)

If automated purge fails, manually purge cache:

1. Go to Cloudflare Dashboard
2. Select christaylor.codes
3. Click "Caching" → "Configuration"
4. Click "Purge Everything"

### Testing API Token Locally

You can test the API token before committing:

```bash
# Test cache purge (replace with your actual values)
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
  -H "Authorization: Bearer YOUR_API_TOKEN" \
  -H "Content-Type: application/json" \
  --data '{"purge_everything":true}'

# Expected response:
# {"success":true,"errors":[],"messages":[],"result":{"id":"..."}}
```

## Security Notes

- **Never commit API tokens** to the repository
- **Use GitHub Secrets** for all sensitive values
- **Rotate tokens** if compromised
- **Limit token permissions** to only what's needed (cache purge only)
- **Set token expiration** if required by your security policy

## Monitoring

**GitHub Actions**:
- Check deployment status: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
- Email notifications on workflow failures (configurable in GitHub settings)

**Cloudflare**:
- View cache purge events: Cloudflare Dashboard → Audit Log
- Monitor cache hit rates: Cloudflare Dashboard → Analytics → Traffic

## Alternative: Selective Cache Purge

The current workflow purges **all cache** (`purge_everything: true`). For better cache performance, you can purge only changed files:

```yaml
# Purge specific files (more efficient)
--data '{"files":["https://christaylor.codes/","https://christaylor.codes/blog/"]}'

# Purge by cache tags (requires Enterprise plan)
--data '{"tags":["blog","projects"]}'

# Purge by prefix (requires Enterprise plan)
--data '{"prefixes":["https://christaylor.codes/blog"]}'
```

For now, `purge_everything` is simpler and ensures no stale content.

## Reference Links

- [Cloudflare API Docs - Purge Cache](https://developers.cloudflare.com/api/operations/zone-purge)
- [GitHub Actions - Deploy Pages](https://github.com/actions/deploy-pages)
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**Last Updated**: 2025-11-05
**Maintained By**: Chris Taylor
