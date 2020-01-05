Import-Module "$PSScriptRoot\..\PSDevSummary.psd1" -Force

# This is required so you don't get prompts all the time from PowerShellForGitHub module
Set-GitHubConfiguration -SuppressTelemetryReminder
Set-GitHubConfiguration -DisableTelemetry
Set-GitHubConfiguration -AssemblyPath "$($Env:UserProfile)\.githubassembly"

# This is the commands from this module
$Modules = Get-DevSummary -Author 'Przemyslaw Klys' -UseCache -UseMarkdown
@(
    "# Summary of my PowerShell Modules"
    ''
    $Modules
) | Set-Content -LiteralPath $PSScriptRoot\Output\SummaryGitHub.MD