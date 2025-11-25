@{
    # Module metadata
    RootModule = 'LighthouseWrapper.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d'
    Author = 'Chris Taylor'
    CompanyName = 'christaylor.codes'
    Copyright = '(c) 2025 Chris Taylor. All rights reserved.'
    Description = 'PowerShell wrapper for Lighthouse CLI to audit web performance, accessibility, SEO, and best practices.'

    # PowerShell version
    PowerShellVersion = '5.1'

    # Functions to export
    FunctionsToExport = @(
        'Invoke-LighthouseAudit',
        'Show-LighthouseResults',
        'Compare-LighthouseResults',
        'Get-LighthouseScores'
    )

    # Cmdlets to export
    CmdletsToExport = @()

    # Variables to export
    VariablesToExport = @()

    # Aliases to export
    AliasesToExport = @()

    # Private data
    PrivateData = @{
        PSData = @{
            Tags = @('Lighthouse', 'Performance', 'Accessibility', 'SEO', 'WebAudit')
            ProjectUri = 'https://christaylor.codes'
        }
    }
}