/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const path = require('path');
const svgo = require('svgo');

const loader = function(source) {
  const filepath = this.resourcePath
  const opts = this.query || {};
  const testRelativePath = path.relative(opts.testPath, filepath)
  const snapshotFilepath = path.relative(
    opts.workspacePath,
    path.join(
      opts.snapshotPath,
      testRelativePath,
    )
  );

  const output = svgo.optimize(source, {
    path: filepath,
    multipass: true,
    plugins: [
      'removeDoctype',
      'removeXMLProcInst',
      'removeComments',
      'removeMetadata',
      'removeUnknownsAndDefaults',
      'removeUnusedNS',
      'removeTitle',
      {
        name: 'removeSVGTestTag',
        fn: (ast, params, info) => {
          return {
            element: {
              enter: (node, parentNode) => {
                if (node.name.includes(':')) {
                  parentNode.children = parentNode.children.filter(child => child !== node);
                }
              }
            }
          }
        }
      }
    ]
  })

  const htmlString = `
<html>
<head></head>
<body style="width: 100%; height: 100%;">
${output.data}
</body>
</html>
  `.trim();

  return `
    describe('SVGSpec/${testRelativePath}', () => {
      beforeEach(async () => {
        await resizeViewport(512, 512);
      });

      afterEach(async () => {
        // reset
        await resizeViewport();
      });

      it("should work", async () => {
        __webf_parse_html__(${JSON.stringify(htmlString)});
        await snapshot(null, '${snapshotFilepath}', false);
      });
    });
  `;
};

module.exports = loader;
