# CLAUDE.md - Project Maintenance Guide

This document contains all the information needed to understand and maintain this Jekyll-based personal website.

## Project Overview

This is a personal portfolio and blog website built with Jekyll and hosted on GitHub Pages. The site features a modern, responsive design with custom layouts and styles.

**Live Site:** https://christaylor.codes (primary) / https://christaylorcodes.github.io (GitHub Pages URL)
**Go-Live Date:** November 3, 2025
**Repository:** https://github.com/christaylorcodes/christaylorcodes.github.io
**Static Site Generator:** Jekyll
**Hosting:** GitHub Pages
**CDN/Security:** Cloudflare (proxied, cache enabled)
**DNS:** Cloudflare
**Owner:** Chris Taylor (ctaylor@christaylor.codes)

## Project Milestones

### Milestone 1: Website Launch ✅
- **Date:** November 3, 2025
- **Status:** Complete
- **Description:** Initial launch of christaylor.codes with custom domain, blog, projects showcase, and privacy compliance framework

### Milestone 2: 90-Day Post-Launch Review 🎯
- **Date:** February 1, 2026
- **Status:** Scheduled
- **Description:** Comprehensive review of website performance, content effectiveness, SEO, accessibility, and user engagement
- **Details:** See [TODO.md](TODO.md) for full review checklist
- **Coordinates with:** Quarterly maturity framework review (February 7, 2026)

## Key Documentation

This guide is part of a comprehensive documentation suite:

**Project Maintenance:**
- **CLAUDE.md** (this file) - Complete project maintenance guide and reference
- [README.md](README.md) - Setup, deployment, and quick start instructions
- [TODO.md](TODO.md) - Sprint planning and task tracking

**Site Maturity & Growth:**
- [WEBSITE-MATURITY-FRAMEWORK.md](WEBSITE-MATURITY-FRAMEWORK.md) - Comprehensive maturity assessment across 7 dimensions
  - Current overall maturity: Level 2.5 (Developing → Defined) - 37%
  - Quarterly review schedule and scoring methodology
  - Phased improvement roadmaps with specific tasks and timelines
  - Success metrics and tracking process
  - **Next quarterly review:** 2026-02-07

**Specialized Guides:**
- [DATA-DRIVEN-ARCHITECTURE.md](DATA-DRIVEN-ARCHITECTURE.md) - Quick reference for data-driven content management
- [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md) - Analytics configuration and monitoring guide
- [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md) - CDN and cache purging setup
- [BACKLINK-STRATEGY.md](BACKLINK-STRATEGY.md) - SEO backlink building and organic discovery strategy
- [SECURITY.md](SECURITY.md) - Security measures, standards compliance, and vulnerability tracking
- [SECURITY-HEADERS-SETUP.md](SECURITY-HEADERS-SETUP.md) - CSP and security headers (Cloudflare best practice)

**Use the maturity framework** to track and plan improvements across Privacy, Accessibility, Analytics, Content Strategy, Design Systems, Content Governance, and Automation.

## Site Structure

```
Website/
├── _config.yml              # Jekyll configuration
├── _data/                   # Centralized data files (YAML)
│   ├── contact.yml         # Contact info and social media links
│   ├── author.yml          # Professional identity and bio
│   └── project-stats.yml   # GitHub stars and gallery downloads
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
├── scripts/                 # Utility PowerShell scripts
├── docs/                    # Documentation
│   ├── archive/            # Historical documentation
│   └── examples/           # Design system component examples
├── prototypes/              # Design prototypes and exploration
├── oceanic.gemspec          # Gem specification for theme
├── build.ps1                # PowerShell build script
├── promote-to-main.ps1      # Dev to main promotion script
├── LICENSE                  # MIT License
├── Gemfile                  # Ruby dependencies
├── README.md                # Project documentation
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
- **Data-driven architecture:** Content is centralized in `_data/` YAML files (see Data-Driven Architecture section)
- No `.nojekyll` file should exist (Jekyll processing is required)

## Data-Driven Architecture

The site follows a **data-driven design principle** where content is separated from presentation. All frequently-updated or repeated information is centralized in YAML data files in the `_data/` directory.

**For a complete quick reference guide, see:** [DATA-DRIVEN-ARCHITECTURE.md](DATA-DRIVEN-ARCHITECTURE.md)

### Design Philosophy

**Separation of Concerns:**
- **Content** (what to display) lives in `_data/` YAML files
- **Presentation** (how to display) lives in templates (`_layouts/`, `_includes/`)
- **Styling** (visual appearance) lives in `_sass/` SCSS files

**Benefits:**
- **Single Source of Truth:** Update content once, affects all pages
- **Maintainability:** No hunting through templates to update contact info or bio
- **Consistency:** Guaranteed synchronization across all pages
- **Scalability:** Easy to add new social platforms, update stats, or change roles
- **Error Prevention:** No risk of forgetting to update one location

### Centralized Data Files

#### 1. Contact Information (`_data/contact.yml`)

**Purpose:** Centralizes all contact information and social media profiles.

**Contains:**
- Primary email address and description
- Social media links (GitHub, LinkedIn, Twitter/X)
  - Username, URL, display name, icon, color style
  - Descriptions for each platform
  - Visibility flags (`show_in_footer`, `show_on_contact`)
- Social profiles array for structured data (schema.org)

**Used By:**
- [_includes/footer.html](c:\_Code\Website\_includes\footer.html) - Social links in footer
- [contact.html](c:\_Code\Website\contact.html) - Contact method cards
- [_includes/structured-data-website.html](c:\_Code\Website\_includes\structured-data-website.html) - JSON-LD schema
- [_includes/structured-data-person.html](c:\_Code\Website\_includes\structured-data-person.html) - JSON-LD schema

**Example Usage:**
```liquid
{{ site.data.contact.email }}
{{ site.data.contact.social_links.github.url }}
```

**To Add a New Social Platform:**
Edit `_data/contact.yml` and add:
```yaml
mastodon:
  username: christaylor
  url: "https://mastodon.social/@christaylor"
  display: "@christaylor"
  icon: "fab fa-mastodon"
  icon_style: "icon-purple"
  description: "Updates and discussions"
  show_in_footer: true
  show_on_contact: true
```
Automatically appears in footer, contact page, and structured data.

#### 2. Author/Professional Identity (`_data/author.yml`)

**Purpose:** Centralizes all professional identity, biographical information, and expertise.

**Contains:**
- Basic identity (name, first/last name)
- Professional titles and roles
- Experience years and description
- Company, location, personal interests
- About page statistics (years, projects, posts, PowerShell lines)
- Quick facts sidebar data
- Biographical paragraphs
- Expertise, skills, and services
- Structured data fields for schema.org

**Used By:**
- [index.html](c:\_Code\Website\index.html) - Hero section (name, title, description)
- [about.html](c:\_Code\Website\about.html) - Stats, quick facts, bio paragraphs
- [_includes/structured-data-website.html](c:\_Code\Website\_includes\structured-data-website.html) - Author/founder info
- [_includes/structured-data-person.html](c:\_Code\Website\_includes\structured-data-person.html) - Complete person schema

**Example Usage:**
```liquid
{{ site.data.author.name }}
{{ site.data.author.roles_short }}
{{ site.data.author.experience_years }}
```

**To Update Annual Stats:**
Edit `_data/author.yml`:
```yaml
experience_years: "21+"  # Update annually
about_highlights:
  - icon: fa-blog
    number: "15+"  # Update quarterly
    label: "Blog Posts"
```

#### 3. Project Statistics (`_data/project-stats.yml`)

**Purpose:** Centralizes GitHub stars and PowerShell Gallery download counts for all projects.

**Contains:**
- GitHub star counts (per project)
- PowerShell Gallery download counts (per project)
- Last updated timestamp

**Used By:**
- [index.html](c:\_Code\Website\index.html) - Homepage podium (top 3 projects)
- [projects.html](c:\_Code\Website\projects.html) - Project cards with stats
- [_layouts/project.html](c:\_Code\Website\_layouts\project.html) - Individual project pages

**Example Usage:**
```liquid
{% assign stats = site.data.project-stats[project_id] %}
{{ stats.stars }} stars
{{ stats.gallery_downloads }} downloads
```

**To Update Stats:**
Run the sync script:
```powershell
.\scripts\sync-project-stats.ps1 -FetchGalleryStats
```
Or manually edit `_data/project-stats.yml`.

### Data-Driven Updates: Common Scenarios

**Change Email Address:**
1. Edit `_data/contact.yml` → Change `email: ctaylor@christaylor.codes`
2. Commit and push
3. Affects: Footer, contact page, all structured data (5+ locations)

**Update Job Title:**
1. Edit `_data/author.yml` → Change `title:` and `structured_data.job_title:`
2. Commit and push
3. Affects: Homepage hero, about page, structured data (10+ locations)

**Add New Social Platform:**
1. Add platform to `_data/contact.yml` → `social_links:`
2. Add URL to `social_profiles:` array
3. Commit and push
4. Automatically appears in footer, contact page, structured data

**Update Blog Post Count:**
1. Edit `_data/author.yml` → Find `about_highlights` → Update blog `number:`
2. Commit and push
3. Affects: About page statistics section

**Change Company:**
1. Edit `_data/author.yml` → Change `company:` and `company_description:`
2. Commit and push
3. Affects: About page quick facts, structured data

### Best Practices

**When to Use Data Files:**
- Information appears in 2+ locations
- Content updates frequently (stats, counts)
- Adding/removing items from lists (social platforms, skills)
- Professional information (name, title, company)
- Contact information

**When to Keep Content in Templates:**
- Unique, page-specific content
- Long-form prose (blog posts, project descriptions)
- One-off sections with no reuse
- Navigation structure (rarely changes)

**Updating Guidelines:**
1. **Always check data files first** before editing templates
2. **Update once** in the data file, not in multiple templates
3. **Verify changes** locally with `.\build.ps1` before committing
4. **Document additions** with comments in YAML files
5. **Test structured data** with Google's Rich Results Test after major changes

## Oceanic Theme Structure

The site uses a custom-built Jekyll theme called **"Oceanic"** that follows official Jekyll theme conventions. The theme is structured for potential future distribution as a RubyGems package.

### Theme Architecture

**SCSS Organization** (`_sass/oceanic/`):
The monolithic CSS file has been refactored into 14 modular SCSS partials for better maintainability:

1. **`_variables.scss`** (45 lines) - CSS custom properties, color system, shadows
2. **`_base.scss`** (50 lines) - Reset, body, typography, container, sections, width strategy
3. **`_navigation.scss`** (125 lines) - Navbar, logo, mobile menu, hamburger
4. **`_hero.scss`** (60 lines) - Hero sections, highlights, buttons container
5. **`_buttons.scss`** (145 lines) - Button components with color variations (primary, secondary, cyan, amber, orange, red)
6. **`_features.scss`** (70 lines) - Feature cards and grid
7. **`_posts.scss`** (670 lines) - Blog list, posts, categories, content styles, code blocks, filter buttons, category badges with color variations
8. **`_projects.scss`** (110 lines) - Project cards, grid, CTA section
9. **`_contact.scss`** (85 lines) - Contact page, method cards, form styles
10. **`_about.scss`** (110 lines) - About page, photo, skills grid, quote
11. **`_footer.scss`** (60 lines) - Footer, social links, copyright
12. **`_syntax.scss`** (200 lines) - Rouge syntax highlighting with Oceanic color scheme
13. **`_animations.scss`** (45 lines) - Keyframe animations (fadeInUp)
14. **`_responsive.scss`** (130 lines) - Media queries for 768px and 480px breakpoints

**Main Import File** (`_sass/oceanic.scss`):
Imports all partials in the correct order (variables → base → components → syntax → animations → responsive).

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
- **[docs/archive/THEME-README.md](docs/archive/THEME-README.md)** - Complete theme documentation for users

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
short_title: "Short Title"  # Optional: Shorter version for blog cards
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

**Post Field Definitions:**
- `layout`: Always use `post` layout
- `title`: Full title of the post (appears in post header, browser tab, and social media)
- `short_title` (Optional): Shorter version for blog cards (recommended: 3-7 words, ~50 characters max)
  - Use when the full title is too long for card layouts
  - If not provided, the full `title` will be used in cards
  - Example: Full title "Introducing ConnectWiseAutomateAgent: PowerShell Automation for Your RMM" → Short title "ConnectWiseAutomateAgent"
- `date`: Publication date and time
- `categories`: 1-2 broad categories
- `tags`: 3-6 specific topics
- `author`: Post author name
- `excerpt`: Brief summary for post previews and search results (standardized at 50 words, 8th grade reading level)
  - **Length**: Target 50 words (acceptable range: 45-55 words)
  - **Reading Level**: 8th grade (clear, accessible language that anyone can understand)
  - **Purpose**: Appears on blog cards, search results, and social media previews
  - **Style**: Concise, direct, and engaging using simple vocabulary
  - **Content**: Should answer "What problem does this solve?" and "What will I learn?"
  - **Guidelines**:
    - Use active voice and simple words
    - Keep sentences short and punchy
    - Focus on one main benefit or outcome
    - Be specific, not abstract
  - **Examples**: See existing posts for reference patterns

**Post Features:**
- Automatic post navigation (previous/next)
- Social sharing buttons
- Category and tag display
- Code syntax highlighting (Rouge with Oceanic theme)
- Responsive images
- SEO optimization via jekyll-seo-tag

**Code Syntax Highlighting:**
The site uses Rouge syntax highlighter with a custom Oceanic-themed color scheme that matches the site's design:
- **Supported languages**: PowerShell, Python, JavaScript, TypeScript, Bash, YAML, JSON, and 100+ others
- **Color scheme**: Dark theme with cyan keywords, amber operators, green strings, matching the Oceanic palette
- **Usage**: Use markdown code fences with language specification:
  ```
  ```powershell
  Get-Process | Where-Object CPU -gt 10
  ```
  ```
- **Wide code support**: Code blocks are 1100px wide (breaks out of normal 800px content width) to support 120+ character lines without horizontal scrolling
- **Styling location**: [_sass/oceanic/_syntax.scss](_sass/oceanic/_syntax.scss)
- **Configuration**: [_config.yml](_config.yml) - kramdown with Rouge, GFM (GitHub Flavored Markdown) input

### Adding Projects

1. Create a new file in `_projects/` with format: `project-name.md`
2. Add front matter:

```yaml
---
layout: project
title: Project Name
icon: fa-icon-name
category: PowerShell
short_description: Brief, concise description for the project card (135-145 characters recommended)
description: |
  Longer detailed description with multiple paragraphs explaining features,
  benefits, and technical details. This appears on the project detail page.
tags:
  - Technology 1
  - Technology 2
demo_url: "https://demo.com"
github_url: "https://github.com/user/repo"
powershell_gallery_url: "https://www.powershellgallery.com/packages/PackageName"
stars: 42
gallery_downloads: 15000
order: 1
---
```

3. Commit and push to deploy

**Project Field Definitions:**
- `layout`: Always use `project` layout
- `title`: Display name
- `icon`: Font Awesome icon class (e.g., `fa-rocket`, `fa-code`, `fa-plug`)
- `category`: Project category (e.g., `PowerShell`, `ConnectWiseManageAPI`)
- `short_description`: Concise text shown on project card (135-145 characters for visual consistency)
- `description`: Extended multi-paragraph description with technical details
- `tags`: List of technologies used
- `demo_url`: Link to live demo (optional)
- `github_url`: Link to repository
- `powershell_gallery_url`: PowerShell Gallery link (if applicable)
- `stars`: GitHub repository star count (used for homepage podium ranking)
- `gallery_downloads`: PowerShell Gallery total download count (optional, displays on project cards and detail pages)
  - **Special Case:** PSGallery Initializer displays 🐔🥚 (chicken and egg emojis) instead of download count as a playful reference to the circular dependency problem it solves
- `order`: Display order (lower numbers appear first)

**Short Description Guidelines:**
- **Length**: 135-145 characters for uniform visual appearance across project cards
- **Structure**: Start with action verb (e.g., "Simplifies", "Automates", "Enables")
- **Content**: Focus on primary value proposition and key benefits
- **Clarity**: Be specific about what the project does and who it's for
- **Examples**:
  - "Simplifies Azure Key Vault integration with automatic serialization, PSCredential management, and secure string operations for PowerShell." (140 chars)
  - "Automate remote support operations and integrate ConnectWise Control into ticketing workflows and monitoring systems with clean PowerShell cmdlets." (141 chars)

### Adding Project Images

Projects can include a hero image and screenshot gallery to visually showcase functionality. Both fields are optional.

**Adding Images to Projects:**

1. **Prepare your images** (see specifications below)
2. **Add images** to `assets/images/projects/` directory
3. **Update project front matter** with image paths:

```yaml
---
layout: project
title: Project Name
# ... other fields ...
image: /assets/images/projects/project-name-hero.png
screenshots:
  - /assets/images/projects/project-name-screenshot-1.png
  - /assets/images/projects/project-name-screenshot-2.png
  - /assets/images/projects/project-name-screenshot-3.png
---
```

**Image Field Definitions:**

- `image`: Hero image displayed prominently at top of project detail page (optional)
  - Single main image that represents the project
  - Use for architecture diagrams, main interface screenshots, or branded hero images
  - Recommended size: 1200x630px (16:9 aspect ratio)
  - Maximum file size: 500KB (optimize for web)
  - Omit field if no hero image available

- `screenshots`: Array of screenshot images in gallery grid (optional)
  - Multiple images showcasing different features or aspects
  - Use for feature demonstrations, UI examples, code samples, terminal output
  - Recommended size: 800x600px or 1920x1080px (maintain 4:3 or 16:9 aspect ratio)
  - Maximum file size: 300KB each (optimize for web)
  - Maximum 6 screenshots recommended for performance
  - Omit field if no screenshots available

**Image Specifications:**

**Hero Images:**
- **Dimensions**: 1200x630px (16:9 aspect ratio for consistency)
- **Format**: PNG (for screenshots/diagrams) or JPG (for photos)
- **Color**: Should work well on dark background (site uses dark theme)
- **Content**: Clean, professional, readable at thumbnail size
- **File naming**: `project-name-hero.png` (lowercase, hyphenated)

**Screenshots:**
- **Dimensions**:
  - 800x600px for UI screenshots (4:3 ratio)
  - 1920x1080px for full desktop screenshots (16:9 ratio)
  - Maintain consistent aspect ratio for visual uniformity
- **Format**: PNG for sharp text/code, JPG for photos
- **Content**: Focus on key features, one concept per screenshot
- **File naming**: `project-name-description-N.png` (e.g., `connectwisemanageapi-terminal-1.png`)

**Creating PowerShell Terminal Screenshots:**

For PowerShell modules, terminal screenshots are highly effective:

1. **Use Windows Terminal or VS Code integrated terminal** for modern appearance
2. **Set appropriate font size** (14-16pt for readability in screenshots)
3. **Use syntax highlighting** (ensure colors show correctly)
4. **Include context**:
   - Module import command
   - Example usage showing key cmdlets
   - Output demonstrating value/results
5. **Keep it concise**: 10-20 lines maximum for readability
6. **Crop tightly**: Remove unnecessary borders/whitespace

**Example Terminal Screenshot Content:**
```powershell
PS C:\> Import-Module ConnectWiseManageAPI
PS C:\> Connect-CWM -Server "https://api.connectwise.com" -Company "YourCompany"
Connected to ConnectWise Manage

PS C:\> Get-CWMTicket -Status Open | Where-Object Priority -eq "Critical" | Select Subject, Board, Owner
Shows results demonstrating the module in action
```

**Creating Architecture/Diagram Images:**

For modules without visual UI, create diagrams:

1. **Show data flow**: How the module interacts with APIs/systems
2. **Highlight key features**: What problems it solves
3. **Use brand colors**: Incorporate oceanic theme colors (cyan #06b6d4, amber #f59e0b)
4. **Keep it simple**: Clear, uncluttered diagrams
5. **Tools**: PowerPoint, Figma, draw.io, or similar

**Optimizing Images for Web:**

Before adding images to the site:

1. **Resize**: Use exact recommended dimensions (no larger)
2. **Compress**:
   - PNG: Use TinyPNG.com or similar (lossless compression)
   - JPG: Save at 80-85% quality
3. **Verify file size**: Must be under specified limits
4. **Test on dark background**: Ensure images look good on site's dark theme

**Image Best Practices:**

- Use consistent dimensions across all projects for visual uniformity
- Include descriptive alt text (handled automatically by layout)
- Images load lazily for performance
- Screenshots have hover effects (lift and glow)
- Hero images are full-width, screenshots are in responsive grid
- Test responsive behavior on mobile devices

**Tools for Creating Project Images:**

- **Screenshots**: Windows Snipping Tool, ShareX, Greenshot
- **Optimization**: TinyPNG, Squoosh.app, ImageOptim
- **Editing**: GIMP, Paint.NET, Photoshop
- **Diagrams**: Draw.io, Lucidchart, Figma, PowerPoint
- **Terminal**: Windows Terminal, VS Code, ConEmu

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
- [ ] Markdown linting passes (run `markdownlint _posts/YYYY-MM-DD-post.md`)
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

**Short Description Best Practices:**
- **Standardized length**: 135-145 characters for visual consistency across project cards
- Lead with action verb (Simplifies, Automates, Enables, etc.)
- Focus on primary value proposition and key benefits
- Be specific about what the project does and target audience
- Mention 2-3 key features or capabilities
- Use active voice and strong verbs

**Extended Description Best Practices:**
- Lead with the benefit/value proposition in first paragraph
- Explain what problem it solves and why it matters
- Provide technical details about implementation and features
- Mention key capabilities with specific examples
- Keep under 200 words per paragraph for readability
- Use active voice and descriptive language

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

#### Markdown Formatting Standards

All markdown content (blog posts, documentation) should follow these formatting standards enforced by markdownlint during CI/CD builds:

**Configuration:** [.markdownlint.json](.markdownlint.json)

**Required Standards (Enforced):**

1. **Heading Hierarchy (MD001)**
   - Heading levels must increment by one level at a time
   - Don't skip from H1 to H3
   - Example: H1 → H2 → H3 (correct), H1 → H3 (incorrect)

2. **Heading Style (MD003)**
   - Use ATX-style headings with `#` symbols
   - Example: `## Heading` (correct), not underlined with `===` (incorrect)

3. **List Style (MD004)**
   - Use dashes `-` for unordered lists (not `*` or `+`)
   - Be consistent throughout document

4. **List Indentation (MD007)**
   - Indent nested list items by 2 spaces
   - Example:
     ```markdown
     - Parent item
       - Child item (2 spaces)
     ```

5. **Heading Uniqueness (MD024)**
   - No duplicate headings at the same level
   - Siblings_only mode: duplicates allowed if not adjacent

6. **Heading Punctuation (MD026)**
   - No trailing punctuation in headings (`.`, `,`, `;`, `:`, `!`)
   - Example: `## Overview` (correct), `## Overview.` (incorrect)

7. **Code Block Style (MD046)**
   - Use fenced code blocks with triple backticks
   - Example: ` ```powershell ` (correct), not indented code blocks (incorrect)

8. **Bold Style (MD050)**
   - Use asterisks for bold: `**bold text**`
   - Be consistent throughout document

**Relaxed Standards (Best Practices, Not Enforced):**

These are recommended but not enforced by CI/CD to accommodate existing content:

1. **Blank Lines (MD022, MD031, MD032)**
   - **Best Practice:** Add blank lines before/after headings, code blocks, and lists
   - Improves readability and visual separation
   - Example:
     ```markdown
     Paragraph text.

     ## New Section

     More paragraph text.
     ```

2. **Code Language Specification (MD040)**
   - **Best Practice:** Always specify language for code blocks
   - Enables syntax highlighting and improves clarity
   - Example: ` ```powershell ` instead of just ` ``` `
   - Supported languages: powershell, python, javascript, bash, yaml, json, etc.

3. **Emphasis Style (MD049)**
   - **Best Practice:** Use underscores for italics: `_italic text_`
   - Be consistent within each document

4. **Single H1 Heading (MD025)**
   - **Best Practice:** Only one H1 (`#`) heading per document
   - Typically the page/post title
   - Use H2 (`##`) for main sections

5. **HTML in Markdown (MD033)**
   - HTML is allowed when markdown can't achieve desired formatting
   - Use sparingly and prefer markdown when possible

**Why These Standards Matter:**

- **Consistency:** Uniform formatting across all content
- **Readability:** Easier for humans to read and scan
- **Accessibility:** Screen readers parse well-formatted markdown better
- **Maintainability:** Easier to update and refactor content
- **SEO:** Search engines favor well-structured content
- **Quality Assurance:** Automated linting catches formatting issues early

**Linting in CI/CD:**

The dev branch workflow (`.github/workflows/dev-build.yml`) automatically runs markdown linting on all `_posts/*.md` files:

```yaml
- name: Lint markdown
  uses: nosborn/github-action-markdown-cli@v3.3.0
  with:
    files: _posts/*.md
    config_file: .markdownlint.json
```

**Local Linting:**

Test your markdown before pushing:

```bash
# Install markdownlint-cli globally
npm install -g markdownlint-cli

# Lint all blog posts
markdownlint _posts/*.md

# Lint specific file
markdownlint _posts/2024-01-01-my-post.md
```

**Quick Reference Checklist:**

When creating new blog posts or documentation:

- [ ] Use ATX-style headings (`#`, `##`, `###`)
- [ ] Increment heading levels by one (no skipping)
- [ ] Use dashes (`-`) for unordered lists
- [ ] Indent nested lists by 2 spaces
- [ ] No trailing punctuation in headings
- [ ] Use fenced code blocks (` ``` `)
- [ ] Specify language for all code blocks (recommended)
- [ ] Add blank lines around headings, lists, code (recommended)
- [ ] Use `**bold**` for bold, `_italic_` for italics (recommended)
- [ ] One H1 heading per document (recommended)

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

### Button System

The Oceanic theme includes a comprehensive, standardized button system with multiple color variations based on the Oceanic palette. All buttons use consistent styling, hover effects, and transitions throughout the site.

**Styles Location:** [_sass/oceanic/_buttons.scss](_sass/oceanic/_buttons.scss)

#### Button Classes

**Base Classes:**
- `.btn` - Base button class (required on all buttons)
- `.btn-primary` - Solid filled button
- `.btn-secondary` - Outlined transparent button

**Color Modifiers:**
- `.btn-cyan` - Cyan/primary brand color
- `.btn-amber` - Amber/warm accent color
- `.btn-orange` - Orange/call-to-action color
- `.btn-red` - Red/warning color
- No modifier - Emerald green (default button color)

#### Usage Examples

```html
<!-- Standard buttons (Emerald Green) -->
<a href="#" class="btn btn-primary">Primary Button</a>
<a href="#" class="btn btn-secondary">Secondary Button</a>

<!-- Color variations -->
<a href="#" class="btn btn-primary btn-cyan">Cyan Button</a>
<a href="#" class="btn btn-primary btn-amber">Amber Button</a>
<a href="#" class="btn btn-primary btn-orange">Orange Button</a>
<a href="#" class="btn btn-primary btn-red">Delete Button</a>

<!-- With icons -->
<a href="#" class="btn btn-primary">
    <i class="fas fa-download"></i> Download
</a>
```

#### Button Color Guide

**Emerald Green (Default - no modifier):**
- **Color:** #10b981
- **Use for:** Primary actions, form submissions, main CTAs
- **Example:** "View My Work", "Submit", "Download"

**Cyan (.btn-cyan):**
- **Color:** #06b6d4
- **Use for:** Brand-focused actions, navigation highlights
- **Example:** "View on GitHub", brand-specific CTAs

**Amber (.btn-amber):**
- **Color:** #f59e0b
- **Use for:** Secondary branding, warm highlights, alternative CTAs
- **Example:** Secondary feature buttons

**Orange (.btn-orange):**
- **Color:** #ea580c
- **Use for:** High-priority actions, urgent notifications
- **Example:** "Upgrade Now", important actions

**Red (.btn-red):**
- **Color:** #dc2626
- **Use for:** Destructive actions, warnings, delete confirmations
- **Example:** "Delete", "Remove", "Cancel Subscription"

#### Button States

All buttons include consistent hover effects:
- **Lift animation:** `translateY(-2px)` for tactile feedback
- **Glow effect:** Color-matched shadow (e.g., `0 0 20px rgba(6, 182, 212, 0.5)`)
- **Color shift:** Slightly lighter shade on hover
- **Smooth transition:** 0.3s ease for all properties

**Example:** View live button examples at [docs/examples/buttons.html](docs/examples/buttons.html)

#### Best Practices

1. **Hierarchy:** Use `.btn-primary` for primary actions, `.btn-secondary` for secondary actions
2. **Color meaning:** Reserve red for destructive actions, orange for high-priority
3. **Consistency:** Stick to emerald green (default) for most primary buttons
4. **Icons:** Add Font Awesome icons for visual clarity when appropriate
5. **Accessibility:** Buttons maintain WCAG AA contrast ratios in all color variations

### Filter Button System

The Oceanic theme includes a standardized filter button system for category filtering, content organization, and selection interfaces. These buttons have a distinct pill-shaped design optimized for filtering use cases.

**Styles Location:** [_sass/oceanic/_posts.scss:144-276](_sass/oceanic/_posts.scss#L144-L276)

#### Filter Button Classes

**Base Classes:**
- `.filter-buttons` - Container for filter button groups
- `.filter-btn` - Base filter button class (required on all filter buttons)
- `.active` - Active/selected state

**Color Modifiers:**
- `.filter-cyan` - Cyan/primary brand color (default)
- `.filter-emerald` - Emerald green for success states
- `.filter-amber` - Amber for warning/in-progress states
- `.filter-orange` - Orange for priority/urgent filters
- `.filter-red` - Red for error/deprecated items

**Additional Components:**
- `.filter-count` - Badge showing item count
- `.filter-dropdown` - Dropdown container for overflow categories
- `.filter-dropdown-btn` - Dropdown trigger button
- `.filter-dropdown-menu` - Dropdown menu container

#### Usage Examples

```html
<!-- Standard filter buttons -->
<div class="filter-buttons">
    <button class="filter-btn active">All</button>
    <button class="filter-btn">Category <span class="filter-count">5</span></button>
</div>

<!-- Color variations -->
<button class="filter-btn filter-cyan active">Cyan</button>
<button class="filter-btn filter-emerald">Emerald</button>
<button class="filter-btn filter-amber">Amber</button>
<button class="filter-btn filter-orange">Orange</button>
<button class="filter-btn filter-red">Red</button>

<!-- With dropdown for overflow -->
<div class="filter-buttons">
    <button class="filter-btn active">All</button>
    <button class="filter-btn">Category 1</button>
    <div class="filter-dropdown">
        <button class="filter-btn filter-dropdown-btn">
            More <i class="fas fa-chevron-down"></i>
        </button>
        <div class="filter-dropdown-menu">
            <button class="filter-btn filter-dropdown-item">Hidden Category</button>
        </div>
    </div>
</div>
```

#### Filter Button Color Guide

All filter button colors use CSS variables from the Oceanic palette defined in [_sass/oceanic/_variables.scss](_sass/oceanic/_variables.scss).

**Cyan (Default):**
- **Color:** #06b6d4 (--primary-color)
- **Use for:** Primary filtering, blog categories, main content filters
- **Example:** Blog post category filters

**Emerald Green (.filter-emerald):**
- **Color:** #10b981 (--button-color)
- **Use for:** Success states, positive filters, active selections
- **Example:** "Active Projects", "Published", "Available"

**Amber (.filter-amber):**
- **Color:** #f59e0b (--secondary-color)
- **Use for:** Warning states, in-progress filters, pending items
- **Example:** "In Progress", "Review Needed", "Beta"

**Red (.filter-red):**
- **Color:** #dc2626 (--accent-rust)
- **Use for:** Error states, blocked items, deprecated content
- **Example:** "Issues", "Deprecated", "Failed"

#### Filter Button States

Filter buttons support three interactive states:
- **Default:** Dark background with subtle border
- **Hover:** Color-matched background with lift animation
- **Active:** Solid color background with glow effect

**Key Features:**
- Smaller padding (`0.5rem 1rem`) compared to action buttons
- Pill-shaped design for visual distinction from action buttons
- Active state persists to show current selection
- Optional count badges for displaying item quantities
- Dropdown support for handling many categories

#### Differences from Action Buttons

**Filter Buttons vs. Action Buttons:**

| Feature | Filter Buttons | Action Buttons |
|---------|---------------|----------------|
| **Purpose** | Selection/filtering | Navigation/actions |
| **Size** | Smaller (0.5rem padding) | Larger (0.875rem padding) |
| **States** | Default, hover, active | Default, hover |
| **Default Color** | Cyan | Emerald green |
| **Visual Style** | Pill-shaped, subtle | Prominent, bold |
| **Count Badges** | Yes | No |
| **Dropdown Support** | Yes | No |

**Example:** View live filter button examples at [docs/examples/categories.html](docs/examples/categories.html)

#### Best Practices

1. **Use appropriate colors:** Match filter color to semantic meaning (green=good, red=bad, amber=caution)
2. **Keep labels concise:** Filter button labels should be 1-2 words
3. **Show counts:** Include count badges when displaying item quantities
4. **Active state:** Always indicate which filter is currently selected
5. **Overflow handling:** Use dropdown menu when there are 10+ categories
6. **Consistent grouping:** Keep filter buttons in `.filter-buttons` containers

### Category Badge System

The Oceanic theme includes a standardized badge system for labeling content, displaying categories, and organizing information with visual tags. These badges are non-interactive with colorful gradient backgrounds.

**Styles Location:** [_sass/oceanic/_posts.scss:379-435](_sass/oceanic/_posts.scss#L379-L435)

#### Badge Classes

**Base Classes:**
- `.post-card-categories` - Container for badge groups
- `.category-badge` - Base badge class (required on all badges)

**Color Modifiers:**
- `.badge-cyan` - Cyan/primary brand color (default)
- `.badge-emerald` - Emerald green for success/stable
- `.badge-amber` - Amber for in-progress/beta
- `.badge-red` - Red for deprecated/critical
- `.badge-purple` - Purple for new/experimental/AI

#### Usage Examples

```html
<!-- Standard category badges -->
<span class="category-badge">PowerShell</span>
<span class="category-badge">Automation</span>

<!-- Color variations -->
<span class="category-badge badge-cyan">Tutorial</span>
<span class="category-badge badge-emerald">Stable</span>
<span class="category-badge badge-amber">Beta</span>
<span class="category-badge badge-red">Deprecated</span>
<span class="category-badge badge-purple">New</span>

<!-- In post card header -->
<div class="post-card-categories">
    <span class="category-badge">Category 1</span>
    <span class="category-badge badge-emerald">Category 2</span>
</div>
```

#### Badge Color Guide

All badge gradients align with the Oceanic color palette defined in [_sass/oceanic/_variables.scss](_sass/oceanic/_variables.scss).

**Cyan (Default):**
- **Gradient:** #0284c7 → #06b6d4 → #38bdf8
- **Palette:** primary-dark → primary → primary-light
- **Use for:** General categories, primary content labels, default tags
- **Example:** "PowerShell", "Automation", "Tutorial"

**Emerald Green (.badge-emerald):**
- **Gradient:** #059669 → #10b981 → #34d399
- **Palette:** button-dark → button → button-light
- **Use for:** Success states, completed items, stable releases
- **Example:** "Stable", "Production", "Released", "Verified"

**Amber (.badge-amber):**
- **Gradient:** #d97706 → #f59e0b → #fbbf24
- **Palette:** Based on secondary-color
- **Use for:** In-progress content, beta features, pending updates
- **Example:** "Beta", "In Progress", "Draft", "Review"

**Red (.badge-red):**
- **Gradient:** #b91c1c → #dc2626 → #f87171
- **Palette:** Based on accent-rust
- **Use for:** Deprecated content, breaking changes, critical issues
- **Example:** "Deprecated", "Breaking", "Critical", "Alert"

**Purple (.badge-purple):**
- **Gradient:** #7e22ce → #a855f7 → #d8b4fe
- **Palette:** Independent purple scale
- **Use for:** Special content, new features, experimental, AI-related
- **Example:** "New", "Experimental", "Preview", "AI"

#### Badge Characteristics

**Visual Properties:**
- **Non-interactive:** Visual labels only, no hover or click states
- **Gradient backgrounds:** Three-color gradients for depth and visual interest
- **Pill shape:** 1rem border-radius for friendly appearance
- **Small size:** 0.875rem font with 0.25rem × 0.75rem padding
- **Capitalized text:** Automatic text-transform for consistency
- **White text:** High contrast on all colored backgrounds

#### Badge vs. Filter Button Comparison

| Feature | Category Badges | Filter Buttons |
|---------|----------------|----------------|
| **Purpose** | Visual labels | Interactive selection |
| **States** | None (static) | Default, hover, active |
| **Background** | Gradient | Solid color |
| **Size** | Smaller (0.25rem padding) | Medium (0.5rem padding) |
| **Border** | None | 1px solid border |
| **Interactive** | No | Yes |
| **Use Case** | Content categorization | Content filtering |

**Example:** View live badge examples at [docs/examples/badges.html](docs/examples/badges.html)

#### Best Practices

1. **Semantic colors:** Use colors that match the content meaning (green=good, red=warning, etc.)
2. **Keep labels short:** Badge text should be 1-3 words maximum
3. **Multiple badges:** Combine badges with different colors to show various aspects
4. **Consistent placement:** Display badges above post titles or project descriptions
5. **Don't overuse:** Limit to 2-4 badges per item to avoid visual clutter
6. **Primary color default:** Use default cyan for most content categories

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

## Local Development & Testing

### Quick Start

Use the provided PowerShell build script for streamlined local development:

```powershell
# Serve with live reload (default)
.\build.ps1

# Build only
.\build.ps1 -Mode build

# Clean build artifacts
.\build.ps1 -Mode clean
```

Visit: **http://localhost:4000**

### Manual Commands

If not using the build script:

```bash
# First time setup
bundle install

# Serve with live reload (recommended)
bundle exec jekyll serve --livereload

# Build only
bundle exec jekyll build

# Clean and rebuild
rm -rf _site .jekyll-cache && bundle exec jekyll build
```

### Essential Testing Checklist

Before committing changes, verify:

**Build Success:**
- [ ] Jekyll build completes without errors
- [ ] `_site/assets/css/styles.css` exists (~30-40KB)
- [ ] No console errors in browser DevTools (F12)

**Visual Verification:**
- [ ] Homepage loads with correct styling (Electric Blue accents)
- [ ] Navigation works (desktop bar, mobile hamburger menu)
- [ ] Hover effects work (cards lift with cyan glow)
- [ ] Blog posts display with syntax highlighting
- [ ] Responsive design works at 768px and 480px breakpoints

**Page-Specific Checks:**
- [ ] All navigation links work
- [ ] Blog post content is readable
- [ ] Code blocks have proper syntax highlighting
- [ ] Images display correctly
- [ ] Footer and social links render

### Common Issues

**Styles don't load (blank page):**
- Check browser console for 404 on styles.css
- Verify `assets/css/styles.scss` has front matter (`---` dashes)
- Rebuild: `.\build.ps1 -Mode clean` then `.\build.ps1 -Mode build`

**SCSS compilation error:**
- Check terminal for specific file/line number
- Verify all `@import` paths in `_sass/oceanic.scss`
- Clear cache: `.\build.ps1 -Mode clean`

**Hover effects missing:**
- Check if CSS loaded completely
- Verify browser supports transitions (not IE)
- Test in different browser

**Port 4000 already in use:**
```bash
bundle exec jekyll serve --port 4001
```

### Build Script Details

The `build.ps1` script automatically:
- Verifies Ruby and Bundler installation
- Checks for and installs dependencies
- Provides colored status output
- Reports compiled CSS size
- Handles errors gracefully

**Script Parameters:**
- `serve` (default): Build + serve with live reload
- `build`: Build only, output to `_site/`
- `clean`: Remove all build artifacts

## Deployment

### Infrastructure Overview

The site uses a multi-layer infrastructure stack:

**Hosting Stack:**
- **GitHub Pages**: Static site hosting with automatic Jekyll builds
- **Cloudflare CDN**: Content delivery network with caching and security
- **Custom Domain**: christaylor.codes (primary)
- **GitHub URL**: christaylorcodes.github.io (fallback)

**Deployment Flow:**
```
Local Changes → GitHub → Jekyll Build → GitHub Pages → Cloudflare CDN → Users
     ↓              ↓           ↓             ↓              ↓
  git push    Actions Run   Build Site   Deploy Site   Purge Cache
```

### GitHub Pages Setup

1. Repository must be named: `christaylorcodes.github.io`
2. GitHub Pages source: **GitHub Actions** (custom workflow)
3. Custom domain: `christaylor.codes` (configured in repository settings)
4. Automatic builds on push to `main` branch

### Cloudflare Configuration

**DNS Settings:**
- Hosted at Cloudflare
- Proxied (orange cloud) for CDN and security features
- CNAME record: `christaylor.codes` → `christaylorcodes.github.io`

**Caching:**
- Cache level: Everything
- Automatic cache purging via GitHub Actions
- Brotli compression: Enabled
- HTTP/2 and HTTP/3: Enabled

**Security:**
- SSL/TLS mode: Full (strict)
- Always use HTTPS: Enabled
- Cloudflare WAF: Default filtering
- No custom firewall rules

**Performance:**
- Auto minify: Managed by Jekyll/Cloudflare
- Browser cache TTL: Respect existing headers
- Edge cache TTL: Default

### Automated Cache Purging

The site uses a GitHub Actions workflow that automatically purges Cloudflare cache after successful deployment.

**Workflow:** `.github/workflows/deploy.yml`

**Jobs:**
1. **Build**: Compile Jekyll site with production settings
2. **Deploy**: Publish to GitHub Pages
3. **Purge Cache**: Clear Cloudflare cache for entire zone

**Setup Required:**

GitHub Secrets (already configured):
- `CLOUDFLARE_API_TOKEN` - API token with cache purge permission
- `CLOUDFLARE_ZONE_ID` - Zone ID for christaylor.codes

**For detailed setup instructions**, see: [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md)

### Automated Project Statistics Updates

The site uses a GitHub Actions workflow that automatically updates GitHub star counts and PowerShell Gallery download counts for all projects.

**Workflow:** `.github/workflows/update-project-stats.yml`

**Schedule:**
- Runs weekly on Mondays at 9 AM UTC (1 AM PST / 2 AM PDT)
- Can be triggered manually via workflow_dispatch

**Process:**
1. **Fetch GitHub Stars**: Queries GitHub API for star counts from all project repositories
2. **Fetch Gallery Downloads**: Runs `scripts/sync-project-stats.ps1` to get PowerShell Gallery download counts
3. **Update Files**: Updates both `_data/project-stats.yml` and individual project front matter
4. **Commit Changes**: Automatically commits and pushes changes if statistics changed
5. **Trigger Deployment**: Push triggers the main deployment workflow

**What Gets Updated:**
- `_data/project-stats.yml` - Centralized statistics file
- `_projects/*.md` - Front matter `stars` and `gallery_downloads` fields
- Last updated timestamp in stats file

**Manual Updates:**
```powershell
# Locally update all stats (including gallery downloads)
.\scripts\sync-project-stats.ps1 -FetchGalleryStats

# Commit and push
git add _data/project-stats.yml _projects/*.md
git commit -m "Update project statistics"
git push
```

**Monitoring:**
- View workflow runs: https://github.com/christaylorcodes/christaylorcodes.github.io/actions/workflows/update-project-stats.yml
- Check job summary for statistics changes
- Review commit history for automated updates

**Setup Required:**
- No secrets needed (uses built-in `GITHUB_TOKEN`)
- `contents: write` permission for commits
- PowerShell Gallery API is public (no auth required)

### Deployment Workflow

```bash
# 1. Make changes locally

# 2. Test locally (recommended - see Local Development & Testing section)
.\build.ps1

# 3. Commit changes
git add .
git commit -m "Description of changes"

# 4. Push to GitHub
git push origin main

# 5. Automated deployment process runs:
#    - Jekyll builds the site (1-2 minutes)
#    - Deploys to GitHub Pages (30 seconds)
#    - Purges Cloudflare cache (5 seconds)
#    - Total time: 2-3 minutes
```

### Monitoring Deployment

**GitHub Actions:**
- View workflow runs: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
- Check deployment status and logs
- Verify all three jobs completed successfully:
  - ✅ build
  - ✅ deploy
  - ✅ purge-cloudflare-cache

**Live Site:**
- Visit https://christaylor.codes to verify changes
- Changes should be visible immediately (no cache delay)
- Hard refresh (Ctrl+F5) if browser cache is outdated

**Cloudflare Dashboard:**
- View cache purge events: Audit Log
- Monitor analytics: Dashboard → Analytics

### Troubleshooting Deployment

**Changes not visible:**
1. Check GitHub Actions for workflow failures
2. Verify all three jobs completed successfully
3. Wait 3-5 minutes for full deployment
4. Hard refresh browser (Ctrl+F5 / Cmd+Shift+R)
5. Check Cloudflare cache status

**Cache purge fails:**
- Deployment will still succeed (cache purge is non-blocking)
- Manually purge via Cloudflare Dashboard if needed
- Check GitHub Secrets are configured correctly
- See [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md) for troubleshooting

**Build fails:**
- Check Actions tab for error details
- Common issues: YAML syntax, Liquid template errors, missing files
- Test locally first with `.\build.ps1` to catch errors early

## Development Workflow

The site uses a **dev branch workflow** to provide a safe development environment separate from production. This allows you to develop, test, and iterate on changes before deploying to the live site.

### Branch Structure

**`main` branch (Production):**
- Automatically deploys to https://christaylor.codes
- Protected branch - only receives changes via promotion from dev
- Every push triggers full deployment pipeline
- Should always be in a working, deployable state

**`dev` branch (Development):**
- Primary development branch for all changes
- Builds are verified but NOT deployed to production
- Safe space for experimentation and iteration
- Can be freely committed to without affecting live site

### Workflow Process

**Standard development workflow:**

1. **Start on dev branch:**
   ```bash
   git checkout dev
   ```

2. **Make changes and test locally:**
   ```powershell
   # Test changes with live reload
   .\build.ps1
   ```

3. **Commit and push to dev:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin dev
   ```

4. **Verify CI build passes:**
   - GitHub Actions automatically builds dev branch
   - Check workflow status: [Actions](https://github.com/christaylorcodes/christaylorcodes.github.io/actions)
   - Ensure build completes successfully with no errors

5. **Promote to production:**
   ```powershell
   # Automated promotion with safety checks
   .\promote-to-main.ps1
   ```

6. **Continue development:**
   - Script automatically returns you to dev branch
   - Main branch is deployed to production
   - Continue working on next changes

### Promotion Script (`promote-to-main.ps1`)

The promotion script provides a safe, automated way to deploy changes to production.

**Features:**
- Comprehensive pre-flight safety checks
- Automated build verification (optional)
- Interactive confirmation before promotion
- Automatic merge and deployment
- Returns to dev branch after completion

**Safety Checks:**
- ✅ Verifies you're on dev branch
- ✅ Checks for uncommitted changes
- ✅ Ensures dev is up to date with remote
- ✅ Runs local Jekyll build (validates site)
- ✅ Confirms fast-forward merge is possible
- ✅ Provides deployment status and tracking

**Usage:**

**Standard promotion (recommended):**
```powershell
.\promote-to-main.ps1
```

**Skip build verification (faster, but less safe):**
```powershell
.\promote-to-main.ps1 -SkipBuild
```

**Force promotion from non-dev branch (use with caution):**
```powershell
.\promote-to-main.ps1 -Force
```

**What happens during promotion:**
1. Runs all safety checks
2. Verifies local build succeeds
3. Asks for confirmation
4. Checks out main branch
5. Pulls latest main from remote
6. Merges dev into main (fast-forward)
7. Pushes main to GitHub
8. Returns to dev branch
9. GitHub Actions deploys to production

**Typical promotion output:**
```
╔════════════════════════════════════════════════════════════╗
║  Dev → Main Promotion Script                              ║
║  christaylor.codes                                         ║
╚════════════════════════════════════════════════════════════╝

==> Verifying git repository
✅ Git repository detected

==> Checking current branch
✅ On dev branch

==> Checking for uncommitted changes
✅ Working directory clean

==> Fetching latest from remote
✅ Fetched latest from origin

==> Checking if dev is up to date
✅ Branch is up to date with remote

==> Running local build verification
✅ Local build successful

╔════════════════════════════════════════════════════════════╗
║  Ready to promote dev → main (PRODUCTION)                 ║
╚════════════════════════════════════════════════════════════╝

Continue with promotion? (yes/no): yes

==> Checking out main branch
✅ Switched to main branch

==> Pulling latest main from remote
✅ Main branch updated

==> Merging dev into main
✅ Merged dev into main

==> Pushing main to GitHub
✅ Pushed main to GitHub

==> Returning to dev branch
✅ Back on dev branch

╔════════════════════════════════════════════════════════════╗
║  ✅ PROMOTION SUCCESSFUL!                                  ║
╚════════════════════════════════════════════════════════════╝

Changes from dev have been promoted to main.

Deployment status:
  • GitHub Actions is building and deploying to production
  • View progress: https://github.com/christaylorcodes/christaylorcodes.github.io/actions
  • Deployment typically takes 2-3 minutes
  • Site will be live at: https://christaylor.codes
```

### GitHub Actions Workflows

**Dev Branch Workflow (`.github/workflows/dev-build.yml`):**
Comprehensive quality assurance pipeline that runs on every push to `dev` branch.

**Build Steps:**
1. **Jekyll Build** - Compiles site with development environment
2. **Critical File Verification** - Ensures index.html and styles.css exist
3. **Markdown Linting** - Validates blog post formatting and consistency
4. **HTML Validation** - Checks for broken internal links, missing images, and invalid HTML
5. **Lighthouse CI** - Tests performance, accessibility, SEO, and best practices
6. **Artifact Upload** - Saves Lighthouse results for 30 days

**What Gets Checked:**

**Markdown Linting (`.markdownlint.json`):**
- Consistent heading hierarchy
- Proper list formatting
- Code fence style consistency
- No trailing spaces
- Configurable rules for technical content

**HTML Validation (html-proofer):**
- Internal link validation (broken links caught before deployment)
- Image existence verification (missing images detected)
- Script and favicon checks
- Ignores external links (prevents false positives from third-party sites)

**Lighthouse CI (`.lighthouserc.json`):**
Tests 5 key pages: home, about, blog, projects, contact

- **Performance**: Minimum score 85% (warns if below)
- **Accessibility**: Minimum score 90% (fails if below - critical for professional site)
- **Best Practices**: Minimum score 85% (warns if below)
- **SEO**: Minimum score 90% (warns if below - critical for discoverability)

**Key Accessibility Checks:**
- ARIA required children
- Color contrast ratios (WCAG compliance)
- Document title presence
- HTML lang attribute
- Image alt attributes
- Meta descriptions

**Results:**
- Lighthouse reports saved as artifacts (viewable in GitHub Actions)
- Build summary shows pass/fail for all checks
- Uploaded to temporary public storage for detailed review
- 30-day retention for trend analysis

**Does NOT deploy to production** - safe testing environment.

**Main Branch Workflow (`.github/workflows/deploy.yml`):**
Production deployment pipeline triggered by promotion from dev.

**Deployment Steps:**
1. **Jekyll Build** - Compiles site with production environment
2. **Deploy to GitHub Pages** - Publishes to christaylor.codes
3. **Purge Cloudflare Cache** - Ensures fresh content delivery
4. **Verification** - Confirms deployment success

**Takes 2-3 minutes end-to-end** from push to live site.

### Best Practices

**Do:**
- Always develop on dev branch
- Test locally before pushing
- Verify CI build passes before promoting
- Use the promotion script for deployments
- Keep dev branch in sync with main

**Don't:**
- Commit directly to main (use dev → main promotion)
- Skip local testing before pushing
- Promote without verifying CI build passes
- Force push to either branch
- Deploy without reviewing changes

### Common Scenarios

**Making a simple change:**
```bash
# 1. Ensure on dev branch
git checkout dev

# 2. Make changes, test locally
.\build.ps1

# 3. Commit and push
git add .
git commit -m "Fix typo in about page"
git push origin dev

# 4. Wait for CI build to pass

# 5. Promote to production
.\promote-to-main.ps1
```

**Working on a major feature:**
```bash
# 1. Start on dev
git checkout dev

# 2. Make incremental changes
# ... edit files ...
git add .
git commit -m "Add new project showcase section"
git push origin dev

# 3. Continue iterating
# ... more edits ...
git add .
git commit -m "Refine project showcase styling"
git push origin dev

# 4. When feature is complete and tested
.\promote-to-main.ps1
```

**Hotfix workflow:**
```bash
# If you need to make an urgent fix to production:

# 1. Start from main
git checkout main
git pull origin main

# 2. Make fix
# ... edit files ...

# 3. Test locally
.\build.ps1

# 4. Commit and push directly to main
git add .
git commit -m "Hotfix: Fix broken contact form"
git push origin main

# 5. Merge fix back to dev
git checkout dev
git merge main
git push origin dev
```

**Syncing dev with main:**
```bash
# If main has changes that dev doesn't (e.g., after hotfix):
git checkout dev
git merge main
git push origin dev
```

### Troubleshooting Development Workflow

**Promotion script fails with "not on dev branch":**
- You're currently on a different branch
- Solution: `git checkout dev` or use `-Force` parameter (not recommended)

**Promotion fails with "uncommitted changes":**
- You have unsaved changes in your working directory
- Solution: Commit changes (`git add . && git commit`) or stash them (`git stash`)

**Fast-forward merge not possible:**
- Main has commits that dev doesn't have
- Solution: Sync dev with main first (`git checkout dev && git merge main`)

**CI build fails on dev:**
- Jekyll build error in your changes
- Solution: Check Actions tab for error details, fix locally, push again

**Changes not appearing after promotion:**
- Wait 2-3 minutes for deployment pipeline
- Check Actions tab for workflow status
- Hard refresh browser (Ctrl+F5)
- Verify Cloudflare cache purge succeeded

**Need to undo a promotion:**
```bash
# Revert the most recent commit on main
git checkout main
git revert HEAD
git push origin main

# This creates a new commit that undoes the changes
# Original commit history is preserved
```

**Markdown linting fails:**
- Check the error message for specific rule violations
- Common issues: Inconsistent heading levels, trailing spaces, list formatting
- Review `.markdownlint.json` for configured rules
- Fix issues in affected markdown files and push again

**HTML validation fails (html-proofer):**
- **Broken internal link**: Fix the link in the source file
- **Missing image**: Ensure image exists in `assets/images/` or correct the path
- **Missing alt attribute**: Add `alt=""` to images for accessibility
- Check Actions tab for specific file and line number

**Lighthouse CI fails or scores below threshold:**
- **Performance < 85%**:
  - Check for large unoptimized images
  - Review JavaScript bundle size
  - Consider implementing lazy loading
- **Accessibility < 90%** (critical - blocks promotion):
  - Missing alt attributes on images
  - Insufficient color contrast
  - Missing ARIA labels
  - Invalid heading hierarchy
- **SEO < 90%**:
  - Missing meta description
  - Missing or duplicate page titles
  - Missing structured data
- View detailed Lighthouse report in GitHub Actions artifacts

**Viewing Lighthouse Reports:**
1. Go to GitHub Actions workflow run
2. Scroll to "Artifacts" section at bottom
3. Download `lighthouse-results` artifact
4. Extract and open HTML reports in browser
5. Review detailed recommendations and scores

### When to Skip the Dev Branch

You may occasionally push directly to main for:
- **Hotfixes** - Critical production issues requiring immediate fix
- **Documentation only changes** - README, CLAUDE.md updates with no site impact
- **Configuration tweaks** - _config.yml changes that don't affect functionality

**For everything else, use the dev → main workflow for safety.**

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

**For known issues and ongoing investigations**, see: [KNOWN-ISSUES.md](KNOWN-ISSUES.md)

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

**Issue:** Character encoding errors in terminal ("ERROR bad Request-Line" with garbled text)
**Solution:**
- These errors do not affect functionality and can be safely ignored
- Likely caused by browser attempting HTTPS connection to HTTP server
- See [KNOWN-ISSUES.md](KNOWN-ISSUES.md) for detailed analysis and workarounds
- Workaround: Explicitly visit `http://localhost:4000` (not `https://`) or disable HTTPS Everywhere extension

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

### Width Strategy

The theme uses a hierarchical width system optimized for readability and user experience:

**Overall Layout:**
- Container: `1200px` - Main layout wrapper for all pages
- Horizontal padding: `20px` - Prevents content from touching screen edges

**Content-Optimized Widths** (for readability):
- Blog post content: `800px` - Optimal reading width (50-75 characters per line)
- Blog post footer: `800px` - Matches content width for visual consistency
- Post header: `800px` - Creates focused attention on post metadata
- Blog posts list: `900px` - Slightly wider for card layout
- About page content: `900px` - Comfortable width for bio and skills
- Contact page: `900px` section / `700px` form - Progressive narrowing to focus
- Hero content: `800px` - Creates visual hierarchy and focus
- Blog intro text: `700px` - Narrower for emphasis

**Technical Content:**
- Code blocks: `1100px` max-width (breaks out of 800px content area to support 120+ character lines without scrolling)
- Code blocks use negative margins on desktop (`calc((800px - 1100px) / 2)`) to expand 150px on each side
- On mobile (≤768px): Code blocks reset to `100%` width with `overflow-x: auto` for horizontal scrolling
- Tables: `100%` width within content container
- Images: `max-width: 100%` to prevent overflow

**Benefits:**
- Improves readability by preventing excessively long text lines
- Creates visual hierarchy through progressive narrowing
- Maintains consistent reading experience across different content types
- Allows technical content (code, tables) to use full available width when needed

**Modifying Widths:**
All max-width values are set in the respective SCSS partials in `_sass/oceanic/`. To change content width, edit the `max-width` property in the relevant component file.

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

## Structured Data & Resume Discoverability

The site implements comprehensive schema.org structured data to improve discoverability by search engines and recruiters. This is particularly important for making your professional profile searchable by recruiting tools and AI-powered search systems.

### Person Structured Data

The about page includes rich Person schema markup optimized for recruiter discovery and professional search.

**Implementation:**
- Structured data include: [_includes/structured-data-person.html](_includes/structured-data-person.html)
- Data source: [_data/author.yml](_data/author.yml) `structured_data` section
- Included on: [about.html:8](about.html#L8)

**Schema Fields Included:**

**Basic Identity:**
- `name`, `givenName`, `familyName` - Full name and components
- `url` - Website URL
- `email` - Contact email
- `image` - Profile photo
- `jobTitle` - Current professional title
- `description` - Professional summary

**Professional Information:**
- `worksFor` - Current employer (Organization schema)
- `hasOccupation` - Detailed occupation info with:
  - Job title and location
  - Skills taxonomy
  - Years of experience
- `knowsAbout` - Array of expertise areas (searchable skills)
- `knowsLanguage` - Language proficiency

**Background:**
- `alumniOf` - Previous employer or education (Organization schema)
- `hasCredential` - Certifications and credentials (optional, commented in author.yml)

**Connections:**
- `sameAs` - Social media profiles (LinkedIn, GitHub, etc.)
- Links to professional networks for verification

**Portfolio Metrics:**
- `interactionStatistic` - Quantifiable achievements:
  - Number of blog posts written
  - Number of open source projects

**Career Intent:**
- `seeks` - Open to consulting/opportunities statement

### Configuring Your Professional Data

All professional information is centralized in [_data/author.yml](_data/author.yml). Update the `structured_data` section:

```yaml
structured_data:
  job_title: "Network Operations Chief"
  description: "Network Operations Chief, vCTO, and Automation Engineer with 20+ years..."
  occupation_skills: "PowerShell, Infrastructure Automation, Network Architecture..."
  seeking: "Open to consulting opportunities in MSP automation, AI integration..."

  # Optional: Add certifications
  credentials:
    - name: "Microsoft Certified: Azure Administrator Associate"
      category: "Professional Certification"
```

### Resume Download Section

The about page includes a prominent "Professional Resume" section with:
- Call-to-action for consulting opportunities
- LinkedIn profile link
- Contact page link
- Placeholder for downloadable PDF resume (commented, ready to activate)

**Location:** [about.html:99-118](about.html#L99-L118)
**Styling:** [_sass/oceanic/_about.scss:474-512](_sass/oceanic/_about.scss#L474-L512)

**To Add PDF Resume:**
1. Create professional resume PDF
2. Save as `assets/downloads/Chris-Taylor-Resume.pdf`
3. Uncomment the download button in [about.html:108-110](about.html#L108-L110)
4. Deploy changes

### SEO Benefits for Recruiter Discovery

**How Structured Data Helps:**
- **Search engines** can understand your professional background
- **Recruiting tools** can parse skills and experience
- **AI assistants** can answer questions about your expertise
- **Social platforms** display rich professional cards
- **Google Knowledge Panel** eligibility for personal brand

**Keywords for Discoverability:**
The structured data includes these searchable elements:
- Job titles (Network Operations Chief, vCTO, Automation Engineer)
- Skills and technologies (PowerShell, Azure, MSP Operations, etc.)
- Years of experience (20+ years)
- Industry context (MSP, managed services, multi-tenant)
- Location (United States)
- Availability (consulting opportunities)

### Testing Structured Data

**Google Rich Results Test:**
1. Visit: https://search.google.com/test/rich-results
2. Enter URL: `https://christaylor.codes/about`
3. Verify Person schema is detected
4. Check for errors or warnings
5. Fix any validation issues

**Schema.org Validator:**
1. Visit: https://validator.schema.org/
2. Enter URL or paste markup
3. Review structured data parsing
4. Verify all fields are correct

**Common Issues:**
- **Invalid JSON-LD**: Check for syntax errors in Liquid templates
- **Missing required fields**: Ensure `name` and `url` are present
- **Broken URLs**: Verify all `sameAs` links are valid
- **Type mismatches**: Ensure values match expected schema types

### Other Structured Data on Site

**Website Schema:**
- Location: [_includes/structured-data-website.html](_includes/structured-data-website.html)
- Type: `WebSite` with search action
- Included on: All pages via [_layouts/default.html](_layouts/default.html)

**Blog Posts:**
- Type: `BlogPosting` (via jekyll-seo-tag)
- Automatic schema for all posts
- Includes author, publication date, headline

**Projects:**
- Type: `SoftwareApplication` (planned)
- Future enhancement for project pages

### Best Practices

**Keep Data Fresh:**
- Update experience years annually
- Add new certifications as earned
- Update skills as expertise grows
- Refresh professional summary quarterly

**Align Across Platforms:**
- Match LinkedIn profile information
- Synchronize with resume PDF
- Use consistent job titles
- Maintain same skills taxonomy

**Privacy Considerations:**
- Only include public contact information
- Use business email (not personal)
- LinkedIn profile should be public
- Consider what's searchable by recruiters

**Recruiter-Friendly Keywords:**
- Use industry-standard job titles
- Include specific technologies and tools
- Mention years of experience
- Add location if relevant for local jobs
- Include buzzwords recruiters search for

## Analytics & Metrics Collection

The site supports comprehensive analytics and metrics collection through multiple services. For detailed setup instructions, see: [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md)

### Available Analytics Tools

**Google Analytics 4 (GA4):**
- Comprehensive user behavior analytics
- Traffic sources and acquisition channels
- Demographics and technology reports
- Custom event tracking (form submissions, outbound links)
- Real-time visitor tracking
- Conversion tracking

**Cloudflare Web Analytics:**
- Privacy-friendly, cookieless analytics
- GDPR/CCPA compliant by default
- Page views, unique visitors, traffic sources
- Performance metrics and Core Web Vitals
- Geographic distribution
- No personal data collection

**Google Search Console:**
- Search performance (queries, clicks, impressions)
- Indexing status and coverage
- SEO insights and Core Web Vitals
- Structured data validation
- Mobile usability
- Rich results monitoring

### Configuration

Analytics are configured in `_config.yml`:

```yaml
# Google Analytics 4
google_analytics: G-XXXXXXXXXX  # Your GA4 measurement ID

# Cloudflare Web Analytics (privacy-friendly)
cloudflare_analytics: YOUR_BEACON_TOKEN_HERE
```

The analytics includes are located in:
- [_includes/google-analytics.html](_includes/google-analytics.html) - GA4 tracking with custom events
- [_includes/cloudflare-analytics.html](_includes/cloudflare-analytics.html) - Cloudflare beacon

Both are loaded in [_layouts/default.html:49-50](_layouts/default.html#L49-L50) and only activate in production (not localhost).

### Custom Event Tracking (Preconfigured)

The GA4 implementation includes automatic tracking for:
- **Outbound links:** GitHub repository clicks, PowerShell Gallery links
- **Social media:** LinkedIn, Twitter/X clicks
- **Conversions:** Contact form submissions
- **Navigation:** Internal page navigation

### Privacy Features

- IP anonymization enabled in GA4
- Secure cookie flags
- Only loads in production environment
- Cloudflare Analytics is completely cookieless
- No personal data sold or shared

### Setup Quick Start

1. **Create GA4 Property** at [analytics.google.com](https://analytics.google.com/)
2. **Enable Cloudflare Analytics** in your Cloudflare Dashboard
3. **Add measurement IDs** to `_config.yml`
4. **Verify Search Console** ownership via DNS
5. **Deploy changes** and verify tracking

See [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md) for:
- Step-by-step setup instructions
- What metrics each tool provides
- Dashboard configuration recommendations
- Privacy compliance guidelines
- Weekly/monthly monitoring checklists

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
