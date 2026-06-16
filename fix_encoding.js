const fs = require('fs');
const path = require('path');

const replacements = {
    "â€œ": "\"",
    "â€\u009d": "\"",
    "â€\x9d": "\"",
    "â€": "\"",
    "â˜…": "★",
    "â€”": "-",
    "â€™": "'",
    "â‚¹": "₹",
    "â€¢": "•",
    "â†’": "->"
};

function walkDir(dir) {
    fs.readdirSync(dir).forEach(f => {
        const dirPath = path.join(dir, f);
        const isDirectory = fs.statSync(dirPath).isDirectory();
        if (isDirectory && !dirPath.includes('.git')) {
            walkDir(dirPath);
        } else if (f.endsWith('.html') || f.endsWith('.js')) {
            let content = fs.readFileSync(dirPath, 'utf8');
            let modified = false;
            for (const [key, val] of Object.entries(replacements)) {
                if (content.includes(key)) {
                    content = content.split(key).join(val);
                    modified = true;
                }
            }
            if (modified) {
                fs.writeFileSync(dirPath, content, 'utf8');
                console.log(`Fixed mojibake in ${f}`);
            }
        }
    });
}

walkDir(__dirname);
