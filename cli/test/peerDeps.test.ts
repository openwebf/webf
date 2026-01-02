import fs from 'fs';
import path from 'path';

import { getPackageTypesFileFromDir, isPackageTypesReady } from '../src/peerDeps';

function makeTempDir(prefix: string): string {
  return fs.mkdtempSync(path.join(process.cwd(), 'test', prefix));
}

describe('peerDeps', () => {
  it('treats package as not ready when declared types file is missing', () => {
    const dir = makeTempDir('peerDeps-');
    const distDir = path.join(dir, 'dist');
    try {
      fs.mkdirSync(distDir, { recursive: true });
      fs.writeFileSync(
        path.join(dir, 'package.json'),
        JSON.stringify({ name: '@openwebf/react-core-ui', types: 'dist/index.d.ts' }, null, 2)
      );

      expect(getPackageTypesFileFromDir(dir)).toBe(path.join(dir, 'dist', 'index.d.ts'));
      expect(isPackageTypesReady(dir)).toBe(false);

      fs.writeFileSync(path.join(distDir, 'index.d.ts'), 'export {};');
      expect(isPackageTypesReady(dir)).toBe(true);
    } finally {
      fs.rmSync(dir, { recursive: true, force: true });
    }
  });
});
