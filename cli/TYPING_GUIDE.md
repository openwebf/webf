# WebF TypeScript Definition Files (.d.ts) Writing Guide

This guide explains how to write TypeScript definition files (.d.ts) for WebF custom elements that will be parsed by the WebF CLI to generate Dart bindings and React/Vue components.

## Basic Structure

Each WebF custom element should have two interfaces:
1. `<ComponentName>Properties` - Defines the element's properties/attributes
2. `<ComponentName>Events` - Defines the element's events

The component name is derived by removing the "Properties" or "Events" suffix.

## Interface Naming Convention

```typescript
// For a component named "FlutterCupertinoButton"
interface FlutterCupertinoButtonProperties {
  // properties...
}

interface FlutterCupertinoButtonEvents {
  // events...
}
```

## Properties Interface

### Basic Property Types

The CLI supports the following TypeScript types that map to Dart types:

- `string` → `String` (Dart)
- `number` → `double` (Dart) 
- `int` → `int` (Dart) - Use type alias `type int = number`
- `boolean` → `bool` (Dart)
- `any` → `dynamic` (Dart)
- `void` → `void` (Dart)

### Property Syntax

```typescript
interface FlutterCupertinoButtonProperties {
  // Required property
  variant: string;
  
  // Optional property (use ? modifier)
  size?: string;
  
  // Boolean property (always non-nullable in Dart)
  disabled?: boolean;
  
  // Kebab-case properties (for HTML attributes)
  'pressed-opacity'?: string;
}
```

### Important Rules for Properties

1. **Boolean properties are always non-nullable** in the generated Dart code, even if marked as optional with `?`
2. **Kebab-case properties** should be quoted (e.g., `'pressed-opacity'`)
3. **Optional properties** use the `?` modifier and will be nullable in Dart (except booleans)
4. **Methods in Properties interface** become instance methods on the element

### Methods in Properties

Methods defined in the Properties interface become callable methods on the element:

```typescript
interface FlutterCupertinoInputProperties {
  // Properties
  val?: string;
  placeholder?: string;
  
  // Methods
  getValue(): string;
  setValue(value: string): void;
  focus(): void;
  blur(): void;
}
```

## Events Interface

Events are defined as properties of the Events interface, where:
- Property name = event name
- Property type = event type (usually `Event` or `CustomEvent<T>`)

```typescript
interface FlutterCupertinoButtonEvents {
  // Standard DOM event
  click: Event;
}

interface FlutterCupertinoInputEvents {
  // CustomEvent with string detail
  input: CustomEvent<string>;
  submit: CustomEvent<string>;
}

interface FlutterCupertinoSwitchEvents {
  // CustomEvent with boolean detail
  change: CustomEvent<boolean>;
}
```

### Event Type Guidelines

- Use `Event` for standard DOM events
- Use `CustomEvent<T>` for custom events with data:
  - `CustomEvent<string>` for string data
  - `CustomEvent<number>` for numeric data
  - `CustomEvent<boolean>` for boolean data

## Attribute Handling

The CLI automatically handles type conversion for HTML attributes:

1. **Boolean attributes**: 
   - HTML: `disabled` or `disabled="true"` → Dart: `true`
   - HTML: `disabled="false"` or absent → Dart: `false`

2. **Numeric attributes**:
   - HTML: `maxlength="100"` → Dart: `100` (int)
   - HTML: `opacity="0.5"` → Dart: `0.5` (double)

3. **String attributes**: Passed through as-is

## Complete Example

Here's a complete example for a switch component:

```typescript
// Type alias for int (optional, for clarity)
type int = number;

interface FlutterCupertinoSwitchProperties {
  // Boolean property (non-nullable in Dart)
  checked?: boolean;
  
  // Boolean property 
  disabled?: boolean;
  
  // Kebab-case string properties
  'active-color'?: string;
  'inactive-color'?: string;
}

interface FlutterCupertinoSwitchEvents {
  // CustomEvent with boolean detail
  change: CustomEvent<boolean>;
}
```

## Special Types and Features

### Arrays
Arrays are supported but rarely used in element properties:
```typescript
interface ExampleProperties {
  items?: string[];  // Generates String[]? in Dart
}
```

### Object Types
Reference other interfaces for complex types:
```typescript
interface ItemData {
  id: string;
  label: string;
}

interface ListProperties {
  selectedItem?: ItemData;
}
```

## Best Practices

1. **Keep interfaces simple** - Properties should represent HTML attributes or simple methods
2. **Use optional properties** for all attributes that have default values
3. **Document complex properties** with JSDoc comments (these are preserved in generated code)
4. **Follow naming conventions**:
   - PascalCase for interface names
   - camelCase for property names (except kebab-case HTML attributes)
   - Properties interface name must end with "Properties"
   - Events interface name must end with "Events"

## What to Avoid

1. **Don't use complex union types** - Keep types simple
2. **Don't use generics** in property types (except CustomEvent<T>)
3. **Don't use function types** as properties - Define them as methods instead
4. **Don't forget the Events interface** - Even if there are no events, include an empty interface

## Testing Your Definitions

After writing your .d.ts file:

1. Run the CLI generator to ensure it parses correctly
2. Check the generated Dart bindings match your expectations
3. Verify the React/Vue components have the correct prop types

## File Naming

Name your .d.ts files to match the Dart file:
- `button.dart` → `button.d.ts`
- `switch.dart` → `switch.d.ts`
- `tab.dart` → `tab.d.ts`