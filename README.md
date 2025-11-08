# Personal Website

A beautiful, responsive personal website built with Jekyll and hosted on GitHub Pages.

**Live at:** https://christaylor.codes
**Go-Live Date:** November 3, 2025

## Features

- Modern, clean design with smooth animations
- Fully responsive layout (mobile, tablet, desktop)
- Easy to customize
- SEO optimized
- Fast loading times
- Multiple pages: Home, About, Projects, Contact
- Social media integration
- Contact form ready

## Prerequisites

Before you begin, ensure you have the following installed:
- Ruby (version 2.5.0 or higher)
- RubyGems
- GCC and Make

## Local Development

### Quick Start (Recommended)

Use the PowerShell build script for streamlined development:

```powershell
# Serve with live reload (default)
.\build.ps1

# Build only (output to _site/)
.\build.ps1 -Mode build

# Clean build artifacts
.\build.ps1 -Mode clean
`

# Sync project stats (for GitHub Pages deployment)
.\build.ps1 -Mode sync-stats
`````

The site will be available at `http://localhost:4000`

The build script automatically:
- Verifies Ruby and Bundler installation
- Installs dependencies if needed
- Provides colored status output
- Reports compiled CSS size

### Manual Setup

If you prefer to run commands manually:

#### 1. Install Dependencies

```bash
# Install Bundler if you haven't already
gem install bundler

# Install Jekyll and other dependencies
bundle install
```

#### 2. Run the Development Server

```bash
# Serve with live reload (recommended)
bundle exec jekyll serve --livereload

# Build only
bundle exec jekyll build

# Clean and rebuild
bundle exec jekyll clean && bundle exec jekyll build
```

The site will be available at `http://localhost:4000`

## Customization

### 1. Update Site Information

Edit `_config.yml` to customize your site:

```yaml
title: Your Name
email: your.email@example.com
description: Your description here
github_username: yourusername
linkedin_username: yourlinkedin
twitter_username: yourtwitter
```

### 2. Customize Content

- **Home Page**: Edit `index.html`
- **About Page**: Edit `about.html`
- **Projects Page**: Edit `projects.html`
- **Contact Page**: Edit `contact.html`

### 3. Update Styles

Modify `assets/css/main.css` to change colors, fonts, and layout:

```css
:root {
    --primary-color: #6366f1;  /* Change to your preferred color */
    --secondary-color: #ec4899;
    /* ... other variables */
}
```

### 4. Set Up Contact Form

The contact form uses Formspree. To enable it:

1. Go to [Formspree.io](https://formspree.io)
2. Sign up for a free account
3. Create a new form
4. Copy your form ID
5. Update the form action in `contact.html`:

```html
<form action="https://formspree.io/f/YOUR_FORM_ID" method="POST">
```


## Managing Project Statistics

This site uses a centralized system for managing GitHub stars and PowerShell Gallery download counts across all projects.

### Updating Project Stats

All project statistics are stored in `_data/project-stats.yml`. To update stats:

```powershell
# 1. Edit _data/project-stats.yml with new values

# 2. Sync stats to project files for GitHub Pages
.\build.ps1 -Mode sync-stats

# 3. Commit and deploy
git add .
git commit -m "Update project stats"
git push
```

**Why sync is needed:** GitHub Pages doesn't run custom Ruby plugins, so stats must be copied from the centralized YAML file to individual project front matter before deployment.

**For more details:** See [PROJECT-STATS-README.md](PROJECT-STATS-README.md) for complete documentation.
## Deploying Changes

### Quick Deploy (Recommended)

Use the PowerShell deployment script to commit and push changes:

```powershell
# Interactive mode (auto-generates commit message from changes)
.\deploy.ps1

# With custom commit message
.\deploy.ps1 -Message "Update README with build documentation"

# Skip git status display
.\deploy.ps1 -Message "Fix navigation styles" -SkipStatus
```

The script automatically:
- Analyzes your changes and generates an intelligent commit message
- Shows current git status
- Stages all changes
- Commits with your message (or generated message)
- Pushes to the main branch
- Displays GitHub Actions URL for monitoring

**Auto-Generated Commit Messages:**

When you run `.\deploy.ps1` without a message, it will analyze your changes and suggest a commit message like:
- "Add deployment script and update documentation"
- "Update styles and configuration"
- "Add 3 new blog posts"

You can then:
- Press Enter to accept the generated message
- Type `n` to write your own
- Type `edit` to modify the generated message

GitHub Pages will automatically rebuild your site in 2-5 minutes.

### Manual Deployment

If you prefer to run git commands manually:

```powershell
# Stage all changes
git add .

# Commit with a message
git commit -m "Your commit message"

# Push to main
git push origin main
```

Or as a one-liner:
```powershell
git add . && git commit -m "Your message" && git push origin main
```

## Initial Deployment to GitHub Pages

### Option 1: Deploy to your username.github.io

1. Create a new repository named `username.github.io` (replace `username` with your GitHub username)

2. Initialize git and push your code:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/username/username.github.io.git
git push -u origin main
```

3. Your site will be available at `https://username.github.io`

### Option 2: Deploy to a project repository

1. Create a new repository on GitHub (e.g., `my-website`)

2. Update `_config.yml`:

```yaml
baseurl: "/my-website"  # Your repository name
url: "https://username.github.io"  # Your GitHub Pages URL
```

3. Push your code:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/username/my-website.git
git push -u origin main
```

4. Enable GitHub Pages:
   - Go to your repository settings
   - Navigate to "Pages" section
   - Select "main" branch as source
   - Click "Save"

5. Your site will be available at `https://username.github.io/my-website`

## GitHub Pages Settings

After pushing your code:

1. Go to your repository on GitHub
2. Click on "Settings"
3. Scroll down to "GitHub Pages" section
4. Under "Source", select the `main` branch
5. Click "Save"

Your site should be live within a few minutes!

## Adding Your Own Content

### Adding Projects

Edit the `projects.html` file and add your own project cards:

```html
<div class="project-card">
    <div class="project-image">
        <i class="fas fa-your-icon"></i>
    </div>
    <div class="project-content">
        <h3>Your Project Name</h3>
        <p>Project description...</p>
        <div class="project-tags">
            <span class="tag">Technology 1</span>
            <span class="tag">Technology 2</span>
        </div>
        <div class="project-links">
            <a href="your-demo-link" class="project-link">
                <i class="fas fa-external-link-alt"></i> Live Demo
            </a>
            <a href="your-github-link" class="project-link">
                <i class="fab fa-github"></i> GitHub
            </a>
        </div>
    </div>
</div>
```

### Updating Skills

Edit the `about.html` file and modify the skills grid:

```html
<div class="skills-grid">
    <div class="skill-tag">Your Skill 1</div>
    <div class="skill-tag">Your Skill 2</div>
    <!-- Add more skills -->
</div>
```

## Troubleshooting

### Site not updating?

- Clear your browser cache
- Wait a few minutes for GitHub Pages to rebuild
- Check the "Actions" tab in your GitHub repository for build status

### Local development issues?

**Using the build script (recommended):**
```powershell
# Clean and rebuild
.\build.ps1 -Mode clean
.\build.ps1
```

**Using manual commands:**
```bash
# Clean and rebuild
bundle exec jekyll clean
bundle exec jekyll build
bundle exec jekyll serve --livereload
```

### Port 4000 already in use?

```bash
bundle exec jekyll serve --port 4001
```

### Ruby version issues?

Make sure you're using a compatible Ruby version (2.5.0 or higher):

```bash
ruby -v
```

## Resources

- [Jekyll Documentation](https://jekyllrb.com/docs/)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Formspree Documentation](https://help.formspree.io/)
- [Font Awesome Icons](https://fontawesome.com/icons)

## License

This project is open source and available under the [MIT License](LICENSE).

## Support

If you have any questions or run into issues, please open an issue on GitHub.

---

Made with ❤️ using Jekyll and GitHub Pages
