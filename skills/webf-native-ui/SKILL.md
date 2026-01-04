---
name: webf-native-ui
description: Setup and use WebF's Cupertino UI library to build native iOS-style UIs with pre-built components instead of crafting everything with HTML/CSS. Use when building iOS apps, adding native UI components, or improving UI performance.
---

# WebF Native UI Libraries

Instead of crafting all UIs with HTML/CSS, WebF provides **pre-built native UI libraries** that render as native Flutter widgets with full native performance. These components look and feel native on each platform while being controlled from your JavaScript code.

## What Are Native UI Libraries?

Native UI libraries are collections of UI components that:
- **Render as native Flutter widgets** (not DOM elements)
- **Look and feel native** on each platform (iOS, Android, etc.)
- **Provide better performance** than HTML/CSS for complex UIs
- **Use platform-specific design** (Cupertino for iOS, Material for Android)
- **Work with React, Vue, and vanilla JavaScript**

## Available Library

### Cupertino UI ✅

**Description**: iOS-style components following Apple's Human Interface Guidelines

**Platforms**: iOS, macOS (optimized for iOS design)

**Component Count**: 30+ components

**Available Components**:
- **Navigation & Layout**: Tab, Scaffold, TabBar, TabView
- **Dialogs & Sheets**: Alert Dialog, Action Sheet, Modal Popup, Context Menu
- **Lists**: List Section, List Tile
- **Forms**: Form Section, Form Row, TextField, Search Field
- **Pickers**: Date Picker, Time Picker
- **Controls**: Button, Switch, Slider, Segmented Control, Checkbox, Radio
- **Icons**: 1000+ SF Symbols
- **Colors**: Cupertino color system

**NPM Packages**:
- React: `@openwebf/react-cupertino-ui`
- Vue: `@openwebf/vue-cupertino-ui`

**Flutter Package**: `webf_cupertino_ui`

**Documentation**: https://openwebf.com/en/ui-components/cupertino

---

## When to Use Native UI vs HTML/CSS

### Use Cupertino UI When:
- ✅ Building iOS-style apps
- ✅ Need native-looking iOS forms, buttons, and controls
- ✅ Want 60fps native performance for complex UIs
- ✅ Building iOS lists, dialogs, or navigation patterns
- ✅ Need Apple's Human Interface Guidelines design language

### Use HTML/CSS When:
- ✅ Building custom designs that don't follow platform patterns
- ✅ Using existing web component libraries (e.g., Tailwind CSS)
- ✅ Need maximum flexibility in styling
- ✅ Porting existing web apps
- ✅ Building cross-platform designs (not platform-specific)

## Setup Instructions

### Step 1: Configure Flutter Project (Optional)

If you have access to the Flutter project hosting your WebF app:

**For Cupertino UI:**
1. Open your Flutter project's `pubspec.yaml`
2. Add the dependency:
   ```yaml
   dependencies:
     webf_cupertino_ui: ^1.0.0
   ```
3. Run: `flutter pub get`
4. Initialize in your main Dart file:
   ```dart
   import 'package:webf/webf.dart';
   import 'package:webf_cupertino_ui/webf_cupertino_ui.dart';

   void main() {
     WebFControllerManager.instance.initialize(WebFControllerManagerConfig(
       maxAliveInstances: 2,
       maxAttachedInstances: 1,
     ));

     // Install Cupertino UI components
     installWebFCupertinoUI();

     runApp(MyApp());
   }
   ```

### Step 2: Install NPM Packages (JavaScript/TypeScript)

**For React:**
```bash
npm install @openwebf/react-cupertino-ui
```

**For Vue:**
```bash
npm install @openwebf/vue-cupertino-ui
```

### Step 3: Using Components in Your Code

**React Example:**
```tsx
import { FlutterCupertinoButton, FlutterCupertinoTextField } from '@openwebf/react-cupertino-ui';

export function MyComponent() {
  return (
    <div>
      <FlutterCupertinoTextField
        placeholder="Enter your name"
        onChanged={(value) => console.log('Value:', value)}
      />
      <FlutterCupertinoButton
        variant="filled"
        onClick={() => console.log('Clicked')}
      >
        Submit
      </FlutterCupertinoButton>
    </div>
  );
}
```

**Vue Example:**
```vue
<template>
  <div>
    <FlutterCupertinoTextField
      placeholder="Enter your name"
      @changed="handleChange"
    />
    <FlutterCupertinoButton
      variant="filled"
      @click="handleClick"
    >
      Submit
    </FlutterCupertinoButton>
  </div>
</template>

<script setup>
import { FlutterCupertinoTextField, FlutterCupertinoButton } from '@openwebf/vue-cupertino-ui';

const handleChange = (value) => {
  console.log('Value:', value);
};

const handleClick = () => {
  console.log('Clicked');
};
</script>
```

## Component Reference

See the [Native UI Component Reference](./reference.md) for a complete list of available components and their properties.

## Common Patterns

### 1. Building an iOS-Style Form

```tsx
import {
  FlutterCupertinoFormSection,
  FlutterCupertinoFormRow,
  FlutterCupertinoTextField,
  FlutterCupertinoButton
} from '@openwebf/react-cupertino-ui';

export function ProfileForm() {
  return (
    <FlutterCupertinoFormSection header="Profile Information">
      <FlutterCupertinoFormRow label="Name">
        <FlutterCupertinoTextField placeholder="John Doe" />
      </FlutterCupertinoFormRow>
      <FlutterCupertinoFormRow label="Email">
        <FlutterCupertinoTextField
          placeholder="john@example.com"
          keyboardType="email"
        />
      </FlutterCupertinoFormRow>
      <FlutterCupertinoButton variant="filled">
        Save Changes
      </FlutterCupertinoButton>
    </FlutterCupertinoFormSection>
  );
}
```

### 2. Building a Settings Screen

```tsx
import {
  FlutterCupertinoListSection,
  FlutterCupertinoListTile,
  FlutterCupertinoSwitch
} from '@openwebf/react-cupertino-ui';

export function SettingsScreen() {
  return (
    <FlutterCupertinoListSection header="Settings">
      <FlutterCupertinoListTile
        title="Notifications"
        trailing={<FlutterCupertinoSwitch value={true} />}
      />
      <FlutterCupertinoListTile
        title="Dark Mode"
        trailing={<FlutterCupertinoSwitch value={false} />}
      />
    </FlutterCupertinoListSection>
  );
}
```

### 3. Showing a Native Dialog

```tsx
import { FlutterCupertinoAlertDialog } from '@openwebf/react-cupertino-ui';

export function ConfirmationDialog({ onConfirm, onCancel }) {
  return (
    <FlutterCupertinoAlertDialog
      title="Confirm Action"
      content="Are you sure you want to proceed?"
      actions={[
        { label: 'Cancel', onPress: onCancel },
        { label: 'Confirm', onPress: onConfirm, isDestructive: true }
      ]}
    />
  );
}
```

## Best Practices

### 1. Mix Native UI with HTML/CSS
You don't have to use native UI everywhere. Mix and match:
```tsx
// Use native components for platform-specific UIs
<FlutterCupertinoButton variant="filled">
  Save
</FlutterCupertinoButton>

// Use HTML/CSS for custom layouts
<div className="custom-layout">
  <h1>Custom Design</h1>
  <p>This uses regular HTML/CSS</p>
</div>
```

### 2. Use Native UI for Complex Components
Native UI components handle complex interactions better:
- Date pickers → Use `FlutterCupertinoDatePicker` instead of HTML input
- Sliders → Use `FlutterCupertinoSlider` for native feel
- Segmented controls → Use `FlutterCupertinoSegmentedControl`

### 3. Check Component Documentation
Always check the official documentation for component props and events:
- https://openwebf.com/en/ui-components/cupertino

### 4. Use TypeScript for Type Safety
All native UI packages include TypeScript definitions:
```tsx
import type { FlutterCupertinoButtonProps } from '@openwebf/react-cupertino-ui';

const buttonProps: FlutterCupertinoButtonProps = {
  variant: 'filled',
  onClick: () => console.log('Clicked')
};
```

## Troubleshooting

### Issue: Components Not Rendering

**Cause**: Flutter package not installed or initialized

**Solution**:
1. Check that the Flutter package is in `pubspec.yaml`
2. Verify `installWebFCupertinoUI()` is called in main.dart
3. Run `flutter pub get`
4. Rebuild your Flutter app

### Issue: TypeScript Errors for Components

**Cause**: NPM package not installed correctly

**Solution**:
```bash
# Reinstall the package
npm install @openwebf/react-cupertino-ui --save

# Clear node_modules and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Issue: Vue Components Not Found

**Cause**: Vue bindings need to be generated

**Solution**: Follow the "For Vue + Cupertino UI" steps in Step 2 above to generate Vue bindings using `webf codegen`.

### Issue: Props Don't Match Flutter Widget

**Cause**: WebF automatically converts between JavaScript and Dart naming

**Solution**:
- JavaScript uses camelCase: `onClick`, `onChange`, `placeholder`
- Flutter uses camelCase too, so props map directly
- Check documentation for exact prop names

## Resources

- **Component Gallery**: https://openwebf.com/en/ui-components
- **Cupertino UI Docs**: https://openwebf.com/en/ui-components/cupertino
- **WebF CLI Docs**: https://openwebf.com/en/docs/tools/webf-cli
- **React Examples**: https://github.com/openwebf/react-cupertino-gallery
- **Vue Examples**: https://github.com/openwebf/vue-cupertino-gallery

## Next Steps

After setting up native UI:

1. **Explore components**: Visit https://openwebf.com/en/ui-components to see all available components
2. **Check examples**: Look at the gallery apps for React and Vue
3. **Mix with HTML/CSS**: Use native UI where it makes sense, HTML/CSS elsewhere
4. **Performance**: Native UI components render at 60fps with Flutter-level performance

## Summary

- ✅ Native UI libraries provide pre-built, platform-specific components
- ✅ Cupertino UI for iOS-style apps (30+ components available now)
- ✅ Form UI for validated forms (available now)
- ✅ Material UI coming soon for Android-style apps
- ✅ Install Flutter packages first, then npm packages
- ✅ Mix native UI with HTML/CSS as needed
- ✅ Better performance than HTML/CSS for complex UIs
- ✅ Full React and Vue support
