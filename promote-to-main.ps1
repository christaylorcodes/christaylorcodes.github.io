#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Promotes changes from dev branch to main (production) with safety checks.

.DESCRIPTION
    This script safely promotes changes from the dev branch to main by:
    - Verifying you're on the dev branch
    - Checking for uncommitted changes
    - Running a local build to verify functionality
    - Merging dev into main (fast-forward)
    - Pushing to GitHub (triggers production deployment)
    - Returning to dev branch for continued development

.PARAMETER SkipBuild
    Skip the local Jekyll build verification step (not recommended).

.PARAMETER Force
    Force promotion even if not on dev branch (use with caution).

.EXAMPLE
    .\promote-to-main.ps1
    Promotes dev branch to main with all safety checks.

.EXAMPLE
    .\promote-to-main.ps1 -SkipBuild
    Promotes without local build verification (faster, but riskier).

.NOTES
    Author: Chris Taylor
    Website: https://christaylor.codes
    This script is part of the dev branch workflow for safe deployments.
#>

[CmdletBinding()]
param(
    [Parameter(HelpMessage = "Skip local build verification (not recommended)")]
    [switch]$SkipBuild,

    [Parameter(HelpMessage = "Force promotion even if not on dev branch (use with caution)")]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Colors for output
$ColorInfo = "Cyan"
$ColorSuccess = "Green"
$ColorWarning = "Yellow"
$ColorError = "Red"

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor $ColorInfo
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $ColorSuccess
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $ColorWarning
}

function Write-Failure {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $ColorError
}

function Test-GitRepository {
    if (-not (Test-Path ".git")) {
        Write-Failure "Not in a git repository. Run this script from the repository root."
        exit 1
    }
}

function Get-CurrentBranch {
    return (git branch --show-current)
}

function Test-UncommittedChanges {
    $status = git status --porcelain
    return ($null -ne $status -and $status.Length -gt 0)
}

function Test-RemoteConnection {
    try {
        git ls-remote --exit-code origin > $null 2>&1
        return $true
    }
    catch {
        return $false
    }
}

# Main script execution
try {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorInfo
    Write-Host "║  Dev → Main Promotion Script                              ║" -ForegroundColor $ColorInfo
    Write-Host "║  christaylor.codes                                         ║" -ForegroundColor $ColorInfo
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor $ColorInfo

    # Step 1: Verify git repository
    Write-Step "Verifying git repository"
    Test-GitRepository
    Write-Success "Git repository detected"

    # Step 2: Check current branch
    Write-Step "Checking current branch"
    $currentBranch = Get-CurrentBranch

    if ($currentBranch -ne "dev" -and -not $Force) {
        Write-Failure "Not on dev branch (currently on: $currentBranch)"
        Write-Host "    Use -Force to promote from current branch (not recommended)" -ForegroundColor $ColorWarning
        exit 1
    }

    if ($Force -and $currentBranch -ne "dev") {
        Write-Warning "Forcing promotion from '$currentBranch' (not dev)"
    }
    else {
        Write-Success "On dev branch"
    }

    # Step 3: Check for uncommitted changes
    Write-Step "Checking for uncommitted changes"
    if (Test-UncommittedChanges) {
        Write-Failure "You have uncommitted changes"
        Write-Host "`nCommit or stash your changes before promoting:`n" -ForegroundColor $ColorWarning
        git status --short
        exit 1
    }
    Write-Success "Working directory clean"

    # Step 4: Fetch latest from remote
    Write-Step "Fetching latest from remote"
    if (-not (Test-RemoteConnection)) {
        Write-Failure "Cannot connect to remote repository"
        exit 1
    }

    git fetch origin
    Write-Success "Fetched latest from origin"

    # Step 5: Check if dev is behind origin/dev
    Write-Step "Checking if dev is up to date"
    $behindCount = git rev-list --count HEAD..origin/$currentBranch
    if ($behindCount -gt 0) {
        Write-Failure "Your $currentBranch branch is behind origin/$currentBranch by $behindCount commits"
        Write-Host "    Run: git pull origin $currentBranch" -ForegroundColor $ColorWarning
        exit 1
    }
    Write-Success "Branch is up to date with remote"

    # Step 6: Run local build (optional)
    if (-not $SkipBuild) {
        Write-Step "Running local build verification"
        Write-Host "    This ensures the site builds successfully before promotion..." -ForegroundColor DarkGray

        if (Test-Path ".\build.ps1") {
            $buildResult = & ".\build.ps1" -Mode build 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Failure "Local build failed"
                Write-Host $buildResult
                exit 1
            }
            Write-Success "Local build successful"
        }
        else {
            Write-Warning "build.ps1 not found, skipping local build verification"
        }
    }
    else {
        Write-Warning "Skipping local build verification (as requested)"
    }

    # Step 7: Confirm promotion
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorWarning
    Write-Host "║  Ready to promote $currentBranch → main (PRODUCTION)            ║" -ForegroundColor $ColorWarning
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor $ColorWarning
    Write-Host "This will:" -ForegroundColor $ColorWarning
    Write-Host "  1. Merge $currentBranch into main" -ForegroundColor $ColorWarning
    Write-Host "  2. Push main to GitHub" -ForegroundColor $ColorWarning
    Write-Host "  3. Trigger production deployment to christaylor.codes" -ForegroundColor $ColorWarning
    Write-Host "  4. Purge Cloudflare cache" -ForegroundColor $ColorWarning
    Write-Host ""

    $confirmation = Read-Host "Continue with promotion? (yes/no)"
    if ($confirmation -notmatch '^y(es)?$') {
        Write-Host "`nPromotion cancelled by user." -ForegroundColor $ColorWarning
        exit 0
    }

    # Step 8: Checkout main
    Write-Step "Checking out main branch"
    git checkout main
    Write-Success "Switched to main branch"

    # Step 9: Pull latest main
    Write-Step "Pulling latest main from remote"
    git pull origin main
    Write-Success "Main branch updated"

    # Step 10: Merge dev into main
    Write-Step "Merging $currentBranch into main"
    git merge $currentBranch --ff-only

    if ($LASTEXITCODE -ne 0) {
        Write-Failure "Fast-forward merge failed"
        Write-Host "`nThis usually means main has commits that $currentBranch doesn't have." -ForegroundColor $ColorWarning
        Write-Host "You may need to:" -ForegroundColor $ColorWarning
        Write-Host "  1. Checkout $currentBranch" -ForegroundColor $ColorWarning
        Write-Host "  2. Merge or rebase with main" -ForegroundColor $ColorWarning
        Write-Host "  3. Try promoting again" -ForegroundColor $ColorWarning
        Write-Host "`nReturning to $currentBranch branch..." -ForegroundColor $ColorInfo
        git checkout $currentBranch
        exit 1
    }
    Write-Success "Merged $currentBranch into main"

    # Step 11: Push to GitHub
    Write-Step "Pushing main to GitHub"
    git push origin main

    if ($LASTEXITCODE -ne 0) {
        Write-Failure "Failed to push main to GitHub"
        Write-Host "`nYou may need to resolve conflicts and push manually." -ForegroundColor $ColorWarning
        exit 1
    }
    Write-Success "Pushed main to GitHub"

    # Step 12: Return to dev branch
    Write-Step "Returning to $currentBranch branch"
    git checkout $currentBranch
    Write-Success "Back on $currentBranch branch"

    # Success summary
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorSuccess
    Write-Host "║  ✅ PROMOTION SUCCESSFUL!                                  ║" -ForegroundColor $ColorSuccess
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor $ColorSuccess

    Write-Host "Changes from $currentBranch have been promoted to main." -ForegroundColor $ColorSuccess
    Write-Host ""
    Write-Host "Deployment status:" -ForegroundColor $ColorInfo
    Write-Host "  • GitHub Actions is building and deploying to production" -ForegroundColor DarkGray
    Write-Host "  • View progress: https://github.com/christaylorcodes/christaylorcodes.github.io/actions" -ForegroundColor DarkGray
    Write-Host "  • Deployment typically takes 2-3 minutes" -ForegroundColor DarkGray
    Write-Host "  • Site will be live at: https://christaylor.codes" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "You are now back on the $currentBranch branch and can continue development." -ForegroundColor $ColorInfo
    Write-Host ""

}
catch {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorError
    Write-Host "║  ❌ PROMOTION FAILED                                       ║" -ForegroundColor $ColorError
    Write-Host "╚════════════════════════════════════════════════════════════╝`n" -ForegroundColor $ColorError

    Write-Failure "An error occurred during promotion:"
    Write-Host $_.Exception.Message -ForegroundColor $ColorError
    Write-Host ""
    Write-Host "You may need to manually resolve the issue." -ForegroundColor $ColorWarning

    # Try to return to original branch
    $currentBranch = Get-CurrentBranch
    if ($currentBranch -eq "main") {
        Write-Host "Attempting to return to dev branch..." -ForegroundColor $ColorInfo
        git checkout dev 2>$null
    }

    exit 1
}
