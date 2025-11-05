# Website TODO List

This document tracks improvements and enhancements for christaylor.codes. Tasks are organized by priority to help maintain and enhance the website.

## Sprint Planning

Tasks below have been organized into 8 focused sprints that group similar work and optimize for efficiency. Each sprint is designed to minimize context switching and token usage.

### Sprint 1: Performance & Image Optimization ✅ COMPLETE
**Priority:** HIGH | **Token Usage:** MEDIUM (~75K tokens) | **Completed:** 2025-11-04

Foundation sprint establishing performance baselines and asset optimization workflows.

**Completed Tasks:**
- [x] Analyze PageSpeed insights and implement fixes (excluding Cloudflare items)
- [x] Create image optimization workflow (WebP conversion process)
- [x] Implement lazy loading for images
- [x] Optimize Font Awesome usage (documentation created - implementation pending)
- [x] Minify CSS for production

**Deliverables:**
- Created `optimize-images.ps1` - Automated WebP conversion script
- Created `docs/IMAGE-OPTIMIZATION-GUIDE.md` - Complete image optimization guide
- Created `docs/FONT-AWESOME-OPTIMIZATION.md` - Font Awesome optimization strategy
- Created `docs/PERFORMANCE-TESTING-GUIDE.md` - Testing and validation procedures
- Created `docs/SPRINT-1-SUMMARY.md` - Comprehensive sprint summary
- Updated `about.html` - WebP picture element + lazy loading
- Updated `index.html` - Hero backgrounds with WebP support
- Updated `assets/js/main.js` - WebP detection + lazy loading fallback
- Updated `_config.yml` - Enabled Sass compression

**Performance Impact (Projected):**
- File size reduction: 73% (~2,060 KB savings)
- PageSpeed improvement: +20-25 points
- LCP improvement: -1.0s to -1.5s

**Next Steps:**
1. Generate WebP images (run script or use Squoosh.app)
2. Create Font Awesome Kit (5-10 minutes)
3. Test and deploy changes
4. Measure actual performance improvements

### Sprint 2: SEO & Accessibility
**Priority:** HIGH | **Token Usage:** MEDIUM-HIGH | **Duration:** 2 sessions

Critical improvements for discoverability and inclusivity.

**Session A - SEO:**
- [ ] Add custom meta descriptions to all pages
- [ ] Review and enhance existing structured data

**Session B - Accessibility:**
- [ ] Add ARIA labels to navigation and interactive elements
- [ ] Ensure all images have descriptive alt text
- [ ] Add skip navigation link for keyboard users
- [ ] Test color contrast ratios for WCAG compliance
- [ ] Test with screen readers

### Sprint 3: Navigation & UX Enhancements
**Priority:** MEDIUM | **Token Usage:** LOW-MEDIUM | **Duration:** 1 session

**Tasks:**
- [ ] Implement active navigation state for all pages
- [ ] Add breadcrumb navigation for better UX

### Sprint 4: Analytics & Monitoring
**Priority:** MEDIUM | **Token Usage:** LOW | **Duration:** 1 session

**Tasks:**
- [ ] Add privacy-focused analytics (Plausible or Fathom)
- [ ] Add performance monitoring
- [ ] Implement error tracking

### Sprint 5: Contact & Social Enhancements
**Priority:** LOW-MEDIUM | **Token Usage:** LOW | **Duration:** 1 session

**Tasks:**
- [ ] Add professional social media links (Twitter, etc.)
- [ ] Consider adding Calendly/scheduling link for consultations

### Sprint 6: Advanced Interactive Features
**Priority:** MEDIUM | **Token Usage:** HIGH | **Duration:** 2-3 sessions

**Session A - Theme Toggle:**
- [ ] Add dark/light mode toggle (currently dark only)

**Session B - Print & Export:**
- [ ] Add print stylesheet
- [ ] Create PDF export functionality for blog posts

**Session C - Gallery:**
- [ ] Add image galleries/lightbox for projects

### Sprint 7: Content Types Expansion
**Priority:** LOW-MEDIUM | **Token Usage:** HIGH | **Duration:** 2-3 sessions

**Tasks:**
- [ ] Create "Case Studies" section for detailed project write-ups
- [ ] Add "Talks" or "Presentations" section
- [ ] Add "Tools" or "Resources" page for useful automation tools
- [ ] Create newsletter signup functionality

### Sprint 8: Development Workflow & Testing
**Priority:** MEDIUM | **Token Usage:** MEDIUM | **Duration:** 1-2 sessions

**Session A - Testing & Automation:**
- [ ] Set up automated testing for HTML validation
- [ ] Add link checker to prevent broken links
- [ ] Create CI/CD pipeline for automated deployments
- [ ] Add accessibility testing in build process

**Session B - Git & Tooling:**
- [ ] Add `.gitattributes` for consistent line endings
- [ ] Create git tags for major releases
- [ ] Add GitHub issue templates and PR template
- [ ] Add npm scripts for common tasks
- [ ] Consider adding Webpack/Gulp for asset pipeline
- [ ] Add CSS linting (stylelint)
- [ ] Add HTML validation in development

---

## Priority 1: Maintenance & Project Management

### Content Management
- [x] Replace placeholder blog posts with real content about automation, PowerShell, and network operations (Completed 2025-11-04)
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
- [x] Add reading time estimates to blog posts (Completed 2025-11-04)
- [x] Implement pagination for blog posts (Completed 2025-11-04)
- [x] Add category/tag filtering functionality on blog index page (Completed 2025-11-04)
- [x] Add copy button to code blocks in blog posts (Completed 2025-11-04)
- [x] Add search functionality for blog posts (Completed 2025-11-04)
- [x] Add "Related Posts" section to blog post layout (Completed 2025-11-04)
- [x] Add comments system using utterances for GitHub-based comments (Completed 2025-11-04 - requires utterances app installation, see UTTERANCES-SETUP.md)
- [x] Add RSS feed icon/link in navigation or footer (Completed 2025-11-04)

### Project Enhancements
- [x] Add project detail pages (set `output: true` in _config.yml for projects collection) (Completed 2025-11-04)
- [x] Add "View Project Details" functionality (Completed 2025-11-04)
- [x] Create project categories for filtering (Completed 2025-11-04)
- [x] Add project screenshots/images functionality (Completed 2025-11-04)
  - Created assets/images/projects directory
  - Updated project template with image field documentation
  - Enhanced project layout to display hero images and screenshot galleries
  - Added comprehensive CSS styling with hover effects
  - Updated sample projects with placeholder image paths
  - Documented image specifications and optimization guidelines in CLAUDE.md
  Create a process to properly process image files.
  Conver images to webp format and optimize them with WebP Express.
  - Create a process to properly process image

### Contact Enhancements
- [x] Add LinkedIn profile link (uncomment in [_config.yml:10](_config.yml#L10)) (Completed 2025-11-04)
- [ ] Add professional social media links (Twitter, etc.)
- [ ] Consider adding calendly/scheduling link for consultations

### Navigation
- [ ] Add breadcrumb navigation for better UX
- [x] Add "Back to Top" button for long pages (Completed 2025-11-04)
- [ ] Implement active navigation state for all pages

## Priority 3: SEO & Performance

### SEO Optimization
- [ ] Add custom meta descriptions to all pages using front matter
- [x] Add Open Graph tags for better social media sharing (Completed 2025-11-03)
- [x] Add Twitter Card meta tags (Completed 2025-11-03)
- [x] Add structured data (JSON-LD) for better search results (Completed 2025-11-04 - Enhanced schema for all page types)

### Performance
Work to correct pagespeed errors
https://pagespeed.web.dev/analysis/https-christaylor-codes/xd0l97cc3z?form_factor=mobile
Ignore anything related to cloudflare
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
2. [x] Create first real blog post about PowerShell automation (Completed 2025-11-04 - Added 4-post series on ConnectWiseAutomateAgent)
3. [x] Add at least one real project from your portfolio (Completed 2025-11-04)
4. [x] Add Open Graph and Twitter Card meta tags for better social sharing (Completed 2025-11-03)
5. [x] Add structured data (JSON-LD) for improved search results (Completed 2025-11-04 - See STRUCTURED-DATA-SUMMARY.md)

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

### Blog Content (November 2025)
- [x] Add ConnectWiseAutomateAgent blog post series (2025-11-04)
  - Introduction to the module and key features
  - Mass agent deployment guide with parallel execution
  - Troubleshooting techniques and diagnostics
  - 10 real-world use cases for MSP automation
- [x] Add reading time estimates to blog posts (2025-11-04)
  - Calculated at ~200 words per minute
  - Displays with clock icon in post metadata
  - Shows minimum 1 minute for short posts
- [x] Implement pagination for blog posts (2025-11-04)
  - 6 posts per page with configurable setting in _config.yml
  - Moved blog.html to blog/index.html (required for Jekyll pagination)
  - Previous/Next buttons with disabled state
  - Numbered page links with active state highlighting
  - Page info display (Page X of Y with total posts)
  - Responsive design for mobile and tablet
  - Uses jekyll-paginate plugin (GitHub Pages compatible)
- [x] Add ConnectWise Manage API blog post series (2025-11-04)
  - Introduction to ConnectWiseManageAPI module
  - Getting started guide with authentication and basic operations
  - Advanced automation scenarios and real-world use cases
  - Best practices for production deployments
- [x] Add category filtering with dynamic buttons and responsive dropdown (2025-11-04)
  - Category filter buttons with post counts
  - Active state highlighting
  - Responsive dropdown for overflow categories
  - Color-coded category badges with gradient backgrounds
  - Filter buttons system with cyan/emerald/amber/red variations
- [x] Add client-side search functionality (2025-11-04)
  - Real-time search with instant results
  - Searches across titles, content, categories, and tags
  - JSON-based search index
  - Highlighted search terms in results
  - Responsive search interface
- [x] Enhance JavaScript functionality (2025-11-04)
  - Refactored and expanded main.js
  - Category filtering logic
  - Search functionality
  - Copy-to-clipboard for code blocks
  - Improved mobile navigation
  - Intersection observer for animations
- [x] Create component sample pages for design system (2025-11-04)
  - buttons.html - Button system demonstration
  - badges.html - Category badge variations
  - categories.html - Filter button examples
  - highlights.html - Hero highlight components
- [x] Add PowerShell build script for local development (2025-11-04)
  - build.ps1 with serve/build/clean modes
  - Automatic dependency checking
  - Colored status output
  - Error handling and reporting
- [x] Expand CLAUDE.md with comprehensive design system documentation (2025-11-04)
  - Button system documentation with color guide
  - Filter button system documentation
  - Category badge system documentation
  - Width strategy documentation
  - Component usage examples and best practices
- [x] Clean up temporary documentation files (2025-11-04)
  - Removed _BUILD-AND-TEST.md
  - Removed _REFACTORING-COMPLETE.md
  - Removed _theme-refactoring-plan.md
