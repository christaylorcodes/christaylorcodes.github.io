# Scripts Directory

This directory contains utility PowerShell scripts for maintaining and managing the christaylor.codes website.

## Available Scripts

### Image Management

**`analyze-images.ps1`**
- Analyzes images in the assets directory
- Reports on file sizes, dimensions, and optimization opportunities
- Helps identify images that need compression

**`optimize-images.ps1`**
- Optimizes images for web deployment
- Compresses PNG and JPG files
- Resizes images to appropriate dimensions
- Run before committing large image files

### CSS & Security

**`calculate-css-hash.ps1`**
- Generates CSP (Content Security Policy) hashes for inline CSS
- Used when updating Content-Security-Policy headers
- See [../docs/SECURITY-HEADERS-SETUP.md](../docs/SECURITY-HEADERS-SETUP.md) for usage

### Project Statistics

**`sync-project-stats.ps1`**
- Syncs GitHub star counts and PowerShell Gallery download statistics
- Updates `_data/project-stats.yml` and project front matter
- Can be run manually or via GitHub Actions workflow

**Usage:**
```powershell
.\scripts\sync-project-stats.ps1 -FetchGalleryStats
```

### Deployment (Legacy)

**`deploy.ps1`**
- Legacy deployment script (deprecated)
- Deployment now handled by GitHub Actions workflows
- Kept for reference and manual deployment scenarios

**`fix-readme-backticks.ps1`**
- Utility script for fixing markdown formatting
- One-time use script kept for reference

## Running Scripts

All scripts should be run from the repository root directory:

```powershell
# From repository root
.\scripts\script-name.ps1
```

## Frequently Used Scripts

Scripts that are used regularly remain in the root directory for convenience:
- `build.ps1` - Local Jekyll build and serve (use this for development)
- `promote-to-main.ps1` - Promote changes from dev to main branch

## Adding New Scripts

When adding new utility scripts:
1. Place them in this directory
2. Add documentation to this README
3. Include usage examples
4. Add error handling and help comments
5. Test thoroughly before committing

## See Also

- [CLAUDE.md](../CLAUDE.md) - Project maintenance guide
- [README.md](../README.md) - Project setup and deployment
- [TODO.md](../TODO.md) - Task tracking and sprint planning
