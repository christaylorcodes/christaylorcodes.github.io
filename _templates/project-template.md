---
title: Project Name Here
icon: fa-code
description: Brief one or two sentence description of the project that appears on the project card. Keep it concise and focused on the value it provides.
tags:
  - PowerShell
  - Automation
  - API
github_url: "https://github.com/christaylorcodes/project-name"
order: 10
---

# Instructions for Creating a New Project

1. Copy this template to the `_projects` directory
2. Rename the file using lowercase with hyphens: `project-name.md`
   - Example: `connectwise-manage-api.md`
3. Update the front matter (the section between the `---` markers above)
4. Optionally add extended description below the front matter
5. Commit and push to publish

## Front Matter Field Descriptions

- **title**: The display name of the project (required)
- **icon**: Font Awesome icon class (required)
  - Use format: `fa-iconname` (e.g., `fa-code`, `fa-rocket`, `fa-cogs`)
  - Browse icons at: https://fontawesome.com/icons
  - Common icons: `fa-code`, `fa-rocket`, `fa-cogs`, `fa-network-wired`, `fa-server`, `fa-cloud`, `fa-terminal`
- **description**: Short description for the project card (required)
  - Keep to 1-2 sentences
  - Focus on the problem solved or value provided
  - This appears on both the home page and projects page
- **tags**: List of technologies/categories (required)
  - 3-6 tags recommended
  - Suggested tags:
    - Languages: PowerShell, Python, JavaScript, C#
    - Technologies: REST API, Azure, AWS, GCP, Docker
    - Categories: Automation, MSP Tools, Networking, Monitoring
    - Platforms: ConnectWise, GitHub Actions, Jenkins
- **github_url**: Link to GitHub repository (optional)
  - Use `"#"` if no public repository
  - Format: `"https://github.com/christaylorcodes/repo-name"`
- **order**: Display order on projects page (required)
  - Lower numbers appear first
  - Use increments of 10 to allow for easy reordering (10, 20, 30, etc.)
  - Featured projects (shown on home page) should have order 1-40

## Extended Description (Optional)

You can add a longer description here below the front matter if needed. This section is optional and currently not displayed on the site, but can be used for future enhancements or documentation.

### Features

- Feature 1: Description
- Feature 2: Description
- Feature 3: Description

### Technical Details

Provide technical implementation details, architecture notes, or other relevant information.

### Usage Example

```powershell
# Example code showing how to use the project
Import-Module ProjectName
Get-SomeCommand -Parameter Value
```

## Example Projects

### Example 1: PowerShell Module
```yaml
title: ConnectWiseManageAPI
icon: fa-plug
description: PowerShell wrapper for the ConnectWise Manage REST API, enabling automation of MSP workflows and integrations.
tags:
  - PowerShell
  - ConnectWise
  - REST API
  - MSP Tools
github_url: "https://github.com/christaylorcodes/ConnectWiseManageAPI"
order: 10
```

### Example 2: Automation Script
```yaml
title: Network Config Automation
icon: fa-network-wired
description: Automated network configuration and monitoring solution for multi-site enterprise environments.
tags:
  - Networking
  - Automation
  - PowerShell
  - Infrastructure
github_url: "https://github.com/christaylorcodes/network-automation"
order: 20
```

### Example 3: API Integration
```yaml
title: Multi-Cloud Resource Manager
icon: fa-cloud
description: Unified management interface for Azure, AWS, and GCP resources with automated provisioning and monitoring.
tags:
  - Azure
  - AWS
  - GCP
  - Automation
  - API Integration
github_url: "https://github.com/christaylorcodes/cloud-manager"
order: 30
```

---

**Remember**: Focus on projects that demonstrate your automation expertise, solve real MSP challenges, or showcase your PowerShell and infrastructure skills.
