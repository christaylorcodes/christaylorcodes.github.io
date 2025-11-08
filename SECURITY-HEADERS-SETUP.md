# Security Headers Setup Guide

This guide explains how to configure security headers for christaylor.codes via Cloudflare to protect against XSS attacks, clickjacking, and other security vulnerabilities.

## Overview

The site currently lacks two important security headers:
1. **Content Security Policy (CSP)** - Prevents XSS attacks and unauthorized code injection
2. **X-Frame-Options** - Prevents clickjacking attacks

These headers are configured via Cloudflare Transform Rules since the site is hosted on GitHub Pages and proxied through Cloudflare CDN.

## Required Security Headers

### 1. Content Security Policy (CSP)

**Purpose:** Controls which resources (scripts, styles, images) can be loaded and executed on the site.

**Recommended Policy:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' https://www.googletagmanager.com https://www.google-analytics.com https://static.cloudflareinsights.com 'sha256-HASH' 'unsafe-inline'; style-src 'self' https://fonts.googleapis.com 'unsafe-inline'; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' https://www.google-analytics.com data:; connect-src 'self' https://www.google-analytics.com https://analytics.google.com https://api.cloudflare.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self' https://formspree.io
```

**Policy Breakdown:**
- `default-src 'self'` - By default, only load resources from same origin
- `script-src` - Allow scripts from:
  - Same origin (`'self'`)
  - Google Analytics (`googletagmanager.com`, `google-analytics.com`)
  - Cloudflare Analytics (`static.cloudflareinsights.com`)
  - Inline scripts with specific SHA-256 hash (`'sha256-HASH'`)
  - Inline scripts (`'unsafe-inline'` - required for GA4)
- `style-src` - Allow stylesheets from:
  - Same origin (`'self'`)
  - Google Fonts (`fonts.googleapis.com`)
  - Inline styles (`'unsafe-inline'` - required for Font Awesome)
- `font-src` - Allow fonts from:
  - Same origin (`'self'`)
  - Google Fonts (`fonts.gstatic.com`)
  - Font Awesome CDN (`cdnjs.cloudflare.com`)
- `img-src` - Allow images from:
  - Same origin (`'self'`)
  - Google Analytics tracking pixels
  - Data URIs (`data:`)
- `connect-src` - Allow AJAX/fetch requests to:
  - Same origin (`'self'`)
  - Google Analytics API endpoints
  - Cloudflare API (for cache purging)
- `frame-ancestors 'none'` - Prevent embedding in iframes (clickjacking protection)
- `base-uri 'self'` - Restrict `<base>` tag to same origin
- `form-action 'self' https://formspree.io` - Allow form submissions to same origin and Formspree

### 2. X-Frame-Options

**Purpose:** Legacy header to prevent clickjacking (redundant with CSP `frame-ancestors` but provides defense-in-depth).

**Recommended Value:**
```
X-Frame-Options: DENY
```

**Options:**
- `DENY` - Never allow embedding in iframes
- `SAMEORIGIN` - Only allow embedding on same origin
- `ALLOW-FROM uri` - Allow embedding from specific origin (deprecated)

### 3. Additional Recommended Headers

**X-Content-Type-Options:**
```
X-Content-Type-Options: nosniff
```
Prevents MIME type sniffing, forcing browsers to respect declared content types.

**Referrer-Policy:**
```
Referrer-Policy: strict-origin-when-cross-origin
```
Controls how much referrer information is sent with requests.

**Permissions-Policy:**
```
Permissions-Policy: geolocation=(), microphone=(), camera=()
```
Disables unnecessary browser features for security.

## Implementation via Cloudflare Transform Rules

### Step 1: Access Cloudflare Dashboard

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Select the **christaylor.codes** zone
3. Navigate to **Rules** → **Transform Rules**

### Step 2: Create HTTP Response Header Modification Rule

1. Click **Create rule**
2. Select **Modify Response Header**
3. Configure the rule:

**Rule Name:** `Security Headers - CSP and Anti-Clickjacking`

**When incoming requests match:**
- Field: `Hostname`
- Operator: `equals`
- Value: `christaylor.codes`

**Then:**
Add the following header modifications:

| Action | Header Name | Value |
|--------|-------------|-------|
| Set static | Content-Security-Policy | `default-src 'self'; script-src 'self' https://www.googletagmanager.com https://www.google-analytics.com https://static.cloudflareinsights.com 'unsafe-inline'; style-src 'self' https://fonts.googleapis.com 'unsafe-inline'; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' https://www.google-analytics.com data:; connect-src 'self' https://www.google-analytics.com https://analytics.google.com https://api.cloudflare.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self' https://formspree.io` |
| Set static | X-Frame-Options | `DENY` |
| Set static | X-Content-Type-Options | `nosniff` |
| Set static | Referrer-Policy | `strict-origin-when-cross-origin` |
| Set static | Permissions-Policy | `geolocation=(), microphone=(), camera=()` |

### Step 3: Save and Deploy

1. Click **Deploy** to activate the rule
2. Changes take effect immediately (no cache purge required)

## Testing Security Headers

### Using Browser Developer Tools

1. Open the site: https://christaylor.codes
2. Open DevTools (F12)
3. Go to **Network** tab
4. Refresh the page
5. Click on the main document request
6. View **Response Headers** section
7. Verify presence of:
   - `content-security-policy`
   - `x-frame-options`
   - `x-content-type-options`
   - `referrer-policy`
   - `permissions-policy`

### Using Online Tools

**SecurityHeaders.com:**
1. Visit https://securityheaders.com/
2. Enter `https://christaylor.codes`
3. Review grade and recommendations

**Mozilla Observatory:**
1. Visit https://observatory.mozilla.org/
2. Enter `christaylor.codes`
3. Run security scan
4. Review results and recommendations

**CSP Evaluator:**
1. Visit https://csp-evaluator.withgoogle.com/
2. Paste the CSP header value
3. Review for potential bypasses or weaknesses

### Using Command Line

```bash
# Check headers with curl
curl -I https://christaylor.codes

# Check specific header
curl -I https://christaylor.codes | grep -i "content-security-policy"
curl -I https://christaylor.codes | grep -i "x-frame-options"
```

## Troubleshooting

### CSP Violations (Site Breaks)

If the site stops working after applying CSP:

1. **Check Browser Console** (F12 → Console tab) for CSP violation errors
2. **Identify blocked resources** - violations show which resources were blocked
3. **Update CSP policy** to allow legitimate resources:
   - Add domain to appropriate directive (script-src, style-src, etc.)
   - Redeploy Cloudflare Transform Rule with updated policy

**Common violations:**
- **Inline scripts blocked** - Add `'unsafe-inline'` to `script-src` (or use nonce/hash)
- **Third-party fonts blocked** - Add font CDN to `font-src`
- **Analytics blocked** - Add analytics domains to `script-src` and `connect-src`

### CSP Report-Only Mode (Testing)

To test CSP without breaking the site:

1. Change header name from `Content-Security-Policy` to `Content-Security-Policy-Report-Only`
2. CSP will report violations in console but won't block resources
3. Review console errors and adjust policy
4. Switch back to enforcing mode once policy is refined

### Headers Not Appearing

If headers don't appear after deploying rule:

1. **Check rule status** - Ensure rule is enabled in Cloudflare dashboard
2. **Verify hostname match** - Rule must match `christaylor.codes` exactly
3. **Purge Cloudflare cache** - Old cached responses may not have headers:
   ```bash
   # Via Cloudflare Dashboard: Caching → Purge Cache → Purge Everything
   ```
4. **Test with cache bypass** - Add `?nocache=1` to URL to bypass cache
5. **Wait for propagation** - Changes can take 1-2 minutes to propagate globally

## Maintenance

### Updating CSP Policy

When adding new third-party services:

1. Identify domains used by the service
2. Update CSP policy in Cloudflare Transform Rule
3. Test with Report-Only mode first
4. Deploy enforcing mode once verified

### Regular Security Audits

**Monthly:**
- Run SecurityHeaders.com scan
- Review for new recommendations

**Quarterly:**
- Run Mozilla Observatory scan
- Update CSP policy for new resources
- Review Permissions-Policy for new browser features

**After major changes:**
- Test all site functionality
- Check browser console for CSP violations
- Verify analytics and tracking still work

## Current Status

### Before Implementation

- ❌ Content Security Policy: **Not Set** (Critical)
- ❌ X-Frame-Options: **Not Set** (Medium)
- ✅ HTTPS: **Enabled** via Cloudflare
- ✅ HSTS: **Enabled** via Cloudflare (Automatic)

### After Implementation

- ✅ Content Security Policy: **Enforced**
- ✅ X-Frame-Options: **DENY**
- ✅ X-Content-Type-Options: **nosniff**
- ✅ Referrer-Policy: **strict-origin-when-cross-origin**
- ✅ Permissions-Policy: **Restricted**
- ✅ HTTPS: **Enabled**
- ✅ HSTS: **Enabled**

**Expected Security Rating:** A+ on SecurityHeaders.com

## References

- [Content Security Policy (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [X-Frame-Options (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options)
- [Cloudflare Transform Rules Documentation](https://developers.cloudflare.com/rules/transform/)
- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)

---

**Last Updated:** 2025-02-07
**Maintained By:** Chris Taylor (ctaylor@christaylor.codes)
**Related Documentation:** [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md), [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md)
