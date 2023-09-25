/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const path = require('path');
const HTMLParser = require('node-html-parser');

const SCRIPT = 'script';

const traverseParseHTML = (ele, scripts) => {
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
    traverseParseHTML(e, scripts);
  });
}

const loader = function(source) {
  const filepath = this.resourcePath
  const filename = path.basename(filepath)
  const opts = this.query || {};
  const scripts = []
  const testRelativePath = path.relative(opts.testPath, filepath)
  const snapshotFilepath = path.relative(
    opts.workspacePath,
    path.join(
      opts.snapshotPath,
      testRelativePath,
    )
  );

  let root = HTMLParser.parse(source);
  traverseParseHTML(root, scripts);

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
  
  return `
    describe('HTMLSpec/${testRelativePath}', () => {
      // Use html_parse to parser html in html file.
      const html_parse = () => __webf_parse_html__(\`${htmlString}\`);
      var index = 0;
      const snapshotAction = async () => { await snapshot(null, '${snapshotFilepath}', ${scripts.length === 0 ? 'null' : 'index.toString()'}); index++; };
      ${isFit ? 'fit' : isXit ? 'xit' : 'it'}("should work", async (done) => {\
        html_parse();\
        requestAnimationFrame(async () => {
          ${scripts.length === 0 ? `await snapshotAction();` : scripts.join('\n')}
          done();
        });
      })
    });
  `;
};

module.exports = loader;
