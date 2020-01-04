Function ConvertTo-Markdown {
    <#
    .Synopsis
    Converts a PowerShell object to a Markdown table.

    .Description
    Converts a PowerShell object to a Markdown table.

    .Parameter InputObject
    PowerShell object to be converted

    .Example
    ConvertTo-Markdown -InputObject (Get-Service)

    Converts a list of running services on the local machine to a Markdown table

    .Example
    ConvertTo-Markdown -InputObject (Import-CSV "C:\Scratch\lwsmachines.csv") | Out-File "C:\Scratch\file.markdown" -Encoding "ASCII"

    Converts a CSV file to a Markdown table

    .Example
    Import-CSV "C:\Scratch\lwsmachines.csv" | ConvertTo-Markdown | Out-File "C:\Scratch\file2.markdown" -Encoding "ASCII"

    Converts a CSV file to a markdown table via the pipeline.

    .Notes
    Ben Neise 10/09/14

    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)][PSObject[]]$collection
    )
    Begin {
        $Items = [System.Collections.Generic.List[string]]::new()
        $columns = [ordered] @{ }
    }
    Process {
        ForEach ($item in $collection) {
            $items.Add($item)

            $item.PSObject.Properties | ForEach-Object {
                if ($null -eq $_.Value) {
                    $_.Value = ""
                }
                if (-not $columns.Contains($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                    $columns[$_.Name] = $_.Value.ToString().Length
                }
            }
        }
    }
    End {
        ForEach ($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length)
        }

        $header = ForEach ($key in $columns.Keys) {
            ('{0,-' + $columns[$key] + '}') -f $key
        }
        $($header -join ' | ')

        $separator = ForEach ($key in $columns.Keys) {
            '-' * $columns[$key]
        }
        $($separator -join ' | ')


        ForEach ($item in $items) {
            $values = ForEach ($key in $columns.Keys) {
                ('{0,-' + $columns[$key] + '}') -f $item.($key)
            }
            $($values -join ' | ')
        }
    }
}