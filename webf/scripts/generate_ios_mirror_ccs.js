#!/usr/bin/env node
/*
 Auto-generate iOS mirror .cc wrappers under ios/Classes for every .cc file under src/.
 Each wrapper mirrors src/<rel>.cc at ios/Classes/<rel>.cc with a single include:
   #include "../.../src/<rel>.cc"
 where the number of "../" is (depth of <rel> directory) + 2.

 Usage:
   node scripts/generate_ios_mirror_ccs.js [--dry-run] [--fix] [--verbose]

 Flags:
   --dry-run  : Do not write files; just print actions.
   --fix      : If a wrapper exists but has wrong include, rewrite it.
   --verbose  : Print detailed logging.
*/

const fs = require('fs');
const path = require('path');

function log(msg, { verbose }) { if (verbose) console.log(msg); }

function walk(dir, filterFn) {
  const out = [];
  const stack = [dir];
  while (stack.length) {
    const cur = stack.pop();
    const entries = fs.readdirSync(cur, { withFileTypes: true });
    for (const e of entries) {
      const p = path.join(cur, e.name);
      if (e.isDirectory()) {
        stack.push(p);
      } else if (e.isFile()) {
        if (!filterFn || filterFn(p)) out.push(p);
      }
    }
  }
  return out;
}

function ensureDirSync(dir) {
  fs.mkdirSync(dir, { recursive: true });
}

function pathToPosix(p) {
  return p.split(path.sep).join('/');
}

function computeIncludeFor(relPathFromSrc) {
  const dir = path.dirname(relPathFromSrc);
  const depth = dir === '.' ? 0 : dir.split(path.sep).length;
  const ups = '../'.repeat(depth + 2);
  return `${ups}src/${pathToPosix(relPathFromSrc)}`;
}

function main() {
  const argv = process.argv.slice(2);
  const dryRun = argv.includes('--dry-run');
  const fix = argv.includes('--fix');
  const verbose = argv.includes('--verbose');

  const cwd = process.cwd();
  const iosClassesDir = path.join(cwd, 'ios', 'Classes');
  const srcDir = path.join(cwd, 'src');

  if (!fs.existsSync(srcDir)) {
    console.error(`src directory not found at ${srcDir}`);
    process.exit(1);
  }
  if (!fs.existsSync(iosClassesDir)) {
    console.error(`ios/Classes directory not found at ${iosClassesDir}`);
    process.exit(1);
  }

  const skipDirNames = new Set(['test', 'tests', 'examples', 'example', 'samples', 'sample', 'docs', 'doc', 'benchmark', 'benchmarks']);
  const allowedTop = new Set(['bindings', 'code_gen', 'core', 'foundation', 'multiple_threading']);
  const srcFiles = walk(srcDir, (p) => p.endsWith('.cc'))
    .filter((p) => {
      const rel = path.relative(srcDir, p);
      const parts = rel.split(path.sep);
      const top = parts[0];
      const base = path.basename(p);
      // Whitelist top-level locations and specific third_party submodule
      let allowed = false;
      if (allowedTop.has(top)) allowed = true;
      else if (top === 'third_party' && parts[1] === 'modp_b64') allowed = true;
      else if (rel === 'webf_bridge.cc') allowed = true;
      if (!allowed) return false;
      // Skip if any path segment is in skipDirNames
      if (parts.some((seg) => skipDirNames.has(seg))) return false;
      // Skip common test file patterns
      if (/(_|\b)(test|unittest)(_|\b).*\.cc$/i.test(base)) return false;
      // Skip any occurrences of node_modules or cmake-build-*
      if (parts.includes('node_modules')) return false;
      if (parts.some((seg) => seg.startsWith('cmake-build-'))) return false;
      return true;
    });
  const created = [];
  const updated = [];
  const skipped = [];

  for (const absSrc of srcFiles) {
    const relFromSrc = path.relative(srcDir, absSrc);
    const targetPath = path.join(iosClassesDir, relFromSrc);
    const targetDir = path.dirname(targetPath);
    const includePath = computeIncludeFor(relFromSrc);
    const content = `#include "${includePath}"\n`;

    if (!fs.existsSync(targetPath)) {
      log(`MISSING -> will create: ${pathToPosix(path.relative(cwd, targetPath))}`, { verbose });
      if (!dryRun) {
        ensureDirSync(targetDir);
        fs.writeFileSync(targetPath, content);
      }
      created.push(targetPath);
    } else {
      // Verify content; update if --fix requested and mismatch.
      const existing = fs.readFileSync(targetPath, 'utf8');
      if (existing.trim() !== content.trim()) {
        if (fix && !dryRun) {
          fs.writeFileSync(targetPath, content);
          updated.push(targetPath);
        } else if (fix && dryRun) {
          updated.push(targetPath);
        } else {
          skipped.push(targetPath);
        }
      }
    }
  }

  // Optionally detect orphans: wrappers with no corresponding src file
  const wrapperFiles = walk(iosClassesDir, (p) => p.endsWith('.cc'));
  const orphanWrappers = [];
  for (const absWrap of wrapperFiles) {
    const relFromClasses = path.relative(iosClassesDir, absWrap);
    const expectedSrc = path.join(srcDir, relFromClasses);
    if (!fs.existsSync(expectedSrc)) {
      orphanWrappers.push(absWrap);
    }
  }

  // Summary
  const rel = (p) => pathToPosix(path.relative(cwd, p));
  console.log(`iOS mirror generation complete.`);
  console.log(`  Created: ${created.length}`);
  if (created.length && verbose) created.forEach((p) => console.log(`    + ${rel(p)}`));
  if (fix) {
    console.log(`  Updated: ${updated.length}`);
    if (updated.length && verbose) updated.forEach((p) => console.log(`    ~ ${rel(p)}`));
  }
  if (skipped.length) {
    console.log(`  Skipped (exists, mismatch): ${skipped.length} (use --fix to rewrite)`);
  }
  if (orphanWrappers.length) {
    console.log(`  Orphan wrappers (no src file): ${orphanWrappers.length}`);
    if (verbose) orphanWrappers.forEach((p) => console.log(`    ? ${rel(p)}`));
  }
  if (dryRun) console.log(`Dry-run: no files were written.`);
}

if (require.main === module) {
  try { main(); } catch (e) { console.error(e); process.exit(1); }
}
