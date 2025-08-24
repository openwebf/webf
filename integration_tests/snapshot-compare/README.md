# WebF Snapshot Compare Tool

A CLI tool for comparing visual snapshots between WebF integration tests and Chrome runner tests.

## Installation

```bash
cd integration_tests/snapshot-compare
npm install
npm run build
```

## Usage

```bash
# Compare snapshots for a specific test file
./lib/cli.js specs/css/css-text-mixin/color_relative_properties_test.ts

# With options
./lib/cli.js specs/css/css-text-mixin/color_relative_properties_test.ts --port 4000 --threshold 0.2 --no-open
```

## Options

- `--port <number>`: Port for the comparison web interface (default: 3000)
- `--no-open`: Do not automatically open the browser
- `--threshold <number>`: Pixel difference threshold 0-1 (default: 0.1)

## Features

1. **Automatic Test Execution**: Runs both WebF and Chrome runner tests
2. **Visual Comparison**: Pixel-by-pixel comparison with difference highlighting
3. **Web Interface**: Interactive UI with:
   - Grid view: Side-by-side comparison
   - Slider view: Interactive overlay comparison
   - Difference statistics and match scoring
4. **Match Classification**:
   - Perfect Match: 0% difference
   - Close Match: < 1% difference
   - Different: ≥ 1% difference

## How it Works

1. Runs the WebF integration test for the specified spec file
2. Runs the Chrome runner test for the same spec
3. Compares all generated snapshots with matching filenames
4. Starts a web server showing the visual differences
5. Opens the browser to display the comparison interface

## Development

```bash
# Run in development mode
npm run dev specs/css/css-text-mixin/color_relative_properties_test.ts
```