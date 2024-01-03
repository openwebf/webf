const exec = require('child_process').exec;
const path = require('path');
const fs = require('fs');

function clean() {
    const specDir = path.join(__dirname, '..', '.specs');
    if (fs.existsSync(specDir)) fs.rmSync(specDir, {recursive: true});
}

clean();