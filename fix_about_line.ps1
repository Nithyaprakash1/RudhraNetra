$content = Get-Content 'about.html' -Raw

# 1. Update the trajectory to Down Right -> Down Left horizontally
$oldTrajectory = @"
                /* Move Center -> Down Right -> Center -> Down Left */
                if (p < 0.33) {
                    txT = lerp(0, SIDE, ease(cl(p / 0.33)));
                    tyT = lerp(0, TY_MAX, ease(cl(p / 0.33)));
                } else if (p < 0.66) {
                    txT = lerp(SIDE, 0, ease(cl((p - 0.33) / 0.33)));
                    tyT = lerp(TY_MAX, 0, ease(cl((p - 0.33) / 0.33)));
                } else {
                    txT = lerp(0, -SIDE, ease(cl((p - 0.66) / 0.34)));
                    tyT = lerp(0, TY_MAX, ease(cl((p - 0.66) / 0.34)));
                }
"@
$newTrajectory = @"
                /* Move Center -> Down Right -> Down Left */
                if (p < 0.48) {
                    txT = lerp(0, SIDE, ease(cl(p / 0.48)));
                    tyT = lerp(0, TY_MAX, ease(cl(p / 0.48)));
                } else {
                    txT = lerp(SIDE, -SIDE, ease(cl((p - 0.48) / 0.52)));
                    tyT = TY_MAX; // Stays perfectly horizontal across the bottom!
                }
"@
$content = $content.Replace($oldTrajectory, $newTrajectory)

# 2. Remove the line animation (anim-progress-bar CSS)
$oldCss = @"
        /* Progress bar — thin line at very bottom of section */
        #anim-progress-bar {
            position: absolute;
            bottom: 0; left: 0;
            height: 3px;
            width: 0%;
            background: linear-gradient(90deg, #A8704D, #8E5936);
            transition: width 0.1s linear;
            z-index: 10;
        }
"@
$content = $content.Replace($oldCss, "        /* Progress bar removed */")

# 3. Remove the line animation HTML
$oldHtml = @"
                <!-- Progress bar -->
                <div id="anim-progress-bar"></div>
"@
$content = $content.Replace($oldHtml, "                <!-- Progress bar removed -->")

# 4. Remove the line animation JS update
$oldJs = @"
                if (progBar) progBar.style.width = (p * 100) + '%';
"@
$content = $content.Replace($oldJs, "")

Set-Content 'about.html' $content -NoNewline
