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

### Theme Color Palette

The site uses a **dark theme** with **turquoise accent** colors. All colors are defined as CSS custom properties (variables) for easy theming.

#### Color Reference

**Primary Colors (Turquoise Accents)**
```
--primary-color:     #06b6d4    ████ Cyan/Turquoise    - Main accent, buttons, links, hover states
--primary-dark:      #0891b2    ████ Dark Turquoise    - Button hover, active states
--primary-light:     #22d3ee    ████ Light Turquoise   - Highlights, glows
--secondary-color:   #14b8a6    ████ Teal             - Secondary accent, variations
```

**Background Colors (Dark Slate)**
```
--bg-darker:         #020617    ████ Almost Black      - Hero, CTA, navbar (darkest backgrounds)
--bg-dark:           #0f172a    ████ Dark Slate        - Main body background
--bg-light:          #1e293b    ████ Slate            - Cards, content sections
--bg-white:          #334155    ████ Light Slate       - Elevated elements, form inputs
```

**Text Colors**
```
--text-dark:         #f1f5f9    ████ Off White        - Main text, headings
--text-light:        #cbd5e1    ████ Light Gray       - Secondary text, descriptions
```

**Border & UI**
```
--border-color:      #475569    ████ Slate Gray       - Borders, dividers
```

#### CSS Variables Location

All variables are defined in `assets/css/main.css` at lines 8-19:

```css
:root {
    --primary-color: #06b6d4;
    --primary-dark: #0891b2;
    --primary-light: #22d3ee;
    --secondary-color: #14b8a6;
    --text-dark: #f1f5f9;
    --text-light: #cbd5e1;
    --bg-dark: #0f172a;
    --bg-darker: #020617;
    --bg-light: #1e293b;
    --bg-white: #334155;
    --border-color: #475569;
}
```

#### Color Usage Guidelines

**Primary Turquoise (`--primary-color`)** - Use for:
- Primary buttons (background)
- Hover states on cards and links
- Active navigation states
- Icon accents
- Call-to-action elements

**Dark Backgrounds** - Layer hierarchy:
1. `--bg-darker` (#020617) - Hero, CTA, navbar (top layer)
2. `--bg-dark` (#0f172a) - Body background (base layer)
3. `--bg-light` (#1e293b) - Content cards, sections (elevated)
4. `--bg-white` (#334155) - Form inputs, modals (most elevated)

**Text Colors** - Hierarchy:
- `--text-dark` (#f1f5f9) - Headings, primary content (high contrast)
- `--text-light` (#cbd5e1) - Descriptions, metadata (medium contrast)

**Special Effects:**
- Glow effects use `rgba(6, 182, 212, 0.3)` for turquoise glow
- Hover states often add `0 0 20px rgba(6, 182, 212, 0.5)` box-shadow

#### Changing the Color Scheme

**To update colors:**
1. Edit the `:root` variables in `assets/css/main.css` (lines 8-19)
2. Maintain contrast ratios for accessibility (WCAG AA: 4.5:1 for text)
3. Test hover states and interactive elements
4. Commit and push changes

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
