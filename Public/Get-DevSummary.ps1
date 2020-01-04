function Get-DevSummary {
    [CmdletBinding()]
    param(
        [string] $Author,
        [string] $PathModuleDetails = "$Env:USERPROFILE\Desktop\ModulesDetails.xml",
        [string] $PathModules = "$Env:USERPROFILE\Desktop\Modules.xml",
        [string] $PathGitHub = "$Env:USERPROFILE\Desktop\GitHubModules.xml",
        [string] $PathModulesHTML = "$Env:USERPROFILE\Desktop\MyModules.HTML",
        [switch] $UseCache,
        [switch] $UseHTMLLinks,
        [switch] $UseUrlMarkdown,
        [switch] $ReturnDetails
    )
    if ($UseCache -and (Test-Path -LiteralPath $PathModules)) {
        $AllModules = Import-Clixml -LiteralPath $PathModules
    } else {
        $AllModules = Find-Module -Verbose
        if ($UseCache) {
            $AllModules | Export-Clixml -LiteralPath $PathModules -Depth 5
        }
    }
    if ($UseCache -and (Test-Path -LiteralPath $PathModuleDetails)) {
        $AllModulesDetails = Import-Clixml -LiteralPath $PathModuleDetails
    } else {
        $AllModulesDetails = [ordered] @{ }
    }
    if ($UseCache -and (Test-Path -LiteralPath $PathGitHub)) {
        $GitHubModules = Import-Clixml -LiteralPath $PathGitHub
    } else {
        $GitHubModules = [ordered] @{ }
    }
    if ($Author) {
        [Array] $MyModules = $AllModules | Where-Object { $_.Author -eq $Author } | Sort-Object Name
    } else {
        [Array] $MyModules = $AllModules | Sort-Object Name
    }
    $Objects = foreach ($_ in $MyModules) {
        $Time = Start-TimeLog
        Write-Color -Text "[i] ", "Generating stats for module ", $($_.Name) -NoNewLine -Color Yellow, DarkGray, Yellow
        if ($null -eq $AllModulesDetails[$_.Name]) {
            $AllModulesDetails[$_.Name] = Find-Module -Name $_.Name -AllVersions -AllowPrerelease
        }
        [Array] $Module = $AllModulesDetails[$_.Name]

        Write-Color -Text ' [Total Release Count: ', $Module.Count, '] ' -NoNewLine -Color Cyan, DarkGray, Cyan
        [Array] $InternalModules = foreach ($M in $Module) {
            $PublishedDate = try {
                [DateTime] $M.PublishedDate
            } catch {
                $M.PublishedDate;
                Write-Warning "Conversion failed for $($M.PublishedDate)"
            }

            [PSCustomObject] @{
                Date      = $PublishedDate
                Downloads = $M.AdditionalMetadata.versionDownloadCount
            }
        }
        [DateTime] $CurrentYear = (Get-Date)
        [int] $Year = $CurrentYear.Year
        [int] $LastYear = ($CurrentYear).AddYears(-1).Year
        [int] $PreviousYear = ($CurrentYear).AddYears(-2).Year
        [Array] $ModuleCurrentYear = $InternalModules | Where-Object { $_.Date.Year -eq $Year }
        [Array] $ModuleLastYear = $InternalModules | Where-Object { $_.Date.Year -eq $LastYear }
        [Array] $ModulePreviousYear = $InternalModules | Where-Object { $_.Date.Year -eq $PreviousYear }

        if ($null -eq $GitHubModules[$_.ProjectUri]) {
            try {
                $GitHubModules[$_.ProjectUri] = Get-GitHubRepository -Uri $_.ProjectUri
            } catch {
                $GitHubProject = $Null
            }
        }
        $GitHubProject = $GitHubModules[$_.ProjectUri] | Select-Object full_name, Name, Stargazers_Count, forks_count, Open_issues, license, Language, HTML_URL, Fork, Created_At, Updated_At, Pushed_At, Archived
        if ($UseHTMLLinks) {
            $Name = "<a href='$($_.ProjectUri)'>$($_.Name)</a>"
            $PSGalleryURL = "<a href='https://www.powershellgallery.com/packages/$($_.Name)'>https://www.powershellgallery.com/packages/$($_.Name)</a>"
            $GitHubURL = "<a href='$($_.ProjectUri)'>$($_.ProjectUri)</a>"
        } elseif ($UseUrlMarkdown) {
            $Name = "[$($_.Name)]($($_.ProjectUri))"
        } else {
            $Name = $_.Name
            $PSGalleryURL = "https://www.powershellgallery.com/packages/$($_.Name)"
            $GitHubURL = $_.ProjectUri
        }
        $Object = [ordered] @{
            'Name'                                  = $Name
            'Type'                                  = $_.Type
            'GitHub Stars'                          = $GitHubProject.Stargazers_Count
            'GitHub Forks'                          = $GitHubProject.forks_count
            'GitHub Open Issues'                    = $GitHubProject.Open_issues
            'GitHub Archived'                       = $GitHubProject.Archived
            'GitHub Created'                        = $GitHubProject.Created_At
            'GitHub Updated'                        = $GitHubProject.Updated_At

            # This is a bug in Find-Module where without parameters is the same
            # https://github.com/PowerShell/PowerShellGet/issues/563
            'Download CountTotal'                   = $Module[0].AdditionalMetadata.downloadCount #$_.AdditionalMetadata.downloadCount
            'Download CountLast'                    = $Module[0].AdditionalMetadata.versionDownloadCount #$_.AdditionalMetadata.versionDownloadCount
            'Releases Total'                        = $Module.Count
            "Releases CurrentYear ($Year)"          = $ModuleCurrentYear.Count
            "Releases LastYear ($LastYear)"         = $ModuleLastYear.Count
            "Releases PreviousYear ($PreviousYear)" = $ModulePreviousYear.Count
            'Last Updated'                          = $_.AdditionalMetadata.published
            'PS Gallery Url'                        = $PSGalleryURL
            #'Project Url'                           = $GitHubURL
            'Description'                           = $_.Description
        }
        if ($ReturnDetails) {
            $Object.'Modules' = $Module
        }

        $EndTime = Stop-TimeLog -Time $Time -Option OneLiner
        Write-Color -Text ' [Time to gather data: ', $EndTime, ']' -Color Cyan, DarkGray, Cyan
        [PSCustomObject] $Object
    }
    if ($UseCache) {
        $AllModulesDetails | Export-Clixml -LiteralPath $PathModuleDetails -Depth 5
        $GitHubModules | Export-Clixml -LiteralPath $PathGitHub -Depth 5
    }
    $Objects
}