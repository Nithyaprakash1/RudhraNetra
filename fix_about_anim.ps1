$content = Get-Content 'about.html' -Raw

# 1. Shift the feature-panel down
$oldPanelCSS = @"
        .feature-panel {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
"@
$newPanelCSS = @"
        .feature-panel {
            position: absolute;
            top: 55%;
            transform: translateY(-45%);
"@
$content = $content.Replace($oldPanelCSS, $newPanelCSS)

# 2. Update the scrolling logic (increase duration, adjust timings)
$oldScript = @"
            const TOTAL = 1100;        // virtual pixels for full animation
            let vScroll   = 0;         // 0 … TOTAL
"@
$newScript = @"
            const TOTAL = 2000;        // Increased virtual pixels for slower scrolling
            let vScroll   = 0;         // 0 … TOTAL
"@
$content = $content.Replace($oldScript, $newScript)

# 3. Adjust the timings for when points appear
$oldTimings = @"
                /* Feature panels — staggered reveal & fade out of first two points */
                const fl1_fadeIn = prog(0.04, 0.18);
                const fl2_fadeIn = prog(0.17, 0.31);
                // First two points fade out as we scroll to the second half (p from 0.38 to 0.48)
                const fl_fadeOut = ease(cl((p - 0.38) / 0.10));

                fl1oT = fl1_fadeIn * (1 - fl_fadeOut);
                fl2oT = fl2_fadeIn * (1 - fl_fadeOut);

                fr1oT = prog(0.52, 0.66);
                fr2oT = prog(0.65, 0.79);
"@
$newTimings = @"
                /* Feature panels — staggered reveal & fade out of first two points */
                const fl1_fadeIn = prog(0.04, 0.14);
                const fl2_fadeIn = prog(0.24, 0.34); // Delayed appearance
                // First two points fade out as we scroll to the second half
                const fl_fadeOut = ease(cl((p - 0.42) / 0.06));

                fl1oT = fl1_fadeIn * (1 - fl_fadeOut);
                fl2oT = fl2_fadeIn * (1 - fl_fadeOut);

                fr1oT = prog(0.52, 0.62);
                fr2oT = prog(0.72, 0.82); // Delayed appearance
"@
$content = $content.Replace($oldTimings, $newTimings)

Set-Content 'about.html' $content -NoNewline
