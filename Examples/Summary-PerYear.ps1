Import-Module "$PSScriptRoot\..\PSDevSummary.psd1" -Force

# This is required so you don't get prompts all the time from PowerShellForGitHub module
Set-GitHubConfiguration -SuppressTelemetryReminder
Set-GitHubConfiguration -DisableTelemetry
Set-GitHubConfiguration -AssemblyPath "$($Env:UserProfile)\.githubassembly"

# This is the commands from this module
$Modules = Get-DevSummary -Author 'Przemyslaw Klys' -UseCache

$Modules2019 = $Modules | Where-Object { $_.'Releases LastYear (2019)' -gt 0 -and $_.'Releases PreviousYear (2018)' -eq 0 }
$Modules2018 = $Modules | Where-Object { $_.'Releases PreviousYear (2018)' -gt 0 }
$Modules2018.Count
$Modules2019.Count