// import_meta_test.js - Test module for import.meta functionality

export function getImportMetaInfo() {
  const info = {
    url: import.meta.url,
    resolve: typeof import.meta.resolve,
    webf: import.meta.webf,
    env: import.meta.env
  };

  // Test import.meta.resolve if available
  if (typeof import.meta.resolve === 'function') {
    try {
      info.resolveTest = {
        relative: import.meta.resolve('./math.js'),
        absoluteLocal: import.meta.resolve('/assets/modules/utils.js'),
        external: import.meta.resolve('https://cdn.skypack.dev/lodash-es')
      };
    } catch (error) {
      info.resolveError = error.message;
    }
  }

  return info;
}

export function testDynamicImport() {
  // Test dynamic import functionality
  return import('./math.js').then(mathModule => {
    return {
      defaultFunction: mathModule.default('add', 10, 5),
      namedExport: mathModule.add(3, 7),
      constant: mathModule.PI
    };
  });
}

export const metaUrl = import.meta.url;
export const isWebF = import.meta.env.platform === 'webf';
