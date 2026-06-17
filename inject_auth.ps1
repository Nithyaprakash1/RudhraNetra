$files = Get-ChildItem -Filter *.html

$scriptsToInject = @"
    <!-- Customer Authentication Scripts -->
    <script src="db.js"></script>
    <script src="auth.js"></script>
    <script src="auth-ui.js"></script>
</body>
"@

foreach ($file in $files) {
    # Skip files that don't need UI or are already auth pages
    if ($file.Name -eq 'admin-login.html' -or $file.Name -eq 'admin.html') {
        continue
    }

    $content = Get-Content $file.FullName -Raw
    
    if ($content -notmatch 'auth\.js') {
        # Replace the closing body tag with our scripts + closing body tag
        $content = $content -replace '</body>', $scriptsToInject
        Set-Content $file.FullName $content -NoNewline
        Write-Host "Injected auth scripts into $($file.Name)"
    }
}
