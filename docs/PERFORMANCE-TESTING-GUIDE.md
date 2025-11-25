# Performance Testing and Validation Guide

This guide provides comprehensive testing procedures to validate performance improvements and ensure optimal site speed.

## Pre-Optimization Baseline

Before implementing optimizations, establish baseline metrics for comparison.

### Baseline Measurements

**Image Sizes (Before WebP):**
- hero-background-3.jpg: 763 KB
- profile-photo.png: 174 KB
- hero-background-2.jpg: 92 KB
- hero-background.jpg: 62 KB
- **Total:** ~1,091 KB

**CSS Delivery:**
- Uncompressed Sass output: ~45-50 KB
- Font Awesome all.min.css: ~1,500 KB
- **Total CSS:** ~1,550 KB

**Estimated Total Page Weight (Homepage):**
- HTML: ~25 KB
- CSS: ~1,550 KB
- JavaScript: ~30 KB
- Images: ~1,091 KB
- Fonts: ~120 KB
- **Total:** ~2,816 KB (~2.8 MB)

## Sprint 1 Optimizations Implemented

**Completed:** 2024-11-04

### 1. WebP Image Conversion

**Changes:**
- Created `optimize-images.ps1` script for batch WebP conversion
- Updated [about.html](_Code\Website\about.html) with picture element and WebP support
- Updated [index.html](_Code\Website\index.html) hero backgrounds for WebP
- Added WebP detection in [main.js](_Code\Website\assets\js\main.js)

**Expected Savings:**
- hero-background-3.jpg: 763 KB → ~270 KB (65% reduction)
- profile-photo.png: 174 KB → ~60 KB (65% reduction)
- hero-background-2.jpg: 92 KB → ~32 KB (65% reduction)
- hero-background.jpg: 62 KB → ~22 KB (65% reduction)
- **Total Savings:** ~745 KB (68% reduction)

### 2. Lazy Loading Implementation

**Changes:**
- Added native lazy loading support (loading="lazy" attribute)
- Implemented Intersection Observer fallback for older browsers
- Profile photo and below-fold images now lazy load

**Expected Impact:**
- Initial page load: ~250-400 KB lighter (images load on demand)
- Faster First Contentful Paint (FCP)
- Improved Largest Contentful Paint (LCP)

### 3. Font Awesome Optimization

**Status:** Documentation created, implementation pending
- Created [FONT-AWESOME-OPTIMIZATION.md](c:\_Code\Website\docs\FONT-AWESOME-OPTIMIZATION.md)
- Identified 45-50 unique icons (2.25% of full library)

**Expected Savings (when implemented):**
- Current: ~1,500 KB (full library)
- With Kit: ~150-200 KB (custom subset)
- **Total Savings:** ~1,300 KB (87% reduction)

### 4. CSS Minification

**Changes:**
- Enabled Sass compression in [_config.yml](_Code\Website\_config.yml)
- Set `style: compressed` and `sourcemap: never`

**Expected Savings:**
- Uncompressed: ~45-50 KB
- Compressed: ~30-35 KB
- **Total Savings:** ~15 KB (30% reduction)

## Sprint 2 Optimizations Implemented

**Completed:** 2024-11-24

### 1. Render-Blocking Resource Elimination

**Changes:**
- Google Fonts: Async loading with preload technique ([_layouts/default.html:36](c:\_Code\Website\_layouts\default.html#L36))
- Font Awesome: Already async loaded ([_layouts/default.html:40](c:\_Code\Website\_layouts\default.html#L40))
- Cookie Consent CSS: Async loading ([_includes/cookie-consent.html:3](c:\_Code\Website\_includes\cookie-consent.html#L3))
- Cookie Consent JS: Deferred loading ([_includes/cookie-consent.html:5](c:\_Code\Website\_includes\cookie-consent.html#L5))
- Main stylesheet: Already async loaded
- JavaScript: Already deferred
- Added preconnect hints for all external CDNs ([_layouts/default.html:29-33](c:\_Code\Website\_layouts\default.html#L29-L33))

**Expected Impact:**
- **First Contentful Paint (FCP):** -200 to -500ms
- **Largest Contentful Paint (LCP):** -300 to -800ms
- **Time to Interactive (TTI):** -500 to -1000ms
- **Total Blocking Time (TBT):** -100 to -300ms
- **Render-blocking resources:** 0 (complete elimination)

### 2. Additional Image Optimization

**Changes:**
- Logo: PNG (175KB) → WebP (6.3KB) in structured data ([_config.yml:26](c:\_Code\Website\_config.yml#L26))
- Added lazy loading to footer security badge ([_includes/footer.html:41](c:\_Code\Website\_includes\footer.html#L41))

**Savings:**
- **Logo:** 175KB → 6.3KB (96% reduction, -169KB)

### 3. Code Cleanup

**Changes:**
- Removed legacy `main.css` (32KB, 1454 lines unused code)
- Site now uses only modular Oceanic SCSS system

**Savings:**
- **Unused CSS removed:** -32KB

## Post-Optimization Target Metrics

**With All Optimizations (WebP + Lazy + FA Kit + CSS Minification):**

**Homepage Load (First Visit):**
- HTML: ~25 KB
- CSS: ~180-215 KB (compressed CSS + FA Kit)
- JavaScript: ~30 KB
- Images (immediate): ~200 KB (hero bg only, lazy load rest)
- Fonts: ~120 KB
- **Total Initial:** ~555-590 KB (~81% reduction)

**Full Page Load (After Lazy):**
- Total with all images: ~600-700 KB (~75-78% reduction)

## Testing Procedures

### 1. Local Testing

**Build and Serve:**
```powershell
.\build.ps1 -Mode clean
.\build.ps1 -Mode serve
```

**Visual Inspection:**
1. Visit http://localhost:4000
2. Check all pages for correct rendering
3. Verify images load correctly
4. Test lazy loading (scroll slowly, watch Network tab)
5. Confirm WebP images load (check Network tab → Type column)

**Developer Tools Checks:**
```
1. Open DevTools (F12)
2. Network tab → Disable cache → Reload
3. Verify WebP images are served (webp in Type column)
4. Check CSS file size (should be compressed)
5. Verify Font Awesome loads (check if Kit or full library)
6. Monitor lazy loading (images load as you scroll)
```

### 2. PageSpeed Insights Testing

**Test URLs:**
- Homepage: https://pagespeed.web.dev/analysis?url=https://christaylor.codes
- Blog: https://pagespeed.web.dev/analysis?url=https://christaylor.codes/blog/
- Projects: https://pagespeed.web.dev/analysis?url=https://christaylor.codes/projects/
- About: https://pagespeed.web.dev/analysis?url=https://christaylor.codes/about/

**Key Metrics to Track:**

**Core Web Vitals:**
- **Largest Contentful Paint (LCP):** <2.5s (good)
- **First Contentful Paint (FCP):** <1.8s (good)
- **Cumulative Layout Shift (CLS):** <0.1 (good)
- **Interaction to Next Paint (INP):** <200ms (good)

**Performance Score:**
- Desktop: 90+ (target)
- Mobile: 85+ (target)

**Opportunities:**
- Properly size images: Should be resolved ✓
- Serve images in next-gen formats: Should be resolved ✓
- Minify CSS: Should be resolved ✓
- Reduce unused CSS: Will be resolved with FA Kit
- Remove render-blocking resources: Should be resolved ✓

### 3. WebPageTest.org

More detailed performance analysis:

**Test Configuration:**
- URL: https://christaylor.codes
- Location: Dulles, Virginia (US East)
- Browser: Chrome
- Connection: Cable (5 Mbps)
- Number of Tests: 3
- Repeat View: First View and Repeat View

**Metrics to Review:**
- First Byte Time: <600ms (target)
- Start Render: <1.5s (target)
- Speed Index: <2.5s (target)
- Fully Loaded: <4s (target)
- Total Page Size: <800 KB (target)
- Requests: <40 (target)

### 4. GTmetrix

Additional performance testing:

**Test URL:** https://gtmetrix.com
**Metrics:**
- GTmetrix Grade: A
- Performance Score: 95%+
- Structure Score: 95%+
- Fully Loaded Time: <3s
- Total Page Size: <800 KB

### 5. Browser Testing

Test on multiple browsers to ensure compatibility:

**Desktop:**
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

**Mobile:**
- Chrome Mobile (Android)
- Safari Mobile (iOS)
- Samsung Internet

**Checks:**
- WebP images display correctly
- Fallback images work on older browsers
- Lazy loading functions properly
- No console errors
- Smooth scrolling and transitions

### 6. Network Throttling

Test on slow connections:

**Chrome DevTools:**
1. F12 → Network tab
2. Throttling dropdown → Slow 3G
3. Reload page
4. Verify acceptable load time
5. Check lazy loading effectiveness

**Target:**
- LCP on Slow 3G: <4s
- Page usable within 3s
- Critical content visible immediately

## Validation Checklist

### WebP Implementation
- [ ] WebP images created for all large JPG/PNG files
- [ ] Picture elements implemented with WebP + fallback
- [ ] JavaScript WebP detection working
- [ ] Hero backgrounds load WebP in supported browsers
- [ ] Fallback images load in unsupported browsers
- [ ] File size reduction confirmed (check Network tab)

### Lazy Loading
- [ ] loading="lazy" attribute on all below-fold images
- [ ] Width/height attributes prevent layout shift
- [ ] Images load as user scrolls
- [ ] Intersection Observer fallback working
- [ ] No broken images or loading errors
- [ ] CLS score improved (target: <0.1)

### CSS Minification
- [ ] styles.css is minified (no whitespace/comments)
- [ ] File size reduced by ~30%
- [ ] No visual regressions
- [ ] Source maps disabled in production

### Font Awesome (After Kit Implementation)
- [ ] Font Awesome Kit created and configured
- [ ] All icons display correctly across site
- [ ] Kit file size ~150-200 KB (vs 1.5 MB)
- [ ] No missing icons
- [ ] No console errors

### Performance Metrics
- [ ] PageSpeed Desktop score: 90+
- [ ] PageSpeed Mobile score: 85+
- [ ] LCP < 2.5s
- [ ] FCP < 1.8s
- [ ] CLS < 0.1
- [ ] Total page weight < 800 KB
- [ ] Time to Interactive < 3.5s

## Monitoring and Continuous Improvement

### Monthly Performance Audits

**Schedule:** First Monday of each month

**Tasks:**
1. Run PageSpeed Insights on all major pages
2. Run WebPageTest on homepage
3. Check Core Web Vitals in Google Search Console
4. Review image sizes (compress new images)
5. Audit Font Awesome Kit (remove unused icons)
6. Check for new optimization opportunities

### Performance Budget

Set and enforce performance budgets:

**Page Weight Budget:**
- Homepage: <800 KB
- Blog Index: <600 KB
- Blog Post: <700 KB
- Project Page: <650 KB
- About Page: <600 KB

**Timing Budget:**
- LCP: <2.5s
- FCP: <1.8s
- Time to Interactive: <3.5s
- Total Load Time: <4s

**Resource Budget:**
- CSS: <250 KB
- JavaScript: <100 KB
- Images: <500 KB per page
- Fonts: <150 KB
- Total Requests: <40

### Alerts and Thresholds

**Performance Degradation Indicators:**
- PageSpeed score drops below 85
- LCP increases above 3s
- Page weight exceeds budget by >10%
- User complaints about slow loading

**Action Items When Thresholds Exceeded:**
1. Review recent changes (git log)
2. Check for new large images
3. Audit third-party scripts
4. Run full performance audit
5. Optimize offending resources

## Automated Benchmark Tooling

### Lighthouse CLI Scripts

**Location:** `scripts/benchmark-performance.ps1` and `scripts/compare-benchmarks.ps1`

**Prerequisites:**
- Node.js and npm installed
- Lighthouse CLI installed: `npm install -g lighthouse`

### Running Benchmarks

**Baseline Benchmark (before changes):**
```powershell
# Start local server
.\build.ps1

# Run benchmark (saves to benchmarks/ directory)
.\scripts\benchmark-performance.ps1 -Target local -Device desktop -HTMLReport -OpenReport
```

**Production Benchmark (after deployment):**
```powershell
# Test live site
.\scripts\benchmark-performance.ps1 -Target production -Device desktop -HTMLReport
```

**Script Options:**
- `-Target`: `local` (localhost:4000) or `production` (christaylor.codes)
- `-Device`: `desktop` or `mobile`
- `-HTMLReport`: Generate HTML report in addition to JSON
- `-OpenReport`: Automatically open HTML report in browser
- `-OutputDir`: Custom output directory (default: `benchmarks/`)

**Output:**
- JSON results: `benchmarks/lighthouse_[target]_[device]_[timestamp].json`
- HTML report: `benchmarks/lighthouse_[target]_[device]_[timestamp].html` (if requested)
- Displays scores and Core Web Vitals in terminal

### Comparing Results

**Compare two benchmark runs:**
```powershell
.\scripts\compare-benchmarks.ps1 -Baseline 'benchmarks/lighthouse_local_desktop_2024-11-24_10-00-00.json' -Current 'benchmarks/lighthouse_local_desktop_2024-11-24_11-30-00.json'
```

**Comparison Output:**
- Performance score changes (+/- points)
- Core Web Vitals improvements (FCP, LCP, TBT, CLS, Speed Index)
- Summary of total improvements vs. regressions
- Color-coded results (green = improved, red = regressed)

### Recommended Workflow

**Before making performance changes:**
1. Run baseline benchmark: `.\scripts\benchmark-performance.ps1 -Target local -Device desktop -HTMLReport`
2. Note the baseline file path
3. Make your optimizations
4. Rebuild: `.\build.ps1 -Mode clean && .\build.ps1 -Mode build`
5. Run new benchmark: `.\scripts\benchmark-performance.ps1 -Target local -Device desktop -HTMLReport`
6. Compare results: `.\scripts\compare-benchmarks.ps1 -Baseline [baseline-path] -Current [new-path]`

**After deploying to production:**
1. Wait 5 minutes for deployment
2. Run production benchmark: `.\scripts\benchmark-performance.ps1 -Target production -Device desktop`
3. Compare with local results to verify improvements carried over

## Tools and Resources

**Performance Testing:**
- PageSpeed Insights: https://pagespeed.web.dev
- WebPageTest: https://www.webpagetest.org
- GTmetrix: https://gtmetrix.com
- Lighthouse (Chrome DevTools): Built-in

**Image Optimization:**
- Squoosh: https://squoosh.app
- TinyPNG: https://tinypng.com
- ImageOptim: https://imageoptim.com

**Performance Monitoring:**
- Google Search Console (Core Web Vitals report)
- Cloudflare Analytics (if using Cloudflare)
- Real User Monitoring (RUM) tools

**Documentation:**
- Web.dev Performance: https://web.dev/performance
- MDN Web Performance: https://developer.mozilla.org/en-US/docs/Web/Performance
- Core Web Vitals: https://web.dev/vitals

## Troubleshooting

### WebP Images Not Loading

**Symptoms:** JPG/PNG loads instead of WebP in Chrome/Firefox

**Solutions:**
1. Check WebP files exist in assets/images
2. Verify picture element syntax
3. Check browser console for errors
4. Test WebP detection script (check HTML class)
5. Verify server MIME type for .webp (should be image/webp)

### Lazy Loading Not Working

**Symptoms:** All images load immediately

**Solutions:**
1. Verify loading="lazy" attribute present
2. Check width/height attributes set
3. Ensure images are below fold
4. Test in different browsers
5. Check JavaScript console for errors

### CSS Not Minified

**Symptoms:** styles.css has whitespace and comments

**Solutions:**
1. Check _config.yml has `sass: style: compressed`
2. Run `.\build.ps1 -Mode clean` to clear cache
3. Rebuild with `.\build.ps1 -Mode build`
4. Check _site/assets/css/styles.css output

### Performance Score Not Improving

**Symptoms:** PageSpeed score unchanged after optimizations

**Solutions:**
1. Clear browser cache
2. Use incognito/private window
3. Wait 5 minutes for CDN cache to update
4. Check all optimizations deployed
5. Verify WebP actually loading (Network tab)
6. Check Font Awesome Kit implemented (not full library)

---

**Last Updated:** 2025-11-04
**Sprint:** Sprint 1 - Performance & Image Optimization
**Next Review:** After implementing Font Awesome Kit
