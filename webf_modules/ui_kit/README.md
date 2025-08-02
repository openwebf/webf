# WebF UI Kit

A comprehensive collection of Flutter UI components exposed as custom HTML elements for WebF applications.

## Features

This package provides the following custom elements:

- **Buttons & Controls**
  - `<flutter-button>` - Customizable Flutter button
  - `<flutter-switch>` - Toggle switch component
  - `<flutter-slider>` - Slider for value selection

- **Navigation & Layout**
  - `<flutter-tab>` - Tab navigation container
  - `<flutter-tab-item>` - Individual tab items
  - `<flutter-bottom-sheet>` - Bottom sheet modal

- **Lists & Data Display**
  - `<webf-listview-cupertino>` - ListView with iOS-style refresh indicator
  - `<webf-listview-material>` - ListView with Material Design refresh indicator
  - `<flutter-showcase-view>` - Showcase view container
  - `<flutter-showcase-item>` - Individual showcase items
  - `<flutter-showcase-description>` - Showcase descriptions

- **Input & Selection**
  - `<flutter-search>` - Search input field
  - `<flutter-select>` - Dropdown selection

- **Media & Icons**
  - `<flutter-icon>` - Flutter icon component
  - `<flutter-svg-img>` - SVG image support

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  webf_ui_kit: ^1.0.0
    hosted: https://dart.cloudsmith.io/openwebf/webf-enterprise/
```

## Quick Start

```dart
import 'package:webf/webf.dart';
import 'package:webf_ui_kit/webf_ui_kit.dart';

void main() {
  // Register all UI components with one function call
  installWebFUIKit();
  
  runApp(MyApp());
}
```

## JavaScript Usage

Once registered, you can use these components in your HTML/JavaScript:

```html
<!-- Button Example -->
<flutter-button variant="filled" onclick="handleClick()">
  Click Me
</flutter-button>

<!-- Tab Navigation -->
<flutter-tab>
  <flutter-tab-item label="Home" active="true">
    <div>Home Content</div>
  </flutter-tab-item>
  <flutter-tab-item label="Profile">
    <div>Profile Content</div>
  </flutter-tab-item>
</flutter-tab>

<!-- ListView with Cupertino Refresh -->
<webf-listview-cupertino>
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</webf-listview-cupertino>

<!-- Search Input -->
<flutter-search placeholder="Search..." onchange="handleSearch(event)">
</flutter-search>

<!-- SVG Image -->
<flutter-svg-img src="assets/icons/logo.svg" width="100" height="100">
</flutter-svg-img>
```

## Component Documentation

### flutter-button

Customizable button with Material and Cupertino styles.

```html
<flutter-button 
  variant="filled|outlined|text" 
  size="small|medium|large"
  disabled="true|false">
  Button Text
</flutter-button>
```

### flutter-switch

Toggle switch component.

```html
<flutter-switch 
  checked="true|false"
  onchange="handleChange(event)">
</flutter-switch>
```

### flutter-slider

Slider for numeric value selection.

```html
<flutter-slider 
  min="0" 
  max="100" 
  value="50"
  onchange="handleSliderChange(event)">
</flutter-slider>
```

### webf-listview-cupertino / webf-listview-material

ListView with platform-specific refresh indicators.

```html
<webf-listview-cupertino onrefresh="handleRefresh()">
  <!-- List items -->
</webf-listview-cupertino>
```

## Requirements

- **Flutter**: >=3.0.0
- **WebF**: >=0.17.0
- WebF Enterprise subscription for deployment

## License

This package is part of WebF Enterprise. Please check your subscription for usage rights.