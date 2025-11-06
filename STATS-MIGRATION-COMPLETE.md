# Project Stats Migration - Complete

## What Was Done

All GitHub stars and PowerShell Gallery download counts have been centralized from individual project files into a single data file for easier maintenance.

### Files Created

1. **`_data/project-stats.yml`** - Centralized statistics for all projects
   - Contains `stars` and `gallery_downloads` for each project
   - Update this file to refresh stats across the entire site

2. **`_plugins/project_stats.rb`** - Jekyll plugin to inject stats into project objects
   - Automatically adds stats to each project at build time
   - **Important**: Works locally but NOT on GitHub Pages (custom plugins disabled)

3. **Helper Scripts:**
   - `remove-project-stats.ps1` - Removed hardcoded stats from project files
   - `update-templates.ps1` - Updated templates to use centralized data
   - `finalize-templates.ps1` - Final template adjustments

### Files Modified

1. **All project files in `_projects/`** - Removed `stars:` and `gallery_downloads:` lines
2. **`_layouts/project.html`** - Uses centralized stats via `page.gallery_downloads`
3. **`index.html`** - Podium section uses `project.stars` and `project.gallery_downloads`
4. **`projects.html`** - Project grid uses `project.stars` and `project.gallery_downloads`

## Current Status

✅ **Local Development**: Fully working
   - The Ruby plugin (`_plugins/project_stats.rb`) injects stats into projects
   - Sorting by stars works correctly
   - All stats display properly

⚠️ **GitHub Pages**: Requires Alternative Approach
   - GitHub Pages doesn't execute custom Ruby plugins for security
   - The site will build but stats won't appear
   - See "GitHub Pages Solution" below

## GitHub Pages Solution

For GitHub Pages compatibility, we have two options:

### Option 1: Manual Enrichment (Recommended for Now)

Keep the current setup for local development,  and manually add back `stars:` and `gallery_downloads:` to each project file when updating GitHub. This is simple and works everywhere.

To update both:
1. Edit `_data/project-stats.yml` with new values
2. Run the sync script (to be created) to copy values back to project files
3. Commit and push

### Option 2: Complex Liquid Solution

Create a complex Liquid template that:
1. Enriches projects with stats at template render time
2. Sorts projects manually using padded star counts
3. Works on GitHub Pages but is harder to maintain

**This option is not recommended** - it's overly complex for the benefit.

## Recommendation

**Use a hybrid approach:**
1. Keep `_data/project-stats.yml` as the single source of truth
2. Create a PowerShell script that syncs stats back to project files before deployment
3. Gitignore the `stars:` and `gallery_downloads:` lines in project files for local dev
4. Run sync script before pushing to GitHub

This gives us:
- ✅ Single source of truth for stats
- ✅ Easy updates (just edit one file)
- ✅ Works on GitHub Pages (stats in project files)
- ✅ Works locally (plugin injects stats)
- ✅ Simple, maintainable solution

## Next Steps

1. **Create sync script** (`sync-project-stats.ps1`) that copies stats from YAML to project files
2. **Add to deployment workflow**: Run sync before git push
3. **Document the process** in CLAUDE.md

## Updating Stats

### Current Process

**To update project statistics:**

```powershell
# 1. Edit _data/project-stats.yml with new values

# 2. If deploying to GitHub Pages, sync to project files:
.\sync-project-stats.ps1

# 3. Build and test locally:
.\build.ps1

# 4. Commit and deploy:
git add .
git commit -m "Update project stats"
git push
```

## Files Safe to Delete

After migration is complete and tested:
- `remove-project-stats.ps1` (one-time migration script)
- `update-templates.ps1` (one-time migration script)
- `finalize-templates.ps1` (one-time migration script)
- `fix-for-github-pages.ps1` (one-time migration script)

**Keep these:**
- `_data/project-stats.yml` - **Source of truth**
- `_plugins/project_stats.rb` - **Local development**
- `sync-project-stats.ps1` - **Deployment helper** (to be created)

---

**Migration completed**: 2025-11-05
**Status**: Local working, GitHub Pages solution pending
