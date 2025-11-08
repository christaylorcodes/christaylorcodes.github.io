---
layout: post
title: "Your Post Title Here"
short_title: "Short Title"  # Optional: Shorter version for blog cards (recommended: 3-7 words, ~50 characters max)
date: YYYY-MM-DD HH:MM:SS -0000
categories: [category1, category2]
tags: [tag1, tag2, tag3]
author: Chris Taylor
excerpt: "Brief 50-word summary at 8th grade reading level. Use clear, simple language. Focus on the main problem and solution."
image: /assets/images/posts/your-post-image.png  # Optional: Custom social sharing image (1200x630px recommended)
description: "Optional SEO meta description if different from excerpt. Used in search results and social media previews."
---

# Instructions for Creating a New Blog Post

1. Copy this template to the `_posts` directory
2. Rename the file using the format: `YYYY-MM-DD-title.md` (use short, simple titles)
   - Example: `2024-11-03-connectwise-automation.md`
3. Update the front matter (the section between the `---` markers above)
4. Write your content below this section using Markdown
5. Commit and push to publish

## Front Matter Field Descriptions

- **layout**: Always use `post` for blog posts
- **title**: The full title of your post (will appear in heading and social media previews)
- **short_title** (Optional): Shorter version for blog cards (recommended: 3-7 words, ~50 characters max)
  - Use when the full title is too long for card layouts
  - Omit this field to use the full title everywhere
  - Example: Full title "Introducing ConnectWiseAutomateAgent: PowerShell Automation for Your RMM" → Short title "ConnectWiseAutomateAgent"
- **date**: Publication date and time in format `YYYY-MM-DD HH:MM:SS -0000`
- **categories**: Broad categories (1-2 recommended)
  - Suggested categories: PowerShell, Automation, MSP, Networking, API Integration, Business Process
- **tags**: Specific topics covered (3-6 recommended)
  - Suggested tags: ConnectWise, PowerShell Gallery, REST API, Scripts, Network Operations, Infrastructure, Azure, AWS, GCP, DevOps
- **author**: Your name (Chris Taylor)
- **excerpt**: Brief summary for previews (appears on blog index, home page, and social media)
  - **Target length**: 50 words (acceptable range: 45-55 words)
  - **Reading level**: 8th grade - use clear, simple language anyone can understand
  - **Style**: Concise, direct, engaging
  - **Guidelines**:
    - Use active voice and simple words
    - Keep it short and punchy
    - Focus on one main benefit
    - Be specific, not abstract
  - **Content**: Should explain the main problem this post solves and what readers will learn
  - **Purpose**: Quick preview that helps readers decide if the post is right for them
- **image** (Optional): Custom social sharing image path (recommended size: 1200x630px)
  - When shared on social media, this image appears as the preview
  - If not specified, the site's default image is used
  - Place images in `assets/images/posts/` directory
- **description** (Optional): SEO meta description if different from excerpt
  - Used by search engines and social media platforms
  - Keep it concise (150-160 characters is optimal for search results)

## Writing Your Content

Write your post content here using Markdown syntax.

### Markdown Formatting Standards

**IMPORTANT**: All blog posts are linted for markdown quality during CI/CD builds. Follow these standards:

**Required (Enforced by CI/CD):**

- Use ATX-style headings with `#` symbols (not underlined)
- Increment heading levels by one (H1 → H2 → H3, don't skip)
- Use dashes `-` for unordered lists (not `*` or `+`)
- Indent nested lists by 2 spaces
- No trailing punctuation in headings (`.`, `,`, `;`, `:`, `!`)
- Use fenced code blocks with triple backticks (not indented blocks)
- Use `**bold**` for bold text (asterisks, not underscores)

**Best Practices (Recommended):**

- Add blank lines before/after headings, code blocks, and lists
- Always specify language for code blocks (e.g., ` ```powershell `)
- Use `_italic_` for italics (underscores preferred for consistency)
- Only one H1 heading per document (typically the title in front matter)

**See full documentation**: [CLAUDE.md - Markdown Formatting Standards](../CLAUDE.md#markdown-formatting-standards)

### Formatting Examples

**Headings:**

```markdown
## Main Section

### Subsection

#### Detail Section
```

**Code blocks with language specification:**

```powershell
# Example PowerShell code
Get-Process | Where-Object {$_.CPU -gt 100}
```

**Lists (use dashes):**

```markdown
- First item
- Second item
  - Nested item (2 space indent)
  - Another nested item
- Third item
```

**Inline code and emphasis:**

- Inline code: `Get-Process`
- **Bold text** uses double asterisks
- _Italic text_ uses underscores
- Links: [Link Text](https://example.com)

### Suggested Post Structure

1. **Introduction**: What problem are you solving or topic are you exploring?
2. **Background/Context**: Why is this important or relevant?
3. **Main Content**: Step-by-step explanation, code examples, technical details
4. **Examples**: Real-world usage scenarios
5. **Conclusion**: Summary and key takeaways

### Images

Place images in `assets/images/posts/` and reference them:

```markdown
![Alt text description](/assets/images/posts/image-name.png)
```

### Social Sharing Images

For optimal social media appearance, create a custom Open Graph image:

- **Recommended size**: 1200x630 pixels (16:9 aspect ratio)
- **Format**: PNG or JPG
- **Content**: Include post title, your name/brand, and relevant visual
- **Text**: Keep text large and readable (appears small in previews)
- **File location**: `assets/images/posts/`
- **Front matter field**: `image: /assets/images/posts/your-image.png`

Without a custom image, shares will use the site's default image (your profile photo).

## Example Content Structure

### Introduction

Start with an engaging opening that explains what the reader will learn.

### The Problem

Describe the challenge or scenario you're addressing.

### The Solution

Explain your approach with code examples and explanations.

### Implementation

Provide step-by-step guidance with code snippets.

### Conclusion

Summarize the key points and benefits of your solution.

---

**Remember**: Focus on practical, actionable content that helps MSP professionals, PowerShell developers, and automation engineers solve real problems.
