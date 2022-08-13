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
  const filename = path.basename(this.resourcePath)
  const opts = this.query || {};
  const scripts = []
  const snapshotFilepath = path.relative(
    opts.workspacePath,
    path.join(
      opts.snapshotPath,
      path.relative(opts.testPath, filename),
    )
  );

  let root = HTMLParser.parse(source);
  traverseParseHTML(root, scripts);

  // Set attr of HTML can let the case use fit. For example: <html fit> xxx </html>.
  let isFit = false;
  root.childNodes && root.childNodes.forEach(ele => {
    if (ele.rawAttrs && ele.rawAttrs.indexOf('fit') >= 0) {
      isFit = true;
    }
  })

  const htmlString = root.toString().replace(/\n/g, '');

  return `
    describe('html-${path.basename(filename)}', () => {
      // Use html_parse to parser html in html file.
      const html_parse = () => __webf_parse_html__('${htmlString}');

      ${isFit ? 'fit' : 'it'}("should work", async () => {\
        html_parse();\
        ${scripts.length === 0 ? `await snapshot(null, '${snapshotFilepath}', false);` : scripts.join('\n')}
      })
    });
  `;
};

module.exports = loader;
