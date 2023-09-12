---
sidebar_position: 10
title: Background and Borders
---

Both background and borders play a crucial role in styling and visually differentiating elements on a web page. 

## Background

The background property in CSS is used to set the background effects for an element. 

It's a shorthand property, meaning it can be used to set several background properties at once.

### Properties:

**background-color**: Sets the background color of an element.
```css
div {
   background-color: red;
}
 ```

**background-image**: Sets one or more background images for an element.
```css
div {
   background-image: url('path/to/image.jpg');
}
 ```

**background-repeat**: Sets if/how a background image will be repeated.
```css
div {
   background-repeat: no-repeat; /* Other values: repeat, repeat-x, repeat-y */
}
 ```

**background-position**: Sets the starting position of a background image.
```css
div {
   background-position: center center; /* Can use values like top, bottom, left, right, or percentages */
}
 ```

**background-size**: Specifies the size of the background images.
```css
div {
   background-size: cover; /* Other values: contain, 50% 50%, auto */
}
```

**background-attachment**: Determines whether the background image scrolls with the content or remains fixed.
```css
div {
   background-attachment: fixed; /* Other value: scroll */
}
```

**background-clip**: Determines the painting area of the background.
```css
div {
   background-clip: border-box; /* Other values: padding-box, content-box */
}
```

**background-origin**: Determines the positioning area of the background images.
```css
div {
   background-origin: padding-box; /* Other values: border-box, content-box */
}
```

### Shorthand:

You can combine multiple background properties into one using the shorthand:
```css
div {
    background: red url('path/to/image.jpg') no-repeat center center / cover;
}
```

## Borders

The `border` property is used to set the borders around an element.

### Properties:

**border-width**: Sets the width of the borders.
```css
div {
    border-width: 2px;
}
```

**border-style**: Sets the style of the borders (e.g., solid).

```css
div {
   border-style: solid;
}
```

**border-color**: Sets the color of the borders.
```css
div {
   border-color: blue;
}
```

**border-radius**: Used to round the corners of an element.
```css
div {
   border-radius: 10px;
}
```

### Individual Sides:

You can also target individual sides of an element:
```css
div {
    border-top: 2px solid blue;
    border-right: 3px dashed red;
    border-bottom: 4px dotted green;
    border-left: 5px double purple;
}
```

### Shorthand:

The shorthand for setting borders is:
```css
div {
    border: 2px solid blue;
}
```