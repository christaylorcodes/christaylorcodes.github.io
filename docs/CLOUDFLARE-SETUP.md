# Cloudflare Cache Purging Setup Guide

This guide explains how to configure automated Cloudflare cache purging for the GitHub Actions deployment workflow.

## Overview

The GitHub Actions workflow automatically purges Cloudflare's cache after successfully deploying the Jekyll site to GitHub Pages. This ensures that visitors see updated content immediately without waiting for Cloudflare's cache to expire.

## Prerequisites

- Cloudflare account with christaylor.codes configured
- GitHub repository with Actions enabled
- Repository admin access (to add secrets)

## Step 1: Create Cloudflare API Token

1. **Log in to Cloudflare Dashboard**: https://dash.cloudflare.com/
2. **Navigate to API Tokens**:
   - Click on your profile icon (top right)
   - Select "My Profile"
   - Go to "API Tokens" tab
   - Click "Create Token"

3. **Configure Token Permissions**:
   - Template: Start with "Custom token"
   - Token name: `GitHub Actions - Cache Purge`
   - Permissions:
     - **Zone** → **Cache Purge** → **Purge**
   - Zone Resources:
     - **Include** → **Specific zone** → **christaylor.codes**
   - Client IP Address Filtering: Leave empty (GitHub Actions IPs change)
   - TTL: End Date → Leave empty (no expiration)

4. **Create and Save Token**:
   - Click "Continue to summary"
   - Review permissions
   - Click "Create Token"
   - **IMPORTANT**: Copy the token immediately (shown only once)
   - Store securely in password manager

## Step 2: Get Cloudflare Zone ID

1. **Navigate to Domain Overview**:
   - In Cloudflare Dashboard, select **christaylor.codes**
   - Scroll down to "API" section on the right sidebar

2. **Copy Zone ID**:
   - Find "Zone ID" field
   - Click to copy (format: 32-character alphanumeric string)
   - Example format: `abc123def456ghi789jkl012mno345pq`

## Step 3: Add GitHub Secrets

1. **Navigate to Repository Settings**:
   - Go to: https://github.com/christaylorcodes/christaylorcodes.github.io
   - Click "Settings" tab
   - Select "Secrets and variables" → "Actions" from left sidebar

2. **Add CLOUDFLARE_API_TOKEN**:
   - Click "New repository secret"
   - Name: `CLOUDFLARE_API_TOKEN`
   - Secret: Paste the API token from Step 1
   - Click "Add secret"

3. **Add CLOUDFLARE_ZONE_ID**:
   - Click "New repository secret"
   - Name: `CLOUDFLARE_ZONE_ID`
   - Secret: Paste the Zone ID from Step 2
   - Click "Add secret"

## Step 4: Configure GitHub Pages

1. **Navigate to Pages Settings**:
   - Repository → Settings → Pages (left sidebar)

2. **Set Source**:
   - Source: **GitHub Actions** (not "Deploy from a branch")
   - This allows the custom workflow to deploy the site

3. **Verify Custom Domain**:
   - Custom domain: `christaylor.codes` should already be configured
   - HTTPS: Should be enforced

## Step 5: Test the Workflow

1. **Trigger a Deployment**:
   - Make a small change to the repository (e.g., update README.md)
   - Commit and push to `main` branch:
     ```bash
     git add .
     git commit -m "Test workflow"
     git push origin main
     ```

2. **Monitor Workflow Execution**:
   - Navigate to: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
   - Click on the latest workflow run
   - Watch the three jobs complete:
     1. ✅ **build** - Compiles Jekyll site
     2. ✅ **deploy** - Deploys to GitHub Pages
     3. ✅ **purge-cloudflare-cache** - Purges Cloudflare cache

3. **Verify Success**:
   - All three jobs should show green checkmarks
   - purge-cloudflare-cache job should show: "✅ Cloudflare cache purged successfully for christaylor.codes"
   - Changes should be visible on https://christaylor.codes within 1-2 minutes

## Troubleshooting

### Cache Purge Job Fails

**Issue**: purge-cloudflare-cache job shows red X

**Solution**:
1. Check the job logs for error details
2. Common issues:
   - **401 Unauthorized**: API token is invalid or expired
   - **403 Forbidden**: API token doesn't have Cache Purge permission
   - **Invalid Zone ID**: Zone ID is incorrect

**Fix**:
- Re-create API token with correct permissions
- Verify Zone ID is correct
- Update GitHub secrets with new values

### Changes Not Appearing on Site

**Issue**: Deployment succeeds but changes not visible

**Solution**:
1. Hard refresh browser: `Ctrl+F5` (Windows) or `Cmd+Shift+R` (Mac)
2. Check Cloudflare cache status in dashboard
3. Manually purge cache:
   - Cloudflare Dashboard → christaylor.codes
   - Click "Caching" → "Purge Everything"

### Build Job Fails

**Issue**: build job fails before deployment

**Solution**:
1. Check error logs in GitHub Actions
2. Common issues:
   - Jekyll syntax errors
   - Missing dependencies
   - YAML front matter issues
3. Test locally first:
   ```powershell
   .\build.ps1
   ```

## Workflow Architecture

The deployment process follows this sequence:

```
1. Push to main branch
   ↓
2. build job (1-2 minutes)
   - Checkout code
   - Setup Ruby 3.3
   - Install dependencies (bundler-cache)
   - Build Jekyll site with production settings
   - Upload artifact
   ↓
3. deploy job (30 seconds)
   - Download artifact
   - Deploy to GitHub Pages
   ↓
4. purge-cloudflare-cache job (5 seconds)
   - Call Cloudflare API
   - Purge entire zone cache
   - Verify success
   ↓
5. Site live with fresh content (total: 2-3 minutes)
```

## Security Best Practices

1. **API Token Scope**: Token is scoped to only Cache Purge permission on one zone
2. **No Expiration**: Token doesn't expire (store securely in GitHub secrets)
3. **Secrets Storage**: Never commit API token or Zone ID to repository
4. **Least Privilege**: Token cannot modify DNS, settings, or other Cloudflare resources
5. **Rotation**: If token is compromised, revoke in Cloudflare and create new one

## Maintenance

**When to Update**:
- If API token is compromised or exposed
- When migrating to a different Cloudflare account
- If changing domain names

**How to Rotate Token**:
1. Create new API token in Cloudflare (Step 1)
2. Update `CLOUDFLARE_API_TOKEN` secret in GitHub (Step 3)
3. Test workflow (Step 5)
4. Revoke old token in Cloudflare Dashboard

## Cache Lifetimes Configuration

GitHub Pages sets short default cache TTLs (~10 minutes). Cloudflare can extend these for better performance.

### Why Extend Cache Lifetimes?

Lighthouse flags assets with short cache TTLs as optimization opportunities. By extending cache lifetimes in Cloudflare, repeat visitors experience faster page loads.

**Assets to cache longer:**
- Images (WebP, PNG, JPG, SVG): 1 year (versioned/content-addressed)
- CSS/JS: 1 year (fingerprinted in production)
- Fonts: 1 year (immutable)
- HTML pages: 1 hour (dynamic content)

### Configure Cache Rules

1. **Navigate to Caching Settings**:
   - Cloudflare Dashboard → christaylor.codes
   - Click "Caching" in left sidebar
   - Click "Cache Rules" tab

2. **Create Rule for Static Assets**:
   - Click "Create rule"
   - Rule name: `Static Assets - Long TTL`
   - When incoming requests match:
     ```
     (http.request.uri.path.extension in {"webp" "png" "jpg" "jpeg" "gif" "svg" "ico" "woff2" "woff" "ttf" "eot"})
     ```
   - Then:
     - **Cache eligibility**: Eligible for cache
     - **Edge TTL**: Override origin → 1 year (31536000 seconds)
     - **Browser TTL**: Override origin → 1 year
   - Deploy

3. **Create Rule for CSS/JS**:
   - Click "Create rule"
   - Rule name: `CSS JS - Long TTL`
   - When incoming requests match:
     ```
     (http.request.uri.path.extension in {"css" "js"})
     ```
   - Then:
     - **Cache eligibility**: Eligible for cache
     - **Edge TTL**: Override origin → 1 week (604800 seconds)
     - **Browser TTL**: Override origin → 1 week
   - Deploy

4. **HTML Pages (Optional)**:
   - Leave at default (respects origin headers)
   - Or create rule for 1 hour TTL

### Verify Cache Configuration

1. **Test with curl**:
   ```bash
   curl -I https://christaylor.codes/assets/images/hero-background-1280w.webp
   ```
   Look for: `cf-cache-status: HIT` and `cache-control: max-age=31536000`

2. **Test in Lighthouse**:
   - Run Lighthouse audit
   - Check "Serve static assets with efficient cache policy" diagnostic
   - Should show improved cache lifetimes

### Important Notes

- **Cache invalidation**: Long TTLs are safe because deployment purges Cloudflare cache
- **Browser cache**: Users may need hard refresh after deployments
- **Fingerprinting**: If adding content-hash to filenames, set TTL to 1 year for immutable caching
- **Order matters**: More specific rules should be higher in the list

## Additional Resources

- [Cloudflare API Documentation](https://developers.cloudflare.com/api/)
- [Cloudflare Cache Rules](https://developers.cloudflare.com/cache/how-to/cache-rules/)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Jekyll on GitHub Pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll)

---

**Last Updated**: 2025-11-25
**Workflow Version**: 1.0
**Tested With**: Ruby 3.3, Jekyll 4.x, GitHub Actions
