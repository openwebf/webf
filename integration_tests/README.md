# WebF integration tests

## Dart Unit test

1. Simply use flutter test command.
2. More to see https://flutter.dev/docs/cookbook/testing/unit/introduction
3. Package test usage: https://pub.dev/packages/test

## JS API Unit Test

1. An JS wrapper of dart unit test framework.
2. Similar to jest framework usage.
3. Support most jest framework apis: `describe`, `it`, `beforeEach`, `afterEach`, `beforeAll`, `afterAll`.
4. Support async operation by return a promise object from `it`.

## Integration test

1. We use flutter integration test to inject a running app.dart.
2. Each js file in fixtures is a test case payload.
3. Each case executed in serial.
4. app_test.dart will drive app.dart to run the test.
5. Compare detection screenshot content.
6. More to see https://flutter.dev/docs/cookbook/testing/integration/introduction

### How to write

The easist way is copy test case from [wpt](https://github.com/web-platform-tests/wpt).

You also write test case script if wpt is not suitable.

1. Create typescript file in `specs` folder.
2. Use describe and it to write test case like jasmine.
3. Use `snapshot()` at the end of `it` to assert.

Tips:

1. You can use `xit` to skip current test or `fit` to focus current test.
2. Every snapshot file is stored at `snapshots` folder. Plases commit those file.
3. You can use `WEBF_TEST_FILTER` shell env to filter test to run. Like `WEBF_TEST_FILTER="foo" npm run integration`.

## Usage

+ **intergration test**: npm run test

### For MacBook Pro 16 inc Users (with dedicated AMD GPU)

Use the following commands to switch your GPU into Intel's integration GPU.

```
sudo pmset -a gpuswitch 0
```

+ 0: Intel's GPU only
+ 1: AMD GPU only
+ 2: dynamic switch

### Run single spec

this above command will execute which spec's name contains "synthesized-baseline-flexbox-001"
```
 WEBF_TEST_FILTER="synthesized-baseline-flexbox-001" npm run integration
```

## Visual Snapshot Comparison

Compare visual snapshots between WebF integration tests and Chrome runner tests:

### Quick Start

```bash
# Build the comparison tool (first time only)
npm run compare:build

# Compare a single test file
npm run compare specs/css/css-text-mixin/color_relative_properties_test.ts

# Compare all tests in a directory
npm run compare:all css-text-mixin

# Compare all tests with snapshots
npm run compare:all -- --all
```

### What it does

1. Runs WebF integration test for the specified file(s)
2. Runs Chrome runner test for the same file(s)
3. Compares generated snapshots pixel-by-pixel
4. Opens a web interface showing visual differences

### Web Interface Features

- **Grid View**: Side-by-side comparison of WebF, Chrome, and diff images
- **Slider View**: Interactive overlay comparison
- **Match Classification**: Perfect Match (green), Close Match (yellow), Different (red)

For detailed usage, see [SNAPSHOT_COMPARISON.md](./SNAPSHOT_COMPARISON.md)

## Test Tools

### Snapshot Viewer

Interactive web-based tool for reviewing and managing failed test snapshots:

```bash
# Install tool dependencies (first time)
npm run tools:install

# View failed snapshots
npm run snapshot-viewer

# View with custom port
npm run snapshot-viewer -- --port 4000
```

Features:
- **Visual Comparison**: Side-by-side view of original, current, and diff images
- **Keyboard Shortcuts**: Fast navigation (Cmd/Ctrl + arrows) and actions
- **Batch Operations**: Accept or reject all changes at once
- **Live Updates**: Automatically detects new failed snapshots

### Spec Preview

Interactive tool for writing and testing WebF integration test specs:

```bash
# Launch spec preview editor
npm run spec-preview

# Use custom port
npm run spec-preview -- --port 4000
```

Features:
- **Live Editor**: Write or paste spec code with syntax highlighting
- **Compile on-the-fly**: Convert TypeScript to JavaScript with WebF runtime
- **Browser Testing**: Quick testing with mocked WebF environment
- **WebF Integration**: Launch specs in actual WebF runtime
- **Real-time Console**: View compilation and test results

See [tools/README.md](tools/README.md) for detailed documentation and keyboard shortcuts.
