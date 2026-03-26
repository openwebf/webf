# Native UI Component Reference

This reference lists all available native UI components in WebF's native UI libraries.

## Cupertino UI Components (iOS-style)

### Navigation & Layout

#### FlutterCupertinoTabScaffold
Creates a tabbed application structure with tab bar.

**Props**:
- `tabs` - Array of tab definitions
- `initialIndex` - Starting tab index (default: 0)

**Example**:
```tsx
<FlutterCupertinoTabScaffold
  tabs={[
    { label: 'Home', icon: 'house' },
    { label: 'Profile', icon: 'person' }
  ]}
  initialIndex={0}
/>
```

#### FlutterCupertinoTabBar
Bottom tab bar for navigation.

**Props**:
- `items` - Array of tab bar items
- `currentIndex` - Active tab index
- `onTap` - Callback when tab is tapped

**Example**:
```tsx
<FlutterCupertinoTabBar
  items={[
    { icon: 'house', label: 'Home' },
    { icon: 'person', label: 'Profile' }
  ]}
  currentIndex={0}
  onTap={(index) => console.log('Tab:', index)}
/>
```

#### FlutterCupertinoTabView
Content container for tab views.

**Props**:
- `children` - Tab content
- `builder` - Optional builder function

---

### Buttons & Actions

#### FlutterCupertinoButton
iOS-style button with multiple variants.

**Props**:
- `variant` - Button style: `'filled'`, `'text'`, or `'plain'` (default: `'text'`)
- `onClick` - Click handler
- `disabled` - Disable button (default: false)
- `children` - Button label/content
- `color` - Custom button color
- `padding` - Custom padding

**Example**:
```tsx
<FlutterCupertinoButton
  variant="filled"
  onClick={() => console.log('Clicked')}
  disabled={false}
>
  Continue
</FlutterCupertinoButton>
```

---

### Dialogs & Overlays

#### FlutterCupertinoAlertDialog
Native iOS alert dialog.

**Props**:
- `title` - Dialog title
- `content` - Dialog message/content
- `actions` - Array of action buttons
  - `label` - Button text
  - `onPress` - Button callback
  - `isDestructive` - Red destructive style (default: false)
  - `isDefaultAction` - Bold default style (default: false)

**Example**:
```tsx
<FlutterCupertinoAlertDialog
  title="Delete Item"
  content="Are you sure you want to delete this item? This action cannot be undone."
  actions={[
    { label: 'Cancel', onPress: () => {} },
    { label: 'Delete', onPress: () => {}, isDestructive: true }
  ]}
/>
```

#### FlutterCupertinoActionSheet
Bottom sheet with action options.

**Props**:
- `title` - Sheet title
- `message` - Sheet message
- `actions` - Array of action buttons
- `cancelButton` - Cancel button configuration

**Example**:
```tsx
<FlutterCupertinoActionSheet
  title="Select Option"
  message="Choose an action to perform"
  actions={[
    { label: 'Option 1', onPress: () => {} },
    { label: 'Option 2', onPress: () => {} }
  ]}
  cancelButton={{ label: 'Cancel', onPress: () => {} }}
/>
```

#### FlutterCupertinoModalPopup
Generic modal popup container.

**Props**:
- `children` - Popup content
- `onDismiss` - Callback when dismissed

**Example**:
```tsx
<FlutterCupertinoModalPopup onDismiss={() => console.log('Dismissed')}>
  <div style={{ padding: '20px', background: 'white' }}>
    <h2>Modal Content</h2>
  </div>
</FlutterCupertinoModalPopup>
```

#### FlutterCupertinoContextMenu
Long-press context menu.

**Props**:
- `actions` - Array of menu actions
- `children` - Trigger element

**Example**:
```tsx
<FlutterCupertinoContextMenu
  actions={[
    { label: 'Copy', onPress: () => {} },
    { label: 'Delete', onPress: () => {}, isDestructive: true }
  ]}
>
  <img src="photo.jpg" alt="Photo" />
</FlutterCupertinoContextMenu>
```

---

### Lists

#### FlutterCupertinoListSection
Grouped list section with header/footer.

**Props**:
- `header` - Section header text
- `footer` - Section footer text
- `children` - List items (FlutterCupertinoListTile)

**Example**:
```tsx
<FlutterCupertinoListSection header="Settings">
  <FlutterCupertinoListTile title="Notifications" />
  <FlutterCupertinoListTile title="Privacy" />
</FlutterCupertinoListSection>
```

#### FlutterCupertinoListTile
Individual list item.

**Props**:
- `title` - Main title text
- `subtitle` - Optional subtitle text
- `leading` - Leading widget/icon
- `trailing` - Trailing widget/icon
- `onTap` - Tap callback
- `additionalInfo` - Right-side info text

**Example**:
```tsx
<FlutterCupertinoListTile
  title="Notifications"
  subtitle="Push and email notifications"
  trailing={<FlutterCupertinoSwitch value={true} />}
  onTap={() => console.log('Tapped')}
/>
```

---

### Forms

#### FlutterCupertinoFormSection
Form section container with header.

**Props**:
- `header` - Section header text
- `footer` - Section footer text
- `children` - Form rows

**Example**:
```tsx
<FlutterCupertinoFormSection header="Profile">
  <FlutterCupertinoFormRow label="Name">
    <FlutterCupertinoTextField placeholder="John Doe" />
  </FlutterCupertinoFormRow>
</FlutterCupertinoFormSection>
```

#### FlutterCupertinoFormRow
Form row with label and input.

**Props**:
- `label` - Row label text
- `children` - Input widget
- `error` - Error message text
- `helper` - Helper text

**Example**:
```tsx
<FlutterCupertinoFormRow label="Email" error="Invalid email">
  <FlutterCupertinoTextField placeholder="email@example.com" />
</FlutterCupertinoFormRow>
```

---

### Text Input

#### FlutterCupertinoTextField
Native iOS text field.

**Props**:
- `placeholder` - Placeholder text
- `value` - Current value
- `onChanged` - Change handler
- `keyboardType` - Keyboard type: `'text'`, `'email'`, `'number'`, `'phone'`, `'url'`
- `obscureText` - Hide text (for passwords, default: false)
- `maxLines` - Maximum lines (default: 1)
- `readOnly` - Read-only mode (default: false)
- `autofocus` - Auto-focus on mount (default: false)
- `clearButtonMode` - Show clear button: `'never'`, `'always'`, `'editing'`, `'notEditing'`

**Example**:
```tsx
<FlutterCupertinoTextField
  placeholder="Enter your name"
  value={name}
  onChanged={(value) => setName(value)}
  keyboardType="text"
  clearButtonMode="editing"
/>
```

#### FlutterCupertinoSearchTextField
Search field with search icon and clear button.

**Props**:
- `placeholder` - Placeholder text (default: "Search")
- `value` - Current value
- `onChanged` - Change handler
- `onSubmitted` - Submit handler

**Example**:
```tsx
<FlutterCupertinoSearchTextField
  placeholder="Search items"
  value={searchQuery}
  onChanged={(value) => setSearchQuery(value)}
  onSubmitted={(value) => performSearch(value)}
/>
```

---

### Pickers

#### FlutterCupertinoDatePicker
Native iOS date picker.

**Props**:
- `mode` - Picker mode: `'date'`, `'time'`, `'dateTime'`
- `initialDate` - Starting date (ISO string)
- `minimumDate` - Minimum selectable date
- `maximumDate` - Maximum selectable date
- `onDateTimeChanged` - Date change handler

**Example**:
```tsx
<FlutterCupertinoDatePicker
  mode="date"
  initialDate="2024-01-01T00:00:00.000Z"
  onDateTimeChanged={(date) => console.log('Selected:', date)}
/>
```

---

### Controls

#### FlutterCupertinoSwitch
Native iOS toggle switch.

**Props**:
- `value` - Switch state (boolean)
- `onChanged` - Change handler
- `activeColor` - Color when active

**Example**:
```tsx
<FlutterCupertinoSwitch
  value={isEnabled}
  onChanged={(value) => setIsEnabled(value)}
  activeColor="#007AFF"
/>
```

#### FlutterCupertinoSlider
Native iOS slider.

**Props**:
- `value` - Current value (0.0 to 1.0)
- `onChanged` - Change handler
- `min` - Minimum value (default: 0.0)
- `max` - Maximum value (default: 1.0)
- `divisions` - Number of discrete divisions
- `activeColor` - Track color when active

**Example**:
```tsx
<FlutterCupertinoSlider
  value={volume}
  onChanged={(value) => setVolume(value)}
  min={0}
  max={100}
  divisions={100}
/>
```

#### FlutterCupertinoSegmentedControl
Segmented control for mutually exclusive choices.

**Props**:
- `children` - Map of segment widgets `{ '0': <Widget />, '1': <Widget /> }`
- `groupValue` - Currently selected value
- `onValueChanged` - Selection change handler

**Example**:
```tsx
<FlutterCupertinoSegmentedControl
  children={{
    '0': <span>Day</span>,
    '1': <span>Week</span>,
    '2': <span>Month</span>
  }}
  groupValue={selectedPeriod}
  onValueChanged={(value) => setSelectedPeriod(value)}
/>
```

#### FlutterCupertinoCheckbox
iOS-style checkbox.

**Props**:
- `value` - Checked state (boolean)
- `onChanged` - Change handler
- `activeColor` - Color when checked

**Example**:
```tsx
<FlutterCupertinoCheckbox
  value={isChecked}
  onChanged={(value) => setIsChecked(value)}
/>
```

#### FlutterCupertinoRadio
iOS-style radio button.

**Props**:
- `value` - Radio value
- `groupValue` - Selected value in group
- `onChanged` - Change handler

**Example**:
```tsx
<FlutterCupertinoRadio
  value="option1"
  groupValue={selectedOption}
  onChanged={(value) => setSelectedOption(value)}
/>
```

---

### Icons & Colors

#### FlutterCupertinoIcon
iOS SF Symbols icons.

**Props**:
- `name` - SF Symbol name (e.g., `'house'`, `'person'`, `'gear'`)
- `size` - Icon size (default: 28)
- `color` - Icon color

**Example**:
```tsx
<FlutterCupertinoIcon name="house" size={24} color="#007AFF" />
```

**Common SF Symbols**:
- Navigation: `'house'`, `'magnifyingglass'`, `'person'`, `'gear'`, `'ellipsis'`
- Actions: `'plus'`, `'minus'`, `'checkmark'`, `'xmark'`, `'trash'`
- Media: `'play.fill'`, `'pause.fill'`, `'heart.fill'`, `'star.fill'`
- Communication: `'message.fill'`, `'envelope.fill'`, `'phone.fill'`

---

## Component Naming Conventions

### React
All components use PascalCase with `Flutter` prefix:
```tsx
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';

<FlutterCupertinoButton variant="filled">Click Me</FlutterCupertinoButton>
```

### Vue
Components use PascalCase (not kebab-case) in templates:
```vue
<template>
  <FlutterCupertinoButton variant="filled">
    Click Me
  </FlutterCupertinoButton>
</template>

<script setup>
import { FlutterCupertinoButton } from '@openwebf/vue-cupertino-ui';
</script>
```

---

## TypeScript Support

All native UI packages include full TypeScript definitions:

```tsx
import type {
  FlutterCupertinoButtonProps,
  FlutterCupertinoTextFieldProps,
  FlutterCupertinoSwitchProps
} from '@openwebf/react-cupertino-ui';

const buttonProps: FlutterCupertinoButtonProps = {
  variant: 'filled',
  onClick: () => console.log('Clicked')
};
```

---

## Event Handlers

### Common Event Props
- `onClick` / `onTap` - Tap/click events
- `onChanged` - Value change events
- `onSubmitted` - Form submission events
- `onDismiss` - Dismiss/close events
- `onFocus` / `onBlur` - Focus events

### Event Data
Most events pass the new value directly:
```tsx
// Switch
<FlutterCupertinoSwitch
  value={enabled}
  onChanged={(newValue) => setEnabled(newValue)}
/>

// Text field
<FlutterCupertinoTextField
  value={text}
  onChanged={(newText) => setText(newText)}
/>
```

---

## Styling Native Components

### Using CSS Classes
Native components can have CSS classes for layout:
```tsx
<FlutterCupertinoButton className="my-button-wrapper">
  Click Me
</FlutterCupertinoButton>
```

```css
.my-button-wrapper {
  margin: 20px;
  width: 200px;
}
```

### Custom Colors
Many components accept color props:
```tsx
<FlutterCupertinoButton
  variant="filled"
  color="#FF3B30"
>
  Delete
</FlutterCupertinoButton>

<FlutterCupertinoSwitch
  value={true}
  activeColor="#34C759"
/>
```

### Note on Styling Limitations
Native UI components render as Flutter widgets, so:
- ✅ Can control: position, size, margin, padding (via wrapper)
- ❌ Cannot control: internal styling, fonts, borders (use Flutter theming)

---

## Resources

- **Official Documentation**: https://openwebf.com/en/ui-components
- **Cupertino Gallery**: https://openwebf.com/en/ui-components/cupertino
- **SF Symbols Browser**: https://developer.apple.com/sf-symbols/
- **Form Validation**: https://pub.dev/packages/form_builder_validators

---

## Getting Help

- **Component not working?** Check that the Flutter package is installed and initialized
- **TypeScript errors?** Ensure the npm package is installed correctly
- **Props not working?** Check the official documentation for the exact prop names
- **Vue components?** Generate bindings using `webf codegen` command
