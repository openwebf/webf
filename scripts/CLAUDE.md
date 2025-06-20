# WebF Scripts Documentation

## Type Generation Process

The WebF type generation system is composed of several interconnected tasks that generate TypeScript definitions from multiple sources:

### 1. Core Bridge Types (`merge-bridge-typings`)
- Scans all `.d.ts` files in `bridge/core/` directory
- Merges them into a single `bridge/typings/webf.d.ts` file
- Processes WebF-specific type annotations:
  - `DartImpl<T>` → `T`
  - `StaticMember<T>` → `T`
  - `StaticMethod<T>` → `T`
  - `SupportAsync<T>` → Generates both sync and async variants
  - `DependentsOnLayout<T>` → `T`
- Adds global declarations for `document` and `window`
- Creates a `webf` namespace containing all type exports

### 2. Polyfill Types (`generate-polyfill-typings`)
- Uses Rollup with `rollup-plugin-dts` to generate types from `bridge/polyfill/src`
- Outputs to `bridge/typings/polyfill.d.ts`
- Configuration in `bridge/polyfill/rollup.config.dts.js`
- Includes reference to `webf.d.ts` for accessing core types like `EventTarget`

### 3. Main Entry Point (`bridge/typings/index.d.ts`)
- References both `webf.d.ts` and `polyfill.d.ts`
- Re-exports polyfill module exports
- Provides a unified interface for all WebF types

## Key Scripts

### `generate_binding_code.js`
Runs the type generation pipeline:
```javascript
series(
  'merge-bridge-typings',     // Generate webf.d.ts from bridge/core
  'update-typings-version',   // Update package version
  'generate-bindings-code'    // Generate C++ binding code
)
```

### `generate_polyfill_bytecode.js`
Includes polyfill type generation:
```javascript
series(
  'generate-bindings-code',
  'compile-build-tools',
  'compile-polyfill',
  'generate-polyfill-typings',  // Generate polyfill.d.ts
  'generate-polyfill-bytecode'
)
```

## Important Notes

1. **DO NOT manually edit generated files**:
   - `bridge/typings/webf.d.ts` - Generated from bridge/core/*.d.ts
   - `bridge/typings/polyfill.d.ts` - Generated from polyfill TypeScript source

2. **Global declarations**: The `document` and `window` globals are added in the `merge-bridge-typings` task in `tasks.js`

3. **Type transformations**: The system automatically handles WebF-specific type annotations and generates appropriate TypeScript types

4. **Testing**: Run tests with `npm test` in the `bridge/typings` directory to ensure types compile correctly without DOM lib

## Common Tasks

- **Regenerate all types**: `node scripts/generate_binding_code.js`
- **Generate only polyfill types**: `cd bridge/typings && npm run generate`
- **Test typings**: `cd bridge/typings && npm test`