/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const path = require('path');
const HTMLParser = require('node-html-parser');
const fs = require('fs');

const SCRIPT = 'script';
const copiedPaths = new Set();

// Copy static files
const copyFileWithParentDir = (sourcePath, buildPath) => {

  if (copiedPaths.has(sourcePath)) {
    return;
  }

  const parentDir = path.basename(path.dirname(sourcePath));
  const sourceParentPath = path.dirname(sourcePath);
  const targetDir = path.join(buildPath, parentDir);

  if (!fs.existsSync(targetDir)) {
    fs.mkdirSync(targetDir, { recursive: true });
  }

  const files = fs.readdirSync(sourceParentPath);

  files.forEach(file => {
    const sourceFilePath = path.join(sourceParentPath, file);
    const targetFilePath = path.join(targetDir, file);

    if (fs.statSync(sourceFilePath).isFile()) {
      fs.copyFileSync(sourceFilePath, targetFilePath);
      copiedPaths.add(sourceFilePath);
    }
  });
}

// All the static files import paths should be normalized
const normalizeLocalPath = (originalPath) => {
  return './' + path.normalize(originalPath).split(path.sep).join('/').replace(/^\.\.\/+/, '');
}

// Handle @import in <style>
const processStyleImports = (styleContent, filepath, buildPath) => {
  const importRegex = /@import\s+(?:url\(['"]?|['"])(.*?)['"]?\)?;/g;
  const backgroundRegex = /background(?:-image)?:\s*url\(['"]?(.*?)['"]?\)/g;

  styleContent = styleContent.replace(importRegex, (match, importPath) => {
    if (!importPath.startsWith('http') && !importPath.startsWith('//')) {
      const absolutePath = path.resolve(path.dirname(filepath), importPath);
      if (fs.existsSync(absolutePath) && absolutePath.includes('blink')) {
        copyFileWithParentDir(absolutePath, buildPath);
      }
      // return `@import '${normalizeLocalPath(importPath)}';`;
      return match.replace(importPath, normalizeLocalPath(importPath));
    }
    return match;
  });

  styleContent = styleContent.replace(backgroundRegex, (match, urlPath) => {
    if (!urlPath.startsWith('http') && !urlPath.startsWith('//')) {
      const absolutePath = path.resolve(path.dirname(filepath), urlPath);
      if (fs.existsSync(absolutePath) && absolutePath.includes('blink')) {
        copyFileWithParentDir(absolutePath, buildPath);
      }
      // return `background: url("${normalizeLocalPath(urlPath)}");`;
      return match.replace(urlPath, normalizeLocalPath(urlPath));
    }
    return match;
  });

  return styleContent;
}

const traverseParseHTML = (ele, scripts, filepath, buildPath) => {
  ele.childNodes && ele.childNodes.forEach(e => {
    if (e.rawTagName === SCRIPT) {
      e.childNodes.forEach(item => {
        // TextNode of script element.
        if (item.nodeType === 3) {
          scripts.push(item._rawText);
        }
        // Delete content of script element for avoid to  script repetition.
        item._rawText = '';
      })
    }

    // Handle <link>
    if (e.rawTagName && e.rawTagName.toLowerCase() === 'link') {
      const href = e.getAttribute('href');
      if (href && !href.startsWith('http') && !href.startsWith('//')) {
        const absolutePath = path.resolve(path.dirname(filepath), href);
        if (fs.existsSync(absolutePath) && absolutePath.includes('blink')) {
          copyFileWithParentDir(absolutePath, buildPath);
        }
        e.setAttribute('href', normalizeLocalPath(href));
      }
    }

    if (e.rawTagName && e.rawTagName.toLowerCase() === 'img') {
      const src = e.getAttribute('src');
      if (src && !src.startsWith('http') && !src.startsWith('//')) {
        const absolutePath = path.resolve(path.dirname(filepath), src);
        if (fs.existsSync(absolutePath) && absolutePath.includes('blink')) {
          copyFileWithParentDir(absolutePath, buildPath);
        }
        e.setAttribute('src', normalizeLocalPath(src));
      }
    }

    // Handle <style>
    if (e.rawTagName && e.rawTagName.toLowerCase() === 'style') {
      e.childNodes.forEach(item => {
        if (item.nodeType === 3) {
          item._rawText = processStyleImports(item._rawText, filepath, buildPath);
        }
      });
    }

    traverseParseHTML(e, scripts, filepath, buildPath);
  });
}

const loader = function(source) {
  copiedPaths.clear();

  const filepath = this.resourcePath;
  const opts = this.query || {};
  const scripts = [];
  const testRelativePath = path.relative(opts.testPath, filepath);
  const snapshotFilepath = path.relative(
    opts.workspacePath,
    path.join(
      opts.snapshotPath,
      testRelativePath,
    )
  );
  const buildPath = this.query.buildPath;

  let root = HTMLParser.parse(source);
  traverseParseHTML(root, scripts, filepath, buildPath);

  // Set attr of HTML can let the case use fit. For example: <html fit> xxx </html>.
  let isFit = false;
  let isXit = false;
  root.childNodes && root.childNodes.forEach(ele => {
    if (ele.rawAttrs && ele.rawAttrs.indexOf('fit') >= 0) {
      isFit = true;
    }
    if (ele.rawAttrs && ele.rawAttrs.indexOf('xit') >= 0) {
      isXit = true;
    }
  })

  const htmlString = root.toString().replace(/['\n]/g, function(c){
    return {'\n': '','\'': '\\'}[c];
  });

  const { snapshotRoot, delayForSnapshot } = this.query.getSnapshotOption(filepath);
  const snapshotTarget = snapshotRoot === 'body' ? 'document.body' : 'document.documentElement';

  return `
    describe('HTMLSpec/${testRelativePath}', () => {
      // Use html_parse to parser html in html file.
      const html_parse = () => __webf_parse_html__(\`${htmlString}\`);
      var index = 0;
      const snapshotAction = async () => { await snapshot(${snapshotTarget}, '${snapshotFilepath}', ${scripts.length === 0 ? 'null' : 'index.toString()'}); index++; };
      ${isFit ? 'fit' : isXit ? 'xit' : 'it'}("should work", async (done) => {\
        html_parse();\
        ${delayForSnapshot ? `
        setTimeout(() => {
          requestAnimationFrame(async () => {
            ${scripts.length === 0 ? `await snapshotAction();` : scripts.join('\n')}
            done();
          });
        }, 3000);
        ` : `
          requestAnimationFrame(async () => {
          ${scripts.length === 0 ? `await snapshotAction();` : scripts.join('\n')}
          done();
        });
        `}
      }, 8000)
    });
  `;
};

module.exports = loader;
