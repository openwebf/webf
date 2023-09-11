---
sidebar_position: 9
title: Box Shadow and Filters
---

Both box-shadow and filter are CSS properties that allow you to enhance the visual appearance of elements.

Let's dive into each of them:

## Box Shadow

The box-shadow property is used to add shadow effects around an element's frame.

You can set multiple effects separated by commas. 

A box shadow is described by X and Y offsets relative to the element, blur and spread radii, and a color.

Syntax:
```css
box-shadow: [horizontal offset] [vertical offset] [blur radius] [optional spread radius] [color];
```

Examples:

- **Simple Shadow**:
  ```css
  box-shadow: 5px 5px 5px #888888;
  ```

- **Shadow with Spread**:
  ```css
  box-shadow: 5px 5px 5px 10px #888888;
  ```

- **Inset Shadow** (shadow inside the element):
  ```css
  box-shadow: inset 5px 5px 5px #888888;
  ```

- **Multiple Shadows**:
  ```css
  box-shadow: 3px 3px 5px #666, -3px -3px 5px #ccc;
  ```

## Filters:

The `filter` property provides visual effects like blurring or color shifting an element. Filters are commonly used to adjust the rendering of images, backgrounds, and borders.

Here are some of the functions you can use with the `filter` property:

- **`blur()`**: Applies a Gaussian blur to the element.
  ```css
  filter: blur(5px);
  ```

- **`grayscale()`**: Converts the element to grayscale.
  ```css
  filter: grayscale(100%); /* Full grayscale */
  ```

- **`sepia()`**: Converts the element to sepia.
  ```css
  filter: sepia(100%); /* Full sepia */
  ```

You can also chain multiple filter functions together:
```css
filter: grayscale(50%) blur(5px);
```


