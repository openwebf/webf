# WebF Example News App Development Guide

## Build Commands
- Development server: `yarn serve` or `npm run serve`
- Production build: `yarn build` or `npm run build`
- Lint and fix files: `yarn lint` or `npm run lint`

## Code Style Guidelines
- **Vue Components**: Use PascalCase for component names and kebab-case for custom elements
- **Imports**: Use `@/` alias for src directory imports (e.g., `import Component from '@/Components/Component.vue'`)
- **File Structure**: 
  - Pages/ - Main page components
  - Components/ - Reusable UI components
  - utils/ - Helper functions and utilities
- **Naming Conventions**:
  - Component files: PascalCase (e.g., `HomePage.vue`)
  - Method names: camelCase
  - CSS classes: kebab-case
- **Component Structure**: Template → Script → Style
- **Custom Elements**: Custom elements use `webf-` or `flutter-` prefix
- **State Management**: Use Pinia for global state management
- **Error Handling**: Use try/catch blocks for async operations

## WebF Integration
This project integrates Vue.js with WebF (Flutter-based web framework). Custom elements with `webf-` or `flutter-` prefixes are Flutter widgets rendered within Vue components.