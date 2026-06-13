import os
import re

html_files = [f for f in os.listdir('.') if f.endswith('.html')]

replacements = {
    r'<a href="#"([^>]*)>Karungali malai</a>': r'<a href="product.html"\1>Karungali malai</a>',
    r'<a href="#"([^>]*)>Karungali Bracelet</a>': r'<a href="product-details.html"\1>Karungali Bracelet</a>',
    r'<a href="#"([^>]*)>Karungali Necklace</a>': r'<a href="product.html"\1>Karungali Necklace</a>',
    r'<a href="#"([^>]*)>Karungali Ring</a>': r'<a href="product.html"\1>Karungali Ring</a>',
    r'<a href="#"([^>]*)>Karungali Damru Bracelet</a>': r'<a href="product.html"\1>Karungali Damru Bracelet</a>'
}

for file in html_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    for pattern, repl in replacements.items():
        new_content = re.sub(pattern, repl, new_content, flags=re.IGNORECASE)
        
    if new_content != content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'Updated {file}')
