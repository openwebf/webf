# WebF Form

WebF custom elements for building validated forms with native Flutter widgets.

## Features

- ✅ `<flutter-form>` container with submit/reset helpers
- ✅ `<flutter-form-field>` inputs with label + vertical/horizontal layout
- ✅ Built-in validation (required, length, email/url, min/max, enum)
- ✅ JavaScript events: `submit`, `validation-error`, `reset`
- ✅ `webf codegen` support for React/Vue typings

## Getting started

Add the dependency:

```yaml
dependencies:
  webf_form: ^1.0.0
```

## Usage

### 1) Register custom elements (Dart)

```dart
import 'package:webf_form/webf_form.dart';

void main() {
  installWebFForm();
  // runApp(...)
}
```

### 2) Use in React

Install the published React bindings package (provided by the WebF team/your vendor):

```bash
npm i @openwebf/react-form
```

```tsx
import { useRef } from 'react';
import { FlutterForm, FlutterFormElement, FlutterFormField } from '@openwebf/react-form';

export function ProfileForm() {
  const ref = useRef<FlutterFormElement>(null);

  return (
    <>
      <FlutterForm
        ref={ref}
        layout="vertical"
        validateOnSubmit
        onSubmit={() => console.log(ref.current?.getFormValues())}
        onValidationError={() => console.log('invalid')}
      >
        <FlutterFormField name="email" label="Email" type="email" required placeholder="name@example.com" />
      </FlutterForm>

      <button onClick={() => ref.current?.validateAndSubmit()}>Submit</button>
    </>
  );
}
```

### 3) Use in Vue

Install the published Vue typings package (provided by the WebF team/your vendor):

```bash
npm i -D @openwebf/vue-form
```

Make sure TypeScript loads the global component typings (pick one):

```ts
// src/env.d.ts (or anywhere that runs/types are included)
import '@openwebf/vue-form';
```

```vue
<template>
  <flutter-form validate-on-submit layout="vertical" @submit="onSubmit" @validation-error="onInvalid">
    <flutter-form-field name="email" label="Email" type="email" required placeholder="name@example.com" />
  </flutter-form>
</template>
```

### 4) Use in plain HTML/JS (WebF)

```html
<flutter-form id="profile" validate-on-submit layout="vertical">
  <flutter-form-field name="email" label="Email" type="email" required placeholder="name@example.com"></flutter-form-field>
  <flutter-form-field name="age" label="Age" type="number" placeholder="18"></flutter-form-field>
</flutter-form>

<button id="submit">Submit</button>
<button id="reset">Reset</button>
```

```js
const form = document.querySelector('#profile');

form.addEventListener('submit', () => {
  const values = form.getFormValues();
  console.log('values:', values);
});

form.addEventListener('validation-error', () => {
  console.log('invalid');
});

document.querySelector('#submit').addEventListener('click', () => form.validateAndSubmit());
document.querySelector('#reset').addEventListener('click', () => form.resetForm());
```

### 5) Validation rules (optional)

```js
const emailField = document.querySelector('flutter-form-field[name="email"]');

emailField.setRules([
  { required: true, message: 'Email is required' },
  { type: 'email', message: 'Please enter a valid email' },
]);
```

## Additional information

- `validate-on-submit`: when enabled, `validateAndSubmit()` dispatches `validation-error` on failure; when disabled it always dispatches `submit` after `save()`.
- `autovalidate`: shows validation errors during user interaction (or after the first submit attempt when `validate-on-submit` is enabled).
