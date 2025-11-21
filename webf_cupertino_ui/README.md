# WebF Cupertino UI

A Flutter package that provides Cupertino-style UI components for WebF applications. This package
wraps Flutter's native Cupertino widgets as HTML custom elements, designed to be used with modern
JavaScript frameworks like Vue.js and React for building Flutter apps using web technologies.

## Features

- **Native Flutter Widgets**: Use Flutter's native Cupertino widgets through web technologies
- **Web Framework Development**: Build your Flutter app UI with Vue.js or React
- **Custom HTML Elements**: Cupertino widgets exposed as HTML custom elements
- **Full Native Performance**: Renders as native Flutter widgets, not web views
- **TypeScript Support**: Complete type definitions for better development experience


## Components Index

- [FlutterCupertinoButton](lib/src/button.md)


## Getting started

### Free & Pro Users

Just Select the options to add `WebF Cupertino UI` in your app build config.

### Enterprise User

**Prerequisites**

- Flutter SDK
- WebF Enterprise subscription (version 0.22.0 or higher)

**Installation**

Add `webf_cupertino_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  webf_cupertino_ui: <version>
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Initialize the package

In your main Dart file, import and install the Cupertino UI components:

```dart
import 'package:webf/webf.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

void main() {
  // Initialize WebF Controller Manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 2,
    maxAttachedInstances: 1,
  ));

  // Install all Cupertino UI components
  installWebFCupertinoUI();

  runApp(MyApp());
}
```

### 2. Use with Vue.js or React

WebF Cupertino UI is designed to work seamlessly with modern JavaScript frameworks like Vue.js and React. The components are exposed as HTML custom elements that can be used within your framework components.

#### Vue.js Example

```vue
<template>
  <div class="form-container">
    <flutter-cupertino-input
      v-model="username"
      placeholder="Enter username"
      :clearButtonMode="clearMode"
    />

    <flutter-cupertino-switch
      v-model="isEnabled"
      @change="handleSwitchChange"
    />

    <flutter-cupertino-button
      variant="filled"
      @click="handleSubmit"
    >
      Submit
    </flutter-cupertino-button>
  </div>
</template>

<script>
export default {
  data() {
    return {
      username: '',
      isEnabled: false,
      clearMode: 'while-editing'
    }
  },
  methods: {
    handleSwitchChange(event) {
      console.log('Switch changed:', event.detail.value);
    },
    handleSubmit() {
      console.log('Form submitted');
    }
  }
}
</script>
```

#### React Example (Coming Soon)

React examples will be available soon. The components work similarly with React's event system and state management.

### 3. Complete Vue.js Gallery Example

For a comprehensive example of all components, check out the Vue Cupertino Gallery:
- **Gallery URL**: [vue-cupertino-gallery.vercel.app](https://vue-cupertino-gallery.vercel.app/) (requires WebF to view)
- **Source Code**: [github.com/openwebf/vue-cupertino-gallery](https://github.com/openwebf/vue-cupertino-gallery)

The gallery demonstrates:
- All available Cupertino components
- Proper Vue.js integration patterns
- Event handling and state management
- Component composition and styling

## TypeScript Support

TypeScript definitions are included for all components. When using TypeScript with Vue or React, you'll get full type checking and IntelliSense support:

```typescript
// Vue 3 with TypeScript
import { ref } from 'vue';

const buttonRef = ref<FlutterCupertinoButton>();

// Access typed properties
if (buttonRef.value) {
  buttonRef.value.variant = 'tinted';
  buttonRef.value.disabled = false;
}
```

```typescript
// Direct DOM access with TypeScript
const button = document.querySelector<FlutterCupertinoButton>('flutter-cupertino-button');
button.variant = 'tinted';
button.disabled = false;
```

## Example

Check out the [example](example/) directory for a complete example app that includes:
- Local HTML examples of all components
- Direct access to the Vue.js Gallery hosted on Vercel

To run the example:
```bash
cd example
flutter run
```

The example app includes a "Cupertino Gallery (Vue.js)" option that loads the gallery directly through WebF.


## Contributing

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
