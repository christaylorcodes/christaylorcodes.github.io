# Website TODO List

This document tracks improvements and enhancements for christaylor.codes. Tasks are organized by priority to help maintain and enhance the website.

## Priority 1: Maintenance & Project Management

### Content Management
- [ ] Replace placeholder blog posts with real content about automation, PowerShell, and network operations
- [ ] Update project entries in `_projects/` with actual projects from your portfolio
- [ ] Replace placeholder project URLs (`#`) with real demo and GitHub repository links
- [ ] Update contact form action URL - Replace `YOUR_FORM_ID` in [contact.html:16](contact.html#L16) with actual Formspree ID
- [ ] Add professional headshot or profile image to About page

### Code Organization
- [ ] Move inline styles to CSS classes for better maintainability
  - Blog post links in [index.html:75](index.html#L75)
  - Post date styling in [index.html:76](index.html#L76)
  - Read more link in [index.html:80](index.html#L80)
  - Project tags margin in [index.html:105](index.html#L105)
  - Contact form intro in [contact.html:12](contact.html#L12)
- [ ] Create reusable CSS classes for repeated patterns (cards, buttons, spacing)
- [ ] Add code comments in main.css to document major sections

### Documentation
- [ ] Create template file for new blog posts in `_templates/post-template.md`
- [ ] Create template file for new projects in `_templates/project-template.md`
- [ ] Document CSS custom property usage in CLAUDE.md
- [ ] Add content contribution guidelines to CLAUDE.md

## Priority 2: Features & Functionality

### Blog Enhancements
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
- [ ] Add form validation feedback (success/error messages)
- [ ] Add LinkedIn profile link (uncomment in [_config.yml:10](_config.yml#L10))
- [ ] Add professional social media links (Twitter, etc.)
- [ ] Consider adding calendly/scheduling link for consultations

### Navigation
- [ ] Add breadcrumb navigation for better UX
- [ ] Add "Back to Top" button for long pages
- [ ] Implement active navigation state for all pages

## Priority 3: SEO & Performance

### SEO Optimization
- [ ] Add custom meta descriptions to all pages using front matter
- [ ] Add Open Graph tags for better social media sharing
- [ ] Add Twitter Card meta tags
- [ ] Create `sitemap.xml` (can use jekyll-sitemap plugin)
- [ ] Create `robots.txt` file
- [ ] Add favicon and Apple touch icons
- [ ] Add structured data (JSON-LD) for better search results

### Performance
- [ ] Implement image optimization workflow
- [ ] Add lazy loading for images
- [ ] Minify CSS for production
- [ ] Consider adding service worker for offline functionality
- [ ] Optimize Font Awesome usage (only load needed icons)
- [ ] Add preconnect hints for Google Fonts and Font Awesome CDN

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
- [ ] Add code syntax highlighting for blog posts with code samples
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

1. [ ] Add real Formspree form ID to contact page
2. [ ] Add favicon set (can use https://realfavicongenerator.net/)
3. [ ] Add LinkedIn profile link to config and footer
4. [ ] Create first real blog post about PowerShell automation
5. [ ] Add at least one real project from your portfolio
6. [ ] Add sitemap.xml using jekyll-sitemap plugin
7. [ ] Add robots.txt file
8. [ ] Move all inline styles to CSS classes

## Notes

- Test all changes locally before pushing to GitHub Pages
- Maintain responsive design for all new features
- Keep dark theme and turquoise accent colors consistent
- Prioritize page load performance
- Ensure all new content aligns with Chris Taylor's professional brand

## Completed Tasks

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
