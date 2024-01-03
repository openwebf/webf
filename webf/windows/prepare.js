const fs = require('fs');
const path = require('path');

function replaceTextToDLL(p) {
    const fileExt = p.slice(-3);
    p = path.isAbsolute(p) ? p : path.join(__dirname, p);
    const dist = p.replace('.txt', '.dll').trim();
    if (fileExt === 'txt' && fs.existsSync(p) && !fs.existsSync(dist)) {
        const relPath = fs.readFileSync(p, {encoding: 'utf-8'});
        const targetPath = path.join(__dirname, relPath);
        fs.createReadStream(targetPath.trim()).pipe(fs.createWriteStream(p.replace('.txt', '.dll').trim()))
    }
}
//
replaceTextToDLL('./webf.txt');
replaceTextToDLL('./pthreadVC2.txt');
replaceTextToDLL('./quickjs.txt');
