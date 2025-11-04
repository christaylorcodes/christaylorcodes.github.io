# Website TODO List

This document tracks improvements and enhancements for christaylor.codes. Tasks are organized by priority to help maintain and enhance the website.

## Priority 1: Maintenance & Project Management

### Content Management
- [ ] Replace placeholder blog posts with real content about automation, PowerShell, and network operations
- [x] Standardize blog post filenames to use simpler titles (e.g., `YYYY-MM-DD-title.md` instead of `YYYY-MM-DD-long-descriptive-title.md`)
- [x] Rename existing blog posts to follow simplified naming convention
- [x] Update project entries in `_projects/` with actual projects from your portfolio (Completed 2025-11-04)
- [x] Replace placeholder project URLs (`#`) with real demo and GitHub repository links (Completed 2025-11-04)

### Code Organization
- [x] Add code comments in main.css to document major sections (Completed 2025-11-04)

### Documentation
- [x] Update CLAUDE.md with oceanic color palette documentation (Completed 2025-11-04)
- [x] Add content contribution guidelines to CLAUDE.md (Completed 2025-11-04)

## Priority 2: Features & Functionality

### Blog Enhancements
- [x] Update the Featured Projects section of the homepage with concise short descriptions (Completed 2025-11-04)
- [ ] Add reading time estimates to blog posts
- [ ] Implement pagination for blog posts (currently shows all posts on one page)
- [ ] Add category/tag filtering functionality on blog index page
- [ ] Add search functionality for blog posts
- [ ] Add "Related Posts" section to blog post layout
- [ ] Add comments system (consider utterances for GitHub-based comments)
- [ ] Add RSS feed icon/link in navigation or footer

### Project Enhancements
- [ ] Add project detail pages (set `output: true` in _config.yml for projects collection)
- [ ] Add project screenshots/images
- [ ] Add "View Project Details" functionality
- [ ] Create project categories for filtering (Automation, PowerShell, Web, etc.)

### Contact Enhancements
- [x] Add LinkedIn profile link (uncomment in [_config.yml:10](_config.yml#L10)) (Completed 2025-11-04)
- [ ] Add professional social media links (Twitter, etc.)
- [ ] Consider adding calendly/scheduling link for consultations

### Navigation
- [ ] Add breadcrumb navigation for better UX
- [ ] Add "Back to Top" button for long pages
- [ ] Implement active navigation state for all pages

## Priority 3: SEO & Performance

### SEO Optimization
- [ ] Add custom meta descriptions to all pages using front matter
- [x] Add Open Graph tags for better social media sharing (Completed 2025-11-03)
- [x] Add Twitter Card meta tags (Completed 2025-11-03)
- [ ] Add structured data (JSON-LD) for better search results (partially complete - jekyll-seo-tag provides basic JSON-LD)

### Performance
- [ ] Implement image optimization workflow
- [ ] Add lazy loading for images
- [ ] Minify CSS for production
- [ ] Consider adding service worker for offline functionality
- [ ] Optimize Font Awesome usage (only load needed icons)

### Accessibility
- [ ] Add ARIA labels to navigation and interactive elements
- [ ] Ensure all images have descriptive alt text
- [ ] Test color contrast ratios for WCAG compliance
- [ ] Add skip navigation link for keyboard users
- [ ] Test with screen readers

## Priority 4: Advanced Features

### Analytics & Monitoring
- [ ] Add Google Analytics or privacy-focused alternative (Plausible, Fathom)
- [ ] Add performance monitoring
- [ ] Implement error tracking

### Interactive Features
- [ ] Add dark/light mode toggle (currently dark only)
- [ ] Add print stylesheet
- [ ] Create PDF export functionality for blog posts
- [ ] Add image galleries/lightbox for projects

### Content Types
- [ ] Create "Case Studies" section for detailed project write-ups
- [ ] Add "Talks" or "Presentations" section
- [ ] Add "Tools" or "Resources" page for useful automation tools
- [ ] Create newsletter signup functionality

## Priority 5: Development Workflow

### Testing
- [ ] Set up automated testing for HTML validation
- [ ] Add link checker to prevent broken links
- [ ] Create CI/CD pipeline for automated deployments
- [ ] Add accessibility testing in build process

### Version Control
- [ ] Add `.gitattributes` for consistent line endings
- [ ] Create git tags for major releases
- [ ] Add GitHub issue templates
- [ ] Add pull request template

### Development
- [ ] Set up local development environment documentation
- [ ] Add npm scripts for common tasks
- [ ] Consider adding Webpack/Gulp for asset pipeline
- [ ] Add CSS linting (stylelint)
- [ ] Add HTML validation in development

## Quick Wins (Easy, High Impact)

These tasks can be completed quickly and provide immediate value:

1. [x] Add LinkedIn profile link to config and footer (Completed 2025-11-04)
2. [ ] Create first real blog post about PowerShell automation
3. [x] Add at least one real project from your portfolio (Completed 2025-11-04)
4. [x] Add Open Graph and Twitter Card meta tags for better social sharing (Completed 2025-11-03)
5. [ ] Add structured data (JSON-LD) for improved search results

## Notes

- Test all changes locally before pushing to GitHub Pages
- Maintain responsive design for all new features
- **Current color theme:** Oceanic palette (dark cyan, midnight green, tiffany blue with warm accents)
- **Blog post naming:** Use simplified titles with required date prefix (e.g., `YYYY-MM-DD-title.md`)
- Prioritize page load performance
- Ensure all new content aligns with Chris Taylor's professional brand

## Completed Tasks

### Initial Setup (2024)
- [x] Initial Jekyll site setup
- [x] Custom layouts and includes
- [x] Dark theme with turquoise accent colors
- [x] Responsive navigation with mobile menu
- [x] Blog functionality with posts collection
- [x] Projects collection with data-driven approach
- [x] Contact form structure
- [x] About page with professional bio
- [x] Recent posts section on home page
- [x] Featured projects section on home page
- [x] SEO plugin integration (jekyll-seo-tag)
- [x] RSS feed plugin integration (jekyll-feed)

### November 2025 Updates
- [x] Add professional headshot or profile image to About page (commit: 73ffbad)
- [x] Add favicon and Apple touch icons (commit: f193c9a)
- [x] Move inline styles to CSS classes for better maintainability (commit: afe678e)
- [x] Create reusable CSS classes for repeated patterns (commit: afe678e)
- [x] Create template file for new blog posts in `_templates/post-template.md` (commit: 2985fa5)
- [x] Create template file for new projects in `_templates/project-template.md` (commit: 2985fa5)
- [x] Create `sitemap.xml` using jekyll-sitemap plugin (commit: afe678e)
- [x] Create `robots.txt` file (commit: afe678e)
- [x] Add preconnect hints for Google Fonts and Font Awesome CDN (commit: 2113c91)
- [x] Remove Formspree form and replace with direct contact methods (commit: 54c2282)
- [x] Implement oceanic color palette redesign (commit: 2113c91)
- [x] Add code syntax highlighting for blog posts (already in post.html layout)
- [x] Add llms.txt for AI model context and understanding (commit: 378554d)
- [x] Document CSS custom property usage in CLAUDE.md (commit: 307f5c1)

### Performance Optimizations (November 2025)
- [x] Fix render blocking requests - Font Awesome async loading (commit: 2113c91)
- [x] Fix render blocking requests - main.js defer attribute (commit: 2113c91)
- [x] Add font-display: swap for faster text rendering (commit: 2113c91)
- [x] Add preconnect hints for CDN resources (commit: 2113c91)

### Content Organization (November 2025)
- [x] Standardize blog post filenames to simpler naming convention (commit: 2667c27)
- [x] Rename existing blog posts to follow simplified format (commit: 2667c27)
- [x] Update CLAUDE.md and templates with simplified naming documentation (commit: 2667c27)
- [x] Update project entries in `_projects/` with actual projects from portfolio (2025-11-04)
- [x] Replace placeholder project URLs with real GitHub repository links (2025-11-04)
- [x] Add LinkedIn profile link to config and footer (2025-11-04)
- [x] Add comprehensive code comments to main.css documenting all major sections (2025-11-04)

### Documentation (November 2025)
- [x] Update CLAUDE.md with oceanic color palette documentation (2025-11-04)
- [x] Add comprehensive content contribution guidelines to CLAUDE.md (2025-11-04)

### Homepage Enhancements (November 2025)
- [x] Add short_description field to all project files for concise homepage summaries (2025-11-04)
- [x] Update index.html Featured Projects section to use short_description (2025-11-04)
- [x] Update project-template.md with dual description field guidance (2025-11-04)
