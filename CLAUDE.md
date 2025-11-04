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
├── _sass/                   # SCSS source files (Oceanic theme)
│   ├── oceanic/
│   │   ├── _variables.scss    # Color system and CSS variables
│   │   ├── _base.scss         # Reset and base styles
│   │   ├── _navigation.scss   # Navigation component
│   │   ├── _hero.scss         # Hero section
│   │   ├── _buttons.scss      # Button styles
│   │   ├── _features.scss     # Feature cards
│   │   ├── _posts.scss        # Blog post styles
│   │   ├── _projects.scss     # Project cards
│   │   ├── _contact.scss      # Contact page
│   │   ├── _about.scss        # About page
│   │   ├── _footer.scss       # Footer component
│   │   ├── _animations.scss   # Animations
│   │   └── _responsive.scss   # Media queries
│   └── oceanic.scss         # Main import file
├── _posts/                  # Blog posts (markdown)
│   └── YYYY-MM-DD-title.md
├── _projects/               # Project entries (markdown)
│   └── project-name.md
├── assets/
│   ├── css/
│   │   └── styles.scss      # Compiled stylesheet (processed by Jekyll)
│   ├── js/
│   │   └── main.js         # JavaScript functionality
│   └── images/             # Site images
├── index.html               # Home page
├── about.html               # About page
├── blog.html                # Blog index
├── projects.html            # Projects showcase
├── contact.html             # Contact page
├── oceanic.gemspec          # Gem specification for theme
├── LICENSE                  # MIT License
├── Gemfile                  # Ruby dependencies
├── README.md                # Project documentation
├── THEME-README.md          # Theme-specific documentation
└── CLAUDE.md                # This file
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
- The site uses a custom "Oceanic" theme (gem-based, structured for future distribution)
- Theme follows Jekyll conventions with modular SCSS in `_sass/oceanic/`
- Uses custom layouts in `_layouts/`
- Collections are used for projects (data-driven)
- No `.nojekyll` file should exist (Jekyll processing is required)

## Oceanic Theme Structure

The site uses a custom-built Jekyll theme called **"Oceanic"** that follows official Jekyll theme conventions. The theme is structured for potential future distribution as a RubyGems package.

### Theme Architecture

**SCSS Organization** (`_sass/oceanic/`):
The monolithic CSS file has been refactored into 13 modular SCSS partials for better maintainability:

1. **`_variables.scss`** (45 lines) - CSS custom properties, color system, shadows
2. **`_base.scss`** (45 lines) - Reset, body, typography, container, sections
3. **`_navigation.scss`** (125 lines) - Navbar, logo, mobile menu, hamburger
4. **`_hero.scss`** (60 lines) - Hero sections, highlights, buttons container
5. **`_buttons.scss`** (40 lines) - Button components (primary, secondary)
6. **`_features.scss`** (70 lines) - Feature cards and grid
7. **`_posts.scss`** (400 lines) - Blog list, individual posts, categories, content styles
8. **`_projects.scss`** (110 lines) - Project cards, grid, CTA section
9. **`_contact.scss`** (85 lines) - Contact page, method cards, form styles
10. **`_about.scss`** (110 lines) - About page, photo, skills grid, quote
11. **`_footer.scss`** (60 lines) - Footer, social links, copyright
12. **`_animations.scss`** (45 lines) - Keyframe animations (fadeInUp)
13. **`_responsive.scss`** (115 lines) - Media queries for 768px and 480px breakpoints

**Main Import File** (`_sass/oceanic.scss`):
Imports all partials in the correct order (variables → base → components → animations → responsive).

**Asset Pipeline** (`assets/css/styles.scss`):
Contains Jekyll front matter (the dashes) and imports `oceanic.scss`. Jekyll processes this file and outputs `_site/assets/css/styles.css`.

### Modifying Styles

**To change colors**: Edit `_sass/oceanic/_variables.scss` only
```scss
:root {
    --primary-color: #06b6d4;    /* Change this to update accent color */
    --secondary-color: #f59e0b;  /* Change this to update warm accent */
    /* ... etc */
}
```

**To modify a specific component**: Edit the corresponding partial
- Navigation styles: `_sass/oceanic/_navigation.scss`
- Blog posts: `_sass/oceanic/_posts.scss`
- Projects: `_sass/oceanic/_projects.scss`
- etc.

**To add new styles**: Create a new partial in `_sass/oceanic/` and import it in `_sass/oceanic.scss`

### Theme Distribution Files

- **`oceanic.gemspec`** - Gem specification for RubyGems distribution
- **`LICENSE`** - MIT License
- **`THEME-README.md`** - Complete theme documentation for users

**Note**: The theme is not yet published to RubyGems. To use it, the files must be present in the site directory.

### Import Order (Important!)

The order in `_sass/oceanic.scss` matters:
1. Variables (defines CSS custom properties used by all other files)
2. Base (foundational styles)
3. Components (navigation, hero, buttons, etc.)
4. Animations (keyframes)
5. Responsive (media queries must be last)

## Content Management

### Adding Blog Posts

1. Create a new file in `_posts/` with naming format: `YYYY-MM-DD-title.md` (use short, simple titles)
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

### Content Contribution Guidelines

This section defines standards for creating and maintaining content on the site to ensure consistency, quality, and professionalism.

#### Content Standards

**Target Audience:**
- MSP (Managed Service Provider) professionals
- PowerShell developers and automation engineers
- IT operations teams
- Technology decision-makers

**Content Voice & Style:**
- **Professional but approachable** - Expert without being condescending
- **Practical and actionable** - Focus on real-world application
- **Specific over generic** - Concrete examples, not abstract concepts
- **Show, don't just tell** - Code examples, screenshots, demonstrations
- **Explain the why** - Context and reasoning, not just instructions

**Writing Quality Standards:**
- Clear, concise writing with proper grammar and spelling
- Technical accuracy - all code examples must be tested and functional
- Proper attribution for external sources, code, or ideas
- No marketing fluff or excessive superlatives
- Professional tone without emojis (unless specifically requested)

#### Blog Post Requirements

When creating blog posts, ensure they meet these standards:

**Technical Content:**
- All code examples must be tested and working
- Include error handling where appropriate
- Explain security considerations for production code
- Provide performance implications when relevant
- Link to documentation for non-obvious functions

**Structure:**
- Clear, descriptive title that includes key technologies
- Excerpt summarizing the post's value proposition
- Introduction explaining the problem and why it matters
- Body with clear sections and headings
- Conclusion with key takeaways
- Tags: 3-5 relevant, searchable terms
- Categories: 1-2 high-level classifications

**SEO Optimization:**
- Front matter includes `title`, `excerpt`, `tags`, `categories`
- Optional custom `description` for search results
- Optional custom social sharing `image` (1200x630px)
- Use descriptive headings (H2, H3) throughout post
- Internal links to other relevant posts when applicable

**Code Formatting:**
- Use proper markdown code blocks with language specification
- Inline code for short references: `Get-Process`
- Code blocks for longer examples with syntax highlighting
- Add comments in code to explain non-obvious logic

**Pre-Publication Checklist:**
- [ ] Code examples tested and working
- [ ] All links verified (no broken links)
- [ ] Proper front matter with all required fields
- [ ] Preview rendered post in local Jekyll server
- [ ] Proofread for grammar and clarity
- [ ] Security review - no credentials or sensitive data
- [ ] Images optimized for web (if included)

#### Project Entry Requirements

**Required Information:**
- Descriptive title
- Clear description of what the project does (focus on value/benefits)
- Accurate technology tags
- Valid GitHub repository URL
- Font Awesome icon that matches project type
- Display order number

**Description Best Practices:**
- Lead with the benefit/value proposition
- Explain what problem it solves
- Mention key features or capabilities
- Keep under 200 words for project card readability
- Use active voice and strong verbs

#### File Naming Conventions

**Blog Posts:**
- Format: `YYYY-MM-DD-title.md`
- Use short, simple titles (3-5 words)
- Lowercase, hyphen-separated
- Example: `2024-11-15-powershell-automation.md`

**Project Files:**
- Format: `project-name.md`
- Match GitHub repository name when possible
- Lowercase, hyphen-separated
- Example: `connectwisemanageapi.md`

**Images:**
- Descriptive names: `project-dashboard-screenshot.png`
- Include dimensions for social sharing images: `post-title-1200x630.png`
- Optimize before uploading (compress, appropriate format)

#### Testing Before Committing

**Local Testing (Recommended):**
```bash
# Start Jekyll local server
bundle exec jekyll serve --livereload

# View site at http://localhost:4000
# Check for errors in terminal output
```

**Pre-Commit Checklist:**
- [ ] Local Jekyll build completes without errors
- [ ] Visual inspection of changed pages
- [ ] Links work correctly
- [ ] Images display properly
- [ ] Responsive design works on mobile
- [ ] No console errors in browser developer tools

**After Pushing to GitHub:**
- Monitor GitHub Actions for build status
- Wait 2-5 minutes for deployment
- Visit live site to verify changes
- Test social sharing preview (Twitter Card Validator, Facebook Debugger)

#### Content Organization Best Practices

**When to Create New Content:**
- Blog post: In-depth technical tutorials, lessons learned, project showcases
- Project entry: Reusable tools, modules, or significant code repositories
- Page update: About page milestones, contact method changes

**Content Maintenance:**
- Review older blog posts annually for accuracy
- Update broken links or deprecated information
- Add update notices to posts with outdated information
- Archive or remove placeholder content

**SEO and Social Media:**
- Create custom social sharing images for important posts
- Use consistent branding across all content
- Internal linking between related posts improves SEO
- Share new content on professional social media (LinkedIn)

## Styling and Design

### Theme Color Palette

The site uses an **Oceanic Palette** with **Electric Blue primary** colors and **warm amber accents**. This creates a professional tech aesthetic (cyan/blue for trust and technology) balanced with warm orange/amber tones for calls-to-action and visual interest.

**Design Philosophy:**
- **Cool + Warm Balance**: Electric blue (cool, tech-focused) paired with amber/orange (warm, human, inviting)
- **Elevation System**: Four background shades create visual depth without color changes
- **Consistent Interactions**: All hover states use cyan glow + shadow + lift pattern
- **Accessibility**: High contrast ratios (WCAG AA compliant) for excellent readability

All colors are defined as CSS custom properties (variables) for easy theming and consistency across the site.

#### Color Reference

**Primary Colors (Electric Blue Theme)**
```
--primary-color:     #06b6d4    ████ Cyan             - Main accent, buttons, links, hover states
--primary-dark:      #0284c7    ████ Sky Blue         - Darker accent, button hover, active states
--primary-light:     #38bdf8    ████ Light Blue       - Lighter accent, highlights, glows
--secondary-color:   #f59e0b    ████ Amber            - Warm accent, secondary branding
```

**Background Colors (Deep Slate)**
```
--bg-darker:         #020617    ████ Rich Black       - Hero, CTA, navbar (darkest backgrounds)
--bg-dark:           #0f172a    ████ Dark Slate       - Main body background
--bg-light:          #1e293b    ████ Slate            - Cards, content sections (elevated)
--bg-white:          #334155    ████ Light Slate      - Highest elevation (form inputs, modals)
```

**Text Colors**
```
--text-dark:         #f1f5f9    ████ Off White        - Main text, headings (high contrast)
--text-light:        #cbd5e1    ████ Light Gray       - Secondary text, descriptions
```

**Utility Colors**
```
--border-color:      #475569    ████ Slate Gray       - Borders, dividers
--accent-warm:       #f59e0b    ████ Amber            - Warm highlights, secondary accent
--accent-orange:     #ea580c    ████ Orange           - Call-to-action elements
--accent-rust:       #dc2626    ████ Red              - Warnings, destructive actions
```

#### CSS Variables Location

All variables are defined in `_sass/oceanic/_variables.scss` within the `:root` selector:

```css
:root {
    /* Primary Colors - Electric Blue Theme */
    --primary-color: #06b6d4;        /* Cyan - main accent */
    --primary-dark: #0284c7;         /* Sky Blue - darker accent */
    --primary-light: #38bdf8;        /* Light Blue - lighter accent */
    --secondary-color: #f59e0b;      /* Amber - warm accent */

    /* Background Colors - Deep Slate */
    --bg-darker: #020617;            /* Rich Black - darkest backgrounds */
    --bg-dark: #0f172a;              /* Dark Slate - main background */
    --bg-light: #1e293b;             /* Slate - elevated sections */
    --bg-white: #334155;             /* Light Slate - highest elevation */

    /* Text Colors */
    --text-dark: #f1f5f9;            /* Off White - primary text */
    --text-light: #cbd5e1;           /* Light Gray - secondary text */

    /* Utility Colors */
    --border-color: #475569;         /* Slate Gray - borders */
    --accent-warm: #f59e0b;          /* Amber - warm highlights */
    --accent-orange: #ea580c;        /* Orange - call-to-action */
    --accent-rust: #dc2626;          /* Red - warnings */

    /* Shadows */
    --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.5), 0 2px 4px -1px rgba(0, 0, 0, 0.3);
    --shadow-lg: 0 20px 25px -5px rgba(0, 0, 0, 0.6), 0 10px 10px -5px rgba(0, 0, 0, 0.4);
}
```

#### Color Usage Guidelines

**Primary Cyan (`--primary-color` #06b6d4)** - Main brand color, use for:
- Primary buttons (background)
- Hover states on cards and links
- Active navigation states
- Icon accents
- Links and interactive elements
- Border highlights on hover

**Secondary Amber (`--secondary-color` #f59e0b)** - Warm accent, use for:
- Secondary branding (logo second color)
- Complementary accent color
- Alternative call-to-action elements
- Visual warmth and balance

**Accent Orange (`--accent-orange` #ea580c)** - Use sparingly for:
- High-priority call-to-action buttons
- Important highlights
- "Hot" or urgent items

**Dark Backgrounds** - Layer hierarchy (elevation system):
1. `--bg-darker` (#020617) - Hero, CTA sections, navbar (darkest/highest contrast)
2. `--bg-dark` (#0f172a) - Body background (base layer)
3. `--bg-light` (#1e293b) - Content cards, sections (elevated)
4. `--bg-white` (#334155) - Form inputs, modals (most elevated/lightest)

**Text Colors** - Hierarchy:
- `--text-dark` (#f1f5f9) - Headings, primary content (highest contrast for readability)
- `--text-light` (#cbd5e1) - Descriptions, metadata, secondary text (medium contrast)

**Special Effects:**
- Cyan glow effects: `rgba(6, 182, 212, 0.3)` for subtle glow
- Cyan hover shadow: `0 0 20px rgba(6, 182, 212, 0.5)` for interactive emphasis
- All card hover effects use consistent pattern: lift (translateY), enhanced shadow, and cyan glow

#### Changing the Color Scheme

**To update colors:**
1. Edit the `:root` variables in `_sass/oceanic/_variables.scss`
2. Maintain contrast ratios for accessibility (WCAG AA: 4.5:1 for text)
3. Test hover states and interactive elements
4. Update glow effect rgba values to match new primary color
5. Commit and push changes

**Example - Change accent to purple:**
```css
--primary-color: #a855f7;
--primary-dark: #9333ea;
--primary-light: #c084fc;
```

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
- `_sass/oceanic/*.scss` - Theme SCSS partials
- `assets/css/styles.scss` - Main stylesheet (processed by Jekyll)
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

## Social Media Sharing (Open Graph & Twitter Cards)

The site is configured for rich social media previews when links are shared on platforms like Twitter, LinkedIn, Facebook, and Slack. This is handled automatically by the jekyll-seo-tag plugin with configuration in `_config.yml`.

### Configuration (_config.yml)

```yaml
# Social media defaults for Open Graph and Twitter Cards
social:
  name: Chris Taylor
  links:
    - https://github.com/christaylorcodes
    - https://christaylor.codes

# Default social sharing image
logo: /assets/images/profile-photo.png

# Author defaults
author:
  name: Chris Taylor
  email: ctaylor@christaylor.codes

# Twitter card settings
twitter:
  card: summary_large_image
  # username: christaylorcodes  # Uncomment when Twitter account is active
```

### Generated Meta Tags

The `{% seo %}` tag in [_layouts/default.html:19](_layouts/default.html#L19) automatically generates:

**Open Graph Tags:**
- `og:title` - Page or post title
- `og:description` - Page description or excerpt
- `og:url` - Canonical URL of the page
- `og:type` - Content type (website, article, etc.)
- `og:image` - Social sharing image
- `og:site_name` - Site title

**Twitter Card Tags:**
- `twitter:card` - Card type (summary_large_image)
- `twitter:site` - Twitter username (when configured)
- `twitter:title` - Post/page title
- `twitter:description` - Description or excerpt
- `twitter:image` - Social sharing image

**Structured Data:**
- JSON-LD schema for rich search results
- Author information
- Organization data

### Page-Specific Overrides

Add these fields to front matter in blog posts or pages to customize social sharing:

```yaml
---
title: "Your Post Title"
description: "Custom description for social media and search results"
image: /assets/images/posts/custom-social-card.png
excerpt: "Brief preview text"
---
```

**Field Priority:**
1. `image` - Custom social sharing image (overrides site default)
2. `description` - Custom meta description (falls back to excerpt, then site description)
3. `title` - Page title (combines with site title)

### Creating Social Sharing Images

**Recommended Specifications:**
- **Size**: 1200x630 pixels (16:9 aspect ratio)
- **Format**: PNG or JPG
- **File size**: Under 1MB
- **Location**: `assets/images/posts/`
- **Content**: Post title, author name, relevant visual

**Image Guidelines:**
- Keep text large and readable (previews appear small)
- Use high contrast for text visibility
- Include branding (site name or logo)
- Avoid placing critical text near edges (may be cropped)
- Test on multiple platforms (Twitter, LinkedIn, Facebook)

**Default Behavior:**
- Without a page-specific `image`, the site uses `logo` from `_config.yml`
- Currently using profile photo as placeholder
- Create a proper 1200x630px branded card for better sharing experience

### Testing Social Sharing

**Before Publishing:**

1. **Twitter Card Validator**: https://cards-dev.twitter.com/validator
   - Enter your URL
   - View preview and debug any issues

2. **Facebook Sharing Debugger**: https://developers.facebook.com/tools/debug/
   - Enter your URL
   - View Open Graph tags and preview
   - Use "Scrape Again" to refresh cache

3. **LinkedIn Post Inspector**: https://www.linkedin.com/post-inspector/
   - Enter your URL
   - View preview and metadata

**Common Issues:**
- **Image not appearing**: Ensure image path is absolute (starts with `/`)
- **Wrong image showing**: Clear social media cache using validation tools
- **Description missing**: Add `excerpt` or `description` to front matter
- **Changes not updating**: Social platforms cache for 24-48 hours; use validation tools to force refresh

### Template Updates

The [_templates/post-template.md](_templates/post-template.md) includes social media fields:

```yaml
image: /assets/images/posts/your-post-image.png  # Social sharing image
description: "SEO meta description for search and social media"
```

See template for complete documentation on creating posts with social media optimization.

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

## Working with Chris - AI Guidelines

This section provides context for AI assistants working with Chris on this website.

### Communication Preferences

**Style**: Detailed and collaborative
- Explain reasoning and provide step-by-step guidance
- Teaching mode: Explain why, not just what
- Advanced technical level (20+ years experience)
- **Never use emojis** unless explicitly requested
- Professional, clear, concise communication

**Approach**:
- Pair programming style - work together collaboratively
- Provide examples and alternatives when relevant
- Reference documentation and best practices
- Break complex tasks into manageable steps
- Ask clarifying questions when needed

### Code Philosophy

**Core Principles**:
- **Readability over cleverness** - Code should be clear and maintainable
- **Verbose, descriptive naming** - Full words, no abbreviations (e.g., `navigationMenu` not `navMenu`)
- **Explicit over implicit** - Make intentions clear
- **Self-documenting code** - Code should tell a story
- **Comment the "why" not the "what"** - Explain reasoning, not obvious actions

**Quality Standards**:
- Input validation where applicable
- Error handling for user-facing features
- Security-conscious (sanitize inputs, no hardcoded credentials)
- Test changes before committing
- Follow existing patterns in the codebase

### Blog Content Guidelines

**For blog post creation**, see: [docs/blog-guidelines.md](c:\_Code\CHRIS\docs\blog-guidelines.md)

**Content Strategy**:
- Target audience: MSP professionals, PowerShell developers, IT operations teams
- Content pillars: PowerShell & Automation, MSP Operations, AI Integration, Lessons Learned
- Voice: Professional but approachable, practical and actionable
- Style: Show don't tell, explain the why, be specific
- Technical depth: Assume competent audience, explain non-obvious choices

**Blog Post Requirements**:
- Clear, specific titles with key technologies
- Working, tested code examples
- Real-world application and context
- Security and performance considerations
- Proper formatting and metadata
- Quality checklist before publishing

**2025 Blog Goals**:
- Minimum 4 posts published
- Focus on quality over quantity
- Build professional reputation
- Share practical, immediately useful knowledge

See full guidelines at: `c:\_Code\CHRIS\docs\blog-guidelines.md`

### Task Management

**TODO Workflow**:
- Check relevant TODO files before starting work
- Break complex tasks into smaller steps
- Track progress and mark completion
- Document learnings and decisions

**Main task files**:
- [c:\_Code\CHRIS\tasks\TODO.md](c:\_Code\CHRIS\tasks\TODO.md) - Main task tracking
- [c:\_Code\CHRIS\projects/christaylor-codes-brand.md](c:\_Code\CHRIS\projects/christaylor-codes-brand.md) - Website/brand tasks

### Git Workflow

**Commit Messages**:
- Descriptive and clear about what changed
- Include context for why changes were made
- Follow existing commit style in repository

**Best Practices**:
- Review changes before committing
- Test locally when possible
- Don't commit sensitive data
- Use meaningful commit messages

### Reference Files

**For comprehensive context**, see the CHRIS repository:
- `c:\_Code\CHRIS\config\preferences.yaml` - Detailed AI preferences
- `c:\_Code\CHRIS\config\coding_standards.md` - Complete coding standards
- `c:\_Code\CHRIS\profile\professional.md` - Professional background and expertise
- `c:\_Code\CHRIS\docs\blog-guidelines.md` - Blog writing guidelines
- `c:\_Code\CHRIS\docs\guides\claude-usage-optimization.md` - Claude Projects optimization

### Claude Projects Optimization

**For improved efficiency**, consider using Claude Projects:

**Benefits**:
- Cached content doesn't count against usage limits
- 200,000 token context window
- Persistent custom instructions
- Better organization by work type

**Recommended Setup**:
- Create a "christaylor.codes - Website" project
- Upload this CLAUDE.md file to knowledge base
- Upload blog-guidelines.md for content work
- Add custom instructions for website-specific context

**See**: `c:\_Code\CHRIS\docs\guides\claude-usage-optimization.md` for detailed setup guide

### About Chris

**Role**: Network Operations Chief, vCTO, Automation Engineer, System Integrator at i.t.NOW
**Experience**: 20+ years (since 2002)
**Expertise**: Infrastructure automation, MSP operations, PowerShell, API integrations
**Focus**: AI integration, business process automation, multi-tenant systems

**Primary Technologies**:
- Languages: PowerShell (expert), TypeScript, SQL, Jinja
- Platforms: ConnectWise (Manage, Automate, Control), Azure, ImmyBot, Rewst
- Domain: Managed Services Provider (MSP) industry

**Community**:
- GitHub: @christaylorcodes
- Website: christaylor.codes
- Email: ctaylor@christaylor.codes
- LinkedIn: Chris Taylor (christaylorcodes)

**Working Style**:
- 90-minute Pomodoro blocks for deep work
- Collaboration and pair programming approach
- Values clear communication and teaching
- Open source contributor

---

**Last Updated:** 2025-11-03
**Jekyll Version:** GitHub Pages compatible
**Documentation Version:** 1.1
