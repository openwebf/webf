/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const path = require('path');
const svgo = require('svgo');

function tryParseSizeNumber(size) {
  if (!size || size.endsWith('%')) {
    // default size
    return 512;
  } else if (size.endsWith('px')) {
    return parseInt(size.slice(0, -2), 10)
  } else {
    const parsedSize = parseInt(size, 10)
    if (!Number.isNaN(parsedSize)) {
      return parsedSize
    }
    throw new Error(`Unknown size ${width}`)
  }
}

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

  let svgWidth = 512;
  let svgHeight = 512;

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
      },
      {
        name: 'collectSVGSize',
        fn: (ast, params, info) => {
          ast.children.forEach(child => {
            if (child.type === 'element' && child.name === 'svg') {
              const {width, height} = child.attributes
              svgWidth = tryParseSizeNumber(width)
              svgHeight = tryParseSizeNumber(height)
            }
          })
          return {
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
        await resizeViewport(${svgWidth}, ${svgHeight});
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
