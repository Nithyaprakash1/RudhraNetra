import os
import glob

html_files = glob.glob('*.html')

for filepath in html_files:
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
        
    original = content
    
    # 1. Fix Energy glow clip
    if '.gold-energy-glow {' in content and 'padding-bottom: 0.15em;' not in content:
        content = content.replace(
            '.gold-energy-glow {\n', 
            '.gold-energy-glow {\n            padding-bottom: 0.15em;\n            margin-bottom: -0.15em;\n'
        )
        content = content.replace(
            '.gold-energy-glow {\r\n', 
            '.gold-energy-glow {\n            padding-bottom: 0.15em;\n            margin-bottom: -0.15em;\n'
        )
        
    # 2. Fix navigation links
    if filepath != 'index.html':
        content = content.replace('<a href="#home"', '<a href="index.html"')
        content = content.replace('<a href="#store"', '<a href="product.html"')
        
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")
    else:
        print(f"No changes needed for {filepath}")

print("Done.")
