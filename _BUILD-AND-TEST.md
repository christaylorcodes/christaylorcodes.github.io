# Build and Test Instructions

## Quick Start

Open PowerShell or Command Prompt in the Website directory and run:

```bash
bundle exec jekyll serve --livereload
```

Then visit: **http://localhost:4000**

---

## Complete Build and Test Process

### Step 1: Install Dependencies (if needed)

If you haven't run `bundle install` recently:

```bash
bundle install
```

### Step 2: Build the Site

Choose one of these commands:

**Option A: Build only (no server)**
```bash
bundle exec jekyll build
```
- Compiles SCSS to CSS
- Generates `_site/` directory
- Check `_site/assets/css/styles.css` to see compiled output

**Option B: Build + Serve with live reload (recommended)**
```bash
bundle exec jekyll serve --livereload
```
- Builds the site
- Starts local server at http://localhost:4000
- Auto-refreshes browser when files change
- Press `Ctrl+C` to stop

**Option C: Build + Serve (no live reload)**
```bash
bundle exec jekyll serve
```
- Same as above but manual browser refresh needed

### Step 3: Verify Build Success

**Check Terminal Output:**
Look for successful compilation messages:
```
Regenerating: 1 file(s) changed at 2025-11-04 10:45:12
                    _sass/oceanic/_variables.scss
                    ...done in 0.123 seconds.
```

**No errors should appear like:**
- `Sass Error: File to import not found`
- `Error: Invalid CSS`
- `Liquid Exception`

### Step 4: Inspect Compiled CSS

Check that SCSS compiled correctly:

**Windows:**
```bash
cat _site/assets/css/styles.css | Select-String ":root" -Context 5,5
```

**Look for:**
- CSS custom properties (`:root { --primary-color: #06b6d4; }`)
- All component styles are present
- No `@import` statements (should be resolved)
- File size should be ~30-40KB

### Step 5: Visual Testing Checklist

Open http://localhost:4000 and verify:

#### Homepage
- [ ] Hero section displays with Electric Blue accents
- [ ] Feature cards show and hover effects work (lift + cyan glow)
- [ ] Recent posts section loads (if posts exist)
- [ ] Featured projects display correctly
- [ ] CTA section at bottom renders

#### Navigation
- [ ] Logo displays (cyan + amber two-tone)
- [ ] Nav links show with animated underline on hover
- [ ] Active page indicator works
- [ ] Mobile: Hamburger menu appears (resize to < 768px)
- [ ] Mobile: Menu opens/closes when clicked

#### Blog Page (`/blog`)
- [ ] Blog post cards display
- [ ] Category badges show (gradient cyan)
- [ ] Post excerpts are readable
- [ ] Card hover effects work (lift + glow)
- [ ] "Read More" links animate (arrow slides right)

#### Individual Blog Post
- [ ] Post header shows title, date, categories
- [ ] Post content is readable with proper spacing
- [ ] Code blocks have dark background and syntax highlighting
- [ ] Blockquotes have cyan left border
- [ ] Images display and are responsive
- [ ] Previous/Next post navigation works
- [ ] Social sharing buttons show

#### Projects Page (`/projects`)
- [ ] Project cards display in grid
- [ ] Project icons show (gradient circles)
- [ ] Technology tags display
- [ ] Card hover effects work (larger lift than features)
- [ ] Demo/GitHub links are clickable

#### About Page (`/about`)
- [ ] Profile photo shows with cyan border
- [ ] Photo zooms slightly on hover
- [ ] Skills grid displays
- [ ] Skill tags have hover effect (cyan fill)
- [ ] Quote section displays (if present)

#### Contact Page (`/contact`)
- [ ] Contact method cards display
- [ ] Icons show in gradient circles
- [ ] Card hover effects work
- [ ] Email/social links are clickable

#### Footer
- [ ] Footer displays at bottom
- [ ] Social links show as circular buttons
- [ ] Social buttons have hover effect (lift + cyan glow)
- [ ] Copyright text displays

### Step 6: Responsive Testing

Test at different screen widths:

#### Desktop (> 768px)
- [ ] Horizontal navigation bar
- [ ] Multi-column grids (features, projects)
- [ ] Full-size hero text
- [ ] Sidebar layouts (if any)

#### Tablet (768px)
- [ ] Navigation collapses to hamburger menu
- [ ] Grids adjust to 1-2 columns
- [ ] Reduced font sizes
- [ ] Hero title is smaller (2.5rem)

#### Mobile (< 480px)
- [ ] Single column layouts
- [ ] Further reduced font sizes
- [ ] Hero title smallest (2rem)
- [ ] Touch-friendly button sizes
- [ ] No horizontal scrolling

**Test Using Browser DevTools:**
- Chrome: F12 → Click device icon → Select device
- Firefox: F12 → Responsive Design Mode
- Safari: Develop → Enter Responsive Design Mode

### Step 7: Browser Console Check

Open DevTools (F12) and check Console tab:

**Should NOT see:**
- ❌ Failed to load resource: 404 (styles.css not found)
- ❌ CSS syntax errors
- ❌ Uncaught errors

**OK to ignore:**
- Browser extension warnings
- Font Awesome CDN messages (if offline)

### Step 8: Performance Check

Check Network tab in DevTools:

**styles.css should:**
- Load successfully (Status: 200)
- Be ~30-40KB (uncompressed)
- Load quickly (< 100ms on localhost)

### Step 9: Animation Testing

Watch for entrance animations on homepage:

**Hero section should:**
1. Title fades in + slides up (0.1s delay)
2. Subtitle fades in + slides up (0.2s delay)
3. Description fades in + slides up (0.3s delay)
4. Buttons fade in + slides up (0.4s delay)

**Staggered cascade effect** should be visible on page load.

---

## Troubleshooting

### Issue: Styles Don't Load (Blank White Page)

**Symptom:** Page loads but has no styling, looks like plain HTML

**Fixes:**
1. Check browser console for 404 error on styles.css
2. Verify `_site/assets/css/styles.css` exists after build
3. Check `assets/css/styles.scss` has front matter (the `---` dashes)
4. Rebuild: `bundle exec jekyll build --verbose`

### Issue: SCSS Compilation Error

**Symptom:** Build fails with "Sass Error" or "Invalid CSS"

**Fixes:**
1. Check terminal output for specific file/line number
2. Verify all `@import` statements use correct paths
3. Check for syntax errors in SCSS files (missing semicolons, brackets)
4. Ensure `_sass/oceanic.scss` imports all partials
5. Clear cache: `rm -rf _site .jekyll-cache` and rebuild

### Issue: Colors Don't Match Original

**Symptom:** Colors look different than before refactoring

**Fixes:**
1. Check `_sass/oceanic/_variables.scss` has correct hex values
2. Verify CSS custom properties are in `:root` selector
3. Ensure variables use `var(--variable-name)` syntax
4. Compare to old `assets/css/main.css` (backup)

### Issue: Responsive Design Broken

**Symptom:** Mobile menu doesn't work or layouts don't adjust

**Fixes:**
1. Check `_sass/oceanic/_responsive.scss` was imported last
2. Verify media queries use correct syntax: `@media (max-width: 768px)`
3. Check JavaScript loads: `assets/js/main.js`
4. Test hamburger menu click handler in browser console

### Issue: Hover Effects Missing

**Symptom:** Cards don't lift, no glow effects on hover

**Fixes:**
1. Check transition properties in component SCSS files
2. Verify box-shadow and transform are defined
3. Test in different browser (could be browser-specific)
4. Check `:hover` pseudo-classes are present

### Issue: Font Awesome Icons Missing

**Symptom:** Boxes or symbols instead of icons

**Fixes:**
1. Check internet connection (CDN needs network access)
2. Verify Font Awesome CDN URL in `_layouts/default.html`
3. Check browser console for CDN loading errors
4. Use fallback: Download Font Awesome locally

---

## Comparison Testing (Optional)

To verify the new theme matches the old styling:

### Step 1: Backup Old CSS
```bash
cp assets/css/main.css assets/css/main.css.backup
```

### Step 2: Build with New Theme
```bash
bundle exec jekyll build
```

### Step 3: Visual Comparison
1. Take screenshots of each page with new theme
2. Temporarily restore old CSS (rename files)
3. Take screenshots of each page with old CSS
4. Compare side-by-side

**Should be identical:**
- Colors and spacing
- Typography and font sizes
- Hover effects and animations
- Responsive breakpoints

---

## Success Criteria

✅ **Build succeeds** without errors
✅ **styles.css** generated in `_site/assets/css/`
✅ **All pages load** and look correct
✅ **Hover effects work** (lift, glow, color changes)
✅ **Responsive design** works at 768px and 480px breakpoints
✅ **No console errors** in browser DevTools
✅ **Animations play** on page load (hero section)
✅ **Visual appearance matches** original theme

---

## After Successful Testing

Once everything works:

### 1. Delete Old CSS (Optional)
```bash
rm assets/css/main.css
```

### 2. Commit Changes
```bash
git add .
git commit -m "Refactor site into Oceanic Jekyll theme

- Convert monolithic main.css into 13 modular SCSS partials
- Follow Jekyll theme conventions with _sass/ directory structure
- Add gem specification for future distribution
- Create comprehensive theme documentation
- Add MIT license
- Update CLAUDE.md with new theme architecture

All styles maintained, zero visual changes to site."

git push origin main
```

### 3. Monitor GitHub Actions
- Visit: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
- Wait 2-5 minutes for build to complete
- Check for green checkmark (success) or red X (failure)

### 4. Verify Live Site
- Visit: https://christaylor.codes
- Test all pages on live site
- Check mobile responsiveness
- Verify no broken styles

---

## Quick Reference

**Start local server:**
```bash
bundle exec jekyll serve --livereload
```

**Build only:**
```bash
bundle exec jekyll build
```

**Clear cache and rebuild:**
```bash
rm -rf _site .jekyll-cache && bundle exec jekyll build
```

**Check for SCSS errors:**
```bash
bundle exec jekyll build --verbose
```

**Stop server:**
Press `Ctrl+C` in terminal

---

**Ready to test!** Run `bundle exec jekyll serve --livereload` and open http://localhost:4000
