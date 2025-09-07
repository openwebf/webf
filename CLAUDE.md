# WebF Development Guide

This is the main guide for WebF development. Detailed content is organized into folder-specific guides.

## 📚 Folder-Specific Guides

| Guide | Description |
|-------|-------------|
| **[C++ Development](bridge/CLAUDE.md)** | C++ bridge development, build commands, FFI patterns, iOS troubleshooting |
| **[Dart/Flutter Development](webf/CLAUDE.md)** | Dart code, widget testing, Flutter patterns, render object system |
| **[Integration Testing](integration_tests/CLAUDE.md)** | Writing and running integration tests, snapshot testing |
| **[CLI Development](cli/CLAUDE.md)** | WebF CLI code generator for React/Vue bindings |
| **[Scripts](scripts/CLAUDE.md)** | Build scripts and utility tools |
| **[Architecture](docs/ARCHITECTURE.md)** | WebF architecture pipeline and design patterns |
| **[Memory & Performance](docs/MEMORY_PERFORMANCE.md)** | Performance optimization, caching, memory management |

## 🚀 Quick Start

### Repository Structure
- `bridge/`: C++ code providing JavaScript runtime and DOM API implementations
- `webf/`: Dart code implementing DOM/CSS and layout/painting on Flutter
- `integration_tests/`: Integration tests and visual regression tests
- `cli/`: WebF CLI for generating React/Vue bindings
- `scripts/`: Build and utility scripts

### Common Commands

| Task | Command |
|------|---------|
| Build C++ (macOS) | `npm run build:bridge:macos` |
| Build C++ (Android, bundled) | `npm run build:bridge:android` |
| Build C++ (Android, separate libs) | `npm run build:bridge:android:separate` |
| Build C++ (all platforms) | `npm run build:bridge:all` |
| Run all tests | `npm test` |
| Run integration tests | `cd integration_tests && npm run integration` |
| Run Dart tests | `cd webf && flutter test` |
| Lint code | `npm run lint` |
| Format code | `npm run format` |
| Clean build | `npm run build:clean` |

## 🔍 Code Navigation

### Search Strategies
- Use `Grep` for specific function/class names
- Use `Glob` for file patterns
- Batch related searches in parallel
- For cross-language features, search both C++ (.cc/.h) and Dart (.dart) files

### Common Patterns
- Function usage: `FunctionName\(`
- Class definition: `class ClassName`
- FFI exports: `WEBF_EXPORT_C`

## 📦 C++ Library Bundling

### Android Library Bundling

WebF supports two modes for bundling C++ libraries in Android builds:

#### Bundled Libraries (Default, Recommended)
```bash
npm run build:bridge:android              # Bundled QuickJS + dynamic STL (default)
npm run build:bridge:android:release      # Bundled QuickJS + dynamic STL (release)
npm run build:bridge:android:static-stl   # Bundled QuickJS + static STL
```

**Outputs:**
- `libwebf.so` - Contains WebF + QuickJS code bundled together
- `libc++_shared.so` - Android STL runtime (only with dynamic STL)

**Advantages:**
- Simpler deployment (fewer .so files)
- Better optimization (cross-library inlining)
- Reduced app size (no duplicate symbols)
- Easier debugging (single library)

#### Separate Libraries (Advanced)
```bash
npm run build:bridge:android:separate     # Separate QuickJS library
WEBF_SEPARATE_QUICKJS=true npm run build:bridge:android
```

**Outputs:**
- `libwebf.so` - WebF core library
- `libquickjs.so` - JavaScript engine (separate)
- `libc++_shared.so` - Android STL runtime

**Use Cases:**
- When you need to share QuickJS with other libraries
- For debugging library boundaries
- Advanced library management scenarios

### Build Options

| Flag/Environment | Description | Default |
|------------------|-------------|---------|
| `--static-quickjs` | Bundle QuickJS into webf library | Android: true, Others: false |
| `--static-stl` | Use static C++ standard library (Android) | false |
| `WEBF_SEPARATE_QUICKJS=true` | Build QuickJS as separate library | false |
| `ANDROID_STL=c++_static` | Set Android STL type | `c++_shared` |
| `--enable-log` | Enable debug logging | false |

### Android STL Options

| STL Type | Description | Libraries Required |
|----------|-------------|-------------------|
| `c++_shared` (default) | Dynamic C++ standard library | `libwebf.so` + `libc++_shared.so` |
| `c++_static` | Static C++ standard library | `libwebf.so` only |
| `system` | System C++ library (deprecated) | `libwebf.so` only |

## 🌉 Cross-Platform Development

### FFI Best Practices
- Always free allocated memory in Dart FFI
- Use `malloc.free()` for `toNativeUtf8()` allocations
- Track pointer ownership in callbacks
- Document memory ownership clearly
- Use RAII patterns in C++ where possible

### Thread Communication
- `PostToJs`: Execute on JS thread
- `PostToDart`: Return results to Dart isolate
- `PostToJsSync`: Synchronous execution (avoid when possible)

## 🧪 Testing

### Test Types
- **Unit Tests**: See folder-specific guides
- **Integration Tests**: See [Integration Development Guide](integration_tests/CLAUDE.md)
- **Flutter Widget Tests**: See [Dart Development Guide](webf/CLAUDE.md)

### Running Tests
```bash
# All tests
npm test

# Specific integration test
cd integration_tests && npm run integration -- specs/css/css-display/display.ts 

# Flutter tests
cd webf && flutter test

# Bridge unit tests
node scripts/run_bridge_unit_test.js
```

## 📦 WebF CLI

The CLI generates type-safe bindings between Flutter/Dart and JavaScript frameworks.

```bash
# Basic usage
webf codegen my-typings --flutter-package-src=../webf_package

# With auto-publish
webf codegen --flutter-package-src=../webf_package --publish-to-npm

# Custom registry
webf codegen --flutter-package-src=../webf_package --publish-to-npm --npm-registry=https://custom.registry.com/
```

## 🏢 Enterprise Features

WebF Enterprise is a closed-source product requiring subscription:

```yaml
dependencies:
  webf:
    hosted: https://dart.cloudsmith.io/openwebf/webf-enterprise/
    version: ^0.22.0
```

## 📊 WebF MCP Server

The MCP server provides dependency graph analysis:

### Key Features
- 8,244+ nodes across multiple languages
- Dependency analysis and impact assessment
- Code quality metrics
- Cross-language FFI analysis
- Architecture validation

### Example Usage
```bash
# Find a class
mcp__webf__get_node_by_name(name="WebFController")

# Analyze dependencies
mcp__webf__get_dependencies(node_name="RenderStyle", max_depth=2)

# Find code smells
mcp__webf__analyze_code_smells(god_class_threshold=20)
```

## 📝 Documentation Guidelines

### Writing Good Docs
1. Clarify that WebF builds Flutter apps, not web apps
2. Provide complete, runnable examples
3. Include WebFControllerManager setup in examples
4. Structure information hierarchically
5. Test all code examples

### Important Reminders
- Do what has been asked; nothing more, nothing less
- NEVER create files unless absolutely necessary
- ALWAYS prefer editing existing files
- Only create documentation when explicitly requested