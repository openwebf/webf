# WebF Cupertino UI Example

This example demonstrates how to use the WebF Cupertino UI package to create iOS-style interfaces in WebF applications.

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the example:
   ```bash
   flutter run
   ```

## Examples Included

### Components Gallery
Shows all available Cupertino UI components including:
- Buttons (plain, filled, tinted variants)
- Form controls (text input, search, textarea)
- Selection controls (switch, checkbox, radio, slider)
- Indicators (loading, toast)

### Form Example
Demonstrates how to build forms using:
- Form sections and form rows
- List sections and list tiles
- Various input types with proper layout

### Dialog Examples
Shows different types of iOS-style dialogs:
- Alert dialogs
- Action sheets
- Date pickers
- Timer pickers
- Custom pickers

### Navigation Example
Demonstrates navigation components:
- Segmented controls (tabs)
- Tab switching with content

## Usage Tips

1. **Initialize Components**: Always call `installWebFCupertinoUI()` before using any components.

2. **WebFControllerManager**: The example uses WebFControllerManager for efficient WebF instance management.

3. **Event Handling**: All components dispatch standard DOM events that can be handled in JavaScript:
   ```javascript
   element.addEventListener('change', (e) => {
     console.log('Value changed:', e.detail.value);
   });
   ```

4. **Styling**: Components can be styled with CSS while maintaining their iOS appearance.

## Running with Hot Reload

The example supports Flutter's hot reload for the Dart code. However, changes to the HTML/CSS/JavaScript content require a hot restart.

## Additional Resources

- [WebF Documentation](https://github.com/openwebf/webf)
- [Flutter Cupertino Widgets](https://api.flutter.dev/flutter/cupertino/cupertino-library.html)