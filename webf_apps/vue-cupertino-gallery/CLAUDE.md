# Vue Cupertino Gallery Development Guide

## Project Overview
This is a Vue 3 showcase application demonstrating all WebF Cupertino UI components. It serves as both a component gallery and reference implementation for developers using WebF's Flutter-based UI components in Vue applications.

## Project Structure
```
vue-cupertino-gallery/
├── src/
│   ├── Pages/          # Component demonstration pages (24 total)
│   ├── components/     # Reusable Vue components
│   ├── assets/         # Styles and static assets
│   └── utils/          # Utility modules (tabBarManager)
├── public/             # Static public assets
└── [config files]      # Vue, Babel, and build configuration
```

## Key Technologies
- **Vue 3.2.13** - Core framework
- **WebF Cupertino UI** - Flutter-based iOS-style components
- **Sass** - CSS preprocessing
- **Vue CLI 5** - Build tooling

## Development Commands
```bash
# Install dependencies
npm install

# Run development server
npm run serve

# Build for production
npm run build

# Lint and fix files
npm run lint
```

## Component Integration Patterns

### Using WebF Cupertino Components
```vue
<template>
  <!-- Use flutter-cupertino- prefix for components -->
  <flutter-cupertino-button 
    variant="filled"
    @click="handleClick"
  >
    Button Text
  </flutter-cupertino-button>
</template>
```

### Navigation Pattern
This project uses WebF's hybrid history API instead of Vue Router:
```javascript
// Navigate to a new page
window.webf.hybridHistory.pushState({ path: '/button' }, '', '/button');

// Listen for navigation
window.addEventListener('popstate', (event) => {
  // Handle navigation
});
```

### Event Handling
WebF components emit standard DOM events that work with Vue's event system:
```vue
<flutter-cupertino-switch
  :checked="isChecked"
  @change="handleChange"
/>
```

## Component Categories

### 1. Common Components
- Icon - System and custom icons

### 2. Control Components
- Button - Various button styles and states
- Switch - Toggle switches
- Checkbox - Checkboxes with different styles
- Radio - Radio button groups
- Slider - Value sliders

### 3. Input Components
- Input - Text input fields
- SearchInput - Search-specific inputs
- Textarea - Multi-line text inputs

### 4. Form Components
- FormRow - Form field containers
- FormSection - Grouped form sections

### 5. List Components
- ListSection - Grouped list containers
- ListTile - Individual list items

### 6. Picker Components
- DatePicker - Date selection
- TimerPicker - Time selection
- Picker - General value picking

### 7. Dialog & Popup Components
- Alert - Alert dialogs
- ActionSheet - Action sheet menus
- Loading - Loading indicators
- ModalPopup - Modal dialogs
- ContextMenu - Context menus

### 8. Navigation Components
- SegmentedTab - Segmented controls
- TabBar - Tab navigation

## Styling Guidelines

### CSS Variables
The app uses CSS custom properties for theming:
```css
:root {
  --primary-color: #007aff;
  --background-color: #f2f2f7;
  --text-color: #000000;
}
```

### Dark Mode Support
CSS automatically adapts to system preferences:
```css
@media (prefers-color-scheme: dark) {
  :root {
    --background-color: #000000;
    --text-color: #ffffff;
  }
}
```

### Component Styling
- Use scoped styles for component-specific CSS
- Leverage CSS variables for consistency
- Avoid inline styles except for dynamic values

## Best Practices

### 1. Component Usage
- Always check the component's available attributes in the respective page
- Use proper boolean attributes (e.g., `disabled="true"`)
- Handle events using Vue's `@event` syntax

### 2. Navigation
- Use the custom RouterView component for page routing
- Implement lazy loading with the `onscreen` event
- Maintain navigation state in TabBarManager

### 3. State Management
- Use Vue's reactive data for component state
- TabBarManager singleton for global tab state
- Avoid direct DOM manipulation

### 4. Performance
- Components lazy load when entering viewport
- Minimize re-renders with proper Vue reactivity
- Use CSS transforms for animations

## Common Patterns

### Creating a New Component Page
1. Create a new `.vue` file in `/src/Pages/`
2. Add the component to HomePage.vue navigation
3. Implement component variations and examples
4. Add proper event handlers and state management

### Custom Element Configuration
The app recognizes WebF/Flutter elements via vue.config.js:
```javascript
compilerOptions: {
  isCustomElement: tag => tag.startsWith('webf-') || tag.startsWith('flutter-')
}
```

## Troubleshooting

### Component Not Rendering
- Ensure the flutter-cupertino- prefix is used
- Check that WebF runtime is properly loaded
- Verify component attributes are correctly formatted

### Navigation Issues
- Check webf.hybridHistory is available
- Ensure RouterView component is properly mounted
- Verify path format in navigation calls

### Styling Issues
- WebF components may have encapsulated styles
- Use CSS specificity carefully
- Some properties may need !important

## Testing Components
- Each component page serves as a test bed
- Test different states (normal, disabled, active)
- Verify event handling works correctly
- Check dark mode appearance

## Build Considerations
- Public path is set to './' for WebF compatibility
- No external routing library reduces bundle size
- CSS is extracted for production builds