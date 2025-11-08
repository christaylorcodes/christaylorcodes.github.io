#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Commits and deploys changes to GitHub Pages

.DESCRIPTION
    This script streamlines the git workflow for deploying changes to the website:
    - Shows current git status
    - Stages all changes
    - Commits with a provided or default message
    - Pushes to the main branch
    - Displays GitHub Actions URL for monitoring deployment

.PARAMETER Message
    The commit message. If not provided, will prompt for input.

.PARAMETER SkipStatus
    Skip displaying git status before committing

.EXAMPLE
    .\deploy.ps1
    # Prompts for commit message

.EXAMPLE
    .\deploy.ps1 -Message "Update README with build documentation"
    # Commits with the specified message

.EXAMPLE
    .\deploy.ps1 -Message "Fix navigation styles" -SkipStatus
    # Commits without showing git status first
#>

param(
    [Parameter(Position = 0)]
    [string]$Message,

    [Parameter()]
    [switch]$SkipStatus
)

# Color output functions
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "→ $Message" "Cyan"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Magenta"
    Write-ColorOutput "  $Message" "Magenta"
    Write-ColorOutput "═══════════════════════════════════════════════════════════════" "Magenta"
    Write-Host ""
}

# Main script
Write-Header "Git Deploy - christaylorcodes.github.io"

# Check if we're in a git repository
if (-not (Test-Path ".git")) {
    Write-Error "Not a git repository. Please run this script from the repository root."
    exit 1
}

# Get current branch
$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Info "Current branch: $currentBranch"

if ($currentBranch -ne "main") {
    Write-Warning "You are not on the main branch. Current branch: $currentBranch"
    $continue = Read-Host "Do you want to continue? (y/N)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Info "Deployment cancelled."
        exit 0
    }
}

# Show git status
if (-not $SkipStatus) {
    Write-Host ""
    Write-Info "Current git status:"
    Write-Host ""
    git status --short
    Write-Host ""
}

# Check if there are changes to commit
$changes = git status --porcelain
if (-not $changes) {
    Write-Warning "No changes to commit."
    exit 0
}

# Function to generate commit message based on changes
function Get-GeneratedCommitMessage {
    param([string[]]$Changes)

    $modified = @()
    $added = @()
    $deleted = @()

    foreach ($line in $Changes) {
        $status = $line.Substring(0, 2).Trim()
        $file = $line.Substring(3).Trim()

        switch -Regex ($status) {
            '^M' { $modified += $file }
            '^A' { $added += $file }
            '^D' { $deleted += $file }
            '^\?\?' { $added += $file }
        }
    }

    # Categorize changes by file type
    $categories = @{
        'Documentation' = @('README.md', 'CLAUDE.md', '*.md')
        'Styles' = @('*.css', '*.scss', '_sass/*')
        'Scripts' = @('*.ps1', '*.sh', '*.js')
        'Configuration' = @('_config.yml', 'Gemfile', '*.gemspec')
        'Content' = @('_posts/*', '_projects/*', '*.html')
        'Images' = @('*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.svg')
    }

    $detectedCategories = @()
    $allFiles = $modified + $added + $deleted

    foreach ($category in $categories.Keys) {
        $patterns = $categories[$category]
        foreach ($pattern in $patterns) {
            if ($allFiles -like $pattern) {
                $detectedCategories += $category
                break
            }
        }
    }

    # Generate message parts
    $parts = @()

    if ($added.Count -gt 0) {
        if ($added.Count -eq 1) {
            $parts += "Add $($added[0])"
        } else {
            $fileName = Split-Path $added[0] -Leaf
            if ($detectedCategories.Count -gt 0) {
                $parts += "Add $($added.Count) $($detectedCategories[0].ToLower()) files"
            } else {
                $parts += "Add $($added.Count) new files"
            }
        }
    }

    if ($modified.Count -gt 0) {
        if ($modified.Count -eq 1) {
            $parts += "Update $($modified[0])"
        } elseif ($detectedCategories.Count -gt 0) {
            $parts += "Update $($detectedCategories[0].ToLower())"
        } else {
            $parts += "Update $($modified.Count) files"
        }
    }

    if ($deleted.Count -gt 0) {
        if ($deleted.Count -eq 1) {
            $parts += "Remove $($deleted[0])"
        } else {
            $parts += "Remove $($deleted.Count) files"
        }
    }

    # Combine parts
    $message = $parts -join " and "

    # Capitalize first letter
    $message = $message.Substring(0, 1).ToUpper() + $message.Substring(1)

    return $message
}

# Get commit message
if (-not $Message) {
    Write-Host ""

    # Generate suggested message
    $generatedMessage = Get-GeneratedCommitMessage -Changes $changes
    Write-Info "Generated commit message:"
    Write-ColorOutput "  $generatedMessage" "Yellow"
    Write-Host ""

    $useGenerated = Read-Host "Use this message? (Y/n/edit)"

    if ($useGenerated -eq "" -or $useGenerated -eq "y" -or $useGenerated -eq "Y") {
        $Message = $generatedMessage
    } elseif ($useGenerated -eq "e" -or $useGenerated -eq "edit") {
        $Message = Read-Host "Enter commit message [$generatedMessage]"
        if (-not $Message) {
            $Message = $generatedMessage
        }
    } else {
        $Message = Read-Host "Enter commit message"
        if (-not $Message) {
            Write-Error "Commit message cannot be empty."
            exit 1
        }
    }
}

# Stage all changes
Write-Host ""
Write-Info "Staging all changes..."
git add .

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to stage changes."
    exit 1
}

Write-Success "Changes staged"

# Commit changes
Write-Info "Committing changes..."
git commit -m "$Message

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to commit changes."
    exit 1
}

Write-Success "Changes committed"

# Push to remote
Write-Info "Pushing to origin/$currentBranch..."
git push origin $currentBranch

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to push changes."
    exit 1
}

Write-Success "Changes pushed to GitHub"

# Post-deployment information
Write-Host ""
Write-Header "Deployment Complete"

Write-Success "Your changes have been pushed to GitHub!"
Write-Host ""
Write-Info "GitHub Pages will rebuild your site in 2-5 minutes."
Write-Host ""
Write-ColorOutput "Monitor build status:" "White"
Write-ColorOutput "  https://github.com/christaylorcodes/christaylorcodes.github.io/actions" "Cyan"
Write-Host ""
Write-ColorOutput "Live site:" "White"
Write-ColorOutput "  https://christaylorcodes.github.io" "Cyan"
Write-Host ""
