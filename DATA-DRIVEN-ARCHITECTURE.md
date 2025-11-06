# Data-Driven Architecture - Quick Reference

This document provides a quick reference for the site's data-driven architecture implemented in November 2025.

## Overview

The site separates **content** (data) from **presentation** (templates) using Jekyll's `_data/` directory. This follows the principle of **Don't Repeat Yourself (DRY)** and provides a **Single Source of Truth** for all frequently-updated information.

## Architecture Layers

```
┌─────────────────────────────────────────────────┐
│  Content Layer (_data/*.yml)                    │
│  What to display - Easy to update               │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│  Presentation Layer (_layouts/, _includes/)     │
│  How to display - Liquid templates              │
└─────────────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────┐
│  Styling Layer (_sass/oceanic/*.scss)           │
│  Visual appearance - SCSS partials              │
└─────────────────────────────────────────────────┘
```

## Data Files

### 1. `_data/contact.yml`

**Purpose:** Contact information and social media links

**Key Sections:**
- `email` - Primary email address
- `email_description` - Context for email usage
- `social_links` - Hash of social platforms (GitHub, LinkedIn, Twitter)
  - Each platform has: `username`, `url`, `display`, `icon`, `icon_style`, `description`
  - Visibility flags: `show_in_footer`, `show_on_contact`
- `social_profiles` - Array of URLs for structured data

**Usage Locations:** 5+ files
- Footer social links
- Contact page cards
- Structured data (schema.org)

**Impact:** Adding a new social platform requires ONE change, affects all locations automatically

### 2. `_data/author.yml`

**Purpose:** Professional identity and biographical information

**Key Sections:**
- `name`, `first_name`, `last_name` - Identity
- `title`, `roles_short`, `roles_list` - Professional titles
- `experience_years`, `experience_since`, `experience_description` - Experience
- `company`, `company_description`, `location` - Employment
- `passion` - Personal interests
- `bio_tagline` - One-liner description
- `about_highlights` - Array of stats for about page (years, projects, posts, PowerShell)
- `quick_facts` - Array of sidebar facts
- `bio` - Multi-paragraph biographical text
- `expertise.core_services` - Array of service offerings
- `expertise.knows_about` - Array of skills
- `structured_data` - Fields for schema.org JSON-LD

**Usage Locations:** 10+ files
- Homepage hero section
- About page (stats, quick facts, bio)
- Structured data schemas

**Impact:** Update job title ONCE, changes everywhere (hero, about, schema.org)

### 3. `_data/project-stats.yml`

**Purpose:** GitHub stars and PowerShell Gallery downloads

**Structure:**
```yaml
project-id:
  stars: 118
  gallery_downloads: 456129
```

**Usage Locations:**
- Homepage podium (top 3 projects)
- Projects page grid
- Individual project detail pages

**Update Method:**
```powershell
.\sync-project-stats.ps1 -FetchGalleryStats
```

## Common Update Scenarios

### Update Email Address
```yaml
# File: _data/contact.yml
email: newemail@example.com
```
**Affects:** Footer, contact page, all structured data (5+ locations)

### Change Professional Title
```yaml
# File: _data/author.yml
title: Senior Network Architect
roles_short: "Senior Network Architect | vCTO | Automation Engineer"
structured_data:
  job_title: "Senior Network Architect"
```
**Affects:** Homepage hero, about page, all structured data (10+ locations)

### Add Social Platform
```yaml
# File: _data/contact.yml
social_links:
  mastodon:
    username: christaylor
    url: "https://mastodon.social/@christaylor"
    display: "@christaylor"
    icon: "fab fa-mastodon"
    icon_style: "icon-purple"
    description: "Updates and discussions"
    show_in_footer: true
    show_on_contact: true

# Don't forget to add to profiles array:
social_profiles:
  - "https://github.com/christaylorcodes"
  - "https://www.linkedin.com/in/christaylorcodes"
  - "https://x.com/christaylorAI"
  - "https://mastodon.social/@christaylor"  # Add here
  - "https://christaylor.codes"
```
**Affects:** Footer, contact page, structured data - appears everywhere automatically

### Update Blog Post Count (Quarterly)
```yaml
# File: _data/author.yml
about_highlights:
  - icon: fa-blog
    number: "15+"  # Update this
    label: "Blog Posts"
```
**Affects:** About page statistics section

### Update Company
```yaml
# File: _data/author.yml
company: New Company Name
company_description: "Description of new company"

# Also update in quick_facts:
quick_facts:
  - icon: fa-building
    label: "Company"
    value: "New Company Name"  # Update this too
```
**Affects:** About page quick facts, structured data

## Liquid Template Usage

### Accessing Contact Data
```liquid
{{ site.data.contact.email }}
{{ site.data.contact.social_links.github.url }}
{{ site.data.contact.social_links.github.display }}
```

### Accessing Author Data
```liquid
{{ site.data.author.name }}
{{ site.data.author.first_name }}
{{ site.data.author.roles_short }}
{{ site.data.author.experience_years }}
{{ site.data.author.company }}
```

### Looping Through Social Links
```liquid
{% for link_data in site.data.contact.social_links %}
  {% assign link_key = link_data[0] %}
  {% assign link = link_data[1] %}
  {% if link.show_in_footer %}
    <a href="{{ link.url }}">
      <i class="{{ link.icon }}"></i>
    </a>
  {% endif %}
{% endfor %}
```

### Looping Through Author Stats
```liquid
{% for highlight in site.data.author.about_highlights %}
  <div class="stat">
    <i class="fas {{ highlight.icon }}"></i>
    <span class="number">{{ highlight.number }}</span>
    <span class="label">{{ highlight.label }}</span>
  </div>
{% endfor %}
```

### Accessing Project Stats
```liquid
{% assign project_id = project.id | remove: '/projects/' %}
{% assign stats = site.data.project-stats[project_id] %}
{% if stats %}
  {{ stats.stars }} stars
  {{ stats.gallery_downloads }} downloads
{% endif %}
```

## Design Principles

### Single Source of Truth
Each piece of information exists in exactly ONE location. Templates reference the data, never duplicate it.

**Bad (Hardcoded):**
```liquid
<!-- index.html -->
<h1>Chris Taylor</h1>

<!-- about.html -->
<h1>Chris Taylor</h1>

<!-- footer.html -->
<p>&copy; Chris Taylor</p>
```
Problem: Change name → update 3+ files

**Good (Data-Driven):**
```liquid
<!-- index.html -->
<h1>{{ site.data.author.name }}</h1>

<!-- about.html -->
<h1>{{ site.data.author.name }}</h1>

<!-- footer.html -->
<p>&copy; {{ site.data.author.name }}</p>
```
Solution: Change name → update 1 file (`_data/author.yml`)

### When to Use Data Files

**Use data files when:**
- ✅ Information appears in 2+ locations
- ✅ Content updates regularly (stats, years, counts)
- ✅ Lists that grow/shrink (social platforms, skills, services)
- ✅ Professional metadata (name, title, company, email)
- ✅ Configuration-like data

**Keep in templates when:**
- ❌ Unique, page-specific content
- ❌ Long-form prose (blog posts, project descriptions)
- ❌ One-off sections with no reuse potential
- ❌ Complex layouts with conditional logic

## Benefits Achieved

### Maintainability
- Update email once, not 5+ times
- Change job title once, not 10+ times
- Add social platform once, appears everywhere

### Consistency
- Guaranteed synchronization across all pages
- No risk of outdated info on one page
- Structured data always matches visible content

### Scalability
- Easy to add new fields without template changes
- Simple to reorganize or restructure data
- Templates remain clean and focused on presentation

### Error Prevention
- Can't forget to update one location
- No typos between different files
- No URL format inconsistencies

## Migration History

**Date:** November 5, 2025

**Phase 1:** Contact Information
- Created `_data/contact.yml`
- Migrated footer, contact page, structured data
- **Impact:** 5+ files now reference single source

**Phase 2:** Professional Identity
- Created `_data/author.yml`
- Migrated homepage hero, about page, structured data
- **Impact:** 10+ files now reference single source

**Total:** 15+ hardcoded locations eliminated, centralized into 2 data files

## Testing After Updates

1. **Build locally:** `.\build.ps1`
2. **Check for errors** in terminal output
3. **Visual inspection** at http://localhost:4000
4. **Verify affected pages:**
   - Homepage hero
   - About page stats and bio
   - Contact page
   - Footer
5. **Test structured data:** Google Rich Results Test
6. **Commit and push** when verified

## Future Expansion Ideas

Potential candidates for data-driven approach:
- Homepage feature cards (`_data/features.yml`)
- Skills/expertise lists (already in `author.yml`)
- Testimonials (`_data/testimonials.yml`)
- Timeline/experience (`_data/timeline.yml`)

---

**Last Updated:** November 5, 2025
**Maintained By:** Chris Taylor
**Architecture Pattern:** Data-Driven Design / Separation of Concerns
