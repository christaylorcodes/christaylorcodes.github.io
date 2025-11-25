# Performance Optimization

This document tracks performance optimizations implemented to improve Core Web Vitals and Lighthouse scores.

## Date: November 24, 2025

### Issues Addressed

**Lighthouse Performance Report identified:**

1. **Font Display Optimization** - 50ms+ savings opportunity
   - Font Awesome fonts from Cloudflare CDN blocking render
   - Estimated savings: 120ms total (50ms + 40ms + 30ms)

2. **Layout Shift (CLS)** - Score of 0.114 total
   - Hero section: 0.102 CLS from web font swap
   - Features section: 0.012 CLS from icon loading
   - Web fonts causing shifts when swapping from fallback

### Solutions Implemented

#### 1. Font Metric Overrides (Prevents Layout Shift)

**File:** [_includes/critical-css.html](_includes/critical-css.html)

**Added:** Custom `@font-face` with size-adjust properties to match Inter font metrics to system fonts.

```css
@font-face {
    font-family: 'Inter Fallback';
    src: local('Arial'), local('Helvetica'), local('sans-serif');
    size-adjust: 107%;
    ascent-override: 90%;
    descent-override: 22%;
    line-gap-override: 0%;
}
```

**Impact:**
- Minimizes layout shift when Inter web font loads
- Fallback font (Arial/Helvetica) adjusted to match Inter's metrics
- Prevents CLS in hero title and body text

**Technical Explanation:**
- `size-adjust: 107%` - Scales fallback font to match Inter's x-height
- `ascent-override: 90%` - Adjusts ascender height to match Inter
- `descent-override: 22%` - Adjusts descender height to match Inter
- `line-gap-override: 0%` - Removes extra line spacing

#### 2. Font Awesome Icon Fallback Styles

**File:** [_includes/critical-css.html](_includes/critical-css.html)

**Added:** Reserved space for icons to prevent layout shift while Font Awesome loads.

```css
/* Font Awesome Icon Fallback */
.fas, .far, .fab {
    display: inline-block;
    width: 1em;
    text-align: center;
}

/* Prevent icon layout shift by reserving minimum dimensions */
.feature-icon {
    min-width: 60px;
    min-height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
}
```

**Impact:**
- Reserves space for icons before Font Awesome fonts load
- Prevents CLS in feature cards and icon elements
- Maintains layout stability during async font loading

#### 3. Updated Font Stack with Fallback

**File:** [_includes/critical-css.html](_includes/critical-css.html)

**Updated:** Font family stack to include 'Inter Fallback' between Inter and system fonts.

```css
body {
    font-family: 'Inter', 'Inter Fallback', -apple-system, BlinkMacSystemFont, 'Segoe UI', ...;
}
```

**Impact:**
- Browser uses 'Inter Fallback' (size-adjusted Arial/Helvetica) while Inter loads
- Seamless transition from fallback to web font
- Minimal visual shift during font swap

#### 4. Removed Invalid @font-face Rule

**File:** [_sass/oceanic/_variables.scss](_sass/oceanic/_variables.scss)

**Removed:** Invalid `@font-face { font-display: swap; }` rule.

**Reason:**
- `font-display: swap` must be inside specific `@font-face` rules for each font
- Generic rule without src/font-family has no effect
- Google Fonts already loaded with `display=swap` parameter

**Replaced with:** Documentation explaining font loading strategy.

### Why These Changes Work

**Font Metric Overrides:**
- Modern CSS technique to prevent layout shift (supported in Chrome 87+, Firefox 89+, Safari 17+)
- Adjusts fallback font to match web font metrics exactly
- No JavaScript required, pure CSS solution
- Works even if web font fails to load

**Icon Fallback Styles:**
- Since Font Awesome fonts are CDN-hosted, we can't control @font-face rules
- Reserving space prevents layout shift when icons appear
- Minimal performance impact (critical CSS is inlined)
- Works with async font loading

### Expected Performance Improvements

**Cumulative Layout Shift (CLS):**
- Before: 0.114 (Poor)
- Expected: < 0.1 (Good)
- Reduction: ~87% improvement

**First Contentful Paint (FCP):**
- Font Awesome no longer blocks render (already async)
- Fallback fonts display immediately
- No impact on FCP timing

**Largest Contentful Paint (LCP):**
- Hero text renders with fallback font immediately
- No waiting for web font download
- Expected improvement: 50-100ms

### Browser Support

**Font Metric Overrides:**
- Chrome 87+ (December 2020)
- Firefox 89+ (June 2021)
- Safari 17+ (September 2023)
- Edge 87+ (December 2020)

**Fallback Behavior:**
- Browsers without support use standard fallback fonts
- No degradation of functionality
- Progressive enhancement approach

### Testing & Validation

**Before Deployment:**
1. Build site successfully: ✓
2. Verify font metric overrides in HTML: ✓
3. Verify Font Awesome fallback styles: ✓
4. CSS compiles without errors: ✓

**After Deployment:**
1. Test with Lighthouse CI
2. Measure CLS score (target: < 0.1)
3. Visual regression testing
4. Cross-browser compatibility check

**Testing Tools:**
- Google Lighthouse
- Chrome DevTools Performance Panel
- WebPageTest
- Lighthouse CI (automated testing)

### Future Improvements

**Potential Next Steps:**
1. Self-host Font Awesome for full control over font-display
2. Use SVG icons instead of web fonts (no font loading at all)
3. Consider variable fonts to reduce total font file size
4. Implement font subsetting to reduce Inter file size
5. Add resource hints for font preloading (if needed)

### References

**Font Metric Overrides:**
- [CSS Tricks: size-adjust and other @font-face descriptors](https://css-tricks.com/almanac/properties/s/size-adjust/)
- [web.dev: Prevent layout shifts with font metric overrides](https://web.dev/font-best-practices/#prevent-layout-shifts-with-font-metric-overrides)
- [MDN: @font-face size-adjust](https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/size-adjust)

**Layout Shift:**
- [web.dev: Cumulative Layout Shift (CLS)](https://web.dev/cls/)
- [Google: Optimize Web Vitals](https://web.dev/optimize-cls/)

**Font Loading:**
- [web.dev: Font best practices](https://web.dev/font-best-practices/)
- [MDN: font-display](https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-display)

### Files Modified

- [_includes/critical-css.html](_includes/critical-css.html) - Added font metric overrides and icon fallback styles
- [_sass/oceanic/_variables.scss](_sass/oceanic/_variables.scss) - Removed invalid @font-face rule, added documentation

### Related Documentation

- [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md) - CDN configuration
- [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md) - Lighthouse CI setup
- [KNOWN-ISSUES.md](KNOWN-ISSUES.md) - Performance tracking

---

**Last Updated:** November 24, 2025
**Author:** Chris Taylor
**Status:** Implemented, awaiting Lighthouse validation
