---
sidebar_position: 3
title: Selectors
---

WebF currently supports the following list of selectors:

1. [Element selectors](#element-selector)
2. [Attribute selectors](#attribute-selector)
3. [Subsets support of pseudo selectors](#subsets-support-of-pseudo-selectors)

## Element selector

Elemental selectors are a group of selectors used to match DOM elements.

### Type (tag name) selector

The type selector, often referred to as the tag name selector or element selector, in CSS is used to select and style
all elements of a given type (i.e., with a specified tag name) in webf.

The selector targets elements based on their node (tag) name. For example:

**HTML structure:**

```html
<h1>Heading Level 1</h1>
<p>This is a paragraph.</p>
<p>Another paragraph here.</p>
<div>A division element.</div>
```

```css
h1 {
    color: green;
}

p {
    font-size: 16px;
}
```

In the above CSS:

The h1 type selector selects all `<h1>` elements on the webf page and applies the specified style to them, in this case
setting
their text color to green.

The p type selector selects all `<p>` (paragraph) elements on the webf page and sets their font size to 16 pixels.

### Class Selector

Class selector allows you to select and style elements based on their class attribute. It's a way to apply styles to
elements that share the same class value without targeting all instances of a particular HTML element. The class
selector is prefixed with a period (.) followed by the class name.

**HTML structure:**

```html
<h1 class="headline">This is a main heading</h1>
<p class="highlight">This is a highlighted paragraph.</p>
<p>This is a regular paragraph.</p>
```

**CSS with class selectors:**

```css
.headline {
    font-size: 24px;
}

.highlight {
    background-color: yellow;
}
```

In the above example:

The .headline class selector targets the `<h1>` element with the class "headline" and applies a font size of 24px to it.

The .highlight class selector targets the `<p>` element with the class "highlight" and gives it a yellow background.

Notice how the regular `<p>` element without the "highlight" class is unaffected by the .highlight style.

### ID Selector

The ID selector allows you to select and style a single, unique element based on its id attribute.

The ID selector is prefixed with a hash (#) followed by the ID value.

The id attribute in HTML should be unique within a webf page, meaning that each specific ID can only be used once per
webf page.
This uniqueness differentiates the ID selector from class selectors, which can be applied to multiple elements on a
webf page.

**HTML structure:**

```html

<div id="header">This is the header</div>
<p id="intro">This is an introductory paragraph.</p>
```

**CSS with ID selectors:**

```css
#header {
    background-color: blue;
    color: white;
}

#intro {
    font-weight: bold;
}
```

in the above example:

The #header ID selector targets the `<div>` element with the ID of "header" and applies a blue background and white text
color to it.

The #intro ID selector targets the `<p>` element with the ID of "intro" and makes its text bold.

## Attribute selector

Attribute selectors in CSS are used to select elements based on their attributes and their attribute values. This allows
for more specific targeting of elements based on attributes rather than just their type, class, or ID.

### Basic Attribute Selector:

Selects elements based on the existence of a specific attribute, regardless of its value.

```css
/* Selects all elements with a "title" attribute */
[title] {
    border: 1px solid black;
}
```

### Exact Value Match:

Selects elements with a specific attribute and value.

```css
/* Selects all input elements with a "type" attribute value of "text" */
input[type="text"] {
    background-color: yellow;
}
```

### Partial Match Using *=:

Selects elements if the attribute value contains a specified substring.

```css
/* Selects elements with a "class" attribute containing the word "button" */
[class*="button"] {
    font-weight: bold;
}
```

### Prefix Match Using ^=:

Selects elements if the attribute value starts with a specified substring.

```css
/* Selects anchor tags with an "href" attribute value starting with "https" */
a[href^="https"] {
    color: green;
}
```

### Suffix Match Using $=:

Selects elements if the attribute value ends with a specified substring.

```css
/* Selects anchor tags with an "href" attribute value ending with ".pdf" */
a[href$=".pdf"] {
    font-weight: bold;
}
```

### Substring Match Following a Hyphen Using |=:

Selects elements if the attribute value is a list of whitespace-separated values, one of which begins with the specified
substring.

```css
/* Selects elements with a "lang" attribute value that starts with "en", such as "en" or "en-US" */
[lang|="en"] {
    text-decoration: underline;
}
```

### Exact Match or Whitespace Separated Value Using ~=:

Selects elements if the attribute value is exactly the specified string or contains the specified string as one of a
whitespace-separated list of words.

```css
/* Selects elements with a "data-tags" attribute containing the word "featured" */
[data-tags~="featured"] {
    border: 1px solid red;
}
```

Attribute selectors can be quite powerful, especially when you need to style elements based on data attributes or other
non-class, non-id attributes. They can be combined with other selectors to achieve more complex selection patterns.

## Subsets support of pseudo selectors

WebF provides support for a subset of pseudo-selectors. We are still working on supporting more pseudo-selectors.

### Pseudo-elements

In CSS, pseudo-elements are used to style specific parts of an element that cannot be targeted with simple selectors.
They can be thought of as "virtual elements" that don't exist in the document tree but can be styled with CSS. A
pseudo-element is introduced with the :: syntax.

WebF support the following lists of pseudo-elements:

1. ::before - Used to insert content before the content of an element.
2. ::after - Used to insert content after the content of an element.

For example, using ::before and ::after pseudo-elements, you can add decorative content to an element:

```css
.element::before {
    content: "★";
    color: red;
}

.element::after {
    content: "★";
    color: blue;
}

```

The above CSS would add a red star before the content and a blue star after the content of .element.

It's important to note that while pseudo-elements appear as part of the document when styled, they do not actually exist
in the DOM and therefore cannot be accessed or manipulated using JavaScript.

### Tree-Structural pseudo-classes

Tree-structural pseudo-classes in CSS are a subset of pseudo-classes that allow for the selection of elements based on
their position or structure within the document tree (the hierarchy of HTML elements). They help target elements without
the need for adding extra classes or IDs based on their relationship to other elements.

WebF support the following lists of pseudo-classes:

1. :root - Matches the root element of a document, typically the `<html>` element.
2. :nth-child(n) - Matches an element that is the nth child of its parent.
3. :nth-last-child(n) - Matches an element that is the nth child of its parent, counting from the last child.
4. :nth-of-type(n) - Matches an element that is the nth of its type within its parent.
5. :nth-last-of-type(n) - Matches an element that is the nth of its type within its parent, counting from the last
   child.
6. :first-child - Matches an element that is the first child of its parent.
7. :last-child - Matches an element that is the last child of its parent.
8. :first-of-type - Matches the first element of its type within its parent.
9. :last-of-type - Matches the last element of its type within its parent.
10. :only-child - Matches an element that is the only child of its parent.
11. :only-of-type - Matches an element that is the only one of its type within its parent.

Example usage:

```css
/* Style all <p> elements that are the first child of their parent */
p:first-child {
    font-weight: bold;
}

/* Style all <li> elements that are odd-numbered children of their parent */
li:nth-child(odd) {
    background-color: #f5f5f5;
}
```

Tree-structural pseudo-classes are especially useful when styling complex layouts or when working with lists,
and other elements where the position of a child relative to its parent or siblings matters.