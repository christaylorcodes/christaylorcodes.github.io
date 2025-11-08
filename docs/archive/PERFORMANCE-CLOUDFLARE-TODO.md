# Cloudflare Performance Optimization Tasks

These items are noted from PageSpeed Insights analysis but considered "working as intended" for the current infrastructure setup. Review and optimize as a separate task when focusing on Cloudflare configuration.

## Cache Lifetime Optimization (Est. savings: 8 KiB)

**Issue:** Short cache TTLs (47m 53s) on static resources

**Affected Resources:**
- `rocket-loader.min.js` (4 KiB)
- `email-decode.min.js` (1 KiB)
- Cloudflare utilities (7 KiB)

**Recommended Actions:**

### 1. Cloudflare Page Rules
Set longer cache TTLs for static assets:
- Pattern: `christaylor.codes/assets/*`
- Cache Level: Cache Everything
- Edge Cache TTL: 1 month
- Browser Cache TTL: 1 month

### 2. Review Cloudflare Rocket Loader
Rocket Loader auto-minifies and defers JavaScript, but can add overhead:
- Current status: Enabled (default)
- Consider testing with it disabled to measure impact
- Location: Cloudflare Dashboard → Speed → Optimization → Rocket Loader

**Steps to test:**
1. Disable Rocket Loader in Cloudflare dashboard
2. Run PageSpeed Insights again
3. Compare LCP and render blocking times
4. Re-enable if performance degrades

### 3. Optimize Cloudflare Caching
Review current cache settings:
- Cloudflare Dashboard → Caching → Configuration
- Ensure "Cache Everything" is enabled for static assets
- Review browser cache TTL settings
- Consider implementing Cache-Control headers in Jekyll if needed

## Additional Cloudflare Optimizations to Consider

### Auto Minify Settings
Current status: Unknown
- Review HTML, CSS, JS minification settings
- Cloudflare Dashboard → Speed → Optimization → Auto Minify

### Brotli Compression
Current status: Likely enabled
- Verify Brotli is enabled for better compression than gzip
- Cloudflare Dashboard → Speed → Optimization → Brotli

### HTTP/3 and QUIC
Current status: Likely enabled
- Verify HTTP/3 support is enabled for faster connections
- Cloudflare Dashboard → Network

### Argo Smart Routing (Paid Feature)
Consider if budget allows:
- Routes traffic through Cloudflare's fastest paths
- Can reduce TTFB significantly
- Pricing: $5/month + $0.10/GB

## Performance Monitoring

After implementing changes:
1. Run Google PageSpeed Insights again
2. Compare before/after metrics
3. Monitor real user metrics via Cloudflare Analytics
4. Test from multiple geographic locations

## Current Performance Baseline

**Before Optimizations:**
- Render blocking CSS: 1,450ms (16.2 KiB transfer)
- LCP: 3,530ms
- Cache lifetime warnings: 8 KiB affected

**After Critical CSS Implementation:**
- Critical CSS inlined: 4.7 KB
- Full stylesheet deferred via preload
- Expected improvement: 30-50% reduction in render blocking time

**Cloudflare-Related Items (Not Yet Addressed):**
- Cache lifetimes: Still short (47m 53s)
- Rocket Loader: Still enabled (may add overhead)
- Static asset caching: Needs page rules

## Notes

- Cloudflare is essential to infrastructure plan for CDN and security
- These optimizations are incremental improvements, not critical issues
- Focus on Cloudflare configuration separately from site code changes
- Test each change individually to measure impact

---

**Created:** 2025-11-08
**Last Updated:** 2025-11-08
**Status:** Pending review
