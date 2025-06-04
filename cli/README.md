# WebF CLI

A command-line tool for generating Flutter classes and Vue/React component declaration files for WebF projects.

## Installation

```bash
npm install -g @openwebf/webf
```

## Usage

The WebF CLI provides three main commands:

### 1. Initialize Typings

Initialize WebF typings in your project:

```bash
webf init <target-directory>
```

This will create the necessary type definition files in the specified directory.

### 2. Create a New Project

Create a new Vue or React project:

```bash
webf create <target-directory> --framework <framework> --package-name <package-name>
```

Options:
- `--framework`: Choose between 'vue' or 'react'
- `--package-name`: Specify your package name

Example:
```bash
webf create my-webf-app --framework react --package-name @myorg/my-webf-app
```

### 3. Generate Code

Generate Flutter classes and component declaration files:

```bash
webf generate <dist-path> --flutter-package-src <flutter-source> --framework <framework>
```

Options:
- `--flutter-package-src`: Path to your Flutter package source
- `--framework`: Choose between 'vue' or 'react'

Example:
```bash
webf generate ./src --flutter-package-src ./flutter_package --framework react
```

## Implementation Details

### Type System

The CLI uses a sophisticated type system to handle various data types:

- Basic Types:
  - `string` (DOM String)
  - `number` (int/double)
  - `boolean`
  - `any`
  - `void`
  - `null`
  - `undefined`

- Complex Types:
  - Arrays: `Type[]`
  - Functions: `Function`
  - Promises: `Promise<Type>`
  - Custom Events: `CustomEvent`
  - Layout-dependent types: `DependentsOnLayout<Type>`

### Naming Conventions and File Structure

#### Interface Naming Patterns

The CLI follows specific patterns for interface naming:

1. **Component Interfaces**:
   - Properties interface: `{ComponentName}Properties`
   - Events interface: `{ComponentName}Events`
   - Example: `ButtonProperties`, `ButtonEvents`

2. **Generated File Names**:
   - React components: `{componentName}.tsx`
   - Vue components: `{componentName}.vue`
   - Flutter classes: `{componentName}.dart`
   - Type definitions: `{componentName}.d.ts`

3. **Name Transformations**:
   - Component name extraction:
     - From `{Name}Properties` → `{Name}`
     - From `{Name}Events` → `{Name}`
   - Example: `ButtonProperties` → `Button`

#### Generated Component Names

1. **React Components**:
   - Tag name: `<{ComponentName} />`
   - File name: `{componentName}.tsx`
   - Example: `ButtonProperties` → `<Button />` in `button.tsx`

2. **Vue Components**:
   - Tag name: `<{component-name} />`
   - File name: `{componentName}.vue`
   - Example: `ButtonProperties` → `<button-component />` in `button.vue`

3. **Flutter Classes**:
   - Class name: `{ComponentName}`
   - File name: `{componentName}.dart`
   - Example: `ButtonProperties` → `Button` class in `button.dart`

#### Type Definition Files

1. **File Location**:
   - React: `src/components/{componentName}.d.ts`
   - Vue: `src/components/{componentName}.d.ts`
   - Flutter: `lib/src/{componentName}.dart`

2. **Interface Structure**:
   ```typescript
   interface {ComponentName}Properties {
     // Properties
   }

   interface {ComponentName}Events {
     // Events
   }
   ```

3. **Component Registration**:
   - React: Exported in `index.ts`
   - Vue: Registered in component declaration file
   - Flutter: Exported in library file

### Component Generation

#### React Components
- Generates TypeScript React components with proper type definitions
- Handles event bindings with proper event types
- Supports async methods with Promise-based return types
- Converts event names to React conventions (e.g., `onClick`, `onChange`)

#### Vue Components
- Generates Vue component type declarations
- Supports Vue's event system
- Handles props and events with proper TypeScript types
- Generates component registration code

#### Flutter Classes
- Generates Dart classes with proper type mappings
- Handles method declarations with correct parameter types
- Supports async operations
- Generates proper event handler types

### Type Analysis

The CLI uses TypeScript's compiler API to analyze and process type definitions:

1. Parses TypeScript interface declarations
2. Analyzes class relationships and inheritance
3. Processes method signatures and parameter types
4. Handles union types and complex type expressions
5. Generates appropriate type mappings for each target platform

### Code Generation Conventions

1. **Naming Conventions**:
   - Properties: camelCase
   - Events: camelCase with 'on' prefix
   - Methods: camelCase
   - Classes: PascalCase

2. **Type Mapping**:
   - TypeScript → Dart:
     - `string` → `String`
     - `number` → `int`/`double`
     - `boolean` → `bool`
     - `any` → `dynamic`
     - `void` → `void`

   - TypeScript → React/Vue:
     - `string` → `string`
     - `number` → `number`
     - `boolean` → `boolean`
     - `any` → `any`
     - `void` → `void`

3. **Event Handling**:
   - React: `EventHandler<SyntheticEvent<Element>>`
   - Vue: `Event`/`CustomEvent`
   - Flutter: `EventHandler<Event>`

## Project Structure

After running the commands, your project will have the following structure:

### React Project
```
my-webf-app/
├── src/
│   ├── components/
│   │   ├── button.tsx
│   │   ├── button.d.ts
│   │   └── index.ts
│   ├── utils/
│   │   └── createComponent.ts
│   └── index.ts
├── package.json
├── tsconfig.json
└── tsup.config.ts
```

### Vue Project
```
my-webf-app/
├── src/
│   ├── components/
│   │   ├── button.vue
│   │   └── button.d.ts
├── package.json
└── tsconfig.json
```

## Dependencies

The CLI automatically installs necessary dependencies for your chosen framework:
- For React: React and related type definitions
- For Vue: Vue and related type definitions

## Development

### Building from Source

```bash
npm install
npm run build
```

### Testing

```bash
npm test
```

## License

ISC
