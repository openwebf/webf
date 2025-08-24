# Snapshot Comparison Scripts

Quick scripts for comparing WebF and Chrome runner snapshots.

## Prerequisites

First, ensure the snapshot comparison tool is installed:

```bash
cd snapshot-compare
npm install
npm run build
cd ..
```

## Single Test Comparison

Compare snapshots for a single test file:

```bash
# Full path
./compare-snapshots.js specs/css/css-text-mixin/color_relative_properties_test.ts

# Relative path (specs/ will be added automatically)
./compare-snapshots.js css/css-text-mixin/color_relative_properties_test.ts

# With options
./compare-snapshots.js css/css-overflow/overflow-inline.ts --port 4000 --threshold 0.2
```

### Options
- `--port <number>`: Port for web interface (default: 3000)
- `--threshold <num>`: Pixel difference threshold 0-1 (default: 0.1)
- `--no-open`: Don't automatically open browser
- `--help`: Show help message

## Batch Comparison

Compare multiple tests at once:

```bash
# Compare all tests in a directory
./compare-all-snapshots.js css-text-mixin
./compare-all-snapshots.js css/css-overflow

# Compare all tests with snapshots
./compare-all-snapshots.js --all

# Just show summary without running comparisons
./compare-all-snapshots.js css-text-mixin --summary
```

## What the Tools Do

1. **Run WebF Test**: Executes `npm run integration -- <spec-file>`
2. **Run Chrome Test**: Executes the same test in Chrome runner
3. **Compare Snapshots**: Pixel-by-pixel comparison with difference highlighting
4. **Web Interface**: Interactive UI to visually inspect differences

## Web Interface Features

- **Grid View**: Side-by-side comparison of WebF, Chrome, and diff images
- **Slider View**: Drag to interactively compare images
- **Match Classification**:
  - 🟢 Perfect Match (0% difference)
  - 🟡 Close Match (< 1% difference)
  - 🔴 Different (≥ 1% difference)

## Examples

```bash
# Compare a single CSS text test
./compare-snapshots.js css/css-text-mixin/locale_support_test.ts

# Compare all overflow tests on port 4000
./compare-all-snapshots.js css/css-overflow --port 4000

# Check what tests have snapshots
./compare-all-snapshots.js --all --summary

# Compare with higher threshold (more tolerant)
./compare-snapshots.js dom/elements/canvas.ts --threshold 0.3
```

## Tips

- The web interface updates in real-time as tests complete
- Use keyboard shortcuts in the web interface:
  - `G`: Toggle between Grid and Slider view
  - `Arrow keys`: Navigate between comparisons
- Snapshots are cached, so re-running is fast
- The tool automatically handles the different snapshot naming conventions