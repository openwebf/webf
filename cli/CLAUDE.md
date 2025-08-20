# WebF CLI Development Guide

## Overview
The WebF CLI is a code generation tool that creates type-safe bindings between Flutter/Dart and JavaScript frameworks (React, Vue). It analyzes TypeScript definition files and generates corresponding Dart classes and JavaScript/TypeScript components.

## Architecture

### Core Components
- `analyzer.ts` - TypeScript AST analysis with multi-level caching
- `generator.ts` - Orchestrates code generation for Dart, React, and Vue
- `dart.ts` - Dart code generation from TypeScript definitions
- `react.ts` - React component generation
- `vue.ts` - Vue component generation
- `commands.ts` - CLI command implementations
- `logger.ts` - Logging utility without external dependencies

### Key Features
- Multi-level caching for performance optimization
- Parallel file processing
- Type-safe attribute handling with automatic conversions
- Comprehensive error handling and recovery

## Code Generation Patterns

### TypeScript to Dart Type Mapping
```typescript
// Boolean attributes are always non-nullable in Dart
interface Props {
  open?: boolean;  // Generates: bool get open;
  title?: string;  // Generates: String? get title;
}
```

### Attribute Type Conversion
HTML attributes are always strings, so the generator includes automatic type conversion:
- Boolean: `value == 'true' || value == ''`
- Integer: `int.tryParse(value) ?? 0`
- Double: `double.tryParse(value) ?? 0.0`
- String: Direct assignment

## Performance Optimizations

### Caching Strategy
1. **Source File Cache**: Parsed TypeScript AST files are cached
2. **Type Conversion Cache**: Frequently used type conversions are cached
3. **File Content Cache**: File contents are cached to detect changes

### Batch Processing
Files are processed in batches for optimal parallelism:
```typescript
await processFilesInBatch(items, batchSize, processor);
```

## Testing Guidelines

### Test Structure
- Unit tests for all core modules
- Mock file system operations before module imports
- Test coverage threshold: 70%

### Running Tests
```bash
npm test                    # Run all tests
npm test -- test/analyzer.test.ts  # Run specific test
npm run test:coverage       # Run with coverage report
```

### Mock Patterns
For modules that read files at load time:
```typescript
jest.mock('fs');
import fs from 'fs';
const mockFs = fs as jest.Mocked<typeof fs>;
mockFs.readFileSync = jest.fn().mockImplementation((path) => {
  // Return appropriate content
});
// Now import the module
import { moduleUnderTest } from './module';
```

## CLI Usage

### Commands
```bash
# Generate code from TypeScript definitions (auto-creates project if needed)
webf codegen <output-dir> --flutter-package-src=<path> [--framework=react|vue] [--package-name=<name>] [--publish-to-npm] [--npm-registry=<url>]

# Create a new project without code generation
webf codegen <output-dir> [--framework=react|vue] [--package-name=<name>]

# Generate and publish to npm
webf codegen <output-dir> --flutter-package-src=<path> --publish-to-npm

# Generate and publish to custom registry
webf codegen <output-dir> --flutter-package-src=<path> --publish-to-npm --npm-registry=https://custom.registry.com/
```

### Auto-creation Behavior
The `generate` command now automatically detects if a project needs to be created:
- If required files (package.json, global.d.ts, tsconfig.json) are missing, it will create a new project
- If framework or package name are not provided, it will prompt interactively
- If an existing project is detected, it will use the existing configuration
- Framework can be auto-detected from existing package.json dependencies

### Metadata Synchronization
When creating typing projects, the CLI automatically synchronizes metadata from the Flutter package:
- Reads `pubspec.yaml` from the Flutter package source directory
- Extracts version and description information
- Applies this metadata to the generated `package.json` files
- Ensures typing packages match the same version as the Flutter package

### Automatic Build
After code generation, the CLI automatically runs `npm run build` if a build script is present in the package.json. This ensures the generated package is immediately ready for use or publishing. The build process:
- Checks for the presence of a `build` script in package.json
- Runs the build command if available
- Continues successfully even if the build fails (with a warning)
- Provides clear console output about the build status

### NPM Publishing
The CLI supports automatic npm publishing with the following features:
- **--publish-to-npm**: Automatically publishes the generated package to npm (build is run automatically)
- **--npm-registry**: Specify a custom npm registry URL (defaults to https://registry.npmjs.org/)
- **Interactive publishing**: If not using the --publish-to-npm flag, the CLI will ask if you want to publish after generation
- **Registry configuration**: When choosing to publish interactively, you can specify a custom registry URL
- Checks if user is logged in before attempting to publish
- Temporarily sets and resets registry configuration when custom registry is used

Requirements for publishing:
- Must be logged in to npm (`npm login`)
- Package must have a valid package.json
- Package will be built automatically before publishing (if build script exists)

Publishing workflow:
1. If `--publish-to-npm` is not specified, CLI prompts after successful generation
2. If user chooses to publish, CLI asks for registry URL (optional)
3. Validates npm login status
4. Publishes to specified registry (no need to build separately)

### Output Directory Behavior
- Dart files are generated in the Flutter package source directory
- React/Vue files are generated in the specified output directory
- If no output directory is specified, a temporary directory is created
- Temporary directories are created in the system temp folder with prefix `webf-typings-`
- When using temporary directories, the path is displayed at the end of generation
- Paths can be absolute or relative to current working directory

### Generated Files Structure
When running `dartGen`:
- Dart binding files are generated with `_bindings_generated.dart` suffix
- Original `.d.ts` files are copied to the output directory maintaining their structure
- An `index.d.ts` file is generated with:
  - TypeScript triple-slash references to all `.d.ts` files
  - ES module exports for all type definitions
  - Package metadata from `pubspec.yaml` in documentation comments
- Directory structure from source is preserved in the output

## Development Workflow

### Adding New Features
1. Update TypeScript interfaces/types
2. Implement feature with tests
3. Update templates if needed
4. Ensure all tests pass
5. Update this documentation

### Debugging
Use the logger for debugging:
```typescript
import { debug, info, warn, error } from './logger';
debug('Processing file:', filename);
```

### Template Modification
Templates are in `/templates/*.tpl`. When modifying:
1. Update the template file
2. Update the corresponding generator function
3. Ensure generated code follows style guidelines

## Common Issues and Solutions

### Issue: Boolean attributes treated as strings
**Solution**: Use `generateAttributeSetter` which handles type conversion

### Issue: Null type handling
**Solution**: Check for literal types containing null:
```typescript
if (type.kind === ts.SyntaxKind.LiteralType) {
  const literalType = type as ts.LiteralTypeNode;
  if (literalType.literal.kind === ts.SyntaxKind.NullKeyword) {
    return FunctionArgumentType.null;
  }
}
```

### Issue: File changes not detected
**Solution**: Clear caches before generation:
```typescript
clearCaches();
```

## Code Style
- Use async/await for asynchronous operations
- Implement proper error handling with try-catch
- Add descriptive error messages
- Use TypeScript strict mode
- Follow existing patterns in the codebase