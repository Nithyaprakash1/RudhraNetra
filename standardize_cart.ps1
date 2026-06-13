$indexContent = Get-Content 'index.html' -Raw
$cartContent = Get-Content 'cart.html' -Raw

$navRegex = '(?s)<nav.*?</nav>'
$indexNav = [regex]::Match($indexContent, $navRegex).Value

$cartContent = [regex]::Replace($cartContent, $navRegex, $indexNav)

Set-Content 'cart.html' $cartContent -NoNewline
