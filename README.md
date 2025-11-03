# Personal Website

A beautiful, responsive personal website built with Jekyll and hosted on GitHub Pages.

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

### 1. Install Dependencies

```bash
# Install Bundler if you haven't already
gem install bundler

# Install Jekyll and other dependencies
bundle install
```

### 2. Run the Development Server

```bash
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

For live reload during development:
```bash
bundle exec jekyll serve --livereload
```

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

## Deployment to GitHub Pages

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

```bash
# Clean and rebuild
bundle exec jekyll clean
bundle exec jekyll build
bundle exec jekyll serve
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
