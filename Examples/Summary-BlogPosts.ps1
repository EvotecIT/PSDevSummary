# Install-Module PSWebToolbox

$Blogs = Get-RSSFeed -Url 'https://evotec.xyz/rss' -All

$DateFrom = Get-Date -Year 2017 -Month 01 -Day 01
$DateTo = Get-Date -Year 2018 -Month 01 -Day 01

$Year2017 = $Blogs | Where-Object { $_.PublishDate -ge $DateFrom -and $_.PublishDate -le $DateTo }
$Year2017.Count

$DateFrom = Get-Date -Year 2018 -Month 01 -Day 01
$DateTo = Get-Date -Year 2019 -Month 01 -Day 01

$Year2018 = $Blogs | Where-Object { $_.PublishDate -ge $DateFrom -and $_.PublishDate -le $DateTo }
$Year2018.Count

$DateFrom = Get-Date -Year 2019 -Month 01 -Day 01
$DateTo = Get-Date -Year 2020 -Month 01 -Day 01

$Year2019 = $Blogs | Where-Object { $_.PublishDate -ge $DateFrom -and $_.PublishDate -le $DateTo }
$Year2019.Count

# PSWriteHTML
$PrettiefiedHTML = foreach ($Blog in $Year2019) {
    [PSCustomObject] @{
        Title       = New-HTMLTag -Tag 'a' -Attributes @{ href = $Blog.Link; target = '_blank' } { $Blog.Title }
        Date        = $Blog.PublishDate
        Tags        = $Blog.Categories
        Description = $Blog.Description
    }
}
$PrettiefiedHTML | Out-HtmlView -FilePath $PSScriptRoot\Output\EmbeddingBlog.html -InvokeHTMLTags -DateTimeSortingFormat 'DD.MM.YYYY HH:mm:ss' -Filtering -PagingOptions 5, 10, 15, 20

# PSParseHTML Minify HTML
Optimize-HTML -File "$PSScriptRoot\Output\EmbeddingBlog.HTML" -OutputFile $PSScriptRoot\Output\EmbeddingBlog1.HTML -Verbose