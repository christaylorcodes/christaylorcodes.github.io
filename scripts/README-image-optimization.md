# Image Optimization Scripts

Modular PowerShell scripts for optimizing website images to meet performance standards defined in [CLAUDE.md](../CLAUDE.md).

## Performance Standards

All scripts validate against these targets from CLAUDE.md:

- **Hero images:** 1920x1080px, <500KB
- **Profile photos:** 400x400px, <100KB
- **Screenshots:** 800x600 or 1920x1080, <300KB
- **Social sharing:** 1200x630px, <500KB

## Scripts Overview

### 1. optimize-images.ps1

**Purpose:** Convert images to WebP format with dimension extraction and performance validation.

**Features:**
- Converts JPG/PNG to WebP
- Detects image type automatically (Hero, Profile, Screenshot, Social)
- Extracts and reports dimensions
- Validates file sizes against performance targets
- Special handling for hero backgrounds (1920x1080 at quality 40)
- Exports metadata JSON for other scripts

**Usage:**
```powershell
# Convert large images (>50KB)
.\scripts\optimize-images.ps1

# Convert all images
.\scripts\optimize-images.ps1 -ConvertAll

# Custom quality settings
.\scripts\optimize-images.ps1 -Quality 80 -BackgroundQuality 50
```

**Output:**
- Optimized WebP images in `assets/images/`
- `assets/images/image-metadata.json` - Metadata file with dimensions and compliance info

**Requirements:**
- ImageMagick (https://imagemagick.org/script/download.php)
- cwebp tool (https://developers.google.com/speed/webp/download)

### 2. update-image-references.ps1

**Purpose:** Update HTML and Markdown files to use WebP images with proper dimensions and loading attributes.

**Features:**
- Changes image extensions from .jpg/.png to .webp
- Adds width and height attributes (prevents CLS)
- Optionally adds loading="eager/lazy" attributes
- Optionally adds fetchpriority="high" for hero/LCP images
- Supports both `<img>` tags and Markdown syntax

**Usage:**
```powershell
# Preview changes (no modifications)
.\scripts\update-image-references.ps1 -WhatIf

# Update with dimensions only
.\scripts\update-image-references.ps1

# Update with full performance attributes
.\scripts\update-image-references.ps1 -AddLoadingAttributes -AddFetchPriority
```

**What it updates:**
- `*.html` files (img tags)
- `*.md` files (img tags and Markdown syntax)
- Adds/updates width/height attributes
- Adds loading and fetchpriority attributes

### 3. generate-responsive-sizes.ps1

**Purpose:** Create multiple size variants for responsive srcset support.

**Features:**
- Generates 640w, 1280w, 1920w variants for Hero images
- Generates 400w, 800w, 1600w variants for Screenshots
- Generates 200w, 400w variants for Profile photos
- Generates 600w, 1200w variants for Social images
- Preserves aspect ratios
- Skips sizes larger than original image

**Usage:**
```powershell
# Generate responsive sizes for all image types
.\scripts\generate-responsive-sizes.ps1

# Generate only for specific types
.\scripts\generate-responsive-sizes.ps1 -ImageTypes Hero,Screenshot

# Custom quality
.\scripts\generate-responsive-sizes.ps1 -Quality 80
```

**Output:**
- Multiple size variants: `image-name-640w.webp`, `image-name-1280w.webp`, etc.

**Note:** After generating, manually update HTML to use srcset:
```html
<img src="hero-1920w.webp"
     srcset="hero-640w.webp 640w, hero-1280w.webp 1280w, hero-1920w.webp 1920w"
     sizes="(max-width: 640px) 640px, (max-width: 1280px) 1280px, 1920px"
     width="1920" height="1080"
     loading="eager"
     fetchpriority="high"
     alt="Hero background">
```

### 4. validate-image-performance.ps1

**Purpose:** Comprehensive validation of all images against performance standards.

**Features:**
- Checks file formats (prefers WebP)
- Validates file sizes against targets
- Validates dimensions match expectations
- Scans HTML/MD for missing width/height attributes
- Checks for missing loading attributes
- Generates detailed HTML compliance report

**Usage:**
```powershell
# Validate and show results
.\scripts\validate-image-performance.ps1

# Generate HTML report
.\scripts\validate-image-performance.ps1 -GenerateReport

# Fail on warnings (for CI/CD)
.\scripts\validate-image-performance.ps1 -FailOnWarnings
```

**Output:**
- Console report with errors and warnings
- Optional: `image-performance-report.html` - Detailed compliance report

**Use in CI/CD:**
```yaml
- name: Validate image performance
  run: .\scripts\validate-image-performance.ps1 -FailOnWarnings
```

## Complete Workflow

### Integrated Build Command

The easiest way to run the complete optimization workflow:

```powershell
.\build.ps1 -Mode optimize-images
```

This runs all four scripts in sequence:
1. Optimize images to WebP
2. Update references with dimensions
3. Generate responsive sizes
4. Validate performance compliance

### Manual Step-by-Step

If you prefer to run scripts individually:

```powershell
# Step 1: Optimize images
.\scripts\optimize-images.ps1 -ConvertAll

# Step 2: Update references
.\scripts\update-image-references.ps1 -AddLoadingAttributes -AddFetchPriority

# Step 3: Generate responsive sizes (optional)
.\scripts\generate-responsive-sizes.ps1 -ImageTypes Hero,Screenshot

# Step 4: Validate compliance
.\scripts\validate-image-performance.ps1 -GenerateReport
```

### Quick Validation

To quickly check image compliance without making changes:

```powershell
.\build.ps1 -Mode validate-images
```

## Common Scenarios

### Adding New Images

When adding new images to the site:

1. Place original images in `assets/images/`
2. Run optimization workflow:
   ```powershell
   .\build.ps1 -Mode optimize-images
   ```
3. Review changes in git
4. Test locally: `.\build.ps1`
5. Commit and deploy

### Fixing Non-Compliant Images

If validation shows warnings:

1. Check the report: `image-performance-report.html`
2. For size issues: Reduce quality or dimensions in source
3. For missing dimensions: Run `update-image-references.ps1`
4. For wrong format: Ensure images are WebP
5. Re-validate: `.\build.ps1 -Mode validate-images`

### Pre-Deployment Check

Before deploying to production:

```powershell
# Validate all images
.\build.ps1 -Mode validate-images

# Run performance benchmarks
.\build.ps1 -Mode benchmark
```

## Performance Impact

Following this workflow ensures:

- **CLS <0.1:** Width/height attributes prevent layout shift
- **LCP <2.5s:** WebP format + preloading + proper dimensions
- **Faster loads:** WebP typically 25-35% smaller than JPG/PNG
- **Better UX:** Lazy loading below the fold saves bandwidth
- **SEO benefits:** Google rewards fast, stable page loads

## Troubleshooting

**ImageMagick not found:**
- Install from: https://imagemagick.org/script/download.php
- Or via Chocolatey: `choco install imagemagick`

**cwebp not found:**
- Install from: https://developers.google.com/speed/webp/download
- Or via Chocolatey: `choco install webp`

**Metadata file not found:**
- Run `optimize-images.ps1` first to generate metadata
- Metadata is required by other scripts

**References not updating:**
- Ensure original filename matches (case-sensitive)
- Check that image metadata was generated
- Use `-WhatIf` to preview changes first

**Responsive sizes not generating:**
- Ensure source image exists
- Check that target width is smaller than original
- Verify ImageMagick and cwebp are installed

## Integration with CI/CD

Add to GitHub Actions workflow:

```yaml
- name: Validate image performance
  run: |
    .\scripts\validate-image-performance.ps1 -FailOnWarnings
  shell: pwsh

- name: Check for non-compliant images
  if: failure()
  run: |
    Write-Host "Image performance validation failed!"
    Write-Host "Run: .\build.ps1 -Mode optimize-images"
  shell: pwsh
```

## Best Practices

1. **Always run optimization** before committing new images
2. **Test locally** after optimization to verify images display correctly
3. **Review git changes** to ensure references were updated correctly
4. **Run validation** before deploying to production
5. **Keep originals** in a separate backup location (not in repo)
6. **Document custom sizes** if deviating from standards
7. **Update CLAUDE.md** if performance targets change

## Related Documentation

- [CLAUDE.md](../CLAUDE.md) - Complete project documentation with performance standards
- [README.md](../README.md) - Project setup and deployment
- [Core Performance Principles](../CLAUDE.md#core-performance-principles) - Detailed performance guidelines
- [Image Optimization Section](../CLAUDE.md#3-image-optimization) - Image specifications

## Script Dependencies

```
optimize-images.ps1
  ├── ImageMagick (identify, resize)
  ├── cwebp (WebP conversion)
  └── Outputs: image-metadata.json

update-image-references.ps1
  ├── Requires: image-metadata.json
  └── Updates: *.html, *.md files

generate-responsive-sizes.ps1
  ├── Requires: image-metadata.json
  ├── ImageMagick (resize)
  ├── cwebp (WebP conversion)
  └── Outputs: *-{width}w.webp files

validate-image-performance.ps1
  ├── ImageMagick (identify)
  └── Outputs: image-performance-report.html (optional)
```

## Future Enhancements

Potential improvements for future versions:

- Automatic srcset HTML generation
- AVIF format support (next-gen image format)
- Automatic art direction for responsive images
- CDN integration for image delivery
- Automated image compression testing
- Integration with Lighthouse CI for continuous performance monitoring

---

**Last Updated:** 2025-11-24
**Maintained By:** Chris Taylor
**Questions:** See [CLAUDE.md](../CLAUDE.md) or open an issue
