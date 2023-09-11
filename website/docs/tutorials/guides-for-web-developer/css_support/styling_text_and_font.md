---
sidebar_position: 6
title: Styling Text and Fonts
---

## Styling text

Text broad category of properties and values that deal with the styling and arrangement of textual content within a
webf/web document.

These properties allow you to adjust the appearance and layout of text elements.

1. text-align:
   + Specifies the horizontal alignment of text.
   + Values: left, right, center, justify.
   ```css
   p {
      text-align: center;
   }
   ```
2. text-decoration:
   + Specifies the decoration added to text.
   + Values: none, underline, overline, line-through.
   ```css
   a {
      text-decoration: none; /* Typically used to remove underlines from hyperlinks */
   }
   ```
3. word-spacing:
   + Specifies the space between words.

   ```css
   p {
     word-spacing: 1em;
   }
   ```
4. white-space:
   + Specifies how whitespace inside an element is handled.
   + Values: normal, nowrap, pre, pre-line, pre-wrap.
   ```css
   pre {
      white-space: pre; /* Preserves whitespace and newlines */
   }
   ```
5. text-shadow:
   + Applies a shadow to text.
   + Requires horizontal shadow, vertical shadow, and color values. Optional: blur radius.

   ```css
   h1 {
     text-shadow: 2px 2px 4px #000;
   }
   ```
6. text-overflow:
+ Specifies how overflowed content that is not displayed should be signaled to the user.
+ Values: clip, ellipsis, fade.

   ```css
   p {
     text-overflow: ellipsis;
   }
   ```

## Font

Fonts allowing developers to specify and manipulate font styles. Here's an overview of how fonts supported in webf:

1. Font-Family:
   The font-family property specifies which font should be used for text within an element. It can be a specific font
   like "Arial", or a generic font family like sans-serif.

  ```css
  p {
    font-family: "Times New Roman", Times, serif;
}
  ```

It's common to provide multiple font families as fallbacks. If the webf does not support the first font, it tries the
next font in the list.

2. Font-Size:
   The font-size property sets the size of the font.

  ```css
  h1 {
    font-size: 2em;
}
  ```

You can use units like px, em, rem, %, vw, etc. to specify font sizes.

3. Font-Weight:
   The font-weight property defines the thickness of the characters in a font.

  ```css
  strong {
    font-weight: bold;
}
  ```

Acceptable values include normal, bold, bolder, lighter, and numbers from 100 to 900.

4. Font-Style:
   The font-style property is used to define if the font should be italic or not.

  ```css
  em {
    font-style: italic;
}
  ```

Common values include normal, italic.

5. Line-Height:
   The line-height property specifies the height of a line and can help improve text readability.

  ```css
  p {
    line-height: 1.5;
}
  ```

6. @font-face:

   The @font-face rule allows custom fonts to be loaded on a webpage. This rule must be followed by a set of descriptors
   that define the font's style and the URI of the font file.

  ```css
    @font-face {
    font-family: "MyCustomFont";
    src: url("path/to/font.otf") format("otf");
}
  ```

WebF supports the following font formats:

  ```
    1. .ttc
    2. .ttf
    3. .otf
  ```

WebF does not support .woff and .woff2 fonts.

7. Font Shorthand:
   The font property is a shorthand property for setting font-style, font-variant, font-weight, font-size, line-height,
   and font-family all at once.
  ```css
  p {
    font: italic bold 1em/1.5 "Arial", sans-serif;
}
  ```