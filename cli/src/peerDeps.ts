import fs from 'fs';
import path from 'path';

export function readJsonFile(jsonPath: string): any {
  return JSON.parse(fs.readFileSync(jsonPath, 'utf-8'));
}

export function getPackageTypesFileFromDir(pkgDir: string): string | null {
  const pkgJsonPath = path.join(pkgDir, 'package.json');
  if (!fs.existsSync(pkgJsonPath)) return null;
  const pkgJson = readJsonFile(pkgJsonPath);
  const typesRel: string | undefined = pkgJson.types;
  if (!typesRel) return null;
  return path.join(pkgDir, typesRel);
}

export function isPackageTypesReady(pkgDir: string): boolean {
  const typesFile = getPackageTypesFileFromDir(pkgDir);
  return typesFile ? fs.existsSync(typesFile) : true;
}

