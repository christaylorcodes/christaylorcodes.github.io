# Performance Testing & Regression Detection

This document explains how to run performance tests and prevent regressions.

## Quick Start

### Local Testing

```powershell
# 1. Start the development server in one terminal
.\build.ps1

# 2. Run benchmarks in another terminal
.\build.ps1 -Mode benchmark
```

This will test the homepage and about page, checking for:
- Performance score ≥ 90%
- CLS (Cumulative Layout Shift) ≤ 0.1
- Other Core Web Vitals thresholds

### CI/CD Automated Testing

Performance tests run automatically on every push to the `dev` branch via GitHub Actions.

**Workflow:** `.github/workflows/dev-build.yml`

**Tests Run:**
- Lighthouse CI on 5 pages (home, about, blog, projects, contact)
- Performance regression checks
- CLS validation (fails build if > 0.1)
- Accessibility checks
- HTML validation

## Performance Thresholds

### Enforced Thresholds (`.lighthouserc.json`)

**Core Web Vitals:**
- **CLS (Cumulative Layout Shift):** ≤ 0.1 (ERROR - fails build)
- **LCP (Largest Contentful Paint):** ≤ 2500ms (WARN)
- **FCP (First Contentful Paint):** ≤ 1800ms (WARN)
- **TBT (Total Blocking Time):** ≤ 200ms (WARN)
- **Speed Index:** ≤ 3400ms (WARN)

**Category Scores:**
- **Performance:** ≥ 90% (WARN)
- **Accessibility:** ≥ 85% (WARN)
- **Best Practices:** ≥ 85% (WARN)
- **SEO:** ≥ 90% (WARN)

**Critical Accessibility (ERROR - fails build):**
- Unsized images (all images must have width/height)
- ARIA required children
- Document title
- HTML lang attribute
- Image alt attributes
- Meta descriptions

## Current Performance Baseline

As of 2025-11-24, after CLS optimizations:

**Homepage:**
- Performance: 99-100/100 ✅
- CLS: 0.005 ✅
- LCP: 698-952ms ✅
- FCP: 358-543ms ✅

**About Page:**
- Performance: 100/100 ✅
- CLS: 0.016 ✅
- LCP: 422ms ✅
- FCP: 361ms ✅

## Common Issues & Fixes

### CLS Regression

**Symptoms:**
- Benchmark fails with "CLS exceeds 0.1 threshold"
- Elements shifting during page load
- Layout "jumps" when images or fonts load

**Common Causes:**
1. **Images without dimensions**
   - Fix: Add explicit `width` and `height` attributes to all `<img>` tags

2. **Animations starting with opacity: 0**
   - Fix: Elements must be visible by default; use JS to trigger animations after load

3. **Font loading causing shift**
   - Fix: Use `font-display: swap` and font metric overrides in critical CSS

4. **Dynamic content loading**
   - Fix: Reserve space with `min-height` on containers

### Performance Regression

**Symptoms:**
- Performance score drops below 90%
- Slower page load times

**Common Causes:**
1. **Large unoptimized images**
   - Fix: Compress images, use WebP format, add `loading="lazy"` for below-fold images

2. **Render-blocking resources**
   - Fix: Defer non-critical CSS/JS, inline critical CSS

3. **Large JavaScript bundles**
   - Fix: Code splitting, remove unused dependencies

## Running Benchmarks

### Full Benchmark Suite

```powershell
# Test local site (requires server running)
.\build.ps1 -Mode benchmark

# Test production site
.\scripts\benchmark-performance.ps1 -Target production -Device desktop -HTMLReport
```

### Single Page Test

```powershell
# Homepage
.\scripts\benchmark-performance.ps1 -Target local -Device desktop

# About page
lighthouse http://localhost:4000/about/ \
  --output=json \
  --output-path=benchmarks/about.json \
  --preset=desktop
```

### Mobile Testing

```powershell
# Test mobile performance
.\scripts\benchmark-performance.ps1 -Target local -Device mobile -HTMLReport
```

## CI/CD Integration

### GitHub Actions Workflow

Performance tests run automatically on every dev branch push:

1. **Build site** with Jekyll
2. **Start local server** on port 4000
3. **Run Lighthouse CI** on all pages
4. **Upload results** as artifacts (30-day retention)
5. **Fail build** if thresholds are not met

**View Results:**
1. Go to GitHub Actions tab
2. Click on the workflow run
3. Download "lighthouse-results" artifact
4. Open HTML reports in browser

### Promotion to Production

The `promote-to-main.ps1` script includes a build verification step. To add benchmark checks:

```powershell
# Option 1: Manual benchmark before promotion
.\build.ps1 -Mode benchmark
.\promote-to-main.ps1

# Option 2: Add -RunBenchmarks flag (future enhancement)
.\promote-to-main.ps1 -RunBenchmarks
```

## Benchmark Output Files

All benchmark results are saved to `benchmarks/` directory:

```
benchmarks/
├── lighthouse_local_desktop_2025-11-24_21-57-34.json
├── lighthouse_local_desktop_2025-11-24_21-57-34.report.html
├── lighthouse_about_benchmark.json
└── lighthouse_production_mobile_2025-11-24.json
```

**File Retention:**
- Local: Git-ignored, retained until manual deletion
- CI/CD: 30-day artifact retention on GitHub

## Best Practices

1. **Run benchmarks before committing** major CSS/JS changes
2. **Test both desktop and mobile** for responsive performance
3. **Review HTML reports** for detailed optimization recommendations
4. **Monitor trends** over time to catch gradual regressions
5. **Test production** periodically to ensure CDN/caching is optimal

## Troubleshooting

### Benchmark fails but site looks fine

**Issue:** Lighthouse can be variable; run multiple times to confirm

**Solution:**
```powershell
# Run 3 times and average results
.\build.ps1 -Mode benchmark
.\build.ps1 -Mode benchmark
.\build.ps1 -Mode benchmark
```

### Chrome/Edge not found

**Error:** "No Chrome or Edge installation found"

**Solution:** Update Chrome path in `scripts/benchmark-performance.ps1`

### Server timeout

**Error:** "Local server not running"

**Solution:** Start server in separate terminal: `.\build.ps1`

## References

- [Web.dev Core Web Vitals](https://web.dev/vitals/)
- [Lighthouse Scoring](https://web.dev/performance-scoring/)
- [CLS Best Practices](https://web.dev/cls/)
- [CLAUDE.md Performance Principles](../CLAUDE.md#core-performance-principles)

---

**Last Updated:** 2025-11-24
**Baseline Version:** Post-CLS optimization (v1.1)
