# Image Optimization Guide

This guide covers the website image optimization workflow including WebP conversion, lazy loading, and performance best practices.

## Current Image Analysis

**Large Images Requiring Optimization:**
- `hero-background-3.jpg` - **763 KB** (CRITICAL - needs immediate optimization)
- `profile-photo.png` - **174 KB** (should be optimized)
- `hero-background-2.jpg` - **92 KB** (moderate priority)
- `hero-background.jpg` - **62 KB** (acceptable size)

**Small SVG Files:** (2-12 KB each - no optimization needed)

**Total Original Size:** ~1,092 KB (just for large images)
**Expected WebP Size:** ~380-450 KB (65-70% reduction)

## Optimization Workflow

### Option 1: Automated Script (Recommended)

The `optimize-images.ps1` script automates WebP conversion:

```powershell
# Install WebP tools (one-time setup)
choco install webp

# Or download from: https://developers.google.com/speed/webp/download
# Extract to C:\Program Files\libwebp\

# Run optimization
.\optimize-images.ps1 -Quality 85

# Convert all images (including smaller ones)
.\optimize-images.ps1 -Quality 85 -ConvertAll
```

### Option 2: Manual Optimization

If automated tools aren't available, use online services:

**Recommended Tools:**
1. **Squoosh** (https://squoosh.app) - Google's image optimizer
   - Upload image
   - Select WebP format
   - Quality: 85
   - Download optimized version

2. **TinyPNG** (https://tinypng.com) - PNG/JPG compression
   - Upload original image
   - Download compressed version

3. **CloudConvert** (https://cloudconvert.com/jpg-to-webp) - Format conversion
   - Convert JPG/PNG to WebP
   - Quality: 85%

### Option 3: ImageMagick

If ImageMagick is installed:

```powershell
# Convert single image
magick convert assets\images\hero-background-3.jpg -quality 85 assets\images\hero-background-3.webp

# Batch convert
Get-ChildItem assets\images -Filter *.jpg | ForEach-Object {
    $webp = $_.FullName -replace '\.jpg$', '.webp'
    magick convert $_.FullName -quality 85 $webp
}
```

## WebP Implementation with Fallbacks

### HTML Picture Element

Use `<picture>` element for WebP with fallbacks:

```html
<picture>
    <source srcset="/assets/images/hero-background.webp" type="image/webp">
    <source srcset="/assets/images/hero-background.jpg" type="image/jpeg">
    <img src="/assets/images/hero-background.jpg" alt="Description" loading="lazy">
</picture>
```

### CSS Background Images

For CSS background images, use feature detection:

```css
/* Default JPG */
.hero-background {
    background-image: url('/assets/images/hero-background.jpg');
}

/* WebP for supporting browsers */
.webp .hero-background {
    background-image: url('/assets/images/hero-background.webp');
}
```

Add WebP detection script to `<head>`:

```javascript
// Detect WebP support
(function() {
    var webp = new Image();
    webp.onload = webp.onerror = function() {
        if (webp.height === 2) {
            document.documentElement.classList.add('webp');
        }
    };
    webp.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
})();
```

## Lazy Loading Implementation

### Native Lazy Loading

Add `loading="lazy"` to images (browser support: 90%+):

```html
<img src="/assets/images/profile-photo.webp" alt="Chris Taylor" loading="lazy">
```

### Update Profile Photo (about.html)

```html
<picture>
    <source srcset="{{ '/assets/images/profile-photo.webp' | relative_url }}" type="image/webp">
    <source srcset="{{ '/assets/images/profile-photo.png' | relative_url }}" type="image/png">
    <img src="{{ '/assets/images/profile-photo.png' | relative_url }}"
         alt="Chris Taylor - Network Operations Chief"
         loading="lazy"
         width="400"
         height="400">
</picture>
```

### Update Hero Backgrounds (index.html)

```html
<div class="hero-background webp-bg"
     data-webp="{{ '/assets/images/hero-background.webp' | relative_url }}"
     data-fallback="{{ '/assets/images/hero-background.jpg' | relative_url }}">
</div>
```

JavaScript to apply backgrounds:

```javascript
document.addEventListener('DOMContentLoaded', function() {
    // Check WebP support
    var supportsWebP = document.documentElement.classList.contains('webp');

    // Apply background images
    document.querySelectorAll('.webp-bg').forEach(function(el) {
        var src = supportsWebP ? el.dataset.webp : el.dataset.fallback;
        el.style.backgroundImage = 'url(' + src + ')';
    });
});
```

## Priority Optimization Tasks

### Immediate (Sprint 1)
1. Convert `hero-background-3.jpg` to WebP (763 KB → ~270 KB = 65% reduction)
2. Convert `profile-photo.png` to WebP (174 KB → ~60 KB = 65% reduction)
3. Implement lazy loading on all images
4. Add WebP detection and fallback support

### Short-term
5. Convert remaining hero backgrounds
6. Add width/height attributes to prevent layout shift
7. Test on multiple browsers and devices
8. Monitor Core Web Vitals (LCP, CLS)

## Performance Targets

**Before Optimization:**
- Total image weight: ~1,092 KB
- Largest Contentful Paint (LCP): ~3-4 seconds (estimated)

**After Optimization:**
- Total image weight: ~380-450 KB (60-65% reduction)
- Largest Contentful Paint (LCP): <2.5 seconds (target)
- Cumulative Layout Shift (CLS): <0.1 (target)

## Browser Support

**WebP Support:** 96%+ of browsers
- Chrome/Edge: Full support
- Firefox: Full support
- Safari: iOS 14+, macOS Big Sur+
- Fallback: JPG/PNG for older browsers

**Lazy Loading Support:** 90%+ of browsers
- Chrome: 77+
- Edge: 79+
- Firefox: 75+
- Safari: 15.4+

## Quality Guidelines

**WebP Quality Settings:**
- **85** - Recommended for photographs (imperceptible quality loss)
- **90** - High quality for important images
- **75** - Acceptable for backgrounds and decorative images
- **60** - Low quality for thumbnails only

## Testing Checklist

- [ ] WebP images created for all large files
- [ ] Picture elements implemented with fallbacks
- [ ] Lazy loading added to all images
- [ ] Width/height attributes added to prevent CLS
- [ ] Tested in Chrome (WebP support)
- [ ] Tested in Safari (WebP support)
- [ ] Tested in Firefox (WebP support)
- [ ] Tested with DevTools throttling (3G speed)
- [ ] Verified fallback works (disable WebP)
- [ ] LCP improved (target: <2.5s)
- [ ] CLS minimized (target: <0.1)

## Maintenance

**When Adding New Images:**
1. Optimize before upload (use Squoosh or script)
2. Create WebP version
3. Use picture element with fallback
4. Add loading="lazy"
5. Include width/height attributes
6. Test on mobile and desktop

## Resources

- **WebP Documentation:** https://developers.google.com/speed/webp
- **Squoosh App:** https://squoosh.app
- **Can I Use WebP:** https://caniuse.com/webp
- **Lazy Loading:** https://web.dev/browser-level-image-lazy-loading/
- **Core Web Vitals:** https://web.dev/vitals/

---

**Last Updated:** 2025-11-04
**Estimated Savings:** 60-70% file size reduction (~650-700 KB saved)
