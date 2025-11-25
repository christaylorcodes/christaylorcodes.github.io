# Performance Baseline - Pre-Optimization

**Date:** 2024-11-24
**Purpose:** Reference metrics before deploying render-blocking optimizations

## Build Metrics

### File Sizes
- **CSS (production):** 57KB (`styles.css` - compressed)
- **JavaScript (production):** 17KB (`main.min.js` - minified, 64% reduction from 45KB)
- **Images directory:** 276KB total
- **Homepage HTML:** 43KB
- **Total site size:** 3.8MB

### Resource Loading Strategy
- **Stylesheet links:** 8 total (including async loaded)
- **Script tags:** 7 total
- **Deferred resources:** 4 (scripts with defer attribute)
- **Lazy loaded images:** 1 on homepage (footer badge)
- **Preload hints:** 4 (fonts, Font Awesome, main CSS, cookie consent CSS)
- **Preconnect hints:** 4 (Google Fonts, gstatic, cdnjs, jsdelivr)

### Critical CSS
- **Inline CSS:** 230 lines
- **Coverage:** Navigation, hero section, base styles, mobile menu

## Optimizations Applied

### Render-Blocking Elimination
- ✅ Google Fonts - Async loaded with preload technique
- ✅ Font Awesome - Async loaded with preload technique
- ✅ Cookie Consent CSS - Async loaded with preload technique
- ✅ Cookie Consent JS - Deferred
- ✅ Main stylesheet - Async loaded with preload technique
- ✅ JavaScript - Deferred (production uses minified version)

### Image Optimization
- ✅ Logo: PNG (175KB) → WebP (6.3KB) - 96% reduction
- ✅ All images use `loading="lazy"` attribute
- ✅ Hero backgrounds already using WebP format

### Code Cleanup
- ✅ Removed legacy `main.css` (32KB unused code)
- ✅ Minified JavaScript enabled for production

## Manual Lighthouse Testing

### Pre-Deployment (Local)

**Run local server:**
```bash
.\build.ps1
# Visit http://localhost:4000
```

**Run Lighthouse in Chrome:**
1. Open Chrome DevTools (F12)
2. Click "Lighthouse" tab
3. Select:
   - ✅ Performance
   - ✅ Accessibility
   - ✅ Best Practices
   - ✅ SEO
4. Device: Desktop (for consistency)
5. Click "Analyze page load"
6. **Save results** or screenshot scores

### Post-Deployment (Production)

**After pushing to main:**
1. Wait 3-5 minutes for deployment
2. Visit https://christaylor.codes
3. Run same Lighthouse test
4. Compare scores with local results

**Also test with:**
- PageSpeed Insights: https://pagespeed.web.dev/analysis/https-christaylor-codes
- WebPageTest: https://www.webpagetest.org/

## Expected Improvements

### PageSpeed Metrics
- **First Contentful Paint (FCP):** -200 to -500ms
- **Largest Contentful Paint (LCP):** -300 to -800ms
- **Time to Interactive (TTI):** -500 to -1000ms
- **Total Blocking Time (TBT):** -100 to -300ms
- **Cumulative Layout Shift (CLS):** Should remain stable (already good)

### Lighthouse Scores
- **Performance:** +10 to +20 points
- **Accessibility:** Should remain stable (already compliant)
- **Best Practices:** Should remain stable
- **SEO:** Should remain stable

### Audit Resolutions
- ✅ "Eliminate render-blocking resources" - Should pass
- ✅ "Properly size images" - Logo optimized (96% smaller)
- ✅ "Serve images in modern formats" - Using WebP ✓
- ✅ "Efficiently encode images" - WebP compression ✓
- ✅ "Enable text compression" - Cloudflare handles this ✓
- ✅ "Reduce JavaScript execution time" - Minified (64% smaller)

## Network Performance

### Critical Path
1. HTML document (43KB)
2. Critical inline CSS (immediate render)
3. Async resources load in parallel:
   - Google Fonts
   - Font Awesome
   - Main stylesheet
   - Cookie consent
4. JavaScript loads deferred (non-blocking)

### Connection Optimization
- **Preconnect:** Reduces DNS + TCP + TLS time for external resources
- **Preload:** Prioritizes critical stylesheets
- **Defer:** Prevents JavaScript from blocking rendering
- **Lazy loading:** Images load only when needed

## Comparison Checklist

After deployment, compare:
- [ ] Performance score (expect +10-20 points)
- [ ] FCP metric (expect -200-500ms)
- [ ] LCP metric (expect -300-800ms)
- [ ] TTI metric (expect -500-1000ms)
- [ ] TBT metric (expect -100-300ms)
- [ ] Render-blocking resources (expect 0)
- [ ] Screenshot similarity (visual regression check)

## Files Modified

1. `_config.yml` - Logo switched to WebP
2. `_layouts/default.html` - Async Google Fonts, added jsdelivr preconnect
3. `_includes/cookie-consent.html` - Async CSS and deferred JS
4. `_includes/footer.html` - Lazy loading for badge image
5. `assets/css/main.css` - Deleted (removed 32KB unused code)

## Notes

- `style.css` (75KB) exists in `_site/` from github-pages gem but is NOT loaded
- Only `styles.css` is actually referenced by pages
- Production build uses minified JavaScript automatically
- All third-party resources now load asynchronously
- Critical CSS provides instant above-the-fold rendering
