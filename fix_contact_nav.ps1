$about = Get-Content about.html -Raw
$navRegex = '(?s)<nav\b[^>]*id="navbar"[^>]*>.*?</nav>'
if ($about -match $navRegex) {
    $nav = $matches[0]
    $contact = Get-Content contact.html -Raw
    $contact = $contact -replace $navRegex, $nav
    Set-Content contact.html $contact
    Write-Host 'Replaced contact.html nav with about.html nav.'
}
