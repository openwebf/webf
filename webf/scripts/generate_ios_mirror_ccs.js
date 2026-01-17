#!/usr/bin/env node
/*
 Auto-generate iOS mirror C/C++ wrappers under ios/Classes based ONLY on bridge_sources.json5.
 Each wrapper mirrors src/<rel>.{cc|c|mm} at ios/Classes/<rel>.{cc|c|mm} with a single include:
   #include "../.../src/<rel>.{cc|c|mm}"
 where the number of "../" is (depth of <rel> directory) + 2.
 With --fix, also removes orphan wrappers (no matching src/ file, or not listed in config) and prunes empty directories.

 Usage:
   node scripts/generate_ios_mirror_ccs.js [--config <path>] [--dry-run] [--fix] [--verbose]

 Flags:
   --config   : Path to bridge_sources.json5 (default: ../bridge/bridge_sources.json5).
   --dry-run  : Do not write or remove files; just print actions.
   --fix      : If a wrapper exists but has wrong include, rewrite it; also remove orphan wrappers.
   --verbose  : Print detailed logging.
*/

const fs = require('fs');
const path = require('path');
const JSON5 = require('json5');

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

function looksLikeGeneratedWrapper(source) {
  const lines = source.split(/\r?\n/).filter((l) => l.trim().length > 0);
  if (lines.length !== 1) return false;
  const line = lines[0].trim();
  return /^#include\s+"(\.\.\/)+src\/.+\.(?:c|cc|mm)"$/.test(line);
}

function computeIncludeFor(relPathFromSrc) {
  const dir = path.dirname(relPathFromSrc);
  const depth = dir === '.' ? 0 : dir.split(path.sep).length;
  const ups = '../'.repeat(depth + 2);
  return `${ups}src/${pathToPosix(relPathFromSrc)}`;
}

function readBridgeSources(configPath, { verbose }) {
  if (!fs.existsSync(configPath)) {
    log(`Config not found at ${configPath}`, { verbose });
    return null;
  }
  const raw = fs.readFileSync(configPath, 'utf8');
  try {
    const json = JSON5.parse(raw);
    if (!json || !Array.isArray(json.BRIDGE_SOURCE)) {
      console.warn(`Invalid config: expected { BRIDGE_SOURCE: string[] } at ${configPath}`);
      return null;
    }
    const list = Array.from(new Set(json.BRIDGE_SOURCE))
      .map((p) => p.trim())
      .filter((p) => p && (p.endsWith('.cc') || p.endsWith('.c') || p.endsWith('.mm')));
    const qjs_list = Array.from(new Set(json.QUICKJS_SOURCE))
      .map((p) => p.trim())
      .filter((p) => p && (p.endsWith('.cc') || p.endsWith('.c')));
    return list.concat(qjs_list);
  } catch (e) {
    console.warn(`Failed to parse ${configPath} with JSON5: ${e.message}`);
    return null;
  }
}

function main() {
  const argv = process.argv.slice(2);
  const dryRun = argv.includes('--dry-run');
  const fix = argv.includes('--fix');
  const verbose = argv.includes('--verbose');
  const configFlagIndex = argv.indexOf('--config');
  const configPathArg = configFlagIndex !== -1 ? argv[configFlagIndex + 1] : undefined;

  const cwd = process.cwd();
  const iosClassesDir = path.join(cwd, 'ios', 'Classes');
  const srcDir = path.join(cwd, 'src');
  const defaultConfigPath = path.join(cwd, '..', 'bridge', 'bridge_sources.json5');
  const configPath = configPathArg ? path.resolve(cwd, configPathArg) : defaultConfigPath;

  if (!fs.existsSync(srcDir)) {
    console.error(`src directory not found at ${srcDir}`);
    process.exit(1);
  }
  if (!fs.existsSync(iosClassesDir)) {
    console.error(`ios/Classes directory not found at ${iosClassesDir}`);
    process.exit(1);
  }

  // Strictly use list from bridge_sources.json5; no filesystem scanning fallback.
  const relFilesFromConfig = readBridgeSources(configPath, { verbose });
  if (!relFilesFromConfig || relFilesFromConfig.length === 0) {
    console.error(`No entries loaded from config ${configPath}. Aborting.`);
    process.exit(1);
  }
  console.log(`Using ${relFilesFromConfig.length} entries from ${pathToPosix(path.relative(cwd, configPath))}`);
  const srcFiles = relFilesFromConfig.map((rel) => path.join(srcDir, rel)).filter((abs) => fs.existsSync(abs));
  const missing = relFilesFromConfig.filter((rel) => !fs.existsSync(path.join(srcDir, rel)));
  if (missing.length) {
    console.warn(`Warning: ${missing.length} files from config not found under src/:`);
    if (verbose) missing.forEach((m) => console.warn(`  - ${m}`));
  }
  const created = [];
  const updated = [];
  const skipped = [];
  const removed = [];
  const removeSkipped = [];

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

  // Orphan detection
  const wrapperFiles = walk(iosClassesDir, (p) => p.endsWith('.cc') || p.endsWith('.c') || p.endsWith('.mm'));
  const orphanNoSrc = [];
  const notListedInConfig = [];
  const relSet = new Set(relFilesFromConfig.map((p) => pathToPosix(p)));
  for (const absWrap of wrapperFiles) {
    const relFromClasses = pathToPosix(path.relative(iosClassesDir, absWrap));
    const expectedSrc = path.join(srcDir, relFromClasses);
    if (!fs.existsSync(expectedSrc)) {
      orphanNoSrc.push(absWrap);
    }
    if (!relSet.has(relFromClasses)) {
      notListedInConfig.push(absWrap);
    }
  }

  if (fix) {
    const orphanCandidates = new Set([...orphanNoSrc, ...notListedInConfig]);
    for (const absWrap of orphanCandidates) {
      let existing;
      try {
        existing = fs.readFileSync(absWrap, 'utf8');
      } catch (e) {
        removeSkipped.push(absWrap);
        continue;
      }
      if (!looksLikeGeneratedWrapper(existing)) {
        removeSkipped.push(absWrap);
        continue;
      }

      log(`ORPHAN -> will remove: ${pathToPosix(path.relative(cwd, absWrap))}`, { verbose });
      if (!dryRun) {
        fs.unlinkSync(absWrap);
        // Remove empty directories up to ios/Classes.
        let currentDir = path.dirname(absWrap);
        while (path.resolve(currentDir) !== path.resolve(iosClassesDir)) {
          const entries = fs.readdirSync(currentDir);
          if (entries.length > 0) break;
          fs.rmdirSync(currentDir);
          currentDir = path.dirname(currentDir);
        }
      }
      removed.push(absWrap);
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
    console.log(`  Removed orphan wrappers: ${removed.length}`);
    if (removed.length && verbose) removed.forEach((p) => console.log(`    - ${rel(p)}`));
    if (removeSkipped.length) {
      console.log(`  Skipped orphan removal (non-wrapper/unreadable): ${removeSkipped.length}`);
      if (verbose) removeSkipped.forEach((p) => console.log(`    x ${rel(p)}`));
    }
  }
  if (skipped.length) {
    console.log(`  Skipped (exists, mismatch): ${skipped.length} (use --fix to rewrite)`);
  }
  if (orphanNoSrc.length) {
    console.log(`  Orphan wrappers found (no src file): ${orphanNoSrc.length}`);
    if (verbose) orphanNoSrc.forEach((p) => console.log(`    ? ${rel(p)}`));
  }
  if (notListedInConfig.length) {
    console.log(`  Wrappers found not listed in config: ${notListedInConfig.length}`);
    if (verbose) notListedInConfig.forEach((p) => console.log(`    ! ${rel(p)}`));
  }
  if (dryRun) console.log(`Dry-run: no files were written or removed.`);
}

if (require.main === module) {
  try { main(); } catch (e) { console.error(e); process.exit(1); }
}
