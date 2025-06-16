# WebF Cupertino UI

A Flutter package that provides Cupertino-style UI components for WebF applications. This package
wraps Flutter's native Cupertino widgets as HTML custom elements, allowing you to use iOS-style UI
components in your WebF web applications.

## Features

- **Native Cupertino Widgets**: Access all the beautiful iOS-style widgets from Flutter's Cupertino
  library
- **Custom HTML Elements**: Use Cupertino widgets as HTML custom elements in your WebF applications
- **Full WebF Integration**: Seamless integration with WebF's rendering engine and event system
- **TypeScript Support**: TypeScript definitions included for better IDE support

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
- WebF (version 0.22.0 or higher)

### Installation

Add `webf_cupertino_ui` to your `pubspec.yaml`:

```yaml
dependencies:
  webf_cupertino_ui: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Usage

### 1. Initialize the package

In your main Dart file, import and install the Cupertino UI components:

```dart
import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

void main() {
  // Install all Cupertino UI components
  installWebFCupertinoUI();

  runApp(MyApp());
}
```

### 2. Use Cupertino components in your HTML

Once installed, you can use the Cupertino components as HTML custom elements:

```html
<!-- Button example -->
<flutter-cupertino-button variant="filled" size="large">
  Click Me
</flutter-cupertino-button>

<!-- Switch example -->
<flutter-cupertino-switch id="mySwitch" value="true"></flutter-cupertino-switch>

<!-- Input example -->
<flutter-cupertino-input
  placeholder="Enter your name"
  clearButtonMode="while-editing">
</flutter-cupertino-input>

<!-- Date Picker example -->
<flutter-cupertino-date-picker
  mode="date"
  initialDateTime="2024-01-01">
</flutter-cupertino-date-picker>
```

### 3. Handle events

All components dispatch standard DOM events:

```javascript
// JavaScript
const button = document.querySelector('flutter-cupertino-button');
button.addEventListener('click', (e) => {
  console.log('Button clicked!');
});

const switchElement = document.querySelector('flutter-cupertino-switch');
switchElement.addEventListener('change', (e) => {
  console.log('Switch value:', e.detail.value);
});
```

### 4. Style with CSS

Components respect CSS styling where applicable:

```css
flutter-cupertino-button {
  width: 200px;
  padding: 16px;
  background-color: #007AFF;
}

flutter-cupertino-input {
  width: 100%;
  min-height: 44px;
}
```

## TypeScript Support

TypeScript definitions are included for all components. When using TypeScript, you'll get full type
checking and IntelliSense support:

```typescript
// TypeScript
const button = document.querySelector<FlutterCupertinoButton>('flutter-cupertino-button');
button.variant = 'tinted';
button.disabled = false;
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This package is licensed under the same license as WebF. See the LICENSE file for details.

## Additional information

For more information about WebF,
visit [https://github.com/openwebf/webf](https://github.com/openwebf/webf).

For issues and feature requests, please visit
the [issue tracker](https://github.com/openwebf/webf/issues).
