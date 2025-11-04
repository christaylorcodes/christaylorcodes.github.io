---
title: Project Name Here
icon: fa-code
short_description: Concise 1-2 sentence benefit-focused summary for homepage cards (20-30 words max).
description: More detailed 3-4 sentence description that explains features, benefits, and use cases for the full projects page (70-90 words).
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
- **short_description**: Concise summary for homepage featured projects (required)
  - 1-2 sentences, 20-30 words maximum
  - Benefit-focused: emphasize what problem it solves or value it provides
  - Used on homepage "Featured Projects" section only
  - Example: "Automates ConnectWise ticket workflows with PowerShell cmdlets for streamlined MSP operations."
- **description**: Detailed description for the full projects page (required)
  - 3-4 sentences, 70-90 words
  - Explain features, benefits, use cases, and technical highlights
  - Used on the main projects page where more detail is appropriate
  - Example: "Comprehensive PowerShell module that automates ConnectWise Manage PSA operations... [longer detailed text]"
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
short_description: PowerShell module that simplifies ConnectWise Manage automation with intuitive cmdlets and intelligent error handling for streamlined MSP operations.
description: Comprehensive PowerShell module that automates ConnectWise Manage PSA operations by providing intuitive cmdlets for the REST API. Features dynamic parameter validation, automatic pagination, and intelligent error handling, eliminating complex manual API construction. Enables MSPs to streamline ticket management, company operations, and configuration workflows while maintaining type-safety and providing extensive inline documentation for rapid development.
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
short_description: Automated network configuration and monitoring solution for multi-site enterprise environments.
description: PowerShell-based automation framework that standardizes network device configuration, monitors compliance, and provides real-time alerting across multi-site deployments. Supports Cisco, HPE, and Dell networking equipment with extensible plugin architecture. Reduces configuration drift and enables rapid deployment of security updates and policy changes across distributed infrastructure.
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
short_description: Unified management interface for Azure, AWS, and GCP resources with automated provisioning and monitoring.
description: Enterprise cloud management platform providing unified control across Azure, AWS, and GCP environments. Features automated resource provisioning, cost optimization recommendations, security compliance monitoring, and centralized billing analytics. Integrates with existing ITSM workflows and provides role-based access control for team collaboration. Reduces multi-cloud complexity while maintaining vendor-specific capabilities.
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
