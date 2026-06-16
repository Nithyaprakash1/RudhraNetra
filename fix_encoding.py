import os

replacements = {
    "â€œ": '"',
    "â€\u009d": '"',
    "â€": '"',
    "â˜…": '★',
    "â€”": '-',
    "â€™": "'",
    "â‚¹": '₹',
    "â€¢": '•',
    "â†’": '->',
    "Ã¢â‚¬Å“": '"',
    "Ã¢â‚¬Â": '"'
}

for root, dirs, files in os.walk('.'):
    if '.git' in root:
        continue
    for f in files:
        if f.endswith('.html') or f.endswith('.js'):
            filepath = os.path.join(root, f)
            try:
                with open(filepath, 'r', encoding='utf-8') as file:
                    content = file.read()
            except UnicodeDecodeError:
                continue

            modified = False
            for k, v in replacements.items():
                if k in content:
                    content = content.replace(k, v)
                    modified = True
            
            if modified:
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f"Fixed mojibake in {f}")
