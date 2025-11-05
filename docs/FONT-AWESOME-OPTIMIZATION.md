# Font Awesome Optimization Guide

This document provides a complete inventory of Font Awesome icons used on the site and optimization strategies to reduce load time.

## Current Situation

**Problem:** Loading the full Font Awesome library (6.7.1)
- **File Size:** ~1.5 MB (all.min.css includes 2,000+ icons)
- **Icons Used:** ~45 unique icons (2.25% of library)
- **Performance Impact:** Significant - unnecessary 1.4 MB transferred

**Solution:** Load only the icons we actually use
- **Estimated Savings:** ~1.3 MB (87% reduction)
- **Methods:** Font Awesome Kits, Custom Subset, or Icon Switching

## Icon Inventory

### Solid Icons (fas) - 32 icons

Core icons used throughout the site:

```
fa-arrow-left         (navigation, back buttons)
fa-arrow-right        (navigation, forward buttons)
fa-blog              (about page stats)
fa-book              (project documentation links)
fa-briefcase         (about page - role)
fa-building          (about page - company)
fa-calendar-alt      (about page stats)
fa-chevron-down      (dropdowns)
fa-chevron-left      (pagination)
fa-chevron-right     (pagination)
fa-chevron-up        (back to top button)
fa-code              (about page stats, templates)
fa-cogs              (homepage features)
fa-download          (project stats, buttons)
fa-envelope          (contact page, footer)
fa-external-link-alt (external links)
fa-file-alt          (blog icons, search results)
fa-folder            (post categories)
fa-inbox             (empty blog state)
fa-infinity          (about page stats)
fa-info-circle       (about page quick facts)
fa-map-marker-alt    (about page - location)
fa-medal             (homepage podium)
fa-mountain          (about page - personal)
fa-network-wired     (homepage features, projects)
fa-project-diagram   (homepage features)
fa-robot             (homepage features)
fa-rss               (footer - RSS feed)
fa-search            (search functionality, no results)
fa-star              (project stars/ratings)
fa-terminal          (project links, about page skills)
fa-times             (close buttons, blog search clear)
fa-trophy            (homepage podium first place)
fa-user              (about page heading)
```

### Regular Icons (far) - 5 icons

Outline/regular weight icons:

```
fa-calendar          (post metadata - dates)
fa-clock             (reading time estimates)
fa-copy              (copy code button)
fa-folder            (post categories in layouts)
fa-user              (post metadata - author)
```

### Brand Icons (fab) - 6 icons

Social media and platform icons:

```
fa-facebook          (social sharing)
fa-github            (footer, project links, contact)
fa-linkedin          (footer, contact, social sharing)
fa-twitter           (social sharing)
fa-x-twitter         (footer, contact - X/Twitter)
```

### Project-Specific Icons (Dynamic) - Variable

Project icons defined in front matter:

```
fa-box-open          (Initialize-PSGallery project)
fa-cloud             (AzureKeyVaultHelper project)
fa-gamepad           (Screeps project)
fa-laptop            (VeeamAgent project)
fa-plug              (ConnectWise API projects)
fa-server            (VeeamSPC project)
fa-shield-virus      (WebrootUnity project)
```

**Total Unique Icons:** ~45-50 icons

## Optimization Methods

### Option 1: Font Awesome Kits (Recommended)

**Pros:**
- Free tier available
- Automatically generates optimized subset
- CDN hosted (fast, cached)
- Easy to maintain (add icons via web interface)
- Supports versioning and rollback

**Cons:**
- Requires Font Awesome account
- Dependency on external service

**Implementation:**

1. Create free Font Awesome account: https://fontawesome.com/start
2. Create a new Kit
3. Add all icons from inventory above
4. Get Kit embed code
5. Replace current Font Awesome link in `_layouts/default.html`

```html
<!-- Replace this -->
<link rel="preload" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css" as="style" onload="this.onload=null;this.rel='stylesheet'">

<!-- With your Kit code -->
<script src="https://kit.fontawesome.com/YOUR_KIT_ID.js" crossorigin="anonymous"></script>
```

### Option 2: Custom Subset Builder

**Pros:**
- Complete control
- Self-hosted or CDN
- No external dependencies
- Maximum performance

**Cons:**
- Requires build tool
- Manual maintenance
- More complex setup

**Tools:**
- **FontAwesome Subsetter** (npm package): https://www.npmjs.com/package/@fal-works/fa-subsetter
- **IcoMoon** (web tool): https://icomoon.io/app

**Example using fa-subsetter:**

```bash
npm install --global @fal-works/fa-subsetter

# Create subset
fa-subsetter create-subset \
  --input node_modules/@fortawesome/fontawesome-free \
  --output assets/fonts/fontawesome-subset \
  --icons arrow-left,arrow-right,blog,calendar,code,download,envelope,github,linkedin # ...etc
```

### Option 3: SVG Icons (Inline)

**Pros:**
- No external CSS/fonts required
- Can be styled with CSS
- Perfect for few icons
- Smallest possible size

**Cons:**
- Requires changing all icon references
- More verbose HTML
- No caching benefit across pages

**Implementation:**

Download SVG files from Font Awesome and inline them:

```html
<!-- Instead of -->
<i class="fas fa-github"></i>

<!-- Use -->
<svg class="icon" viewBox="0 0 496 512">
    <path d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6..."/>
</svg>
```

### Option 4: Switch to System Icons

**Pros:**
- No external dependency
- Fastest load time
- Native feel

**Cons:**
- Limited icon selection
- Requires icon font or library
- May need redesign

**Options:**
- **Feather Icons:** https://feathericons.com/ (286 icons, 14KB)
- **Tabler Icons:** https://tabler-icons.io/ (4,000+ icons, customizable)
- **Bootstrap Icons:** https://icons.getbootstrap.com/ (1,800+ icons)

## Recommended Implementation Plan

**Phase 1: Immediate (Sprint 1)**
1. Create Font Awesome Kit account
2. Add all icons from inventory above
3. Update `_layouts/default.html` with Kit embed code
4. Test site for missing icons
5. Deploy and measure improvement

**Expected Results:**
- Load time reduction: ~800ms-1.2s (depending on connection)
- File size reduction: ~1.3 MB
- PageSpeed score increase: +5-10 points

**Phase 2: Future Optimization**
1. Audit icon usage after phase 1
2. Remove unused icons from Kit
3. Consider switching to SVG sprites for most-used icons
4. Implement icon lazy loading for below-fold content

## Implementation Steps (Font Awesome Kit)

### Step 1: Create Account and Kit

1. Go to https://fontawesome.com/start
2. Sign up for free account
3. Click "Create a Kit"
4. Name it "christaylor.codes"
5. Note your Kit ID (format: abc123def4)

### Step 2: Add Icons to Kit

In Kit settings, add these icons:

**Solid (fas):**
arrow-left, arrow-right, blog, book, briefcase, building, calendar-alt, chevron-down, chevron-left, chevron-right, chevron-up, code, cogs, download, envelope, external-link-alt, file-alt, folder, inbox, infinity, info-circle, map-marker-alt, medal, mountain, network-wired, project-diagram, robot, rss, search, star, terminal, times, trophy, user

**Regular (far):**
calendar, clock, copy, folder, user

**Brands (fab):**
facebook, github, linkedin, twitter, x-twitter

**Project Icons:**
box-open, cloud, gamepad, laptop, plug, server, shield-virus

### Step 3: Update default.html

```html
<!-- In _layouts/default.html, replace Font Awesome section -->

<!-- OLD CODE - Remove this:
<link rel="preconnect" href="https://cdnjs.cloudflare.com">
<link rel="preload" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css"></noscript>
-->

<!-- NEW CODE - Add this: -->
<script src="https://kit.fontawesome.com/YOUR_KIT_ID.js" crossorigin="anonymous"></script>
```

### Step 4: Test

```bash
# Build locally
.\build.ps1

# Visit http://localhost:4000
# Check all pages for icon display
# Verify no broken icons
```

### Step 5: Deploy

```bash
git add _layouts/default.html
git commit -m "Optimize Font Awesome with custom Kit (reduces load by ~1.3MB)"
git push origin main
```

## Verification Checklist

After implementing Font Awesome optimization:

- [ ] All icons display correctly on homepage
- [ ] Navigation icons work (hamburger menu)
- [ ] Blog page icons display (calendar, user, clock)
- [ ] Project page icons display (tech stack icons)
- [ ] About page icons display (stats, skills)
- [ ] Contact page icons display (social media)
- [ ] Footer icons display (GitHub, LinkedIn, RSS)
- [ ] Search icons display correctly
- [ ] Filter dropdown chevrons display
- [ ] Copy code button icon displays
- [ ] Back to top button icon displays
- [ ] Social sharing icons display on blog posts
- [ ] No console errors related to Font Awesome
- [ ] PageSpeed Insights shows improvement

## Performance Impact

**Before Optimization:**
- Font Awesome CSS: 1.5 MB
- Icons needed: 45 (~2.25% of library)
- Wasted bandwidth: ~1.4 MB per visitor

**After Optimization (Kit):**
- Font Awesome Kit: ~150-200 KB
- Icons needed: 45 (100% of payload)
- Savings: ~1.3 MB per visitor (87% reduction)

**Estimated PageSpeed Improvements:**
- Desktop: +8-12 points
- Mobile: +10-15 points
- First Contentful Paint: -400ms to -800ms
- Largest Contentful Paint: -200ms to -400ms

## Maintenance

**Adding New Icons:**
1. Log into Font Awesome Kit
2. Search for icon
3. Add to kit
4. Changes deploy automatically (within minutes)
5. No code changes required

**Removing Unused Icons:**
1. Audit icon usage quarterly
2. Remove from Kit if no longer used
3. Kit size reduces automatically

## Resources

- **Font Awesome Kits:** https://fontawesome.com/kits
- **Icon Search:** https://fontawesome.com/search
- **Kit Documentation:** https://fontawesome.com/docs/web/setup/use-kit
- **Version 6 Upgrade Guide:** https://fontawesome.com/docs/web/setup/upgrade/upgrade-from-v5

---

**Last Updated:** 2025-11-04
**Estimated Savings:** 1.3 MB (87% file size reduction)
**Priority:** HIGH - Significant performance improvement
