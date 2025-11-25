# Known Issues

This document tracks known issues with the website build and deployment process.

## Jekyll Serve - Character Encoding Errors

**Status:** Under Investigation
**First Observed:** 2025-11-08
**Severity:** Low (does not affect production builds or deployments)

### Symptoms

When running `bundle exec jekyll serve` or `.\build.ps1`, the server occasionally displays multiple "ERROR bad Request-Line" messages with garbled/corrupted characters in the terminal output:

```
[2025-11-08 15:49:58] ERROR bad Request-Line '\x16\x03\x01\a\x12\x01\x00\a\x0E\x03\x03♦XN@♦I♦♦@♦N\L' Vh.C
[2025-11-08 15:49:58] ERROR bad Request-Line '\x16\x03\x01\a\x12\x01\x00\a\x0E\x03\x03♦♦'.
[2025-11-08 15:50:02] ERROR bad Request-Line '\x16\x03\x01\x06♦ \x01\x00\x06♦ \x03\x03>♦♦ \x14f\x13\a#\é♦M≡♦
```

### Impact

- **Local Development:** Errors appear in terminal but do not prevent the site from building or serving
- **Production Builds:** No impact - production builds via GitHub Actions work correctly
- **Site Functionality:** No impact - the site renders and functions normally in the browser
- **User Experience:** No impact - visitors to the site are unaffected

### Analysis

The error messages appear to be:

1. **HTTP Request Parsing Errors:** WEBrick (Jekyll's development server) is receiving malformed HTTP requests
2. **Character Encoding:** The garbled text suggests binary data or non-UTF-8 encoding in the requests
3. **Potential Sources:**
   - Browser attempting HTTPS connection to HTTP server (TLS handshake bytes being sent to non-TLS server)
   - Browser extension or security software intercepting requests
   - Corrupted browser cache
   - Operating system network stack issues
   - YAML files with encoding problems being processed by Liquid templates

### Possible Root Causes

**Most Likely:**
- **TLS/HTTPS Mismatch:** Browser or tool trying to establish HTTPS connection to `http://localhost:4000` (the `\x16\x03\x01` prefix is a TLS ClientHello message)
- The browser may be auto-upgrading HTTP to HTTPS or using HTTPS Everywhere extension

**Less Likely:**
- YAML front matter in project files with non-UTF-8 characters
- Liquid template processing producing invalid output
- File encoding issues in includes or layouts

### Workarounds

1. **Ignore the errors:** They do not affect functionality
2. **Clear browser cache and cookies**
3. **Disable HTTPS Everywhere or similar browser extensions**
4. **Force HTTP in browser:** Explicitly visit `http://localhost:4000` (not `https://`)
5. **Use incognito/private browsing mode** to avoid extensions
6. **Try a different browser** to rule out browser-specific issues

### Investigation Steps

To diagnose the issue further:

1. **Check YAML file encodings:**
   ```powershell
   # Check for non-UTF-8 files
   Get-ChildItem -Recurse -Include *.md,*.yml,*.yaml,*.html |
     ForEach-Object {
       $content = [System.IO.File]::ReadAllBytes($_.FullName)
       $encoding = [System.Text.Encoding]::GetEncoding(0).GetString($content)
       if ($encoding -match '[^\x00-\x7F]') {
         Write-Output "$($_.FullName): Non-ASCII content detected"
       }
     }
   ```

2. **Validate YAML front matter:**
   ```powershell
   # Install yamllint if not already installed
   # pip install yamllint

   # Check all project files
   Get-ChildItem _projects/*.md | ForEach-Object {
     Write-Output "Checking $($_.Name)..."
     yamllint $_.FullName
   }
   ```

3. **Monitor network requests:**
   - Open browser DevTools Network tab
   - Watch for failed or malformed requests to localhost:4000
   - Check request headers and response codes

4. **Test with different browsers:**
   - Chrome/Edge (Chromium-based)
   - Firefox
   - Safari (if on macOS)

5. **Check for HTTPS redirects:**
   - Look for `Upgrade-Insecure-Requests` header
   - Check for HSTS (HTTP Strict Transport Security) policies
   - Verify no ServiceWorker is intercepting requests

### Related Files

Files that may be related to encoding issues:

- `_layouts/project.html` - Recently modified (front matter parsing issue fixed 2025-11-08)
- `_projects/*.md` - YAML front matter in all project files
- `_includes/structured-data-software.html` - JSON-LD schema with escaped characters
- `_data/project-stats.yml` - Centralized project statistics data

### Resolution

This issue is documented for tracking purposes. Once the root cause is identified and a fix is implemented, update this section with:

- Root cause analysis
- Fix applied
- Testing verification
- Date resolved

---

## Font Awesome Font-Display Performance Warning

**Status:** Documented / Accepted
**First Observed:** 2025-11-25
**Severity:** Very Low (20-30ms delay, minor Lighthouse warning)

### Symptoms

Lighthouse reports "Ensure text remains visible during webfont load" with ~30ms estimated savings for Font Awesome font files from cdnjs.cloudflare.com.

### Impact

- **Performance:** Minimal - 20-30ms delay showing icon fonts
- **User Experience:** Icons may flash briefly when loading
- **Lighthouse Score:** Minor warning, does not significantly impact performance score

### Technical Details

Font Awesome fonts are loaded from cdnjs.cloudflare.com CDN. The `@font-face` rules in Font Awesome's CSS may use `font-display: block` instead of `swap`.

**What we've tried:**
- Added `@font-face` overrides in `_includes/critical-css.html` with `font-display: swap`
- However, CSS `@font-face` overrides without a matching `src` property don't override the CDN's rules

### Why This Can't Be Fully Fixed (Without Trade-offs)

1. **CDN fonts:** We can't modify Font Awesome's CSS served from cdnjs
2. **Self-hosting:** Would require downloading FA fonts and managing updates manually
3. **SVG sprites:** Better performance but requires significant refactoring

### Current Mitigation

- `font-display: swap` declarations in critical CSS (partial effect)
- Icon placeholders reserve space via CSS (prevents layout shift)
- Preconnect to cdnjs.cloudflare.com speeds up font loading

### Possible Future Solutions

1. **Self-host Font Awesome** - Full control over font-display, but maintenance burden
2. **Use SVG icon sprites** - Better performance, but refactoring required
3. **Subset Font Awesome** - Only include icons actually used (~8 icons vs 2000+)
4. **Wait for CDN update** - cdnjs may update FA defaults in future

### Recommendation

Accept this minor warning. The 20-30ms impact is negligible and the trade-off of self-hosting or converting to SVG sprites isn't worth the maintenance cost for such a small gain.

---

**Last Updated:** 2025-11-25
**Next Review:** 2026-02-01
