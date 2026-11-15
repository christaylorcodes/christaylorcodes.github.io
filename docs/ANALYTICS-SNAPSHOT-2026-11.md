# Analytics Snapshot - November 2026

**Period:** May 14, 2026 - November 13, 2026 (last 6 months)
**Created:** 2026-11-15
**Compared to:** [ANALYTICS-BASELINE-2026-02.md](ANALYTICS-BASELINE-2026-02.md)
**Next Review:** February 2027

## Google Search Console

**Property:** `https://christaylor.codes/` (URL-prefix property, not a domain property)

### Search Performance (6 months)

| Metric | Value | Feb 2026 baseline (90 days) |
|--------|-------|-----------------------------|
| Total Clicks | 113 | 30 |
| Total Impressions | ~11,000 | 5,805 |
| Average CTR | 1.0% | 0.52% |
| Average Position | 13.7 | ~11 |
| Pages with impressions | 29 | 21 indexed |
| Queries with impressions | 146 | - |

CTR doubled. Average position slipped a little because the site now shows for broader queries ("connectwise api", "automate rmm") where it ranks on page 3+.

### Top Pages

| Page | Clicks | Impressions | CTR | Position |
|------|--------|-------------|-----|----------|
| /projects/connectwisecontrolapi/ | 37 | 1,620 | 2.3% | 17.1 |
| Troubleshooting Automate agents (2024-03-04) | 19 | 1,196 | 1.6% | 11.6 |
| Introducing ConnectWiseAutomateAgent (2024-02-12) | 17 | 2,774 | 0.6% | 18.3 |
| /projects/connectwisemanageapi/ | 17 | 2,694 | 0.6% | 11.7 |
| Self-healing Automate agents (2024-03-01) | 6 | 1,477 | 0.4% | 12.2 |
| Homepage | 4 | 419 | 1.0% | 7.7 |
| /about/ | 3 | 223 | 1.3% | 6.2 |
| Rewst Flow 2026 CTF (2026-06-23) | 3 | 116 | 2.6% | 8.3 |
| Introducing ConnectWiseManageAPI (2024-09-16) | 2 | 100 | 2.0% | 10.2 |
| AI Doom Coefficient (2025-11-03) | 1 | 261 | 0.4% | 14.7 |

### Top Queries

| Query | Clicks | Impressions | CTR | Position |
|-------|--------|-------------|-----|----------|
| screenconnect api | 4 | 68 | 5.9% | 10.6 |
| connectwise control api | 3 | 33 | 9.1% | 7.4 |
| screenconnect api documentation | 1 | 21 | 4.8% | 9.9 |
| connectwise manage api documentation | 1 | 18 | 5.6% | 17.3 |
| connectwise api | 0 | 228 | 0% | 33.3 |
| automate rmm | 0 | 126 | 0% | 24.9 |
| "agent" connectwise | 0 | 120 | 0% | 75.5 |
| christaylor.codes | 0 | 105 | 0% | 30.9 |
| connectwise automate support | 0 | 78 | 0% | 58.9 |
| system healer | 0 | 72 | 0% | 43.7 |
| connectwise command | 0 | 70 | 0% | 18.4 |
| saaz rmm agent | 0 | 67 | 0% | 22.3 |
| connectwise manage api | 0 | 64 | 0% | 20.3 |
| connectwise control integration | 0 | 59 | 0% | 41.7 |
| connectwise hosted api azure ad token memberhash | 0 | 45 | 0% | 9.6 |

The brand query "christaylor.codes" sits at position 30.9, down from 3.0 in February. Worth checking whether a directory or scraper site is outranking the homepage for it.

## Query Clusters and Actions

| Cluster | Signal | Action taken (Nov 2026) |
|---------|--------|-------------------------|
| ScreenConnect API | Most clicks on the site. The site still said "ConnectWise Control" | Renamed project page, new 0.5 post, update callouts on the 2023 posts |
| ConnectWise PSA / Manage API | "connectwise api" 228 impr at pos 33; nothing on page 1 | Project page rewrite, new 0.5 upgrade post, callouts on the 2024 posts |
| Automate agent / self-healing | Two posts with 1.4K-2.7K impressions at 0.4-0.6% CTR | Title/description rewrites, new health-check post (2.x), callouts |
| AI-style long questions | "I manage 500 endpoints, how do I set up safe self-healing", pos 4-9 | Answered directly in the health-check post |
| Hosted API memberhash / Azure AD token | ~53 impr across variants at pos ~9.6, no page targets it | **Open.** Candidate post, needs input on whether a module covers it |
| Automate internals | "ltsvcmon", "ltsvc.exe", "2 agents on one computer", "rmm agent system requirements" | **Open.** Candidate FAQ section in the troubleshooting post |

## Next Review Checklist

- [ ] Compare CTR on the three retitled pages (Introducing Automate Agent, Manage API project, self-healing post)
- [ ] Check whether the new 0.5 posts and health-check post are indexed and ranking
- [ ] Re-check the "christaylor.codes" brand query position
- [ ] Decide on the Hosted API memberhash post
