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

### Cupertino Gallery (Vue.js)
A comprehensive Vue.js application demonstrating all components. This example loads directly from the deployed Vercel app.

The Vue.js gallery is automatically deployed and available at the configured URL. Simply run the Flutter example app and navigate to "Cupertino Gallery (Vue.js)" to see it in action.

To customize the gallery or deploy your own version:

1. Clone the vue-cupertino-gallery repository:
   ```bash
   git clone https://github.com/openwebf/vue-cupertino-gallery.git
   cd vue-cupertino-gallery
   ```

2. Deploy to Vercel:
   ```bash
   vercel
   ```

3. Update the `vercelUrl` in `lib/main.dart` with your deployment URL.

Note: The Vue.js gallery source code is maintained separately at: https://github.com/openwebf/vue-cupertino-gallery

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