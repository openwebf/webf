/*
 * Copyright (C) 2022-present The Kraken authors. All rights reserved.
 */
const { declare } = require('@babel/helper-plugin-utils');
const { types } = require('@babel/core');
const filepath = require('path');

module.exports = declare((api, opts) => {
  api.assertVersion(7);

  function ensureSnapshotFilenameArgs(callPath, file, calleeName, filenameArgIndex) {
    const filename = file.filename;
    const callee = callPath.get('callee');
    if (callee.node.name !== calleeName) return;

    const args = callee.container.arguments;
    // Only auto-inject for the common forms:
    // - snapshotFlutter()
    // - snapshotFlutter(x, y, w, h)
    // Avoid guessing when users pass other argument patterns.
    if (!(args.length === 0 || args.length === filenameArgIndex)) return;
    const snapshotFilepath =
      filepath.relative(
        opts.workspacePath,
        filepath.join(
          opts.snapshotPath,
          filepath.relative(opts.testPath, filename),
        )
      );

    // If the call already has a filename argument, do nothing.
    if (args.length > filenameArgIndex) return;

    // Fill missing positional args with `undefined` so `snapshotFilepath` lands
    // on the intended slot.
    while (args.length < filenameArgIndex) {
      args.push(types.identifier('undefined'));
    }
    args.push(types.stringLiteral(snapshotFilepath));
  }

  return {
    name: 'transform-snapshot',

    visitor: {
      CallExpression: function (path, file) {
        const filename = file.filename;
        const callee = path.get('callee');
        if (callee.node.name == 'snapshot') {
          const args = callee.container.arguments;
          const snapshotFilepath =
            filepath.relative(
              opts.workspacePath,
              filepath.join(
                opts.snapshotPath,
                filepath.relative(opts.testPath, filename),
              )
            );

          if (args.length == 0) {
            // snapshot() => snapshot(null, filename)
            args.push(types.nullLiteral());
            args.push(types.stringLiteral(snapshotFilepath));
          } else if (args.length == 1) {
            // snapshot(0.1) => snapshot(0.1, filename)
            args.push(types.stringLiteral(snapshotFilepath));
          }
          return;
        }

        // snapshotFlutter([x,y,w,h], filename)
        // Ensure the filename arg is always the 5th parameter:
        //   snapshotFlutter(x?, y?, w?, h?, filename?, postfix?)
        ensureSnapshotFilenameArgs(path, file, 'snapshotFlutter', 4);
      },
    },
  };
});
