Import-Module "$PSScriptRoot\..\PSDevSummary.psd1" -Force

# This is required so you don't get prompts all the time from PowerShellForGitHub module
Set-GitHubConfiguration -SuppressTelemetryReminder
Set-GitHubConfiguration -DisableTelemetry
Set-GitHubConfiguration -AssemblyPath "$($Env:UserProfile)\.githubassembly"

# This is the commands from this module
$Modules = Get-DevSummary -Author 'Przemyslaw Klys' -UseCache -UseUrlInName

# Use GitHub to get GitHub summary
$GitHubModules = Get-PowerShellGitHubModules -Owner 'EvotecIT'

# Use PSWriteHTML/Dashimo to create dashboard
Dashboard -FilePath "$Env:USERPROFILE\Desktop\MyModules.HTML" {
    Tab -Name 'PowerShell Gallery Modules' {
        Table -DataTable $Modules -DisablePaging {
            TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator le -Value 20 -BackgroundColor Gray
            TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator lt -Value 10 -BackgroundColor Red
            TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator gt -Value 20 -BackgroundColor Yellow
            TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator gt -Value 100 -BackgroundColor Green
        } -Filtering -InvokeHTMLTags
    }
    Tab -Name 'GitHub Modules Only' {
        Table -DataTable $GitHubModules -DisablePaging {
            TableConditionalFormatting -Name 'Stars' -ComparisonType number -Operator le -Value 20 -BackgroundColor Gray
            TableConditionalFormatting -Name 'Stars' -ComparisonType number -Operator lt -Value 10 -BackgroundColor Red
            TableConditionalFormatting -Name 'Stars' -ComparisonType number -Operator gt -Value 20 -BackgroundColor Yellow
            TableConditionalFormatting -Name 'Stars' -ComparisonType number -Operator gt -Value 100 -BackgroundColor Green
        } -Filtering -InvokeHTMLTags
    }
} -Show