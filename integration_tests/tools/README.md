# WebF Test Tools

A collection of utilities for WebF integration testing and development.

## 🖼️ Snapshot Viewer

An interactive web-based tool for reviewing and managing failed integration test snapshots.

### Features

- **Visual Comparison**: Side-by-side view of original, current, and diff images
- **Batch Operations**: Accept or reject all changes at once
- **Keyboard Shortcuts**: Fast navigation and actions
- **Live Updates**: Automatically detects new failed snapshots
- **Web Interface**: Modern, responsive UI for easy snapshot review

### Installation

```bash
cd integration_tests/tools/snapshot-viewer
npm install
```

### Usage

#### From integration_tests directory:
```bash
# View snapshots in default location (./snapshots)
node tools/snapshot-viewer/cli.js

# Specify custom snapshot directory
node tools/snapshot-viewer/cli.js --dir ./custom-snapshots

# Use custom port
node tools/snapshot-viewer/cli.js --port 4000
```

#### As npm script (add to package.json):
```json
{
  "scripts": {
    "snapshot-viewer": "node tools/snapshot-viewer/cli.js"
  }
}
```

Then run:
```bash
npm run snapshot-viewer
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + ←` | Previous snapshot |
| `Cmd/Ctrl + →` | Next snapshot |
| `Cmd/Ctrl + Enter` | Accept current version |
| `Escape` | Keep original version |
| `Alt + A` | Accept all current versions |
| `Alt + R` | Keep all original versions |

### How It Works

1. **Scans for Failed Snapshots**: Looks for `.current.png` files in the snapshot directory
2. **Displays Comparisons**: Shows original, current, and diff images side-by-side
3. **Update Snapshots**: Choose to accept new versions or keep originals
4. **Cleanup**: Automatically removes temporary `.current.png` and `.diff.png` files

### File Structure

```
snapshots/
├── test-name.png           # Original/baseline snapshot
├── test-name.current.png   # New version (when test fails)
└── test-name.diff.png      # Visual difference
```

### API Endpoints

The server provides these REST endpoints:

- `GET /api/snapshots` - List all failed snapshots
- `POST /api/snapshots/update` - Update single snapshot
- `POST /api/snapshots/update-all` - Batch update all snapshots
- `POST /api/snapshots/rescan` - Rescan for new failures

## 🧪 Spec Preview

An interactive tool for writing, compiling and testing WebF integration test specs in real-time.

### Features

- **Live Editor**: Write or paste spec code with syntax highlighting
- **TypeScript Compilation**: Compile specs on-the-fly
- **Browser Testing**: Run specs in browser with mocked WebF environment
- **WebF Debug Server**: Provides a URL endpoint for WebF to fetch and run compiled specs
- **Real-time Console**: View compilation and runtime output

### Installation

```bash
cd integration_tests/tools/spec-preview
npm install
```

### Usage

#### From integration_tests directory:
```bash
# Launch spec preview
node tools/spec-preview/cli.js

# Use custom port
node tools/spec-preview/cli.js --port 4000
```

#### As npm script:
```bash
npm run spec-preview
```

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + S` | Compile code |
| `Cmd/Ctrl + Enter` | Run in browser |
| `Cmd/Ctrl + Shift + B` | Run in browser |
| `Cmd/Ctrl + Shift + W` | Copy WebF URL |
| `Cmd/Ctrl + Shift + C` | Compile code |

### How It Works

1. **Write Code**: Write or paste your spec code in the editor
2. **Compile**: Convert TypeScript to JavaScript with WebF runtime
3. **Get Debug URL**: After compilation, a WebF debug URL is displayed
4. **Test in Browser**: Run in browser for quick testing with mocked environment
5. **Test in WebF**: Use the debug URL in your WebF app or development tools
6. **Debug**: View console output and test results

The debug server URL (e.g., `http://localhost:3400/webf_debug_server.js`) can be used in:
- WebF development environments
- Android Studio or Xcode for mobile testing
- Any WebF-enabled application that can fetch and execute JavaScript from a URL

## 🔧 Future Tools

Additional tools can be added to this directory:

- **Test Generator**: Auto-generate test specs from WPT
- **Performance Analyzer**: Analyze test execution times
- **Coverage Reporter**: Visual test coverage reports

## Development

### Adding New Tools

1. Create a new directory under `tools/`
2. Include a `package.json` with dependencies
3. Add CLI entry point if needed
4. Update this README with documentation

### Guidelines

- Keep tools modular and independent
- Provide both CLI and programmatic interfaces
- Include comprehensive error handling
- Add keyboard shortcuts for common actions
- Follow WebF coding standards

## Contributing

When adding new tools or features:

1. Test thoroughly with actual WebF snapshots
2. Ensure compatibility with existing workflows
3. Document all features and options
4. Add examples to this README