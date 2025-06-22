# WebF React Use Cases

This is a React implementation of the WebF use cases demo, converted from the original Vue.js version. It demonstrates various WebF components and functionality using React instead of Vue.

## Features

The demo includes the following use cases:

### 1. Homepage
- Navigation menu with links to different demos
- Custom ListView component integration

### 2. Show Case Page
- Showcase/Highlight component demonstrations
- Multiple examples of tooltip positioning
- Interactive and non-interactive background controls
- Multi-step guided tours
- Button-controlled showcases

### 3. ListView Page
- Custom ListView with refresh and load more functionality
- Cupertino style refresh indicators
- Material design refresh indicators
- Custom refresh indicator styles

### 4. Form Page
- Form validation demonstrations
- Multiple input types (text, email, number, url, password)
- Layout switching (vertical/horizontal)
- Real-time validation with custom rules
- Form submission and reset functionality

## Project Structure

```
src/
├── components/
│   └── RouterView.tsx          # Router component wrapper
├── pages/
│   ├── HomePage.tsx            # Main navigation page
│   ├── ShowCasePage.tsx        # Showcase demonstrations
│   ├── ListviewPage.tsx        # ListView examples
│   └── FormPage.tsx            # Form validation examples
├── utils/
│   └── CreateComponent.tsx     # Utility for creating WebF components
├── App.tsx                     # Main application component
└── index.tsx                   # Application entry point
```

## Key Differences from Vue Version

1. **Component Creation**: Uses a `createComponent` utility to wrap WebF custom elements for React
2. **State Management**: Uses React hooks (`useState`, `useRef`) instead of Vue's reactive data
3. **Event Handling**: Converts Vue's `@event` syntax to React's `onEvent` props
4. **Refs**: Uses `useRef` instead of Vue's `$refs` for accessing component instances
5. **Lifecycle**: Uses `useEffect` instead of Vue lifecycle methods
6. **CSS Modules**: Uses CSS Modules (`.module.css`) to prevent styling conflicts between components

## WebF Components Used

- `webf-router-link` - Routing navigation
- `webf-listview` - Custom scrollable lists
- `flutter-cupertino-button` - iOS-style buttons
- `flutter-showcase-view` - Highlight/tooltip components
- `flutter-webf-form` - Form validation wrapper
- `flutter-webf-form-field` - Individual form fields
- `flutter-cupertino-switch` - iOS-style toggle switches
- `flutter-cupertino-list-section` - List section headers

## Getting Started

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start the development server:
   ```bash
   npm start
   ```

3. Build for production:
   ```bash
   npm run build
   ```

## Navigation

The app uses WebF's routing system with the following routes:
- `/` - Homepage with navigation menu
- `/show_case` - Showcase component demonstrations
- `/listview` - ListView examples
- `/form` - Form validation examples

## Technical Notes

- This project uses TypeScript for type safety
- WebF custom elements are wrapped using the `createComponent` utility
- Event handling is converted from Vue's event system to React's synthetic events
- **CSS Modules** are used to prevent styling conflicts between components
- All styling uses CSS custom properties for theming support
- **Enhanced Event Handling**: Improved `createComponent` utility to properly handle WebF custom element events
- The project maintains the same functionality as the original Vue version

## CSS Modules Implementation

This project uses CSS Modules to avoid styling conflicts:

### Benefits
- **Scoped Styles**: Each component's styles are automatically scoped
- **No Naming Conflicts**: Multiple components can use same class names without conflicts
- **Better Maintainability**: Easy to identify which styles belong to which component
- **Type Safety**: TypeScript can provide autocomplete for CSS class names

### Usage Pattern
```tsx
// Import styles as an object
import styles from './ComponentName.module.css';

// Use styles with object notation
<div className={styles.container}>
  <h1 className={styles.title}>Title</h1>
  <button className={styles.button}>Click me</button>
</div>
```

### File Structure
- `HomePage.module.css` - HomePage component styles
- `ShowCasePage.module.css` - ShowCasePage component styles
- `ListviewPage.module.css` - ListviewPage component styles
- `FormPage.module.css` - FormPage component styles
- `CommonStyles.module.css` - Shared component styles (example)