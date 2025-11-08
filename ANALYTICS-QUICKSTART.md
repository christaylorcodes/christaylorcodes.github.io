# Analytics Quick Start Guide

Fast track to getting analytics running on christaylor.codes.

## 5-Minute Setup

### Step 1: Get Your Tracking IDs

**Google Analytics 4:**
1. Visit [analytics.google.com](https://analytics.google.com/)
2. Create property → Data stream → Web
3. Copy your **Measurement ID** (format: `G-XXXXXXXXXX`)

**Cloudflare Web Analytics:**
1. Visit [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Analytics & Logs → Web Analytics
3. Add site → Copy your **Beacon Token**

### Step 2: Add to Configuration

Edit `_config.yml` and uncomment/add your IDs:

```yaml
# Analytics Configuration
google_analytics: G-XXXXXXXXXX  # Your actual GA4 ID
cloudflare_analytics: YOUR_ACTUAL_TOKEN  # Your actual beacon token
```

### Step 3: Deploy

```bash
git add _config.yml
git commit -m "Enable Google Analytics and Cloudflare Analytics"
git push origin main
```

Wait 2-3 minutes for GitHub Pages deployment.

### Step 4: Verify Tracking

**Google Analytics:**
- Open [analytics.google.com](https://analytics.google.com/)
- Go to Reports → Realtime
- Visit your site
- You should appear as an active user

**Cloudflare Analytics:**
- Open Cloudflare Dashboard → Web Analytics
- View your site
- Data appears within minutes

---

## What You Get

### Google Analytics 4

**Traffic Metrics:**
- Users, sessions, page views
- Traffic sources (Google, LinkedIn, direct)
- Real-time visitor count
- Geographic location

**User Behavior:**
- Most popular pages
- Session duration
- Bounce rates
- User flow through site

**Technology:**
- Devices (desktop/mobile/tablet)
- Browsers and operating systems
- Screen resolutions

**Custom Events (Automatic):**
- GitHub link clicks
- PowerShell Gallery clicks
- Social media clicks
- Contact form submissions

### Cloudflare Web Analytics

**Privacy-Friendly Metrics:**
- Unique visitors (no cookies)
- Page views
- Referrers
- Page load times
- Geographic data
- Browser/device stats

**GDPR Compliant:** No cookies, no personal data collection

---

## Google Search Console (Bonus)

**What It Provides:**
- Search queries that find your site
- Click-through rates (CTR)
- Search position rankings
- Indexing issues
- Core Web Vitals performance

**Setup (5 minutes):**

1. Visit [search.google.com/search-console](https://search.google.com/search-console/)
2. Add property: `https://christaylor.codes`
3. Verify ownership:
   - Choose **DNS verification**
   - Add TXT record to Cloudflare DNS
   - Click "Verify"
4. Submit sitemap: `https://christaylor.codes/sitemap.xml`

**Data appears in 1-2 days.**

---

## Monitoring Routine

### Daily (Optional)
- Check real-time visitors in GA4
- Monitor for any traffic spikes

### Weekly
- Review top 5 pages by traffic
- Check traffic sources
- Review any new search queries (Search Console)

### Monthly
- Traffic trends (up or down?)
- Best performing content
- Search Console: CTR improvements needed?
- Core Web Vitals: Any performance issues?

---

## Key Dashboards

**Google Analytics:**
- **Realtime:** See visitors right now
- **Acquisition → Traffic acquisition:** Where users come from
- **Engagement → Pages and screens:** Most popular content
- **Events:** Custom event tracking (form, clicks)

**Cloudflare Analytics:**
- **Visitors:** Unique visitor trend
- **Page views:** Total page views
- **Referrers:** Top referring sites
- **Performance:** Page load times

**Google Search Console:**
- **Performance:** Queries, clicks, impressions, CTR
- **Coverage:** Indexing status
- **Core Web Vitals:** Performance metrics

---

## Privacy & Compliance

**What's Enabled:**
- ✅ IP anonymization (GA4)
- ✅ Secure cookie flags
- ✅ No cross-site tracking
- ✅ Cloudflare: completely cookieless

**What's NOT Collected:**
- ❌ Personal identifying information
- ❌ Email addresses (unless form submission)
- ❌ Data sold to third parties

**For EU compliance:** Consider adding cookie consent banner (see ANALYTICS-SETUP.md)

---

## Troubleshooting

**Analytics not showing data:**
1. Wait 5-10 minutes after deployment
2. Check `_config.yml` has correct IDs (uncommented)
3. Visit site in incognito mode
4. Check browser console for errors (F12)

**Only seeing localhost traffic:**
- Analytics only load in production (not `http://localhost:4000`)
- Must visit live site at `https://christaylor.codes`

**Search Console not showing data:**
- Takes 1-2 days for initial data
- Check verification status (must be verified)
- Ensure sitemap is submitted

---

## Next Steps

**After Setup:**
1. [ ] Create custom GA4 dashboard with key metrics
2. [ ] Set up weekly email reports (GA4 feature)
3. [ ] Configure conversion goals (contact form)
4. [ ] Monitor Search Console weekly for SEO opportunities
5. [ ] Review analytics monthly to inform content strategy

**Optional Enhancements:**
- Custom event tracking for project page visits
- A/B testing different CTAs
- Heatmaps with Hotjar or Microsoft Clarity
- Privacy policy page for transparency

---

## Support

**Documentation:**
- Full guide: [ANALYTICS-SETUP.md](ANALYTICS-SETUP.md)
- Site maintenance: [CLAUDE.md](CLAUDE.md)

**External Resources:**
- [GA4 Help Center](https://support.google.com/analytics/)
- [Cloudflare Analytics Docs](https://developers.cloudflare.com/analytics/web-analytics/)
- [Search Console Help](https://support.google.com/webmasters/)

---

**Last Updated:** 2025-11-07
