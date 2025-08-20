# WebF CLI

A powerful code generation tool for WebF that creates type-safe bindings between Flutter/Dart and JavaScript frameworks (React, Vue). It analyzes TypeScript definition files and generates corresponding Dart classes and JavaScript/TypeScript components.

## Installation

```bash
npm install -g @openwebf/webf
```

## Usage

### Generate Code

The `webf codegen` command generates Dart abstract classes and React/Vue components from TypeScript definitions. It automatically creates a project if needed.

```bash
webf codegen [output-dir] [options]
```

#### Arguments:
- `output-dir`: Path to output generated files (default: ".")

#### Options:
- `--flutter-package-src <path>`: Flutter package source path containing TypeScript definitions
- `--framework <framework>`: Target framework - 'react' or 'vue'
- `--package-name <name>`: Package name for the webf typings
- `--publish-to-npm`: Automatically publish the generated package to npm
- `--npm-registry <url>`: Custom npm registry URL (defaults to https://registry.npmjs.org/)

#### Examples:

**Generate code with auto-creation of project:**
```bash
# Generate React components from Flutter package
webf codegen my-typings --flutter-package-src=../webf_cupertino_ui --framework=react

# Generate Vue components with custom package name
webf codegen my-vue-app --flutter-package-src=./flutter_pkg --framework=vue --package-name=@myorg/webf-vue

# Use temporary directory (auto-created)
webf codegen --flutter-package-src=../webf_cupertino_ui
```

**Create a new project without code generation:**
```bash
# Create React project structure
webf codegen my-project --framework=react --package-name=my-webf-react

# Create Vue project structure  
webf codegen my-project --framework=vue --package-name=my-webf-vue
```

**Generate and publish to npm:**
```bash
# Publish to default npm registry
webf codegen my-typings --flutter-package-src=../webf_ui --publish-to-npm

# Publish to custom registry
webf codegen my-typings --flutter-package-src=../webf_ui --publish-to-npm --npm-registry=https://custom.registry.com/
```

### Interactive Mode

If you don't provide all required options, the CLI will prompt you interactively:

```bash
webf codegen my-app
# CLI will ask:
# - Which framework would you like to use? (react/vue)
# - What is your package name?
# - Would you like to publish this package to npm?
```

## Key Features

### 1. Auto-creation
The CLI automatically detects if a project needs to be created based on the presence of required files (package.json, global.d.ts, tsconfig.json).

### 2. Flutter Package Detection
When `--flutter-package-src` is not provided, the CLI searches for a Flutter package in the current directory or parent directories by looking for `pubspec.yaml`.

### 3. Metadata Synchronization
The CLI reads version and description from the Flutter package's `pubspec.yaml` and applies them to the generated `package.json`.

### 4. Automatic Build
After code generation, the CLI automatically runs `npm run build` if a build script exists in the package.json.

### 5. Framework Detection
For existing projects, the CLI can auto-detect the framework from package.json dependencies.

### 6. TypeScript Environment Validation
The CLI validates that the Flutter package has proper TypeScript configuration:
- Checks for `tsconfig.json`
- Verifies `.d.ts` files exist
- Offers to create `tsconfig.json` if missing

## Generated Project Structure

### React Project
```
my-webf-app/
├── src/
│   ├── components/
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── ...
│   ├── utils/
│   │   └── createComponent.ts
│   └── index.ts
├── package.json
├── tsconfig.json
├── tsup.config.ts
├── global.d.ts
└── .gitignore
```

### Vue Project
```
my-webf-app/
├── src/
│   ├── components/
│   │   ├── Button.vue
│   │   ├── Input.vue
│   │   └── ...
│   └── index.ts
├── package.json
├── tsconfig.json
├── global.d.ts
└── .gitignore
```

### Flutter Package (Generated Dart Files)
```
flutter_package/
├── lib/
│   ├── src/
│   │   ├── button_bindings_generated.dart
│   │   ├── input_bindings_generated.dart
│   │   └── ...
│   └── widgets.dart
└── pubspec.yaml
```

## Type System

The CLI handles comprehensive type mapping between TypeScript and Dart:

### Basic Types
- `string` → `String` (Dart) / `string` (JS)
- `number` → `int`/`double` (Dart) / `number` (JS)
- `boolean` → `bool` (Dart) / `boolean` (JS)
- `any` → `dynamic` (Dart) / `any` (JS)
- `void` → `void`
- `null` → `null`
- `undefined` → handled specially

### Complex Types
- Arrays: `Type[]` → `List<Type>` (Dart)
- Functions: Proper signature conversion
- Promises: `Promise<Type>` → `Future<Type>` (Dart)
- Union types: Handled with appropriate conversions
- Custom types: Preserved with proper imports

### Attribute Type Conversion
HTML attributes are always strings, so the generator includes automatic type conversion:
- Boolean: `value == 'true' || value == ''`
- Integer: `int.tryParse(value) ?? 0`
- Double: `double.tryParse(value) ?? 0.0`
- String: Direct assignment

## Performance Optimizations

The CLI implements several performance optimizations:

### Multi-level Caching
1. **Source File Cache**: Parsed TypeScript AST files
2. **Type Conversion Cache**: Frequently used type conversions
3. **File Content Cache**: Detect changes efficiently

### Parallel Processing
Files are processed in batches for optimal performance, maximizing CPU utilization.

## Development

### Prerequisites
- Node.js >= 14
- npm or yarn

### Building from Source
```bash
git clone https://github.com/openwebf/webf
cd webf/cli
npm install
npm run build
```

### Running Tests
```bash
npm test                    # Run all tests
npm test -- --coverage      # Run with coverage
npm test -- analyzer.test   # Run specific test file
```

### Development Workflow
```bash
# Make changes to source files
npm run build    # Compile TypeScript
npm test         # Run tests
npm link         # Link for local testing
```

## Troubleshooting

### Common Issues

**Missing TypeScript definitions:**
- Ensure your Flutter package has `.d.ts` files in the `lib/` directory
- Create a `tsconfig.json` in your Flutter package root

**Build failures:**
- Check that all dependencies are installed: `npm install`
- Verify TypeScript compilation: `npm run build`

**Publishing errors:**
- Ensure you're logged in to npm: `npm login`
- Verify package name availability
- Check registry URL if using custom registry

## License

ISC