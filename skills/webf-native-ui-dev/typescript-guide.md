# TypeScript Definition Guide for Hybrid UI Components

Complete reference for writing `.d.ts` files that will be parsed by the WebF CLI to generate Dart bindings and React/Vue components.

## Interface Naming Convention

**Required pattern:**
```typescript
interface <ComponentName>Properties { ... }
interface <ComponentName>Events { ... }
```

The component name is automatically derived by removing the "Properties" or "Events" suffix.

## Type Mappings

| TypeScript Type | Dart Type | Notes |
|----------------|-----------|-------|
| `string` | `String` | Nullable if optional |
| `number` | `double` | For floating point |
| `int` | `int` | Use `type int = number` alias |
| `boolean` | `bool` | **Always non-nullable** |
| `any` | `dynamic` | Avoid when possible |
| `void` | `void` | For methods only |

## Properties Interface

```typescript
interface MyComponentProperties {
  // Required string property
  id: string;

  // Optional string property (nullable in Dart)
  title?: string;

  // Boolean property (non-nullable in Dart even with ?)
  disabled?: boolean;

  // Numeric properties
  width?: number;      // → double in Dart
  maxCount?: int;      // → int in Dart

  // Kebab-case properties (quoted)
  'pressed-opacity'?: string;
  'active-color'?: string;

  // Complex data as JSON strings
  items?: string;  // Will be parsed with jsonDecode()

  // Methods
  focus(): void;
  getValue(): string;
}
```

## Events Interface

```typescript
interface MyComponentEvents {
  // Standard DOM event (no data)
  click: Event;

  // CustomEvent with typed data
  change: CustomEvent<string>;
  select: CustomEvent<number>;
  toggle: CustomEvent<boolean>;
}
```

## Complete Example

```typescript
/**
 * A text input component with validation.
 */
type int = number;

interface MyInputProperties {
  value?: string;
  placeholder?: string;
  maxLength?: int;
  disabled?: boolean;

  focus(): void;
  blur(): void;
  clear(): void;
}

interface MyInputEvents {
  input: CustomEvent<string>;
  submit: CustomEvent<string>;
  focus: Event;
  blur: Event;
}
```

## Best Practices

- ✅ Use JSDoc comments for documentation
- ✅ Document default values with `@default`
- ✅ Keep event names simple and descriptive
- ✅ Use kebab-case for HTML-style attributes
- ✅ Group related properties with comments
- ❌ Don't use arrays or objects (use JSON strings)
- ❌ Don't use arrow functions for methods

## Resources

- **WebF CLI Guide**: [../../cli/CLAUDE.md](../../cli/CLAUDE.md)
- **CLI Typing Guide**: [../../cli/TYPING_GUIDE.md](../../cli/TYPING_GUIDE.md)
- **Example Components**: [../../native_uis/webf_cupertino_ui/lib/src/](../../native_uis/webf_cupertino_ui/lib/src/)
