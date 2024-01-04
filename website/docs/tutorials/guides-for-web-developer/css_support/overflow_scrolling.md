---
sidebar_position: 5
title: Overflow and Scrolling
---

## Overflowing content

The `overflow` property in CSS is used to control what happens when content overflows its box.

This can be especially relevant for elements that have a fixed width and height. The overflow can be caused by content (
like text or images) that's too large, or by content that's dynamically added to an element, such as with JavaScript.

The overflow property has several values:

**visible (default)**: Content is not clipped, and it renders outside the element's box.

```css
div {
  overflow: visible;
}
```

**hidden**: Content is clipped, and any content that overflows the element's box will be hidden.

```css
div {
  overflow: hidden;
}
```

**scroll**: Content is clipped, but a scrollbar is always added to the element, even if the content does not overflow.

```css
div {
    overflow: scroll;
}
```

**auto**: Content is clipped, and a scrollbar is added only if the content overflows the element's box.

```css
div {
  overflow: auto;
}
```

### Separate Overflow for Horizontal and Vertical:

You can also control the overflow behavior separately for the horizontal and vertical axes using overflow-x and overflow-y:

```css
div {
  overflow-x: auto;    /* Horizontal overflow */
  overflow-y: hidden;  /* Vertical overflow */
}
```