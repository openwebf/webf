---
sidebar_position: 5
title: Value and Units
---

In CSS, "values" and "units" are fundamental concepts that specify how styles are applied to web content.

## Supported Values

value in CSS refers to the specific settings assigned to properties to control the styling of an element. Values
dictate how properties influence the display and behavior of content. They can take a variety of forms, such as:

1. Keywords: Pre-defined names that are recognized by browsers. For example, for the display property, you can use
   keywords
   like block, inline, and none.

  ```css
  div {
    display: block;
}
  ```

2. Numbers: Some properties accept simple numeric values. For instance, the z-index property can accept an integer to
   determine stacking order.

  ```css
  .overlay {
    z-index: 10;
}
  ```

3. Lengths: A number followed by a length unit, such as px, em, rem, etc.

  ```css
  p {
    margin: 20px;
    font-size: 1.5rem;
}
  ```

4. Percentages: Often relative to some other value, like the size of a parent element.

  ```css
  img {
    width: 50%;
}
  ```

5. Colors: Values that specify colors, and can be written in various ways:

+ Named colors: red, green, blue, etc.
+ Hexadecimal: #FF0000, #00FF00, #0000FF, etc.
+ RGB: rgb(255, 0, 0), rgb(0, 255, 0), rgb(0, 0, 255), etc.
+ RGBA (with alpha for transparency): rgba(255, 0, 0, 0.5)
+ HSL: hsl(120, 100%, 50%)
+ HSLA (with alpha for transparency): hsla(120, 100%, 50%, 0.5)

  ```css
  div {
    background-color: rgba(255, 255, 255, 0.5);
  }

  ```

6. URLs: Used for properties that require a link to an external resource, like images.

  ```css
  div {
    background-image: url("path/to/image.jpg");
  }
  ```

7. Strings: Certain properties accept textual data, usually encapsulated in quotes.

  ```css
  ::before {
    content: "Hello!";
}
  ```

8. Functional Notations: Functions that take specific arguments and are used to achieve certain effects or
   representations. Examples include calc(), linear-gradient(), radial-gradient(), rotate(), and many others.

  ```css
  div {
    width: calc(100% - 20px);
    background: linear-gradient(red, blue);
}
  ```

9. Global Values: These are values that can be used for any CSS property. They include:

+ inherit: Takes the computed value of the property for the element's parent.
+ initial: Uses the initial (default) value for that property.

Each CSS property has a predefined set of valid values it can accept. Using an invalid value for a property will lead to
the property being ignored by webf.

## Supported Units

units are essential for determining dimensions, spacings, font sizes, and more.

Here's an in-depth look:

1. Absolute Length Units: These are fixed units and aren't affected by the size of the parent element or viewport. They're not always suitable for responsive designs, but they have their use cases.
   + px (Pixels): The most common unit, especially in screen media. Represents a single pixel on the screen.
   + pt (Points): Traditionally used in print media. 1pt = 1/72 of an inch.
   + pc (Picas): 1pc = 12pt.
   + mm (Millimeters), cm (Centimeters), in (Inches): Physical length units. Their exact rendering can vary depending on the screen's DPI (dots per inch).
2. Relative Length Units: These units are relative to other sizes, like the size of the parent element or the viewport, making them ideal for responsive designs.
   + em: Relative to the font size of the element itself. If the font size isn't defined, it's relative to the parent. For instance, if an element has a font size of 20px, 1em will equal 20px for that element.
   + rem (Root EM): Relative to the font size of the root element (`<html>`), usually set by browsers to 16px by default.
3. Viewport-percentage Lengths: They are relative to the size of the viewport (the visible area of the browser window).
   + vw (Viewport Width): Represents 1% of the viewport's width.
   + vh (Viewport Height): Represents 1% of the viewport's height.
   + vmin: The lesser of vw and vh.
   + vmax: The greater of vw and vh.
4. Percentage: Often relative to the size of a parent element. For instance, if a container is 500px wide, a child element with a width of 50% would be 250px wide.
5. Time Units: Used for animations and transitions.
   + s (Seconds)
   + ms (Milliseconds): 1 second is equivalent to 1000 milliseconds.
6. Angle Units: Often used for rotating elements and gradient angles.
   + deg (Degrees): There are 360 degrees in a full circle.
   + rad (Radians): A full circle is approximately 6.28319 radians.
   + grad (Gradians): A full circle is 400 gradians.
   + turn: Represents a full circle (or a rotation of 360 degrees).