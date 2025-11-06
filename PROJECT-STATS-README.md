# Project Statistics Management

## Overview

GitHub stars and PowerShell Gallery download counts are now centralized in a single data file for easy maintenance. This system works both locally (with a Ruby plugin) and on GitHub Pages (with synced front matter).

## Files

### Data File (Source of Truth)
- **`_data/project-stats.yml`** - All project statistics in one place

### Scripts
- **`sync-project-stats.ps1`** - Syncs stats from YAML to project files for GitHub Pages
- **`_plugins/project_stats.rb`** - Auto-injects stats during local builds (doesn't run on GitHub Pages)

### Helper Includes
- **`_includes/get-project-stats.html`** - Liquid include for looking up stats (not currently used)
- **`_includes/project-stats.html`** - Alternative stats lookup (not currently used)

## How It Works

### Local Development
1. Edit `_data/project-stats.yml` to update any stats
2. Run `.\build.ps1` to build the site
3. The Ruby plugin (`_plugins/project_stats.rb`) automatically adds stats to each project
4. Templates use `project.stars` and `project.gallery_downloads` directly

### GitHub Pages Deployment
1. Edit `_data/project-stats.yml` to update stats
2. Run `.\sync-project-stats.ps1` to copy stats to project files
3. Commit and push to GitHub
4. GitHub Pages builds the site using stats from project front matter

**Why this is needed**: GitHub Pages doesn't run custom Ruby plugins for security, so we sync the stats to project files where they can be read during build.

## Updating Project Stats

### Quick Update (Recommended)

```powershell
# 1. Edit _data/project-stats.yml with new values

# 2. Sync to project files (using build script)
.\build.ps1 -Mode sync-stats

# 3. Test locally
.\build.ps1

# 4. Commit and deploy
git add .
git commit -m "Update project stats"
git push
```

### Alternative: Use Standalone Script

```powershell
# Run the sync script directly
.\sync-project-stats.ps1

# Or with dry-run to preview changes
.\sync-project-stats.ps1 -WhatIf
```

## File Structure

### _data/project-stats.yml
```yaml
connectwisemanageapi:
  stars: 118
  gallery_downloads: 0

connectwisecontrolapi:
  stars: 81
  gallery_downloads: 0

# ... etc
```

**Project IDs must match filenames** in `_projects/` (without `.md` extension).

### Project Files (After Sync)
```yaml
---
layout: project
title: ConnectWise Manage API
# ... other fields ...
stars: 118
gallery_downloads: 0
order: 10
---
```

## Best Practices

### Updating Stats
1. **Single source of truth**: Always update `_data/project-stats.yml` first
2. **Run sync before deploying**: Always run `sync-project-stats.ps1` before pushing to GitHub
3. **Test locally**: Build and check the site locally before deploying
4. **Batch updates**: Update all projects at once for consistency

### Adding New Projects
1. Create project file in `_projects/`
2. Add entry to `_data/project-stats.yml` with matching filename
3. Run `sync-project-stats.ps1`

### Maintenance
- Update stats monthly or when significant milestones are reached
- Check GitHub API for accurate star counts
- Check PowerShell Gallery for download counts
- Keep `_data/project-stats.yml` comments up to date

## Troubleshooting

### Stats not showing on local build
- **Check**: Does `_plugins/project_stats.rb` exist?
- **Check**: Are stats in `_data/project-stats.yml`?
- **Fix**: Clean and rebuild: `.\build.ps1 -Mode clean`, then `.\build.ps1 -Mode build`

### Stats not showing on GitHub Pages
- **Check**: Did you run `sync-project-stats.ps1`?
- **Check**: Are `stars:` and `gallery_downloads:` in project front matter?
- **Fix**: Run sync script and push changes

### Sorting not working
- **Local**: Plugin should handle it automatically via `project.stars`
- **GitHub Pages**: Stats must be in project files for sorting to work

### Project ID mismatch
- Project IDs in `_data/project-stats.yml` must match filenames exactly
- Example: `connectwisemanageapi.md` → `connectwisemanageapi:` in YAML

## Architecture

### Why Two Approaches?

**Local (Ruby Plugin)**:
- Fast: Stats injected once during site generation
- Clean: No duplication in project files
- Flexible: Easy to extend with computed stats

**GitHub Pages (Synced Front Matter)**:
- Compatible: Works without custom plugins
- Reliable: Stats always available in templates
- Transparent: Front matter is version-controlled

### Trade-offs

**Pros**:
- ✅ Single source of truth for stats
- ✅ Easy to update (one file)
- ✅ Works everywhere (local + GitHub Pages)
- ✅ Maintainable

**Cons**:
- ⚠️ Requires running sync script before deploy
- ⚠️ Stats duplicated in project files for GitHub Pages
- ⚠️ Could forget to sync (but build.ps1 could check)

## Future Improvements

### Automation Ideas
1. Add check to `build.ps1` that warns if stats are out of sync
2. Create pre-commit hook to auto-run sync script
3. Add GitHub Action to fetch stats from APIs automatically
4. Create dashboard to view all project stats at a glance

### Stats Enhancement
1. Add trend indicators (stars this month, etc.)
2. Fetch real-time stats from GitHub/PSGallery APIs
3. Add "last updated" timestamp to stats
4. Track additional metrics (forks, issues, PRs)

---

**Last Updated**: 2025-11-05
**Status**: ✅ Fully operational
