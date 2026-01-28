# WebF Lucide Icons

Lucide icons for WebF applications.

It wraps [`lucide_icons_flutter`](https://pub.dev/packages/lucide_icons_flutter) as a custom HTML
element (`<flutter-lucide-icon>`), so you can use 1600+ Lucide icons in your WebF app with full
native Flutter rendering.

Browse all available icons at [lucide.dev/icons](https://lucide.dev/icons).

## React / Vue (npm) — Install & Use

These npm packages are for **WebF JavaScript developers**. They provide framework integrations and
TypeScript types for the Lucide icon custom element rendered by Flutter.

> This is not a "run in the browser" icon library. You still need a Flutter app with WebF + this
> Flutter package installed (see the Flutter section below).

### Install

React:

```bash
npm install @openwebf/react-lucide-icons
```

Vue:

```bash
npm install @openwebf/vue-lucide-icons
```

### React usage (from `@openwebf/react-lucide-icons`)

```tsx
import React from 'react';
import { FlutterLucideIcon, LucideIcons } from '@openwebf/react-lucide-icons';

export function App() {
  return (
    <>
      {/* Basic icon */}
      <FlutterLucideIcon name={LucideIcons.rocket} />

      {/* With size and color via Tailwind */}
      <FlutterLucideIcon
        name={LucideIcons.heart}
        className="text-4xl text-red-500"
      />

      {/* With stroke width variant */}
      <FlutterLucideIcon
        name={LucideIcons.activity}
        strokeWidth={400}
      />

      {/* Buttons with icons */}
      <button className="flex items-center gap-2 px-4 py-2 bg-blue-500 text-white rounded-lg">
        <FlutterLucideIcon name={LucideIcons.plus} />
        <span>Add Item</span>
      </button>

      {/* Status indicators */}
      <div className="flex items-center gap-2 p-3 bg-green-50 rounded-lg">
        <FlutterLucideIcon name={LucideIcons.circleCheck} className="text-xl text-green-600" />
        <span>Success! Your changes have been saved.</span>
      </div>

      {/* List items with icons */}
      <div className="flex items-center gap-3 p-3 rounded-lg">
        <FlutterLucideIcon name={LucideIcons.circleUser} className="text-2xl text-blue-500" />
        <div>
          <div className="font-medium">Profile Settings</div>
          <div className="text-sm text-gray-500">Manage your account</div>
        </div>
        <FlutterLucideIcon name={LucideIcons.chevronRight} className="text-gray-400" />
      </div>
    </>
  );
}
```

### Vue usage (from `@openwebf/vue-lucide-icons`)

1) Enable template type-checking for the custom element by referencing the package types (for
example in `src/env.d.ts`):

```ts
/// <reference types="@openwebf/vue-lucide-icons" />
```

2) Use the custom element in your SFC templates:

```vue
<template>
  <flutter-lucide-icon name="rocket" style="color: blue; font-size: 24px;" />

  <flutter-lucide-icon name="heart" style="color: red; font-size: 32px;" />

  <flutter-lucide-icon name="activity" stroke-width="400" />
</template>
```

## Properties

| Property | Attribute | Type | Default | Description |
|----------|-----------|------|---------|-------------|
| `name` | `name` | `LucideIcons` (string) | `''` | Icon name (e.g. `"rocket"`, `"heart"`, `"activity"`) |
| `label` | `label` | `string` | `'Lucide icon'` | Accessibility label for screen readers |
| `strokeWidth` | `stroke-width` | `number` | `null` | Stroke weight variant: 100, 200, 300, 400, 500, or 600 |

## CSS Styling

Style the icon using standard CSS properties or Tailwind classes:

| CSS Property | Tailwind | Effect |
|-------------|----------|--------|
| `color` | `text-red-500`, `text-blue-600`, etc. | Sets the icon color |
| `font-size` | `text-xl`, `text-2xl`, `text-4xl`, etc. | Sets the icon size |

```tsx
// Tailwind classes
<FlutterLucideIcon name={LucideIcons.star} className="text-4xl text-yellow-500" />

// Inline styles
<FlutterLucideIcon name={LucideIcons.star} style={{ color: 'gold', fontSize: '32px' }} />
```

## Flutter (WebF runtime) — Install & Use

The npm packages above only provide types/framework wrappers. The actual rendering happens inside
your Flutter app via WebF + this Flutter package.

### 1) Add dependencies

Add `webf_lucide_icons` to your `pubspec.yaml`:

```yaml
dependencies:
  webf_lucide_icons: ^0.1.0
```

This package depends on WebF and `lucide_icons_flutter` and will pull them in automatically.

### 2) Register the custom element

Call `installWebFLucideIcons()` before creating/loading any WebF pages:

```dart
import 'package:flutter/material.dart';
import 'package:webf_lucide_icons/webf_lucide_icons.dart';

void main() {
  installWebFLucideIcons();
  runApp(const MyApp());
}
```

Now your WebF pages can use `<flutter-lucide-icon>` and it will render as a native Flutter icon
widget.

## Contributing & Testing (via `webf codegen`)

This repo is the source of truth for:
- Flutter custom element (`lib/src/icon.dart`)
- TypeScript typings (`lib/src/icon.d.ts`, `lib/src/lucide_icons.d.ts`)
- Generated Dart bindings (`lib/src/icon_bindings_generated.dart`, generated by `webf codegen`)
- Generated npm packages (`@openwebf/react-lucide-icons`, `@openwebf/vue-lucide-icons`)

Typical workflow:

1) Regenerate icon map and TypeScript enum:

```bash
cd native_uis/webf_lucide_icons
dart run tool/generate_lucide_icons.dart
```

2) Regenerate Dart bindings (if `icon.d.ts` changes):

```bash
webf codegen --dart-only
```

3) Generate the React/Vue npm packages (optionally add `--publish-to-npm`):

```bash
webf codegen --framework react --package-name @openwebf/react-lucide-icons
webf codegen --framework vue --package-name @openwebf/vue-lucide-icons
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
