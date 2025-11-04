# Utterances Comments Setup

The utterances commenting system has been added to your blog posts, but requires one final step to activate.

## What is Utterances?

Utterances is a lightweight, privacy-friendly commenting system that uses GitHub Issues to store comments. It's perfect for developer blogs because:
- No tracking or ads
- No external database required
- Comments stored as GitHub issues in your repo
- GitHub authentication prevents spam
- Supports markdown in comments
- Dark theme matches your site design

## Setup Instructions

### Step 1: Install the Utterances GitHub App

1. Visit: https://github.com/apps/utterances
2. Click "Install"
3. Select your repository: `christaylorcodes/christaylorcodes.github.io`
4. Grant the app access to create issues

### Step 2: Verify Configuration

The utterances script is already configured in [_layouts/post.html](_layouts/post.html) with these settings:

```javascript
repo: "christaylorcodes/christaylorcodes.github.io"
issue-term: "pathname"
theme: "github-dark"
```

**Configuration explained:**
- `repo`: Your GitHub repository (already set)
- `issue-term: "pathname"`: Creates one issue per blog post using the URL path
- `theme: "github-dark"`: Matches your Oceanic dark theme

### Step 3: Test Comments

1. Build and deploy your site: `git push origin main`
2. Wait 2-5 minutes for GitHub Pages to rebuild
3. Visit any blog post on your live site
4. Scroll to the bottom - you should see the comments widget
5. Sign in with GitHub and post a test comment
6. Check your repository issues - a new issue should be created

## Managing Comments

Comments appear as GitHub issues in your repository with the label "utterances". You can:
- **Moderate**: Close or lock issues to prevent further comments
- **Edit**: Edit or delete individual comment issues
- **Organize**: Add labels to categorize discussion
- **Respond**: Reply directly in the GitHub issue

## Troubleshooting

**Comments widget not appearing:**
- Verify the utterances app is installed on your repo
- Check browser console for errors
- Ensure repo name is correct in post.html

**"utterances is not installed" error:**
- Install the app: https://github.com/apps/utterances
- Grant access to your repository

**Comments not loading:**
- Check if you have issues disabled in repo settings
- Go to Settings → Features → Enable Issues

## Customization

If you want to change the theme or settings, edit the script in [_layouts/post.html:150-156](_layouts/post.html#L150-L156).

**Available themes:**
- `github-dark` (current) - Matches your Oceanic theme
- `github-light` - Light theme
- `github-dark-orange` - Dark with orange accents
- `icy-dark` - Dark with blue accents
- `photon-dark` - Dark with purple accents

**Issue term options:**
- `pathname` (current) - One issue per URL path
- `url` - Full URL including domain
- `title` - Blog post title
- `og:title` - Open Graph title

## Next Steps

1. Install the utterances app (5 minutes)
2. Test on a live blog post
3. Delete this setup file once working

For more info: https://utteranc.es/
