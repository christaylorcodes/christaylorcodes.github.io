# Website TODO List

**Project Type**: [PERSONAL]
**Time Allocation**: Part of 12 hours/week personal brand work (post-recovery)

This document tracks improvements and enhancements for christaylor.codes. Tasks are organized by priority to help maintain and enhance the website.

## Time Allocation

**Recovery Window (Nov 12-26, 2025)**:
- **Week 1 (Nov 12-18)**: Blog content creation focus (Blog Posts #2-3) - 28-44 hours
- **Week 2 (Nov 19-25)**: Website infrastructure (SEO, accessibility) - 20-30 hours

**Post-Recovery (Nov 26+)**:
- **Fridays**: 8-10 hours (primary deep work block for blog posts and LinkedIn content)
- **Scattered**: 2-4 hours (engagement, small updates, monitoring)
- **Monthly Total**: ~48 hours/month average (12 hours/week)

---

## Milestones

### Milestone: 90-Day Post-Launch Review 🎯
**Status:** Scheduled
**Go-Live Date:** November 3, 2025
**Review Date:** February 1, 2026 (90 days post-launch)
**Type:** Major project milestone

**Review Objectives:**
- [ ] Analyze website performance and user engagement metrics
  - Review Google Analytics / Cloudflare Analytics data
  - Check PageSpeed Insights scores (compare to baseline)
  - Review Core Web Vitals
  - Analyze traffic sources and user behavior
- [ ] Content performance assessment
  - Blog post engagement (views, time on page, bounce rate)
  - Most popular content and projects
  - Identify content gaps or opportunities
- [ ] Technical health check
  - Review uptime and availability
  - Check for broken links
  - Review security (headers, CSP, dependencies)
  - Verify all automated workflows are functioning
- [ ] SEO effectiveness
  - Check Google Search Console performance
  - Review indexed pages and crawl errors
  - Analyze search queries and rankings
  - Assess structured data effectiveness
- [ ] Accessibility review
  - Re-run WAVE/axe/Lighthouse audits
  - Compare to baseline scores
  - Address any new issues
- [ ] User feedback collection
  - Review any contact form submissions
  - Check GitHub discussions/issues
  - Review social media engagement
- [ ] Action items and priorities
  - Document lessons learned
  - Update TODO with new priorities based on data
  - Plan next 90-day sprint goals

**Coordinate with:** [docs/WEBSITE-MATURITY-FRAMEWORK.md](docs/WEBSITE-MATURITY-FRAMEWORK.md) quarterly review (2026-02-07)

---

## Related Documentation

**Site Maturity Tracking:**
- [docs/WEBSITE-MATURITY-FRAMEWORK.md](docs/WEBSITE-MATURITY-FRAMEWORK.md) - Comprehensive maturity assessment and growth roadmap
- Review quarterly to track progress across 7 key dimensions
- Next review: 2026-02-07

**Project Documentation:**
- [CLAUDE.md](CLAUDE.md) - Complete project maintenance guide
- [README.md](README.md) - Setup and deployment instructions

**SEO & Growth:**
- [docs/BACKLINK-STRATEGY.md](docs/BACKLINK-STRATEGY.md) - Comprehensive backlink building and organic discovery strategy
- 10 core strategies with implementation roadmap
- Metrics tracking and quarterly review process

## Sprint Planning

Tasks below have been organized into 9 focused sprints that group similar work and optimize for efficiency. Each sprint is designed to minimize context switching and token usage.

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

### Sprint 2: SEO & Accessibility ⏳ RECOVERY WINDOW (Nov 19-25)
**Priority:** HIGH | **Project Type:** [PERSONAL] | **Duration:** 14-18 hours total
**Timeline:** Recovery Week 2 (Nov 19-25, 2025)

Critical improvements for discoverability and inclusivity during recovery window.

**SEO Optimization** (8-10 hours) - Nov 19-21:
- [ ] Add custom meta descriptions to all pages [PERSONAL] [HIGH] (3-4 hours)
  - Homepage, About, Blog, Projects, Contact, Terms, Privacy
- [ ] Set up Google Analytics 4 or Cloudflare Web Analytics [PERSONAL] [HIGH] (2-3 hours)
- [ ] Configure Google Search Console and submit sitemap [PERSONAL] [HIGH] (1-2 hours)
- [ ] Set up conversion tracking (blog engagement, GitHub clicks) [PERSONAL] [HIGH] (1-2 hours)
- [ ] Create analytics baseline dashboard [PERSONAL] [MEDIUM] (1 hour)
- [ ] Review and enhance existing structured data [PERSONAL] [MEDIUM] (1 hour)

**Accessibility Improvements** (6-8 hours) - Nov 22-25:
- [ ] Add ARIA labels to navigation and interactive elements [PERSONAL] [HIGH] (2-3 hours)
- [ ] Ensure all images have descriptive alt text [PERSONAL] [HIGH] (2-3 hours)
- [ ] Add skip navigation link for keyboard users [PERSONAL] [MEDIUM] (1 hour)
- [ ] Run WAVE/axe/Lighthouse accessibility audits [PERSONAL] [HIGH] (1-2 hours)
- [ ] Fix critical accessibility issues found [PERSONAL] [HIGH] (1-2 hours)
- [ ] Test color contrast ratios for WCAG AA compliance [PERSONAL] [MEDIUM] (30 min)
- [ ] Test with screen readers if time permits [PERSONAL] [LOW] (1-2 hours)

### Sprint 3: Navigation & UX Enhancements 📅 DEFERRED (Q1 2026)
**Priority:** MEDIUM | **Project Type:** [PERSONAL] | **Duration:** 4-6 hours
**Timeline:** Q1 2026 (Friday workflow)

**Tasks:**
- [ ] Implement active navigation state for all pages [PERSONAL] [MEDIUM] (2-3 hours)
- [ ] Add breadcrumb navigation for better UX [PERSONAL] [MEDIUM] (2-3 hours)

### Sprint 4: Advanced Analytics 📅 DEFERRED (Q2 2026)
**Priority:** LOW | **Project Type:** [PERSONAL] | **Duration:** 4-6 hours
**Timeline:** Q2 2026 (after Sprint 2 basic analytics in place)

**Context:** PSWebsiteHealth module suite in development to automate website monitoring. See [c:\_Code\CHRIS\projects\pswebsitehealth.md](c:\_Code\CHRIS\projects\pswebsitehealth.md)

**Tasks:**
- [ ] Add privacy-focused analytics (Plausible or Fathom) [PERSONAL] [LOW] (2-3 hours)
- [ ] Add performance monitoring (automated via PSLighthouse) [PERSONAL] [LOW] (3-4 hours)
- [ ] Implement error tracking [PERSONAL] [LOW] (2-3 hours)
- [ ] Set up automated weekly performance checks [PERSONAL] [LOW] (2-3 hours)
- [ ] Create monitoring dashboard for maturity framework metrics [PERSONAL] [LOW] (4-6 hours)

**Note:** Sprint 2 includes basic analytics (GA4/Cloudflare). Sprint 4 is for advanced monitoring tools.

### Sprint 5: Contact & Social Enhancements 📅 DEFERRED (Q2 2026)
**Priority:** LOW | **Project Type:** [PERSONAL] | **Duration:** 2-3 hours
**Timeline:** Q2 2026

**Tasks:**
- [ ] Add professional social media links (Twitter, etc.) [PERSONAL] [LOW] (1-2 hours)
- [ ] Consider adding Calendly/scheduling link for consultations [PERSONAL] [LOW] (1 hour)

### Sprint 6: Advanced Interactive Features 📅 DEFERRED (Q3 2026)
**Priority:** MEDIUM | **Project Type:** [PERSONAL] | **Duration:** 20-30 hours
**Timeline:** Q3 2026 (low priority, nice-to-have features)

**Session A - Theme Toggle:**
- [ ] Add dark/light mode toggle (currently dark only) [PERSONAL] [MEDIUM] (8-10 hours)

**Session B - Print & Export:**
- [ ] Add print stylesheet [PERSONAL] [LOW] (2-3 hours)
- [ ] Create PDF export functionality for blog posts [PERSONAL] [LOW] (6-8 hours)

**Session C - Gallery:**
- [ ] Add image galleries/lightbox for projects [PERSONAL] [MEDIUM] (6-8 hours)

### Sprint 7: Content Types Expansion 📅 DEFERRED (Q4 2026)
**Priority:** LOW | **Project Type:** [PERSONAL] | **Duration:** 38-52 hours
**Timeline:** Q4 2026 (after core brand established)

**Tasks:**
- [ ] Create "Case Studies" section for detailed project write-ups [PERSONAL] [LOW] (10-12 hours)
- [ ] Add "Talks" or "Presentations" section [PERSONAL] [LOW] (4-6 hours)
- [ ] Add "Tools" or "Resources" page for useful automation tools [PERSONAL] [LOW] (6-8 hours)
- [ ] Create newsletter signup functionality [PERSONAL] [LOW] (6-8 hours)
- [ ] Add "Books" section for recommended reading or reading list [PERSONAL] [LOW] (6-8 hours)
  - Professional development books, technical references, favorites
  - Cover images, ratings, and personal notes/reviews
  - Consider integration with Goodreads or similar service
  - Group by categories (PowerShell, Automation, Leadership, etc.)
- [ ] Add "Careers/Jobs" section with Google JobPosting structured data [PERSONAL] [LOW] (8-12 hours)
  - **Goal:** Enable posting job opportunities with proper schema.org/JobPosting markup for Google Jobs integration
  - **Implementation Tasks:**
    - Add `_jobs` collection to `_config.yml` (similar to projects collection)
    - Create `_layouts/job.html` with job detail display and JSON-LD structured data
    - Create `jobs.html` listing page with filterable job cards
    - Add `_sass/oceanic/_jobs.scss` for styling (import in oceanic.scss)
    - Create example job posting template in `_jobs/` directory
    - Add "Careers" navigation link
    - Document usage in CLAUDE.md
  - **Required Structured Data Fields:**
    - `title` - Job title
    - `description` - Full job description (HTML formatted)
    - `datePosted` - Posting date (ISO 8601 format)
    - `validThrough` - Application deadline
    - `hiringOrganization` - Company info (name, logo, URL)
    - `jobLocation` - Location (address or remote)
    - `employmentType` - FULL_TIME, PART_TIME, CONTRACTOR, etc.
    - `baseSalary` - Salary range (optional but recommended)
  - **Design Decisions Needed:**
    - Hiring organization name (i.t.NOW vs. Chris Taylor personal brand)
    - Default job types and locations (remote vs. specific locations)
    - Application process (contact form, email, external ATS)
    - Salary display preferences (show publicly or not)
    - Auto-hide expired jobs (after validThrough date)
  - **Testing/Validation:**
    - Test with Google Rich Results Test tool (https://search.google.com/test/rich-results)
    - Verify JSON-LD validates against schema.org/JobPosting
    - Check mobile responsiveness
    - Test filtering and search functionality
  - **References:**
    - Schema.org: https://schema.org/JobPosting
    - Google Search Central: https://developers.google.com/search/docs/appearance/structured-data/job-posting

### Sprint 8: Development Workflow & Testing ⏳ IN PROGRESS
**Priority:** HIGH → MEDIUM | **Project Type:** [PERSONAL] | **Duration:** 12-16 hours
**Timeline:** Phase 1 Complete (Nov 2025), Phase 2 Deferred (Q2-Q3 2026)

**Phase 1 - Core CI/CD Pipeline ✅ COMPLETE (Nov 8, 2025)**
- [x] Create dev branch workflow with automated promotion tooling [PERSONAL] [HIGH] (4-5 hours)
  - Created `dev` branch as primary development environment
  - Built comprehensive promotion script (`promote-to-main.ps1`) with safety checks
  - Documented complete workflow in CLAUDE.md
- [x] Set up automated testing for HTML validation [PERSONAL] [HIGH] (2-3 hours)
  - Implemented html-proofer for link checking and HTML validation
  - Validates images, scripts, and internal links on every dev branch push
- [x] Add markdown linting for blog posts [PERSONAL] [HIGH] (1-2 hours)
  - Configured markdownlint with sensible rules for technical content
  - Ensures consistent formatting across all blog posts
- [x] Add Lighthouse CI for performance/accessibility/SEO [PERSONAL] [HIGH] (2-3 hours)
  - Automated performance testing on 5 key pages
  - Tracks accessibility, SEO, and best practices scores
  - Saves results as artifacts for trend analysis

**Phase 2 - Enhanced Quality Checks 📅 PLANNED (Q2 2026)**
**Estimated Duration:** 6-8 hours

**Session A - Content Quality (3-4 hours):**
- [ ] Add front matter validation for blog posts [PERSONAL] [MEDIUM] (1-2 hours)
  - Verify required fields: layout, title, date, excerpt, categories
  - Ensure consistent metadata across all posts
  - Prevent publishing posts with missing SEO data
- [ ] Add spell checking for markdown content [PERSONAL] [MEDIUM] (1-2 hours)
  - Automated spell checking for blog posts and documentation
  - Custom dictionary for technical terms and abbreviations
  - Catches typos before publication
- [ ] Add structured data validation [PERSONAL] [MEDIUM] (1-2 hours)
  - Validate JSON-LD schema markup
  - Ensure schema.org compliance for rich search results
  - Test with Google Rich Results validator

**Session B - Code Quality & Security (3-4 hours):**
- [ ] Add SCSS linting (stylelint) [PERSONAL] [MEDIUM] (2-3 hours)
  - Enforce consistent SCSS formatting
  - Catch CSS syntax errors and best practice violations
  - Maintain clean, maintainable stylesheets
- [ ] Add security scanning for dependencies [PERSONAL] [MEDIUM] (1 hour)
  - bundler-audit for Ruby gem vulnerabilities
  - Automated alerts for security updates
  - Integrate with GitHub security features
- [ ] Add HTML validation in development [PERSONAL] [LOW] (1-2 hours)
  - W3C HTML validator integration
  - Catch markup errors during local development

**Session C - Git & Tooling (2-3 hours):**
- [ ] Add `.gitattributes` for consistent line endings [PERSONAL] [LOW] (30 min)
- [ ] Create git tags for major releases [PERSONAL] [LOW] (1 hour)
- [ ] Add GitHub issue templates and PR template [PERSONAL] [LOW] (2 hours)
- [ ] Add npm scripts for common tasks [PERSONAL] [LOW] (1-2 hours)

**Benefits of Completed Phase 1:**
- ✅ Safe development environment (dev branch prevents accidental production deployments)
- ✅ Automated quality checks catch issues before production
- ✅ Performance/accessibility/SEO monitoring with every build
- ✅ Professional-grade CI pipeline with comprehensive validation
- ✅ Lighthouse scores tracked over time for continuous improvement

### Sprint 9: SEO & Link Building 📅 PLANNED (Q1-Q2 2026)
**Priority:** MEDIUM-HIGH | **Project Type:** [PERSONAL] | **Duration:** 12-16 hours total
**Timeline:** Q1-Q2 2026 (after Sprint 2 basic SEO foundation)

**Strategy Document:** [docs/BACKLINK-STRATEGY.md](docs/BACKLINK-STRATEGY.md) - Comprehensive backlink building strategy

Strategic sprint to build domain authority and organic discovery through natural, high-quality backlinks from relevant sources in the MSP, PowerShell, and IT automation communities.

**Target Metrics (6 months):**
- Total backlinks: 50-100
- Referring domains: 30-50 unique domains
- Domain Authority: Increase to 25+
- Referral traffic: 200-500 visits/month

**Month 1-2: Quick Wins** (4-6 hours) - Low effort, immediate impact:
- [ ] Update all GitHub README files with links to tutorials and christaylor.codes [PERSONAL] [HIGH] (2 hours)
- [ ] Add comprehensive metadata to PowerShell Gallery modules [PERSONAL] [MEDIUM] (1 hour)
- [ ] Cross-post top 3 blog posts to Dev.to and Hashnode with canonical links [PERSONAL] [MEDIUM] (1-2 hours)
- [ ] Submit modules to awesome-powershell GitHub list [PERSONAL] [MEDIUM] (30 min)
- [ ] Create author accounts: Stack Overflow, Reddit, PowerShell.org [PERSONAL] [MEDIUM] (1 hour)
- [ ] Join and participate in r/PowerShell, r/msp communities [PERSONAL] [MEDIUM] (ongoing)
- [ ] Answer 5 ConnectWise/PowerShell questions on Stack Overflow [PERSONAL] [MEDIUM] (2 hours)
- [ ] Reach out to 5 MSP bloggers with "Free tools for your readers" pitch [PERSONAL] [LOW] (1 hour)

**Month 3-4: Content Creation** (4-6 hours) - Medium effort, high long-term value:
- [ ] Create "Ultimate Guide to ConnectWise Manage API Automation" (5000+ words) [PERSONAL] [HIGH] (6-8 hours)
- [ ] Design one infographic: "MSP Automation Maturity Model" [PERSONAL] [MEDIUM] (2-3 hours)
- [ ] Write guest post for Dev.to or DZone [PERSONAL] [MEDIUM] (4-5 hours)
- [ ] Create "PowerShell for MSPs" resource list page on site [PERSONAL] [MEDIUM] (2 hours)
- [ ] Competitor backlink analysis (identify 20 link opportunities) [PERSONAL] [LOW] (2 hours)
- [ ] Broken link building outreach (10 site owners) [PERSONAL] [LOW] (2 hours)

**Month 5-6: Outreach & Scaling** (4-6 hours) - Higher effort, compounding returns:
- [ ] Pitch guest posts to Channel Futures, MSP Alliance [PERSONAL] [MEDIUM] (2-3 hours)
- [ ] Apply for ConnectWise integration partner listing [PERSONAL] [LOW] (1-2 hours)
- [ ] Create second linkable asset: "50 MSP Automation Scripts" [PERSONAL] [MEDIUM] (6-8 hours)
- [ ] Reach out to 10 more MSP bloggers with new resource [PERSONAL] [LOW] (1-2 hours)
- [ ] Submit tools to 5 additional directories [PERSONAL] [LOW] (1 hour)
- [ ] Continue Stack Overflow participation (target 20 answers total) [PERSONAL] [LOW] (ongoing)

**Ongoing Activities** (1-2 hours/week):
- [ ] Sign up for HARO and respond to 2-3 queries/week [PERSONAL] [LOW] (30 min/week)
- [ ] Monitor backlinks monthly in Google Search Console [PERSONAL] [MEDIUM] (30 min/month)
- [ ] Track referral traffic and domain authority growth [PERSONAL] [MEDIUM] (quarterly)

**Integration:**
- Builds on Sprint 2 SEO foundation (meta descriptions, analytics, Search Console)
- Supports christaylor-codes-brand.md Phase 5: SEO & Discovery
- Aligns with docs/WEBSITE-MATURITY-FRAMEWORK.md SEO dimension (current 30% → target 60%)

---

### Sprint 10: Code Quality Standards Improvement 📅 PLANNED (Q2-Q3 2026)
**Priority:** LOW | **Project Type:** [PERSONAL] | **Duration:** 18-28 hours total
**Timeline:** Q2-Q3 2026 (after higher priority content and SEO work)

This sprint restores stricter quality standards that were temporarily relaxed to get the CI/CD pipeline operational. While the site currently meets minimum quality thresholds, these improvements will bring it up to professional best-practice standards.

**Context:**
During CI/CD implementation (November 2025), we relaxed certain quality standards to accommodate existing content:
- **Markdown linting**: Relaxed 6 cosmetic rules (MD022, MD025, MD031, MD032, MD040, MD049)
- **Accessibility**: Lowered threshold from 90% to 85%, made color-contrast a warning
- **Lighthouse preset**: Removed "lighthouse:recommended" preset to eliminate strict PWA and performance checks
- **Current state**: Site passes all critical checks, but has improvement opportunities

**Phase 1: Markdown Quality Restoration** (4-6 hours):
- [ ] Fix markdown linting violations in existing blog posts (98 errors across 15 posts) [PERSONAL] [LOW] (3-4 hours)
  - Most common: MD032 (blanks around lists), MD031 (blanks around code), MD040 (code language)
  - Use `markdownlint _posts/*.md` to identify specific issues
  - Fix systematically, starting with posts that have most errors
  - Update posts in batches to avoid large commits
- [ ] Re-enable strict markdown rules in `.markdownlint.json` [PERSONAL] [LOW] (30 min)
  - MD022: true (blanks around headings)
  - MD025: true (single H1)
  - MD031: true (blanks around fences)
  - MD032: true (blanks around lists)
  - MD040: true (code language specification)
  - MD049: { "style": "underscore" } (consistent emphasis)
- [ ] Verify all posts pass strict linting [PERSONAL] [LOW] (30 min)
- [ ] Update CLAUDE.md to reflect restored standards [PERSONAL] [LOW] (30 min)

**Phase 2: Accessibility Improvements** (4-6 hours):
- [ ] Fix color contrast issues causing 88% accessibility score [PERSONAL] [LOW] (2-3 hours)
  - Identify elements with insufficient contrast (check Lighthouse report)
  - Review secondary text color (#cbd5e1) on backgrounds
  - Test button text contrast on all color variations
  - Verify link colors meet WCAG AA standards (4.5:1 minimum)
  - Update CSS variables in `_sass/oceanic/_variables.scss` as needed
- [ ] Restore stricter Lighthouse thresholds in `.lighthouserc.json` [PERSONAL] [LOW] (30 min)
  - categories:accessibility: ["error", {"minScore": 0.90}]
  - color-contrast: "error" (from current "warn")
- [ ] Verify all pages pass 90% accessibility threshold [PERSONAL] [LOW] (1-2 hours)
  - Run Lighthouse on all 5 key pages
  - Address any remaining issues
  - Document any intentional exceptions
- [ ] Update CLAUDE.md and workflow documentation [PERSONAL] [LOW] (30 min)

**Phase 3: Lighthouse Recommended Preset Restoration** (6-10 hours):
- [ ] Evaluate and fix Lighthouse recommended preset violations [PERSONAL] [LOW] (4-6 hours)
  - Fix link-in-text-block issues (ensure links are visually distinct)
  - Fix heading-order problems (ensure logical heading hierarchy)
  - Fix label-content-name-mismatch (ensure labels match accessible names)
  - Fix identical-links-same-purpose (ensure unique link text or context)
  - Review and address performance recommendations:
    - Offscreen images (implement lazy loading if not already done)
    - Render-blocking resources (optimize CSS/JS loading)
    - Unused CSS/JavaScript (consider code splitting)
    - Text compression (verify Cloudflare gzip/brotli is working)
  - Evaluate PWA requirements (installable-manifest, themed-omnibox)
    - Decision needed: Does this portfolio site need PWA features?
    - If yes: Add web app manifest and theme colors
    - If no: Document decision to exclude PWA from preset
- [ ] Re-enable "lighthouse:recommended" preset in `.lighthouserc.json` [PERSONAL] [LOW] (30 min)
  - Add back: "preset": "lighthouse:recommended"
  - May need to add exceptions for PWA requirements if not desired
  - Update explicit assertions to complement preset
- [ ] Verify all pages pass recommended preset checks [PERSONAL] [LOW] (2-3 hours)
  - Run Lighthouse CI on all 5 key pages
  - Review and address any remaining failures
  - Test edge cases (blog posts, project pages)
  - Document any intentional exceptions with rationale
- [ ] Update documentation and CI/CD configuration [PERSONAL] [LOW] (1 hour)
  - Update CLAUDE.md with restored preset documentation
  - Update dev-build.yml if needed
  - Document decision on PWA features

**Success Criteria:**
- [ ] All blog posts pass strict markdown linting (0 errors)
- [ ] All pages achieve 90%+ accessibility score
- [ ] Color contrast meets WCAG AA standards (4.5:1 for normal text, 3:1 for large)
- [ ] All pages pass "lighthouse:recommended" preset checks
- [ ] PWA features evaluated and decision documented
- [ ] CI/CD enforces strict standards without false positives

**Benefits:**
- **Professional quality**: Site meets industry best practices for content formatting
- **Accessibility**: Better experience for users with visual impairments
- **Maintainability**: Consistent formatting makes content easier to update
- **SEO**: Search engines favor well-structured, accessible content
- **Brand reputation**: Demonstrates attention to detail and quality

**Dependencies:**
- Sprint 2 (Blog Posts 2-4) should be complete to avoid rework
- Can be done incrementally without impacting site functionality
- No user-facing changes (improvements are in source quality only)

**Related Documentation:**
- [.markdownlint.json](.markdownlint.json) - Current relaxed configuration
- [.lighthouserc.json](.lighthouserc.json) - Current Lighthouse thresholds
- [CLAUDE.md - Markdown Standards](CLAUDE.md#markdown-formatting-standards) - Full documentation
- [CLAUDE.md - Development Workflow](CLAUDE.md#development-workflow) - Quality check process

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
- [x] Add Professional Resume section to About page (Completed 2025-11-08)
  - Added resume download section with call-to-action
  - LinkedIn and contact page links
  - Placeholder for PDF resume (ready to activate)
  - Styled with gradient background and cyan border
  - Documented in CLAUDE.md
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
- [x] Enhance Person structured data for recruiter discovery (Completed 2025-11-08)
  - Added givenName/familyName fields
  - Added knowsLanguage field
  - Added experience years to hasOccupation
  - Added support for credentials/certifications
  - Added interaction statistics (blog posts, projects)
  - Fixed "seeks" field (removed incorrect JobPosting type)
  - Documented in CLAUDE.md with testing instructions

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
