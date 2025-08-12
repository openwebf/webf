#!/usr/bin/env node
// Read a JSON5 file describing { BRIDGE_SOURCE: [ ... ] } and print one path per line.
// We avoid external deps by evaluating the JSON5 as a JS object literal in a sandbox.

const fs = require('fs');
const vm = require('vm');
const path = require('path');

const file = process.argv[2] || path.join(process.cwd(), 'bridge_sources.json5');

try {
  const code = fs.readFileSync(file, 'utf8');
  // Wrap in parentheses so object-literal is a valid expression.
  const script = new vm.Script('(' + code + ')', { filename: file, displayErrors: true });
  const obj = script.runInNewContext(Object.create(null), { timeout: 1000 });
  if (!obj || !Array.isArray(obj.BRIDGE_SOURCE)) {
    console.error('Invalid JSON5: missing BRIDGE_SOURCE array');
    process.exit(2);
  }
  for (const item of obj.BRIDGE_SOURCE) {
    if (typeof item === 'string' && item.trim().length) {
      process.stdout.write(item.trim() + '\n');
    }
  }
} catch (e) {
  console.error(String(e && e.stack || e));
  process.exit(1);
}

