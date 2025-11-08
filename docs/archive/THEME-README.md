# Oceanic Jekyll Theme

A modern, professional dark theme for Jekyll featuring an Electric Blue and warm amber color palette. Perfect for tech portfolios, developer blogs, and project showcases.

![Oceanic Theme](screenshot.png)

## Features

- **Modern Design**: Clean, professional aesthetic with Electric Blue accents
- **Dark Theme**: Comfortable dark color scheme with excellent readability
- **Responsive**: Mobile-first design that looks great on all devices
- **Blog Ready**: Beautiful blog post layouts with syntax highlighting
- **Project Showcase**: Dedicated project cards and layouts
- **SEO Optimized**: Built-in jekyll-seo-tag support with Open Graph and Twitter Cards
- **Fast**: Minimal JavaScript, optimized CSS, fast page loads
- **Accessible**: WCAG AA compliant color contrasts
- **Customizable**: Easy-to-modify SCSS variables for colors and styling

## Quick Start

### Installation

Add this line to your Jekyll site's `Gemfile`:

```ruby
gem "oceanic"
```

And add this line to your `_config.yml`:

```yaml
theme: oceanic
```

Then execute:

```bash
bundle install
```

## Usage

### Layouts

The theme includes two main layouts:

#### Default Layout
Used for standard pages (about, contact, projects, etc.)

```yaml
---
layout: default
title: "Your Page Title"
---

Your content here...
```

#### Post Layout
Used for blog posts with additional metadata and navigation

```yaml
---
layout: post
title: "Your Post Title"
date: 2025-01-15
categories: [technology, tutorial]
tags: [jekyll, web-development]
author: Your Name
excerpt: "A brief description of your post"
---

Your post content...
```

### Configuration

Configure the theme in your `_config.yml`:

```yaml
title: Your Site Title
email: your-email@example.com
description: Brief description of your site
url: "https://yoursite.com"

# Social Media
github_username: yourusername
linkedin_username: yourusername
twitter_username: yourusername

# Collections (for projects)
collections:
  projects:
    output: false
    sort_by: order

# Plugins
plugins:
  - jekyll-feed
  - jekyll-seo-tag
  - jekyll-sitemap
```

### Creating Blog Posts

Create files in `_posts/` with the naming format: `YYYY-MM-DD-title.md`

```yaml
---
layout: post
title: "Getting Started with Jekyll"
date: 2025-01-15 10:00:00 -0000
categories: [tutorial, jekyll]
tags: [jekyll, static-site, tutorial]
author: Your Name
excerpt: "Learn how to get started with Jekyll static site generator"
image: /assets/images/posts/jekyll-intro.png  # Optional social sharing image
---

Your markdown content here...
```

### Creating Project Entries

Create files in `_projects/` directory:

```yaml
---
title: My Awesome Project
icon: fa-rocket
description: Brief description for the project card
tags:
  - Jekyll
  - Ruby
  - Web Development
demo_url: "https://demo.example.com"
github_url: "https://github.com/username/repo"
order: 1
---

Optional longer description in markdown format...
```

## Customization

### Color Scheme

The theme uses CSS custom properties (variables) for easy customization. Override them in your own CSS file or by creating `_sass/oceanic/_variables.scss` in your site:

```css
:root {
    /* Primary Colors - Electric Blue Theme */
    --primary-color: #06b6d4;        /* Cyan - main accent */
    --primary-dark: #0284c7;         /* Sky Blue - darker accent */
    --primary-light: #38bdf8;        /* Light Blue - lighter accent */
    --secondary-color: #f59e0b;      /* Amber - warm accent */

    /* Customize other colors as needed */
}
```

### Override Theme Files

You can override any theme file by creating an identically-named file in your site:

```
your-site/
├── _layouts/
│   └── post.html           ← Overrides theme's post layout
├── _includes/
│   └── navigation.html     ← Overrides theme's navigation
├── _sass/
│   └── oceanic/
│       └── _variables.scss ← Overrides theme's colors
└── assets/
    └── css/
        └── custom.css      ← Additional custom styles
```

### Navigation

Edit `_includes/navigation.html` in your site to customize navigation links:

```html
<li><a href="/" class="nav-link">Home</a></li>
<li><a href="/about" class="nav-link">About</a></li>
<li><a href="/blog" class="nav-link">Blog</a></li>
<li><a href="/projects" class="nav-link">Projects</a></li>
<li><a href="/contact" class="nav-link">Contact</a></li>
```

## Theme Structure

```
oceanic/
├── _includes/
│   ├── navigation.html     # Site navigation bar
│   └── footer.html         # Site footer
├── _layouts/
│   ├── default.html        # Base layout
│   └── post.html           # Blog post layout
├── _sass/
│   └── oceanic/
│       ├── _variables.scss    # Color system and CSS variables
│       ├── _base.scss         # Reset and base styles
│       ├── _navigation.scss   # Navigation component
│       ├── _hero.scss         # Hero section
│       ├── _buttons.scss      # Button styles
│       ├── _features.scss     # Feature cards
│       ├── _posts.scss        # Blog post styles
│       ├── _projects.scss     # Project cards
│       ├── _contact.scss      # Contact page
│       ├── _about.scss        # About page
│       ├── _footer.scss       # Footer component
│       ├── _animations.scss   # Animations and keyframes
│       └── _responsive.scss   # Media queries
├── assets/
│   ├── css/
│   │   └── styles.scss     # Main stylesheet (imports oceanic.scss)
│   └── js/
│       └── main.js         # JavaScript functionality
├── oceanic.gemspec         # Gem specification
├── LICENSE                 # MIT License
└── README.md              # This file
```

## Color Palette

### Primary Colors (Electric Blue)
- **Primary**: `#06b6d4` - Cyan (main accent color)
- **Primary Dark**: `#0284c7` - Sky Blue (hover states)
- **Primary Light**: `#38bdf8` - Light Blue (highlights)

### Secondary Colors (Warm Accents)
- **Secondary**: `#f59e0b` - Amber (warm accent)
- **Accent Orange**: `#ea580c` - Orange (CTAs)
- **Accent Rust**: `#dc2626` - Red (warnings)

### Background Colors (Deep Slate)
- **Darkest**: `#020617` - Rich Black (navbar, hero)
- **Dark**: `#0f172a` - Dark Slate (body background)
- **Light**: `#1e293b` - Slate (cards, elevated sections)
- **Lightest**: `#334155` - Light Slate (highest elevation)

### Text Colors
- **Primary**: `#f1f5f9` - Off White (headings, main text)
- **Secondary**: `#cbd5e1` - Light Gray (body text, descriptions)

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Development

### Local Setup

```bash
# Clone the repository
git clone https://github.com/christaylorcodes/oceanic-theme.git
cd oceanic-theme

# Install dependencies
bundle install

# Serve the theme locally
bundle exec jekyll serve --livereload

# View at http://localhost:4000
```

### Building the Gem

```bash
# Build the gem
gem build oceanic.gemspec

# Install locally for testing
gem install ./oceanic-0.1.0.gem

# Publish to RubyGems (when ready)
gem push oceanic-0.1.0.gem
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/christaylorcodes/oceanic-theme.

## Credits

**Author**: Chris Taylor ([@christaylorcodes](https://github.com/christaylorcodes))

**Built with**:
- [Jekyll](https://jekyllrb.com/) - Static site generator
- [Font Awesome](https://fontawesome.com/) - Icons
- [Google Fonts (Inter)](https://fonts.google.com/specimen/Inter) - Typography

## License

The theme is available as open source under the terms of the [MIT License](LICENSE).

## Support

- **Documentation**: https://github.com/christaylorcodes/oceanic-theme
- **Issues**: https://github.com/christaylorcodes/oceanic-theme/issues
- **Contact**: ctaylor@christaylor.codes

---

**Oceanic Theme v0.1.0** | Built with ❤️ by [Chris Taylor](https://christaylor.codes)
