# Jekyll Theme Refactoring Plan
## Converting christaylor.codes to "jekyll-theme-oceanic"

**Created:** 2025-11-04
**Purpose:** Refactor the custom site into a proper, exportable Jekyll gem-based theme following official Jekyll conventions

---

## Overview

This plan converts the current custom Jekyll site into a properly structured, gem-based Jekyll theme called **"jekyll-theme-oceanic"** (named after the Oceanic Blue color palette). This will make the theme:
- ✅ Reusable across multiple Jekyll sites
- ✅ Distributable via RubyGems
- ✅ Easier to maintain with modular SCSS structure
- ✅ Following Jekyll best practices and conventions
- ✅ Overridable by site-specific customizations

---

## Jekyll Theme Guidelines Summary

Based on official Jekyll documentation:

### Required Directory Structure
```
jekyll-theme-oceanic/
├── _layouts/          ✓ Already exists
│   ├── default.html
│   └── post.html
├── _includes/         ✓ Already exists
│   ├── navigation.html
│   └── footer.html
├── _sass/             ✗ NEEDS CREATION
│   └── *.scss         → Modular SCSS partials
├── assets/            ⚠️ NEEDS RESTRUCTURING
│   ├── css/
│   │   └── styles.scss  → Main stylesheet with front matter
│   └── js/
│       └── main.js    ✓ Already exists
├── .gemspec           ✗ NEEDS CREATION
├── README.md          ⚠️ EXISTS (needs theme-specific version)
└── screenshot.png     ✗ NEEDS CREATION
```

### Key Principles

1. **SCSS Processing:**
   - Place source SCSS in `_sass/` directory
   - Create `assets/css/styles.scss` with front matter that imports from `_sass/`
   - Jekyll processes files with front matter; `_sass/` files are partials only

2. **Gem Distribution:**
   - `.gemspec` file defines theme metadata, version, dependencies
   - Follow Semantic Versioning (start with 0.1.0)
   - Publish to RubyGems.org for public distribution

3. **User Overrides:**
   - Users can override ANY theme file by creating identically-named files in their site
   - Example: Site's `_layouts/post.html` overrides theme's version

4. **Configuration:**
   - Theme can include `_config.yml` with defaults
   - User's config always takes precedence (merge behavior)

---

## Current State Analysis

### What We Have ✓
- `_layouts/default.html` and `_layouts/post.html` - Good template structure
- `_includes/navigation.html` and `_includes/footer.html` - Reusable components
- `assets/css/main.css` - Comprehensive CSS (~1500 lines) with excellent organization
- `assets/js/main.js` - JavaScript functionality
- Well-documented color system using CSS custom properties
- Responsive design with clear breakpoints

### What Needs Change ⚠️
- `main.css` should be SCSS in `_sass/` directory
- Single monolithic CSS file should be split into logical partials
- No `.gemspec` for gem distribution
- No theme-specific documentation
- No screenshot for theme preview
- Asset pipeline not following Jekyll conventions

---

## Proposed SCSS Structure

### Modular Partial Organization

Split the current `main.css` (~1500 lines) into logical SCSS partials:

```
_sass/
├── oceanic/
│   ├── _variables.scss       → CSS custom properties, color system
│   ├── _base.scss            → Reset, body, container, typography
│   ├── _navigation.scss      → Navbar and mobile menu
│   ├── _hero.scss            → Hero sections
│   ├── _buttons.scss         → Button styles and hover states
│   ├── _sections.scss        → Generic section layouts
│   ├── _features.scss        → Features grid and cards
│   ├── _posts.scss           → Blog post list and individual post styles
│   ├── _projects.scss        → Projects grid and cards
│   ├── _contact.scss         → Contact page form and styles
│   ├── _about.scss           → About page specific styles
│   ├── _footer.scss          → Footer component
│   ├── _animations.scss      → Keyframes and transitions
│   └── _responsive.scss      → Media queries and responsive overrides
└── oceanic.scss              → Main import file (imports all partials)
```

### Assets Structure

```
assets/
├── css/
│   └── styles.scss           → Front matter + @import "oceanic"
└── js/
    └── main.js               → Existing JavaScript (unchanged)
```

**styles.scss contents:**
```scss
---
# Only the main Sass file needs front matter (the dashes are enough)
---

@import "oceanic";
```

---

## Implementation Steps

### Phase 1: Create SCSS Structure
1. ✅ Create `_sass/oceanic/` directory
2. ✅ Create `_variables.scss` - Extract CSS custom properties (lines 51-77 from main.css)
3. ✅ Create `_base.scss` - Reset and base styles (lines 32-95)
4. ✅ Create `_navigation.scss` - Navigation styles
5. ✅ Create `_hero.scss` - Hero section styles
6. ✅ Create `_buttons.scss` - Button components
7. ✅ Create remaining partials for sections, features, posts, projects, etc.
8. ✅ Create `oceanic.scss` main import file that imports all partials in correct order
9. ✅ Create `assets/css/styles.scss` with front matter

### Phase 2: Update Layouts
1. ✅ Update `_layouts/default.html` to reference `/assets/css/styles.css` (compiled output)
2. ✅ Verify all assets load correctly

### Phase 3: Create Gem Distribution Files
1. ✅ Create `jekyll-theme-oceanic.gemspec` with:
   - Metadata (name, version, authors, email, summary, description)
   - Homepage URL
   - License (MIT recommended)
   - Runtime dependencies (jekyll ~> 4.0)
   - Required file patterns
2. ✅ Create `LICENSE` file (MIT or your choice)

### Phase 4: Documentation
1. ✅ Create `THEME-README.md` with:
   - Installation instructions (Gemfile and _config.yml setup)
   - Available layouts and includes
   - Configuration options
   - Customization guide (override instructions)
   - Color palette documentation
   - Credit and license
2. ✅ Create `screenshot.png` (1280x800px recommended) showing theme preview

### Phase 5: Update Configuration
1. ✅ Update `_config.yml` to include theme-specific defaults
2. ✅ Add theme name: `theme: jekyll-theme-oceanic` (commented out for local dev)

### Phase 6: Testing
1. ✅ Test local build: `bundle exec jekyll serve`
2. ✅ Verify all pages render correctly
3. ✅ Check responsive design on mobile/tablet/desktop
4. ✅ Validate all CSS loads properly
5. ✅ Test theme override capability (create override file to confirm it works)

### Phase 7: Documentation Update
1. ✅ Update `CLAUDE.md` with new theme structure
2. ✅ Document how to work with SCSS partials
3. ✅ Explain gem-based theme concept

---

## Naming Conventions

**Theme Name:** `jekyll-theme-oceanic`
**Reasoning:**
- Describes the color palette (Oceanic Blue with warm accents)
- Follows Jekyll theme naming convention (`jekyll-theme-*`)
- Professional, memorable, describes the design aesthetic
- Not tied to personal branding (makes it reusable)

**Gem Name:** `jekyll-theme-oceanic`
**Version:** `0.1.0` (semantic versioning - initial development release)

---

## Benefits of This Refactoring

### For Maintenance
- **Modular SCSS:** Easier to find and update specific component styles
- **Clear Organization:** Logical file structure matches page components
- **Reduced Cognitive Load:** Smaller files, focused purposes
- **Better Version Control:** Smaller diffs when changing specific components

### For Reusability
- **Gem Distribution:** Anyone can use `gem 'jekyll-theme-oceanic'`
- **Override System:** Users customize by adding files, not editing theme
- **Clean Separation:** Theme code vs. content (posts, pages, projects)
- **Shareable:** Portfolio piece showing proper Jekyll theme development

### For Your Workflow
- **Easier Updates:** Change color scheme by editing `_variables.scss` only
- **Safer Customization:** Site-specific overrides don't modify theme core
- **Professional Quality:** Follows industry best practices
- **Learning Value:** Deep understanding of Jekyll's theme system

---

## File Size Comparison

**Before (Current):**
```
assets/css/main.css           ~1500 lines (monolithic)
```

**After (Proposed):**
```
_sass/oceanic/_variables.scss      ~30 lines
_sass/oceanic/_base.scss          ~100 lines
_sass/oceanic/_navigation.scss    ~120 lines
_sass/oceanic/_hero.scss           ~80 lines
_sass/oceanic/_buttons.scss        ~60 lines
_sass/oceanic/_sections.scss       ~80 lines
_sass/oceanic/_features.scss      ~120 lines
_sass/oceanic/_posts.scss         ~250 lines
_sass/oceanic/_projects.scss      ~200 lines
_sass/oceanic/_contact.scss       ~150 lines
_sass/oceanic/_about.scss         ~100 lines
_sass/oceanic/_footer.scss         ~80 lines
_sass/oceanic/_animations.scss     ~50 lines
_sass/oceanic/_responsive.scss    ~150 lines
_sass/oceanic.scss                 ~20 lines (imports)
assets/css/styles.scss              ~5 lines (front matter + import)
Total: Same content, better organized
```

---

## Migration Path for Users

If someone wanted to use this theme on a new site:

### Installation

**1. Add to Gemfile:**
```ruby
gem "jekyll-theme-oceanic"
```

**2. Update _config.yml:**
```yaml
theme: jekyll-theme-oceanic
```

**3. Install:**
```bash
bundle install
```

### Customization

**Override any file by creating identically-named file in site:**
```
my-site/
├── _layouts/
│   └── post.html           ← Overrides theme's post layout
├── _sass/
│   └── oceanic/
│       └── _variables.scss ← Overrides theme's color variables
└── _config.yml
```

**Customize colors without file overrides:**
```yaml
# _config.yml
oceanic_theme:
  primary_color: "#your-color"
  secondary_color: "#your-color"
```

---

## Compatibility

- **Jekyll Version:** 4.0+ (can support 3.9+ if needed)
- **GitHub Pages:** Compatible (may need bundled gems approach)
- **Ruby Version:** 2.7+ recommended
- **Dependencies:**
  - `jekyll (~> 4.0)`
  - `jekyll-feed (~> 0.15)`
  - `jekyll-seo-tag (~> 2.8)`

---

## Publishing to RubyGems (Optional - Future Step)

Once theme is stable and tested:

```bash
# Build the gem
gem build jekyll-theme-oceanic.gemspec

# Publish to RubyGems.org (requires account)
gem push jekyll-theme-oceanic-0.1.0.gem
```

**For now:** Keep it local/GitHub only until you're ready to share publicly.

---

## Open Questions / Decisions Needed

1. **License:** MIT or other? (MIT recommended for open source)
2. **Public Distribution:** Share on RubyGems immediately or keep private initially?
3. **Version Number:** Start at 0.1.0 (pre-release) or 1.0.0?
4. **Theme Name:** Confirm "oceanic" or prefer alternative?
5. **Content Files:** Keep sample posts/projects in theme or separate?

---

## Next Steps

1. Review this plan and confirm approach
2. Begin Phase 1: Create SCSS structure (can be done incrementally)
3. Test thoroughly at each phase
4. Update documentation as we go
5. Consider publishing as open source project

---

## References

- [Jekyll Themes Documentation](https://jekyllrb.com/docs/themes/)
- [Jekyll Assets Documentation](https://jekyllrb.com/docs/step-by-step/07-assets/)
- [Semantic Versioning](https://semver.org/)
- [RubyGems Guides](https://guides.rubygems.org/make-your-own-gem/)

---

**Status:** 📝 Planning Complete - Ready for Implementation
**Estimated Effort:** 3-4 hours for full refactoring
**Risk Level:** Low (incremental changes, fully reversible)
