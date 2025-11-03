# CLAUDE.md - Project Maintenance Guide

This document contains all the information needed to understand and maintain this Jekyll-based personal website.

## Project Overview

This is a personal portfolio and blog website built with Jekyll and hosted on GitHub Pages. The site features a modern, responsive design with custom layouts and styles.

**Live Site:** https://christaylorcodes.github.io
**Repository:** https://github.com/christaylorcodes/christaylorcodes.github.io
**Static Site Generator:** Jekyll
**Hosting:** GitHub Pages
**Owner:** Chris Taylor (ctaylor@christaylor.codes)

## Site Structure

```
Website/
├── _config.yml              # Jekyll configuration
├── _layouts/                # Page templates
│   ├── default.html        # Main layout wrapper
│   └── post.html           # Blog post layout
├── _includes/               # Reusable components
│   ├── navigation.html     # Site navigation bar
│   └── footer.html         # Site footer
├── _posts/                  # Blog posts (markdown)
│   └── YYYY-MM-DD-title.md
├── _projects/               # Project entries (markdown)
│   └── project-name.md
├── assets/
│   ├── css/
│   │   └── main.css        # Custom styles
│   ├── js/
│   │   └── main.js         # JavaScript functionality
│   └── images/             # Site images
├── index.html               # Home page
├── about.html               # About page
├── blog.html                # Blog index
├── projects.html            # Projects showcase
├── contact.html             # Contact page
├── Gemfile                  # Ruby dependencies
└── README.md                # Project documentation
```

## Key Configuration (_config.yml)

```yaml
title: Chris Taylor
email: ctaylor@christaylor.codes
url: "https://christaylor.codes"
github_username: christaylorcodes

# Collections
collections:
  projects:
    output: false
    sort_by: order
```

**Important Notes:**
- The site does NOT use a theme (no `theme:` in config)
- Uses custom layouts in `_layouts/`
- Collections are used for projects (data-driven)
- No `.nojekyll` file should exist (Jekyll processing is required)

## Content Management

### Adding Blog Posts

1. Create a new file in `_posts/` with naming format: `YYYY-MM-DD-title-of-post.md`
2. Add front matter:

```yaml
---
layout: post
title: "Your Post Title"
date: 2024-02-20 10:00:00 -0000
categories: [category1, category2]
tags: [tag1, tag2, tag3]
author: Chris Taylor
excerpt: "Brief description for post previews"
---

Your content here in Markdown...
```

3. Write content using Markdown
4. Commit and push to deploy

**Post Features:**
- Automatic post navigation (previous/next)
- Social sharing buttons
- Category and tag display
- Code syntax highlighting
- Responsive images
- SEO optimization via jekyll-seo-tag

### Adding Projects

1. Create a new file in `_projects/` with format: `project-name.md`
2. Add front matter:

```yaml
---
title: Project Name
icon: fa-icon-name
description: Brief description for the project card
tags:
  - Technology 1
  - Technology 2
demo_url: "https://demo.com"
github_url: "https://github.com/user/repo"
order: 1
---

Optional longer description...
```

3. Commit and push to deploy

**Project Field Definitions:**
- `title`: Display name
- `icon`: Font Awesome icon class (e.g., `fa-rocket`, `fa-code`)
- `description`: Short text shown on project card
- `tags`: List of technologies used
- `demo_url`: Link to live demo (use `#` if none)
- `github_url`: Link to repository (use `#` if none)
- `order`: Display order (lower numbers appear first)

### Updating Pages

**Home Page** (`index.html`):
- Update hero section text
- Modify feature cards
- Change call-to-action text

**About Page** (`about.html`):
- Edit bio text
- Update skills in the skills grid
- Modify section headings

**Contact Page** (`contact.html`):
- Update Formspree form action (line 13)
- Change contact methods
- Update email and social links

## Styling and Design

### CSS Variables (assets/css/main.css)

```css
:root {
    --primary-color: #6366f1;     /* Main brand color */
    --primary-dark: #4f46e5;      /* Darker shade */
    --secondary-color: #ec4899;   /* Accent color */
    --text-dark: #1f2937;         /* Dark text */
    --text-light: #6b7280;        /* Light text */
    --bg-light: #f9fafb;          /* Light background */
    --bg-white: #ffffff;          /* White background */
    --border-color: #e5e7eb;      /* Border color */
}
```

**To Change Colors:**
1. Edit variables in `assets/css/main.css` (lines 8-18)
2. Commit and push changes

### Design System

**Typography:**
- Font: Inter (Google Fonts)
- Fallback: System fonts

**Icons:**
- Font Awesome 6.4.0 (CDN)
- Used for: Navigation, features, projects, social links

**Responsive Breakpoints:**
- Mobile: max-width 480px
- Tablet: max-width 768px
- Desktop: 769px and above

## Layouts and Components

### Default Layout (`_layouts/default.html`)

Wraps all pages with:
- HTML head with SEO tags
- Navigation include
- Main content area
- Footer include
- JavaScript

### Post Layout (`_layouts/post.html`)

Extends default layout, adds:
- Post header (title, date, author, categories)
- Post content with styled markdown
- Post navigation (prev/next)
- Social sharing buttons
- Back to blog button

### Navigation (`_includes/navigation.html`)

- Responsive navigation bar
- Active state highlighting
- Mobile hamburger menu
- Logo linked to home

### Footer (`_includes/footer.html`)

- Site description
- Social media links
- Copyright notice

## JavaScript Functionality (`assets/js/main.js`)

Features:
- Mobile navigation toggle
- Smooth scroll for anchor links
- Active navigation highlighting
- Intersection observer for animations
- Form handling placeholder

## Deployment

### GitHub Pages Setup

1. Repository must be named: `christaylorcodes.github.io`
2. GitHub Pages source: `main` branch
3. No custom domain configured (using default GitHub Pages URL)
4. Automatic builds on push to `main`

### Deployment Workflow

```bash
# 1. Make changes locally
# 2. Test locally (optional):
bundle install
bundle exec jekyll serve

# 3. Commit changes
git add .
git commit -m "Description of changes"

# 4. Push to GitHub
git push origin main

# 5. Wait 2-5 minutes for GitHub Pages to rebuild
```

### Checking Build Status

Visit: https://github.com/christaylorcodes/christaylorcodes.github.io/actions

## Dependencies (Gemfile)

```ruby
gem "github-pages"           # GitHub Pages Jekyll version
gem "webrick"                # Local development server
gem "jekyll-feed"            # RSS feed generation
gem "jekyll-seo-tag"         # SEO meta tags
```

**Updating Dependencies:**
```bash
bundle update
git add Gemfile.lock
git commit -m "Update dependencies"
git push
```

## Common Tasks

### Change Site Title/Owner Info

Edit `_config.yml`:
```yaml
title: Your Name
email: your.email@example.com
github_username: yourusername
```

### Add Social Media Links

Edit `_config.yml`:
```yaml
linkedin_username: yourlinkedin
twitter_username: yourtwitter
```

Uncomment the `#` prefix to enable.

### Setup Contact Form

1. Create account at https://formspree.io
2. Create a new form
3. Copy form ID
4. Edit `contact.html` line 13:
```html
<form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
```

### Add Custom Domain

1. Purchase domain and point to GitHub Pages
2. Update `_config.yml`:
```yaml
url: "https://yourdomain.com"
```
3. Add CNAME file in repository root:
```
yourdomain.com
```
4. Configure DNS with your provider

### Update Navigation

Edit `_includes/navigation.html` to add/remove/reorder nav items:
```html
<li><a href="/path" class="nav-link">Label</a></li>
```

## Important Files to Never Delete

- `_config.yml` - Jekyll configuration
- `_layouts/default.html` - Base layout
- `_includes/navigation.html` - Site navigation
- `_includes/footer.html` - Site footer
- `assets/css/main.css` - All styles
- `assets/js/main.js` - JavaScript functionality
- `Gemfile` - Ruby dependencies
- `.gitignore` - Git ignore rules

## Files to Exclude from Git

Already configured in `.gitignore`:
- `_site/` - Jekyll build output
- `.sass-cache/`
- `.jekyll-cache/`
- `vendor/`
- `.DS_Store`
- `.env`

## Troubleshooting

### Site Not Rendering Correctly

**Issue:** Pages show raw HTML/Liquid tags
**Solution:** Ensure no `.nojekyll` file exists in root

**Issue:** Custom layouts not working
**Solution:** Remove `theme:` from `_config.yml`

**Issue:** Changes not appearing
**Solution:**
1. Check GitHub Actions for build errors
2. Clear browser cache
3. Wait 5 minutes for deployment

### Build Failures

**Issue:** Jekyll build fails on GitHub
**Solution:**
1. Check Actions tab for error messages
2. Verify all Liquid syntax is correct
3. Ensure all required files exist
4. Check for YAML syntax errors in front matter

### Local Development Issues

**Issue:** `bundle exec jekyll serve` fails
**Solution:**
```bash
bundle install
bundle update
bundle exec jekyll serve --livereload
```

**Issue:** Port 4000 already in use
**Solution:**
```bash
bundle exec jekyll serve --port 4001
```

## Design Guidelines

### Adding New Sections

1. Follow existing CSS patterns
2. Use defined color variables
3. Maintain responsive design
4. Add appropriate spacing (5rem sections)
5. Include hover states and transitions

### Typography Scale

- Hero Title: 3.5rem (2.5rem mobile)
- Section Title: 2.5rem (2rem mobile)
- Card Title: 1.5rem
- Body Text: 1rem
- Small Text: 0.875rem

### Spacing System

- Section padding: `5rem 0` (3rem mobile)
- Card padding: `2rem`
- Gap between items: `2rem`
- Container max-width: `1200px`

## Performance Considerations

- Static site (very fast)
- CSS: Single file, no preprocessor
- JavaScript: Minimal, vanilla JS
- Images: Store in `assets/images/`, optimize before upload
- Fonts: Google Fonts CDN
- Icons: Font Awesome CDN

## SEO Features

- jekyll-seo-tag plugin installed
- Meta descriptions in `_config.yml`
- Per-page title customization
- Semantic HTML structure
- Responsive meta viewport
- Social sharing meta tags
- RSS feed via jekyll-feed

## Backup and Version Control

- All code in Git
- Hosted on GitHub
- Main branch is production
- Create feature branches for major changes
- Tag releases for major versions

## Future Enhancements

Ideas for future development:
- [ ] Add dark mode toggle
- [ ] Implement search functionality
- [ ] Add project detail pages
- [ ] Create an RSS feed page
- [ ] Add reading time to blog posts
- [ ] Implement comments system
- [ ] Add portfolio image galleries
- [ ] Create a resume/CV page
- [ ] Add testimonials section
- [ ] Implement newsletter signup

## Contact and Support

**Site Owner:** Chris Taylor
**Email:** ctaylor@christaylor.codes
**GitHub:** @christaylorcodes

For Claude Code users: This project was built with Claude Code assistance and can be maintained the same way.

---

**Last Updated:** 2025-11-03
**Jekyll Version:** GitHub Pages compatible
**Documentation Version:** 1.0
