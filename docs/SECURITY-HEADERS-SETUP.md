# Security Headers Setup Guide

This guide explains how to configure security headers for christaylor.codes via Cloudflare to protect against XSS attacks, clickjacking, and other security vulnerabilities.

## Overview

This guide documents the **Content Security Policy (CSP)** and security headers implementation for christaylor.codes as a **Cloudflare best practice**.

**Status:** ✅ Implemented (2025-11-08)

Security headers are configured via Cloudflare Transform Rules since the site is hosted on GitHub Pages and proxied through Cloudflare CDN. This approach provides:
- Strong XSS protection with strict source allowlists
- Clickjacking prevention
- Performance optimization through inline critical CSS
- Industry-standard balance of security and usability

## Required Security Headers

### 1. Content Security Policy (CSP)

**Purpose:** Controls which resources (scripts, styles, images) can be loaded and executed on the site.

**Implemented Policy:**
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com https://static.cloudflareinsights.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data: https:; connect-src 'self' https://www.google-analytics.com https://region1.google-analytics.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self' https://formspree.io
```

**Policy Breakdown:**
- `default-src 'self'` - By default, only load resources from same origin
- `script-src 'self' 'unsafe-inline'` + allowed domains - Allow scripts from:
  - Same origin (`'self'`)
  - Inline scripts (`'unsafe-inline'` - **required for critical performance**)
  - Google Analytics (`www.googletagmanager.com`)
  - Cloudflare Analytics (`static.cloudflareinsights.com`)
  - Font Awesome CDN (`cdnjs.cloudflare.com`)
  - Cookie Consent Library (`cdn.jsdelivr.net`)
- `style-src 'self' 'unsafe-inline'` + allowed domains - Allow stylesheets from:
  - Same origin (`'self'`)
  - Inline styles (`'unsafe-inline'` - **required for critical CSS**)
  - Google Fonts (`fonts.googleapis.com`)
  - Font Awesome CDN (`cdnjs.cloudflare.com`)
  - Cookie Consent Library (`cdn.jsdelivr.net`)
- `font-src` - Allow fonts from:
  - Same origin (`'self'`)
  - Google Fonts (`fonts.gstatic.com`)
  - Font Awesome CDN (`cdnjs.cloudflare.com`)
- `img-src 'self' data: https:` - Allow images from:
  - Same origin (`'self'`)
  - Data URIs (`data:`)
  - Any HTTPS source (`https:`)
- `connect-src` - Allow AJAX/fetch requests to:
  - Same origin (`'self'`)
  - Google Analytics API endpoints (`www.google-analytics.com`, `region1.google-analytics.com`)
- `frame-ancestors 'none'` - Prevent embedding in iframes (**clickjacking protection**)
- `base-uri 'self'` - Restrict `<base>` tag to same origin
- `form-action 'self' https://formspree.io` - Allow form submissions to same origin and Formspree only

### Why `unsafe-inline` is Acceptable (Cloudflare Best Practice)

This CSP uses `'unsafe-inline'` for scripts and styles, which is **industry standard** for sites with:

1. **Critical CSS Performance Optimization**
   - Location: [_includes/critical-css.html](_includes/critical-css.html)
   - Purpose: Inline above-the-fold CSS for immediate rendering (no render-blocking requests)
   - Impact: Improved Core Web Vitals (LCP, FCP)

2. **Google Analytics Implementation**
   - Location: [_includes/google-analytics.html](_includes/google-analytics.html)
   - Standard GA4 implementation requires inline script
   - Industry-wide practice (Google's own sites use this approach)

3. **Async CSS Loading**
   - Location: [_layouts/default.html:38,45](_layouts/default.html)
   - `onload` attributes for deferred stylesheet loading
   - Performance optimization technique

**Security Mitigation:**
- **Strict source allowlists** prevent loading external scripts/styles from unauthorized domains
- **No user-generated content** that could inject malicious code
- **All inline code is static** and version-controlled in the repository
- **Regular security audits** via automated scanning (Aikido Security)

**Comparable Security:**
- Google's own properties use this CSP approach
- GitHub Pages sites commonly use this pattern
- Mozilla Observatory accepts this with strict source lists
- OWASP recognizes performance-critical inline code as acceptable trade-off

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

**Rule Name:** `Content Security Policy`

**When incoming requests match:**
- Field: `Hostname`
- Operator: `equals`
- Value: `christaylor.codes`

**Then:**
Add the following header modifications:

**Primary CSP Rule:**

| Action | Header Name | Value |
|--------|-------------|-------|
| Set static | Content-Security-Policy | `default-src 'self'; script-src 'self' 'unsafe-inline' https://www.googletagmanager.com https://static.cloudflareinsights.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data: https:; connect-src 'self' https://www.google-analytics.com https://region1.google-analytics.com https://ipinfo.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self' https://formspree.io` |

**Optional Additional Headers (Recommended):**

Create a second rule named "Additional Security Headers" with:

| Action | Header Name | Value |
|--------|-------------|-------|
| Set static | X-Frame-Options | `DENY` |
| Set static | X-Content-Type-Options | `nosniff` |
| Set static | Referrer-Policy | `strict-origin-when-cross-origin` |
| Set static | Permissions-Policy | `camera=(), microphone=(), geolocation=(), interest-cohort=()` |

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

### Implemented (2025-11-08, Updated 2025-01-08)

**Primary Headers:**
- ✅ Content Security Policy: **Enforced** (restrictive policy with strict source allowlists)
  - Includes `cdn.jsdelivr.net` for cookie consent library (Osano Cookie Consent)
  - Geolocation detection disabled to avoid mixed content warnings
- ✅ HTTPS: **Enabled** via Cloudflare SSL/TLS Full (Strict)
- ✅ HSTS: **Enabled** via Cloudflare (Automatic, 31536000 seconds, includeSubDomains)

**Recommended Additional Headers (Optional):**
- ⚠️ X-Frame-Options: **Recommended** (redundant with CSP `frame-ancestors` but provides defense-in-depth)
- ⚠️ X-Content-Type-Options: **Recommended** (prevents MIME sniffing attacks)
- ⚠️ Referrer-Policy: **Recommended** (controls referrer information leakage)
- ⚠️ Permissions-Policy: **Recommended** (restricts unnecessary browser features)

**Expected Security Rating:**
- SecurityHeaders.com: **B+ to A-** (with CSP only), **A to A+** (with all optional headers)
- Mozilla Observatory: **B+ to A-**
- Aikido Security: **90-95/100** (improvement from 85)

## References

- [Content Security Policy (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [X-Frame-Options (MDN)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options)
- [Cloudflare Transform Rules Documentation](https://developers.cloudflare.com/rules/transform/)
- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [CSP Evaluator](https://csp-evaluator.withgoogle.com/)

---

**Last Updated:** 2025-01-08
**Maintained By:** Chris Taylor (ctaylor@christaylor.codes)
**Related Documentation:** [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md), [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md)

**Changelog:**
- **2025-11-08**: Removed `ipinfo.io` from CSP and disabled geolocation in cookie consent (eliminates mixed content warning in Lighthouse)
- **2025-01-08**: Added `cdn.jsdelivr.net` to CSP for cookie consent library
- **2025-11-08**: Initial CSP implementation
