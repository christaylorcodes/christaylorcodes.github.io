# Content Security Policy (CSP) Configuration Guide

This guide provides step-by-step instructions for configuring strict Content Security Policy headers in Cloudflare to fix the Aikido Security audit finding: "CSP config allows inline CSS".

## Summary of Changes

All inline `style=""` attributes have been removed from the HTML and replaced with CSS classes. The only remaining inline CSS is the critical CSS `<style>` block in `_includes/critical-css.html`, which is allowed using a SHA-256 hash in the CSP policy.

**Critical CSS Hash:**
```
sha256-oTCC4jjnPFMqFmgIwPsdQW7KXt/huDGLOX/fwwOdZZs=
```

## Cloudflare Configuration Steps

### Step 1: Log into Cloudflare Dashboard

1. Navigate to [https://dash.cloudflare.com](https://dash.cloudflare.com)
2. Select your account
3. Click on the **christaylor.codes** domain

### Step 2: Create HTTP Response Header Transform Rule

1. In the left sidebar, click **Rules** → **Transform Rules**
2. Click **Create rule** button
3. Select **Modify Response Header** (or **HTTP Response Header Modification** depending on your plan)

### Step 3: Configure the Rule

**Rule name:**
```
Strict Content Security Policy
```

**When incoming requests match:**
- Select: `All incoming requests`
- Or use custom expression: `(http.host eq "christaylor.codes")`

**Then:**
- **Operation:** Set static
- **Header name:** `Content-Security-Policy`
- **Value:** (Use the complete CSP below)

```
default-src 'self'; script-src 'self' https://www.googletagmanager.com https://www.google-analytics.com https://static.cloudflareinsights.com https://cdnjs.cloudflare.com; style-src 'self' 'sha256-oTCC4jjnPFMqFmgIwPsdQW7KXt/huDGLOX/fwwOdZZs=' https://fonts.googleapis.com https://cdnjs.cloudflare.com; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com data:; img-src 'self' https://www.google-analytics.com https://app.aikido.dev data:; connect-src 'self' https://www.google-analytics.com https://stats.g.doubleclick.net https://cloudflareinsights.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self';
```

### Step 4: Enable the Rule

1. Click **Deploy** button
2. The rule will be activated immediately

## CSP Policy Breakdown

Here's what each directive does:

| Directive | Value | Purpose |
|-----------|-------|---------|
| `default-src` | `'self'` | Default policy - only allow resources from same origin |
| `script-src` | `'self'` + Google Analytics + Cloudflare Analytics + CDN | Allow JavaScript from your site and analytics services |
| `style-src` | `'self'` + **hash** + Google Fonts + CDN | Allow CSS from your site (including critical CSS via hash), Google Fonts, and Font Awesome CDN |
| `font-src` | `'self'` + Google Fonts + CDN + data: | Allow fonts from Google Fonts, Font Awesome CDN, and inline data URIs |
| `img-src` | `'self'` + Google Analytics + Aikido badge + data: | Allow images from your site, analytics, security badge, and inline data URIs |
| `connect-src` | `'self'` + Google Analytics endpoints + Cloudflare | Allow AJAX/fetch requests to analytics services |
| `frame-ancestors` | `'none'` | Prevent site from being embedded in iframes (clickjacking protection) |
| `base-uri` | `'self'` | Restrict base tag to same origin |
| `form-action` | `'self'` | Only allow forms to submit to same origin (or add Formspree if used) |

## CSP Policy (One-line format for easy copy/paste)

```
default-src 'self'; script-src 'self' https://www.googletagmanager.com https://www.google-analytics.com https://static.cloudflareinsights.com https://cdnjs.cloudflare.com; style-src 'self' 'sha256-oTCC4jjnPFMqFmgIwPsdQW7KXt/huDGLOX/fwwOdZZs=' https://fonts.googleapis.com https://cdnjs.cloudflare.com; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com data:; img-src 'self' https://www.google-analytics.com https://app.aikido.dev data:; connect-src 'self' https://www.google-analytics.com https://stats.g.doubleclick.net https://cloudflareinsights.com; frame-ancestors 'none'; base-uri 'self'; form-action 'self';
```

## Testing the Configuration

### Step 1: Verify CSP Header is Applied

After deploying the rule, test that the header is being sent:

1. Open your browser and visit: https://christaylor.codes
2. Open Developer Tools (F12)
3. Go to **Network** tab
4. Refresh the page
5. Click on the first request (the HTML page)
6. Check the **Response Headers** section
7. You should see:
   ```
   content-security-policy: default-src 'self'; script-src...
   ```

### Step 2: Check for CSP Violations

1. Open Developer Tools (F12)
2. Go to **Console** tab
3. Refresh the page
4. Look for CSP violation errors (should be none)
5. Navigate to different pages (Blog, Projects, About, Contact)
6. Verify no console errors appear

### Step 3: Re-run Aikido Security Audit

1. Visit: https://app.aikido.dev
2. Navigate to your audit dashboard
3. Click **Re-scan** or wait for automatic scan
4. Verify the "CSP config allows inline CSS" issue is resolved

## Expected Aikido Results

After implementing this CSP:

**Before:**
- **Issue:** CSP config allows inline CSS
- **Risk:** Low (Score: 20)
- **Details:** `style-src includes unsafe-inline`

**After:**
- **Status:** ✅ Resolved
- **Details:** CSP uses hash-based inline styles (secure)
- **Improvement:** No unsafe-inline directive in CSP

## Troubleshooting

### Issue: CSP violations in console

**Symptom:** Browser console shows "Refused to load..." errors

**Solution:**
1. Identify the blocked resource URL in the error message
2. Add the domain to the appropriate CSP directive
3. Update the Cloudflare Transform Rule
4. Clear browser cache and test again

### Issue: Styles not loading

**Symptom:** Site appears unstyled or critical CSS doesn't work

**Solution:**
1. Verify the hash is correct (run `.\calculate-css-hash.ps1` again)
2. Ensure hash is in single quotes in CSP: `'sha256-...'`
3. Check that `https://fonts.googleapis.com` and `https://cdnjs.cloudflare.com` are in `style-src`

### Issue: Contact form not working

**Symptom:** Form submission fails with CSP error

**Solution:**
If using Formspree, add to `form-action` directive:
```
form-action 'self' https://formspree.io;
```

### Issue: New analytics service blocked

**Symptom:** Analytics not tracking after CSP deployment

**Solution:**
Add the analytics service domains to appropriate directives:
- Scripts: `script-src`
- Tracking pixels: `img-src`
- API calls: `connect-src`

## Updating the Critical CSS Hash

If you modify `_includes/critical-css.html`, you must recalculate the hash:

1. Run the hash calculation script:
   ```powershell
   .\calculate-css-hash.ps1
   ```

2. Copy the new hash (looks like: `sha256-...`)

3. Update the Cloudflare Transform Rule:
   - Go to **Rules** → **Transform Rules**
   - Edit the "Strict Content Security Policy" rule
   - Replace the old hash in `style-src` with the new hash
   - Deploy the updated rule

4. Clear Cloudflare cache:
   - Go to **Caching** → **Configuration**
   - Click **Purge Everything**

5. Test the site in browser

## Additional Security Headers (Optional)

While configuring CSP, consider adding these additional security headers:

### X-Frame-Options
Prevents clickjacking (redundant with CSP `frame-ancestors` but provides defense-in-depth):
```
Header: X-Frame-Options
Value: DENY
```

### X-Content-Type-Options
Prevents MIME-type sniffing:
```
Header: X-Content-Type-Options
Value: nosniff
```

### Referrer-Policy
Controls how much referrer information is sent:
```
Header: Referrer-Policy
Value: strict-origin-when-cross-origin
```

### Permissions-Policy
Restricts browser features:
```
Header: Permissions-Policy
Value: geolocation=(), microphone=(), camera=()
```

Create separate Transform Rules for each header using the same configuration steps as above.

## Security Best Practices

1. **Monitor CSP Reports:** Consider adding `report-uri` or `report-to` directive to receive violation reports
2. **Start with Report-Only:** Test CSP with `Content-Security-Policy-Report-Only` header before enforcing
3. **Review Regularly:** Audit CSP policy quarterly as site evolves
4. **Document Changes:** Update this guide when adding new external resources
5. **Test Thoroughly:** Test on all pages and browsers after CSP changes

## References

- **MDN CSP Documentation:** https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP
- **CSP Evaluator:** https://csp-evaluator.withgoogle.com/
- **Cloudflare Transform Rules:** https://developers.cloudflare.com/rules/transform/
- **Aikido Security:** https://app.aikido.dev/

---

**Last Updated:** 2025-11-08
**Script:** calculate-css-hash.ps1
**Current Hash:** sha256-oTCC4jjnPFMqFmgIwPsdQW7KXt/huDGLOX/fwwOdZZs=
