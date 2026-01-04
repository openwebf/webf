# WebF Cupertino UI

A Cupertino UI component set for WebF.

It wraps Flutter's native Cupertino widgets as HTML custom elements (e.g. `<flutter-cupertino-button>`),
so you can build Flutter app UIs using web technologies with WebF.

## React / Vue (npm) — Install & Use

These npm packages are for **WebF JavaScript developers**. They provide framework integrations and
TypeScript types for the Cupertino custom elements rendered by Flutter.

> This is not a “run in the browser” UI library. You still need a Flutter app with WebF + this
> Flutter package installed (see the next section).

### Install

Vue:

```bash
npm install @openwebf/vue-cupertino-ui
```

React:

```bash
npm install @openwebf/react-cupertino-ui
```

### React usage (from `@openwebf/react-cupertino-ui`)

```tsx
import React, { useState } from 'react';
import {
  FlutterCupertinoButton,
  FlutterCupertinoInput,
  FlutterCupertinoSwitch,
} from '@openwebf/react-cupertino-ui';

export function App() {
  const [username, setUsername] = useState('');
  const [enabled, setEnabled] = useState(false);

  return (
    <>
      <FlutterCupertinoInput
        val={username}
        placeholder="Enter username"
        onInput={(e) => setUsername(e.detail)}
      />

      <FlutterCupertinoSwitch
        checked={enabled}
        onChange={(e) => setEnabled(e.detail)}
      />

      <FlutterCupertinoButton onClick={() => console.log({ username, enabled })}>
        Submit
      </FlutterCupertinoButton>
    </>
  );
}
```

### Vue usage (from `@openwebf/vue-cupertino-ui`)

1) Enable template type-checking for the custom elements by referencing the package types (for
example in `src/env.d.ts`):

```ts
/// <reference types="@openwebf/vue-cupertino-ui" />
```

2) Use the custom elements in your SFC templates:

```vue
<template>
  <flutter-cupertino-input
    :val="username"
    placeholder="Enter username"
    @input="(e) => (username = e.detail)"
  />

  <flutter-cupertino-switch
    :checked="enabled"
    @change="(e) => (enabled = e.detail)"
  />

  <flutter-cupertino-button @click="submit">
    Submit
  </flutter-cupertino-button>
</template>

<script setup lang="ts">
import { ref } from 'vue';

const username = ref('');
const enabled = ref(false);

function submit() {
  console.log({ username: username.value, enabled: enabled.value });
}
</script>
```

## Flutter (WebF runtime) — Install & Use

The npm packages above only provide types/framework wrappers. The actual rendering happens inside
your Flutter app via WebF + this Flutter package.

### 1) Add dependencies

Add `webf_cupertino_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  webf_cupertino_ui: ^0.4.0
```

This package depends on WebF (`webf: ^0.24.0`) and will pull it in automatically, but you can pin it
explicitly if your app needs to.

### 2) Register the custom elements

Call `installWebFCupertinoUI()` before creating/loading any WebF pages:

```dart
import 'package:flutter/material.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

void main() {
  installWebFCupertinoUI();
  runApp(const MyApp());
}
```

Now your WebF pages can use the Cupertino tags (e.g. `<flutter-cupertino-button>`) and they will
render as real Flutter Cupertino widgets.

## Features

- **Native Flutter Widgets**: Use Flutter's native Cupertino widgets through web technologies
- **Web Framework Development**: Build your Flutter app UI with Vue.js or React
- **Custom HTML Elements**: Cupertino widgets exposed as HTML custom elements
- **Full Native Performance**: Renders as native Flutter widgets, not web views
- **TypeScript Support**: Complete type definitions for better development experience

## Components & Docs

Component docs live in `lib/src/*.md` (React-focused):
- [FlutterCupertinoActionSheet](lib/src/action_sheet.md)
- [FlutterCupertinoAlert](lib/src/alert.md)
- [FlutterCupertinoButton](lib/src/button.md)
- [FlutterCupertinoCheckbox](lib/src/checkbox.md)
- [FlutterCupertinoContextMenu](lib/src/context_menu.md)
- [FlutterCupertinoDatePicker](lib/src/date_picker.md)
- [FlutterCupertinoFormSection](lib/src/form_section.md)
- [FlutterCupertinoInput](lib/src/input.md)
- [FlutterCupertinoListSection](lib/src/list_section.md)
- [FlutterCupertinoListTile](lib/src/list_tile.md)
- [FlutterCupertinoModalPopup](lib/src/modal_popup.md)
- [FlutterCupertinoRadio](lib/src/radio.md)
- [FlutterCupertinoSearchTextField](lib/src/search_text_field.md)
- [FlutterCupertinoSlider](lib/src/slider.md)
- [FlutterCupertinoSlidingSegmentedControl](lib/src/sliding-segmented-control.md)
- [FlutterCupertinoSwitch](lib/src/switch.md)
- [FlutterCupertinoTabBar](lib/src/tab_bar.md)
- [FlutterCupertinoTabScaffold](lib/src/tab_scaffold.md)
- [FlutterCupertinoTabView](lib/src/tab_view.md)
- [FlutterCupertinoTextFormFieldRow](lib/src/text_form_field_row.md)


## Contributing & Testing (via `webf codegen`)

This repo is the source of truth for:
- Flutter custom elements (`lib/src/*.dart`)
- TypeScript typings (`lib/src/*.d.ts`)
- Generated Dart bindings (`lib/src/*_bindings_generated.dart`, generated by `webf codegen`)
- Generated npm packages (`@openwebf/react-cupertino-ui`, `@openwebf/vue-cupertino-ui`)

Typical workflow:

1) Update or add typings in `lib/src/*.d.ts`
2) Regenerate Dart bindings:

```bash
webf codegen --dart-only
```

3) Generate the React/Vue npm packages (optionally add `--publish-to-npm`):

```bash
webf codegen --framework react --package-name @openwebf/react-cupertino-ui
webf codegen --framework vue --package-name @openwebf/vue-cupertino-ui
```

4) Run tests:

```bash
flutter test
```

See `CONTRIBUTING.md` and `docs/migration-rules.md` for more details and conventions.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
