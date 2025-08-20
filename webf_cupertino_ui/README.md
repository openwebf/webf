# WebF Cupertino UI

[![pub package](https://img.shields.io/pub/v/webf_cupertino_ui.svg)](https://pub.dev/packages/webf_cupertino_ui)
[![CI](https://github.com/openwebf/webf-cupertino-ui/actions/workflows/ci.yml/badge.svg)](https://github.com/openwebf/webf-cupertino-ui/actions/workflows/ci.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![WebF Enterprise](https://img.shields.io/badge/WebF-Enterprise%20Only-orange.svg)](https://openwebf.com)

> **This package is exclusively for WebF Enterprise subscribers.** Visit [openwebf.com](https://openwebf.com) for subscription information.

## What is WebF?

WebF enables you to build Flutter apps using web technologies (HTML, CSS, JavaScript) with frameworks like Vue.js and React. This is NOT for building web applications - it's for building native Flutter applications using familiar web development tools.

## 🎨 Vue.js Gallery Example

A comprehensive Vue.js application showcasing all Cupertino components is available at:
**https://vue-cupertino-gallery.vercel.app/**

**Note:** This is not a traditional web demo. To view the gallery, you must:
1. Have a WebF Enterprise subscription
2. Install this package in your Flutter app
3. Load the gallery through WebF (see quick start below)

### Quick Start - View the Gallery

```dart
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

void main() {
  // Initialize WebF Controller Manager
  WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
    maxAliveInstances: 2,
    maxAttachedInstances: 1,
  ));
  
  // Install Cupertino UI components
  installWebFCupertinoUI();
  
  runApp(MaterialApp(
    home: Scaffold(
      body: WebF.fromControllerName(
        controllerName: 'gallery',
        bundle: WebFBundle.fromUrl('https://vue-cupertino-gallery.vercel.app/'),
      ),
    ),
  ));
}
```

---

A Flutter package that provides Cupertino-style UI components for WebF applications. This package
wraps Flutter's native Cupertino widgets as HTML custom elements, designed to be used with modern
JavaScript frameworks like Vue.js and React for building Flutter apps using web technologies.

## Features

- **Native Flutter Widgets**: Use Flutter's native Cupertino widgets through web technologies
- **Web Framework Development**: Build your Flutter app UI with Vue.js or React
- **Custom HTML Elements**: Cupertino widgets exposed as HTML custom elements
- **Full Native Performance**: Renders as native Flutter widgets, not web views
- **TypeScript Support**: Complete type definitions for better development experience

### Available Components

- **Button** (`<flutter-cupertino-button>`) - iOS-style buttons with various variants
- **TextField** (`<flutter-cupertino-input>`) - iOS-style text input fields
- **Switch** (`<flutter-cupertino-switch>`) - iOS-style toggle switches
- **Slider** (`<flutter-cupertino-slider>`) - iOS-style sliders
- **Checkbox** (`<flutter-cupertino-checkbox>`) - iOS-style checkboxes
- **Radio** (`<flutter-cupertino-radio>`) - iOS-style radio buttons
- **Picker** (`<flutter-cupertino-picker>`) - iOS-style picker wheels
- **DatePicker** (`<flutter-cupertino-date-picker>`) - iOS-style date pickers
- **TimerPicker** (`<flutter-cupertino-timer-picker>`) - iOS-style timer pickers
- **Alert** (`<flutter-cupertino-alert>`) - iOS-style alert dialogs
- **ActionSheet** (`<flutter-cupertino-action-sheet>`) - iOS-style action sheets
- **ContextMenu** (`<flutter-cupertino-context-menu>`) - iOS-style context menus
- **Loading** (`<flutter-cupertino-loading>`) - iOS-style loading indicators
- **Toast** (`<flutter-cupertino-toast>`) - iOS-style toast notifications
- **Tab/TabBar** (`<flutter-cupertino-tab>`, `<flutter-cupertino-tab-bar>`) - iOS-style tab
  navigation
- **SegmentedTab** (`<flutter-cupertino-segmented-tab>`) - iOS-style segmented controls
- **FormRow/FormSection** (`<flutter-cupertino-form-row>`, `<flutter-cupertino-form-section>`) -
  iOS-style form layouts
- **ListSection/ListTile** (`<flutter-cupertino-list-section>`, `<flutter-cupertino-list-tile>`) -
  iOS-style list layouts
- **Icon** (`<flutter-cupertino-icon>`) - iOS-style icons
- **SearchInput** (`<flutter-cupertino-search-input>`) - iOS-style search fields
- **TextArea** (`<flutter-cupertino-textarea>`) - iOS-style multiline text input
- **ModalPopup** (`<flutter-cupertino-modal-popup>`) - iOS-style modal popups

## Getting started

### Prerequisites

- Flutter SDK
- WebF Enterprise subscription (version 0.22.0 or higher)

> **⚠️ WebF Enterprise Required**: This package requires a WebF Enterprise subscription. It depends on the WebF Enterprise edition from a private Cloudsmith repository and is only available to WebF Enterprise subscribers.
>
> To get access to WebF Enterprise, please visit [openwebf.com](https://openwebf.com) for more information about enterprise subscriptions and pricing.

### Installation

Add `webf_cupertino_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  webf_cupertino_ui: ^0.1.0
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

Contributions are welcome! Please read our [contributing guide](CONTRIBUTING.md) to learn about our development process, how to propose bugfixes and improvements, and how to build and test your changes.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Additional information

- **Homepage**: [https://github.com/openwebf/webf-cupertino-ui](https://github.com/openwebf/webf-cupertino-ui)
- **Issue tracker**: [https://github.com/openwebf/webf-cupertino-ui/issues](https://github.com/openwebf/webf-cupertino-ui/issues)
- **WebF Enterprise**: [https://openwebf.com](https://openwebf.com)
