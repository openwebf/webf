---
sidebar_position: 4
title: Cascade and Inheritance
---

WebF supports cascade and inheritance in CSS.

## Cascade support in CSS

The cascade is a fundamental concept in CSS that defines how webf/browser should determine the final value for a CSS
property on an element when there might be multiple conflicting rules.

The cascade determines the priority of different
styles based on their specificity, and order of declaration.

1. Specificity: This determines which CSS rule is applied by the browser based on which rule is more specific or
   targeted to an element.
   Inline styles (e.g., style="color: red;" on an element) have the highest specificity.
   ID selectors have higher specificity than class, attribute, and pseudo-class selectors.
   Class, attribute, and pseudo-class selectors have higher specificity than type selectors (e.g., h1).
   Universal selectors (*), combinators (+, >, ~, ' ') and the negation pseudo-class (:not()) have no specificity.
2. Order of declaration: If multiple rules have equal specificity, the last rule declared wins.
3. Importance: The !important annotation on a style can override styles based on the factors mentioned above. However,
   it's worth noting that over-reliance on !important is generally discouraged as it can make stylesheets difficult to
   understand and maintain.

An example to illustrate:

```css
/* This has lower specificity */
div {
    color: blue;
}

/* This has higher specificity because it targets an ID */
#myDiv {
    color: red;
}

/* This comes later and would override previous styles with equal specificity */
div {
    color: green;
}
```

In the above, an element with the ID "myDiv" would be colored red, despite the later rule, because ID selectors have
higher specificity.

## Inheritance in CSS

Inheritance is a key concept in CSS that pertains to the way certain properties are passed from parent elements to their
descendants (children, grandchildren, etc.).

When you set a style on an element, some properties of that style will automatically be applied to its descendant
elements unless specified otherwise. This behavior helps reduce redundancy.

For example, if you set the color property on a parent element, its child elements will inherit that color by default:

```css
/* CSS */
div {
    color: red;
}

```

```html
<!-- HTML -->
<div>
    This text is red.
    <p>This paragraph text is also red because it inherits the color from the parent div.</p>
</div>
```

The following list contains all the CSS properties for which WebF currently supports inheritance:

1. `color`
2. `font-family`
3. `font-size`
4. `font-style`
5. `font-weight`
6. `font`
7. `line-height`
8. `text-align`
9. `visibility`
