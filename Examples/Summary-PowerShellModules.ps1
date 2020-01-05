Import-Module "$PSScriptRoot\..\PSDevSummary.psd1" -Force

# This is required so you don't get prompts all the time from PowerShellForGitHub module
Set-GitHubConfiguration -SuppressTelemetryReminder
Set-GitHubConfiguration -DisableTelemetry
Set-GitHubConfiguration -AssemblyPath "$($Env:UserProfile)\.githubassembly"

# This is the commands from this module
$Modules = Get-DevSummary -Author 'Przemyslaw Klys' -UseHTMLLinks -UseCache

# Use PSWriteHTML/Dashimo to create dashboard
Dashboard -FilePath "$PSScriptRoot\Output\EmbeddingModules.HTML" {
    Table -DataTable $Modules {
        TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator le -Value 20 -BackgroundColor Orange -Color Black
        TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator lt -Value 10 -BackgroundColor Red -Color Black
        TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator gt -Value 20 -BackgroundColor Yellow -Color Black
        TableConditionalFormatting -Name 'GitHub Stars' -ComparisonType number -Operator gt -Value 100 -BackgroundColor Green -Color Black
    } -Filtering -InvokeHTMLTags
} -Show -UseCssLinks -UseJavaScriptLinks
# Use PSParseHTML to Optimize/Minify HTML
Optimize-HTML -File "$PSScriptRoot\Output\EmbeddingModules.HTML" -OutputFile $PSScriptRoot\Output\EmbeddingModules1.HTML -Verbose