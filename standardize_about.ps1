$indexContent = Get-Content 'index.html' -Raw
$aboutContent = Get-Content 'about.html' -Raw

$navRegex = '(?s)<nav.*?</nav>'
$indexNav = [regex]::Match($indexContent, $navRegex).Value

$aboutContent = [regex]::Replace($aboutContent, $navRegex, $indexNav)

Set-Content 'about.html' $aboutContent -NoNewline
