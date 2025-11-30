# WebF Cupertino UI Examples

This guide provides a collection of examples for using the pre-built Flutter Cupertino widgets available in the `@openwebf/react-cupertino-ui` package.

## Installation

First, make sure you have the package installed in your project:
```bash
npm install @openwebf/react-cupertino-ui
```

---

## Components

### FlutterCupertinoButton

The `FlutterCupertinoButton` component renders a native iOS-style button.

**Props:**
*   `onClick`: `() => void` - A callback for when the button is pressed.
*   `disabled`: `boolean` - If `true`, the button will be non-interactive.
*   `variant`: `'filled' | 'outline'` - The visual style of the button.

**Example:**
```jsx
import { FlutterCupertinoButton } from '@openwebf/react-cupertino-ui';

function ButtonExample() {
  return (
    <>
      <FlutterCupertinoButton onClick={() => alert('Clicked!')}>
        Default Button
      </FlutterCupertinoButton>

      <FlutterCupertinoButton variant="filled" onClick={() => alert('Clicked!')}>
        Filled Button
      </FlutterCupertinoButton>

      <FlutterCupertinoButton disabled={true}>
        Disabled Button
      </FlutterCupertinoButton>
    </>
  );
}
```

---

### FlutterCupertinoSwitch

The `FlutterCupertinoSwitch` component renders a native iOS-style switch.

**Props:**
*   `checked`: `boolean` - Whether the switch is on or off.
*   `onChange`: `(event) => void` - Callback for when the switch value changes. The new value is in `event.detail.checked`.

**Example:**
```jsx
import { useState } from 'react';
import { FlutterCupertinoSwitch } from '@openwebf/react-cupertino-ui';

function SwitchExample() {
  const [isChecked, setIsChecked] = useState(false);

  // The checked status is passed in the event's detail property
  const handleChange = (event) => {
    setIsChecked(event.detail.checked);
  };

  return (
    <FlutterCupertinoSwitch
      checked={isChecked}
      onChange={handleChange}
    />
  );
}
```

---

### FlutterCupertinoSlider

The `FlutterCupertinoSlider` component renders a native iOS-style slider.

**Props:**
*   `value`: `number` - The current value of the slider.
*   `min`: `number` - The minimum value.
*   `max`: `number` - The maximum value.
*   `onChange`: `(event) => void` - Callback for when the value changes. The new value is in `event.detail.value`.

**Example:**
```jsx
// [To be filled in with a code example]
```

---

### FlutterCupertinoActivityIndicator

The `FlutterCupertinoActivityIndicator` component renders a native iOS-style loading spinner.

**Props:**
*   `animating`: `boolean` - Whether the indicator is spinning. Defaults to `true`.
*   `radius`: `number` - The radius of the indicator.

**Example:**
```jsx
// [To be filled in with a code example]
```
---

*More components and examples to be added.*
