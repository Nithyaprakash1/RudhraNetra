$content = Get-Content 'about.html' -Raw

$oldCss = @"
        .feat-item {
            opacity: 0;
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }
"@

$newCss = @"
        .feat-item {
            opacity: 0;
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 32px;
            background: rgba(255, 241, 224, 0.45);
            backdrop-filter: blur(16px);
            border: 1px solid rgba(139, 69, 19, 0.15);
            padding: 24px;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.05);
            transition: all 0.4s ease;
        }
"@

$content = $content.Replace($oldCss, $newCss)
Set-Content 'about.html' $content -NoNewline
