function Get-PowerShellGitHubModules {
    [CmdletBinding()]
    param(
        [string] $Owner = 'EvotecIT'
    )
    $GitHubModules = Get-GitHubRepository -OwnerName $Owner
    #$GitHubModules | Sort-Object Stargazers_Count -Descending | Format-Table full_name, Name, Stargazers_Count, forks_count, Open_issues, license, Language, HTML_URL, Fork, Created_At, Updated_At, Pushed_At, Archived -AutoSize
    foreach ($_ in $GitHubModules) {
        [PSCustomObject] @{
            'Name'      = $_.Name
            'Full Name' = $_.full_name
            'Stars'     = $_.Stargazers_Count
            'Forks'     = $_.forks_count
            'Issues'    = $_.Open_issues
            'License'   = $_.license.Name
            'Language'  = $_.Language
            'Uri'       = $_.HTML_URL
            'Is Fork'   = $_.Fork
            'Created'   = $_.Created_At
            'Updated'   = $_.Updated_At
            'Archived'  = $_.Archived
        }
    }
}