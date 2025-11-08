# Documentation Directory

This directory contains specialized guides, historical documentation, and design system examples for the christaylor.codes website.

## Directory Structure

```
docs/
├── README.md (this file)
├── archive/                          # Historical and superseded documentation
│   ├── README.md
│   ├── ANALYTICS-QUICKSTART.md      # Superseded by ANALYTICS-SETUP.md
│   ├── CSP-CONFIGURATION-GUIDE.md   # Superseded by SECURITY-HEADERS-SETUP.md
│   ├── PERFORMANCE-CLOUDFLARE-TODO.md
│   ├── PROJECT-STATS-README.md
│   ├── STATS-MIGRATION-COMPLETE.md
│   ├── STRUCTURED-DATA-SUMMARY.md
│   └── THEME-README.md              # Consolidated into CLAUDE.md
├── examples/                         # Design system component examples
│   ├── README.md
│   ├── badges.html                  # Category badge showcase
│   ├── buttons.html                 # Button system examples
│   └── categories.html              # Filter button demonstrations
├── ANALYTICS-SETUP.md               # Analytics configuration guide
├── AUDIT-PLAN.md                    # Website audit planning
├── BACKLINK-STRATEGY.md             # SEO backlink building strategy
├── CLOUDFLARE-SETUP.md              # CDN and cache setup
├── DATA-DRIVEN-ARCHITECTURE.md      # Data-driven content management
├── SECURITY-HEADERS-SETUP.md        # CSP and security headers
└── WEBSITE-MATURITY-FRAMEWORK.md    # Maturity assessment framework
```

## Active Documentation

These guides are actively maintained and represent current best practices:

### Site Maturity & Growth

**[WEBSITE-MATURITY-FRAMEWORK.md](WEBSITE-MATURITY-FRAMEWORK.md)**
- Comprehensive maturity assessment across 7 dimensions
- Current overall maturity: Level 2.5 (Developing → Defined) - 37%
- Quarterly review schedule and scoring methodology
- Phased improvement roadmaps with specific tasks and timelines
- Next review: 2026-02-07

**[AUDIT-PLAN.md](AUDIT-PLAN.md)**
- Comprehensive website auditing guide
- Covers accessibility, analytics, content, privacy, performance, and design
- Audit procedures and tools
- Checklist format for quarterly reviews

### Technical Guides

**[ANALYTICS-SETUP.md](ANALYTICS-SETUP.md)**
- Google Analytics 4 configuration
- Cloudflare Web Analytics setup
- Google Search Console integration
- Privacy compliance (GDPR/CCPA)
- Custom event tracking
- Dashboard configuration

**[CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md)**
- CDN configuration
- Cache purging automation
- GitHub Actions integration
- Performance optimization

**[SECURITY-HEADERS-SETUP.md](SECURITY-HEADERS-SETUP.md)**
- Content Security Policy (CSP) configuration
- Cloudflare Transform Rules setup
- Security best practices
- Header testing and validation

### Content & Architecture

**[DATA-DRIVEN-ARCHITECTURE.md](DATA-DRIVEN-ARCHITECTURE.md)**
- Quick reference for data-driven content management
- YAML data file structure
- Contact information (`_data/contact.yml`)
- Author/professional identity (`_data/author.yml`)
- Project statistics (`_data/project-stats.yml`)
- Common update scenarios

**[BACKLINK-STRATEGY.md](BACKLINK-STRATEGY.md)**
- SEO backlink building and organic discovery strategy
- 10 core strategies with implementation roadmap
- Metrics tracking and quarterly review process
- Target: 50-100 backlinks from 30-50 unique domains

## Archive Documentation

Historical documentation and completed migration guides are preserved in `archive/` for reference. See [archive/README.md](archive/README.md) for details on archived content.

## Design System Examples

Live component demonstrations are available in `examples/` for reference when implementing design system elements. See [examples/README.md](examples/README.md) for component usage guide.

## Quick Links

**From docs/ directory:**
- Core project guide: [../CLAUDE.md](../CLAUDE.md)
- Setup instructions: [../README.md](../README.md)
- Task tracking: [../TODO.md](../TODO.md)
- Security measures: [../SECURITY.md](../SECURITY.md)

**Navigation:**
- [View all archived docs →](archive/)
- [View design system examples →](examples/)

## When to Use Each Guide

**Setting up the site:**
1. Start with [../README.md](../README.md) for setup
2. Reference [../CLAUDE.md](../CLAUDE.md) for maintenance
3. Use [DATA-DRIVEN-ARCHITECTURE.md](DATA-DRIVEN-ARCHITECTURE.md) for content updates

**Improving the site:**
1. Review [WEBSITE-MATURITY-FRAMEWORK.md](WEBSITE-MATURITY-FRAMEWORK.md) for current state
2. Use [AUDIT-PLAN.md](AUDIT-PLAN.md) for comprehensive audits
3. Follow specialized guides for specific improvements

**SEO and growth:**
1. Start with [BACKLINK-STRATEGY.md](BACKLINK-STRATEGY.md) for organic discovery
2. Use [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md) for tracking
3. Monitor progress via maturity framework

**Security and performance:**
1. Review [../SECURITY.md](../SECURITY.md) for current security posture
2. Implement [SECURITY-HEADERS-SETUP.md](SECURITY-HEADERS-SETUP.md) for headers
3. Optimize with [CLOUDFLARE-SETUP.md](CLOUDFLARE-SETUP.md) for CDN

## Maintenance

**Active documentation** in this directory is regularly updated and should be consulted for current best practices.

**Archived documentation** in `archive/` is preserved for historical reference but may contain outdated information.

**Example pages** in `examples/` are updated when design system components change.

---

**Last Updated:** 2025-11-08
**Maintained by:** Chris Taylor
**Contact:** ctaylor@christaylor.codes
