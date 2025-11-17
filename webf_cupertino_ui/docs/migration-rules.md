# WebF Cupertino UI – Global Migration Rules (to React)

This document defines consistent rules to migrate WebF custom elements and TypeScript typings into React components using the generator in `@openwebf/react-core-ui`.

The goals:
- Keep lib/src/*.d.ts as the single source of truth for component attributes, methods, and events.
- Preserve WebF semantics (hyphen-case attributes) in typings.
- Generate React-friendly components with camelCase props and idiomatic event handlers.

## 1) Source Typings (lib/src/*.d.ts)

- Always define component props with hyphen-case names when appropriate.
  - Example: `'pressed-opacity'?: string;`, `'disabled-color'?: string;`
- Keep standard names as-is when they are not hyphenated (e.g., `variant?: string;`, `size?: string;`, `disabled?: boolean;`).
- Define events in a dedicated interface `ComponentEvents` with proper CustomEvent payload typing.
  - Example: `input: CustomEvent<string>;`, `tabchange: CustomEvent<number>;`, `click: Event;`
- If the component exposes callable methods, list them in a dedicated `ComponentMethods` section (or document them to be added to the element type).
- Use the shared aliases `type int = number; type double = number;` from `lib/src/global.d.ts` where needed.
- After adding or updating a `.d.ts` file, run `webf codegen --dart-only` from the package root to regenerate `*_bindings_generated.dart` before implementing or changing the Dart `WidgetElement` so the Dart API stays in sync with the typings.

Example (Button):
```ts
interface FlutterCupertinoButtonProperties {
  variant?: string;
  size?: string;
  disabled?: boolean;
  'pressed-opacity'?: string;
  'disabled-color'?: string;
}

interface FlutterCupertinoButtonEvents {
  click: Event;
}
```

## 2) React Component Generation Rules

Use `createWebFComponent` from `@openwebf/react-core-ui` to create React wrappers. The generator should:

- Expose React props in camelCase where hyphen-case exists in the typings.
  - Map camelCase → hyphen-case via `attributeMap`.
  - List props in `attributeProps` to auto-sync as attributes.
- Keep boolean props (e.g., `disabled`) as booleans. Presence semantics are handled by the wrapper.
- Map DOM events to `onX` React handlers with correct typing.
  - Example: `click` → `onClick`, `input` → `onInput`, `change` → `onChange`.
  - For CustomEvent<T>, pass the DOM event object; consumers can access `event.detail`.
- If methods exist, type them on the element interface via `WebFElementWithMethods<...>` and let apps call them with `ref`.

Template:
```ts
import React from 'react';
import { createWebFComponent, WebFElementWithMethods } from '@openwebf/react-core-ui';

// 1) Props interface (React-friendly camelCase props)
export interface ComponentProps {
  /* copy comments from .d.ts and convert hyphen-case to camelCase */
  exampleProp?: string;           // ← camelCase
  'example-prop'?: never;         // (optional) prevent direct hyphen-case usage in React
  onExample?: (event: CustomEvent<string>) => void;
  id?: string;
  className?: string;
  style?: React.CSSProperties;
  children?: React.ReactNode;
}

// 2) Element interface (methods if any)
export interface ComponentElement extends WebFElementWithMethods<{
  // methodName(args...): returnType
}> {}

// 3) Factory
export const Component = createWebFComponent<ComponentElement, ComponentProps>({
  tagName: 'custom-tag-name',
  displayName: 'Component',
  attributeProps: [
    // List camelCase prop keys that correspond to attributes
    'exampleProp',
  ],
  attributeMap: {
    // Map camelCase prop → hyphen-case attribute
    exampleProp: 'example-prop',
  },
  events: [
    { propName: 'onExample', eventName: 'example', handler: (cb) => (e) => cb(e as CustomEvent) },
  ],
  defaultProps: {},
});
```

## 3) Property Mapping Conventions

- Hyphen-case properties in .d.ts become camelCase React props.
  - `'pressed-opacity'` → `pressedOpacity`
  - `'disabled-color'` → `disabledColor`
- Keep direct names when already natural: `variant`, `size`, `disabled`, `value`, `placeholder`.
- Numeric-like values may remain `string` in the DOM; the underlying element performs parsing. Type React props to match expected developer ergonomics:
  - If the DOM expects string but developer ergonomics favor string as well (e.g., opacity), use `string`.
  - If semantically numeric (e.g., `iconSize`, `height`), you can accept `string | number` in React and coerce to string.

## 4) Events Mapping Conventions

- Use `onClick` for `click`.
- Use `onInput` for `input` (payload in `event.detail`).
- Use `onChange` for `change` (payload in `event.detail`).
- For custom names, convert to `onXxx`: `tabchange` → `onTabchange` (or prefer `onTabChange` if you normalize names in the generator; keep consistent across the library).
- Event handler receives the native DOM `Event` or `CustomEvent<T>`.

## 5) Methods Exposure (via ref)

- If a component has methods (`show`, `hide`, `switchTab`, `clear`, etc.), add them to the element type:
  - Example: `export interface FooElement extends WebFElementWithMethods<{ show(opts: any): void; hide(): void; }>{}`
- Consumers call them via a ref to the React component:
```ts
const ref = useRef<FooElement>(null);
useEffect(() => { ref.current?.show({ title: 'Hi' }); }, []);
return <Foo ref={ref} />;
```

## 6) Children & Slots

- If a component has sub-components (slots), keep them as distinct custom tags and provide wrappers for each.
  - Example: `flutter-cupertino-input-prefix`, `flutter-cupertino-input-suffix` → React wrappers `FlutterCupertinoInputPrefix`, `FlutterCupertinoInputSuffix`.
- Document the composition pattern in the component README (e.g., which children are considered header/footer/prefix/suffix).

## 7) Styling Guidance

- Encourage `className` and `style` props on the React wrapper. They apply to the host element.
- The underlying element may read CSS (padding, min-height, border-radius, text-align, background-color). Document per component.

### Layout Responsibilities

- Keep migrated custom elements as layout-neutral as possible: they should render the underlying Flutter widget, not impose additional layout (no extra `Column`, `Expanded`, page sections, etc.).
- Let the surrounding DOM/CSS control layout (width, height, margins, flex/grid placement). Use `renderStyle` only to adapt to layout, not to introduce new structure.
- If a legacy implementation bundled layout (for example, segmented control + content column), move that composition into higher-level widgets/pages or React usage examples instead of the core custom element.
- For content created from standard WebF/HTML elements, avoid manually reading their width/height to drive Flutter layout; rely on Flutter defaults and CSS layout, and restrict `renderStyle` usage to styling concerns (typography, colors, simple spacing) where necessary.

## 8) Documentation Pattern (lib/src/<component>.md)

For each migrated component, you must create `lib/src/<component>.md` alongside the `.d.ts` and Dart files; migrations are not considered complete without this doc.

Each `lib/src/<component>.md` should contain React-only usage:
- Import statement for the generated React component
- Quick start snippet
- Props examples (variants, sizes, states)
- Event example
- Styling example
- Notes (Flutter differences, width/padding interactions, etc.)

Use `lib/src/button.md` as a reference and keep structure consistent across all components.

## 9) Checklist for Each Component

1. Ensure .d.ts uses hyphen-case for non-standard attributes.
2. Add/verify events interface with correct payload typing.
3. If methods exist, list them and plan element typing.
4. Run `webf codegen --dart-only` so Dart bindings reflect the latest typings.
5. Implement/verify Dart component maps those attributes/events/methods using the generated bindings.
6. Generate React wrapper with:
   - attributeProps and attributeMap (camelCase → hyphen-case)
   - events mapping (onX → DOM event)
   - defaultProps as needed
7. Author React usage doc in `lib/src/<component>.md` and keep it in sync with the actual API before merging.
   - Whenever you change a component’s attributes, events, or behavior, update the corresponding `lib/src/<component>.md` in the same PR so docs always reflect the implementation.

## 10) JS vs Flutter State Ownership

- Treat the WebF `WidgetElement` subclass as the single source of truth for any state that is observable or controlled from JavaScript (attributes, properties, method-driven state).
- Store JS-visible state as fields on the `WidgetElement`, not only inside `WebFWidgetElementState`. The `State` object may hold transient/UI-only state (animations, focus flags, controllers) but should always rebuild from the element’s fields.
- When JavaScript updates state (via attributes or properties), update the element fields first in the generated/hand-written setters and then notify `state` (`state?.setState(() {})` or dedicated helpers).
- When Flutter-side interactions change JS-visible state (like tab index), update the element fields and dispatch the appropriate DOM events so React/JS can observe the change.

## 11) Common Pitfalls

- Boolean attributes: DOM presence implies true. Ensure the wrapper sets/removes attribute correctly for `true/false`.
- Hyphen-case vs camelCase: Keep hyphen-case in .d.ts; expose camelCase in React via `attributeMap`.
- CustomEvent typing: When passing to callbacks, use `CustomEvent<any>` or a precise generic if known.
- Fixed width + padding: Some components remove internal padding if width is fixed—document it.
- Over-structuring: avoid wrapping controls in layout widgets that applications can provide themselves; keep the core element focused on behavior, styling hooks, and state/events.

---

Following these rules keeps the WebF custom elements authoritative while offering a clean, predictable React developer experience.
