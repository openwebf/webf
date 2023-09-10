---
sidebar_position: 5
title: The Box Model
---

The box model in CSS describes the layout and design properties of elements as rectangular boxes, detailing how they are
sized, padded, bordered, and margined. The box model is fundamental to understanding how space is
managed and elements are displayed in webf/web design.

Each box in the box model consists of the following components, from the innermost to the outermost:

1. Content: This is the main content of the box, where text, images, or other media are displayed. The dimensions of the
   content box can be controlled using the width and height properties.

2. Padding: This is the space between the content of the box and its border. Padding does not have any color by default,
   but it will show the background color of the box. You can control padding with properties like padding-top,
   padding-right, padding-bottom, and padding-left or the shorthand padding.

3. Border: This is a potentially visible boundary around the padding and content. It can have a style, width, and color.
   The border is controlled with properties like border-style, border-width, border-color, and their specific variations
   for each side (e.g., border-top-width).

4. Margin: This is the outermost layer of the box, and it represents the space between the box's border and the
   neighboring
   elements. Margin is transparent and doesn't show any color, not even the background color of the element. You can
   control the margin with properties like margin-top, margin-right, margin-bottom, and margin-left or the shorthand
   margin.

The following diagram shows how these areas relate and the terminology used to refer to the various parts of the box:

![img](./imgs/box_model.png)

When you set the width and height of an element, you're typically setting the size of the content area. However, the
actual space the box takes up on a page is influenced by the padding, border, and margin. So, if you have an element
with a width of 300px, padding of 10px on all sides, a border of 2px on all sides, and a margin of 15px on all sides,
the total width it occupies on the page would be:

```
Total width = width + left padding + right padding + left border + right border + left margin + right margin
            = 300px + 10px + 10px + 2px + 2px + 15px + 15px
            = 354px
```

One important concept to understand with the box model is the box-sizing property:

+ content-box: The width and height properties set the size of the content box, not including padding and
  border.

+ border-box (default for webf): The width and height properties include content, padding, and border, but not the
  margin.

:::caution

From now on, WebF only supports the `box-sizing: border-box` mode. Setting the `box-sizing` property to `content-box` will have no effect until WebF is released with `content-box` support.

:::