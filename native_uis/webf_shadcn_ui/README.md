# webf_shadcn_ui

shadcn/ui style components for WebF applications. This package provides [shadcn_ui](https://pub.dev/packages/shadcn_ui) Flutter widgets wrapped as HTML custom elements for use in WebF.

## Features

- 40+ UI components matching shadcn/ui design
- Full theming support with 12 color schemes
- Light/Dark mode support
- TypeScript definitions for React/Vue code generation
- Seamless integration with WebF applications

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  webf_shadcn_ui: ^0.1.0
```

## Quick Start

1. Install the custom elements in your main function:

```dart
import 'package:webf_shadcn_ui/webf_shadcn_ui.dart';

void main() {
  installWebFShadcnUI();
  runApp(MyApp());
}
```

2. Use the components in your HTML:

```html
<flutter-shadcn-theme color-scheme="blue" brightness="light">
  <flutter-shadcn-card>
    <flutter-shadcn-card-header>
      <flutter-shadcn-card-title>Welcome</flutter-shadcn-card-title>
      <flutter-shadcn-card-description>Get started with shadcn components</flutter-shadcn-card-description>
    </flutter-shadcn-card-header>
    <flutter-shadcn-card-content>
      <flutter-shadcn-button variant="default">Click me</flutter-shadcn-button>
    </flutter-shadcn-card-content>
  </flutter-shadcn-card>
</flutter-shadcn-theme>
```

## Available Components

### Theming
- `<flutter-shadcn-theme>` - Theme provider with color scheme and brightness support

### Form Controls
- `<flutter-shadcn-button>` - Button with variants (default, secondary, destructive, outline, ghost, link)
- `<flutter-shadcn-input>` - Text input field
- `<flutter-shadcn-textarea>` - Multi-line text input
- `<flutter-shadcn-checkbox>` - Checkbox control
- `<flutter-shadcn-radio>` - Radio button group
- `<flutter-shadcn-switch>` - Toggle switch
- `<flutter-shadcn-select>` - Dropdown select
- `<flutter-shadcn-slider>` - Range slider
- `<flutter-shadcn-combobox>` - Searchable select
- `<flutter-shadcn-form>` - Form container with field components

### Display Components
- `<flutter-shadcn-card>` - Card container with header, content, footer slots
- `<flutter-shadcn-alert>` - Alert message with title and description
- `<flutter-shadcn-badge>` - Badge/label component
- `<flutter-shadcn-avatar>` - User avatar with fallback
- `<flutter-shadcn-toast>` - Toast notification
- `<flutter-shadcn-tooltip>` - Hover tooltip
- `<flutter-shadcn-progress>` - Progress bar
- `<flutter-shadcn-separator>` - Visual separator

### Navigation/Layout
- `<flutter-shadcn-tabs>` - Tabbed interface
- `<flutter-shadcn-dialog>` - Modal dialog
- `<flutter-shadcn-sheet>` - Slide-out panel
- `<flutter-shadcn-popover>` - Floating content container
- `<flutter-shadcn-breadcrumb>` - Breadcrumb navigation
- `<flutter-shadcn-dropdown-menu>` - Dropdown menu
- `<flutter-shadcn-context-menu>` - Right-click context menu

### Data Display
- `<flutter-shadcn-table>` - Data table
- `<flutter-shadcn-accordion>` - Collapsible sections
- `<flutter-shadcn-calendar>` - Date calendar
- `<flutter-shadcn-date-picker>` - Date picker with popover
- `<flutter-shadcn-time-picker>` - Time picker
- `<flutter-shadcn-image>` - Image with loading states

### Advanced
- `<flutter-shadcn-scroll-area>` - Scrollable container
- `<flutter-shadcn-skeleton>` - Loading placeholder
- `<flutter-shadcn-collapsible>` - Collapsible section

## CSS Customization

### Button Text Styling

The `<flutter-shadcn-button>` component supports CSS customization for text styles while automatically handling the text color based on the button variant and theme.

**What CSS properties work on button children:**
- `font-size` / `font-weight` / `font-family`
- `letter-spacing` / `word-spacing`
- `text-decoration` / `font-style`
- Other text styling properties

**What's controlled by the button theme:**
- Text color (automatically set based on button variant)

**Example with inline styles:**

```html
<flutter-shadcn-button variant="default">
  <span style="font-size: 18px; font-weight: bold;">Large Bold Text</span>
</flutter-shadcn-button>
```

**Example with React and Tailwind:**

```jsx
<FlutterShadcnButton variant="secondary">
  <span className="text-lg font-semibold tracking-wide">Styled Text</span>
</FlutterShadcnButton>
```

This approach ensures:
- CSS styles from your HTML/JSX are preserved (font-size, font-weight, etc.)
- Text color automatically matches the button's theme variant (primary has white text, outline has dark text, etc.)

## Color Schemes

The following color schemes are available:
- blue, gray, green, neutral, orange, red, rose, slate, stone, violet, yellow, zinc

Set the color scheme on the theme provider:

```html
<flutter-shadcn-theme color-scheme="violet" brightness="dark">
  <!-- Your content -->
</flutter-shadcn-theme>
```

## Generating React/Vue Components

Use the WebF CLI to generate framework-specific packages:

```bash
# React components
webf codegen webf-shadcn-react \
  --flutter-package-src=./native_uis/webf_shadcn_ui \
  --framework=react

# Vue components
webf codegen webf-shadcn-vue \
  --flutter-package-src=./native_uis/webf_shadcn_ui \
  --framework=vue
```

## License

Apache License 2.0
