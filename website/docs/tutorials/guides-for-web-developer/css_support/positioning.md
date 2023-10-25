---
sidebar_position: 12
title: Positioning
---

The Positioned Layout in CSS refers to the behavior of elements whose position property is set to a value other than
static (which is the default value).

Positioned elements can be laid out based on their containing elements or other
reference points, and they do not follow the standard flow of the document, hence they are "out of flow."

## Relative positioned layout

When a box's position property set to relative.

This type of positioning allows you to move an element from its normal
position in the flow of the document using the top, right, bottom, and left offset properties.

Using these offset properties will move the element from where it would normally be in the document flow.

For example:

```css
.relative-box {
    position: relative;
    top: 10px;
    left: 20px;
}
```

This will move the .relative-box element 10 pixels down and 20 pixels to the right from its original position.

**Space Reservation:**

An essential characteristic of position: relative is that the element still occupies its original space in the layout.
So, even though it might be visually offset, the space it originally took up remains reserved, and other elements in the
flow will act as if the relatively positioned element hasn't moved.

**Z-index**

Relatively positioned elements can also use the z-index property to control their stacking order when they overlap with
other elements. This allows developers to ensure that specific elements appear above or below others.

## Absolute positioned layout

When a box's position property set to absolute, an element with this setting is taken out of the document's normal flow.

This type of positioning is powerful and offers a high level of control over the placement of an element within its
context.

**Containing Block:**

One of the most crucial aspects of absolute positioning is understanding its containing block or reference point.

The containing block for an absolutely positioned element is the nearest positioned ancestor, i.e., an ancestor with its
position set to anything other than static (like relative, absolute, fixed, or sticky).

If no positioned ancestor exists, the containing block defaults to the initial containing block, which is typically the
viewport.

Here's a basic implementation using absolute positioning:

**HTML:**

```html

<div class="relative">This div element has position: relative;
    <div class="absolute">This div element has position: absolute;</div>
</div>
```

```css
div.relative {
    position: relative;
    width: 400px;
    height: 200px;
    border: 3px solid #73AD21;
}

div.absolute {
    position: absolute;
    top: 80px;
    right: 0;
    width: 200px;
    height: 100px;
    border: 3px solid #73AD21;
}
```

**No Space Reservation:**

When an element is positioned absolutely, it is removed from the normal flow of the document. This means it doesn't
occupy space where it originally was, and other elements will position themselves as if the absolutely positioned
element doesn't exist.

**Z-index:**

Absolutely positioned elements can overlap other elements. To control the stacking order of these overlaps, you can use
the z-index property. Higher values of z-index mean the element will appear above those with lower values.

## Fixed positioned layout

The "fixed positioned layout" pertains to elements that have their position property set to fixed. Elements with fixed
positioning are removed from the document's normal flow and are positioned relative to the viewport. This means that
they stay in the same position on the screen, even if the rest of the page is scrolled.

For instance, if you have:

```css
.fixed-element {
    position: fixed;
    top: 10px;
    right: 15px;
}

```

The .fixed-element will always be 10 pixels from the top and 15 pixels from the right edge of the viewport, regardless
of scrolling.

**Removed from the Normal Flow:**

Elements with fixed positioning don't take up space in the document layout. They essentially "float" above the content.
This means other content will flow and position itself as if the fixed positioned element doesn't exist.

**Z-Index:**

Since fixed positioned elements can float above other content, you might need to use the z-index property to control the
stacking order when there's an overlap. Higher values of z-index will ensure the element appears above those with lower
values.

## Sticky positioned layout

The "sticky positioned layout" pertains to elements that have their position property set to sticky.

This unique positioning type is a hybrid between relative and fixed positioning.

A sticky element toggles between relative and fixed, depending on the scroll position.

It is positioned based on the user's scroll position and can "stick" when it hits the top, bottom, or any side of the
viewport.

**Containing Block:**

+ For an element to have a sticky position effectively, its parent container (or the containing block) must have a
  defined height. The sticky element will remain within the confines of this container, even when it's sticking.
+ If the container is too tall (or doesn't constrain the sticky element's movement enough), the sticky effect might not
  be apparent because the element might never meet the specified threshold.

**Interactions with Overflow:**

The value of the overflow property on parent elements can affect sticky positioning.

If any ancestor has overflow set to hidden, scroll, or auto and the box isn't a scroll container, then the position:
sticky will not work as expected.

**Example:**

Here's a basic example of a sticky header:

```css
.sticky-header {
    position: sticky;
    top: 0; /* Will start sticking at the top of the viewport */
    background-color: #333;
    color: white;
    padding: 10px;
    z-index: 100; /* to ensure it's on top of other content */
}
```

In this example, as you scroll down a page, the .sticky-header will begin to "stick" to the top of the viewport as soon
as its top edge touches the top of the viewport, and it will remain "stuck" in that position as you continue to scroll
until its parent container is completely out of view.

Sticky positioning offers an elegant way to enhance user interfaces, providing fixed positioning when needed while
respecting the natural document flow.

## Positioned offset

Once an element's position property is set to a value other than static, you can use the following properties to define
its position:

+ top
+ right
+ bottom
+ left

The values you give to these properties define the "offset" of the element from the reference point defined by the
position property. For instance, with position: absolute; top: 10px; left: 20px;, the element will be placed 10 pixels
from the top and 20 pixels from the left of its containing block.

## Containing Block

For positioned elements, the containing block (or reference point) from which they are offset is determined by their
position value:

+ static and relative: The containing block is formed by the edge of the content box of the nearest block container
  ancestor.
+ absolute: The containing block is the nearest positioned ancestor (an element with position set to relative, absolute,
  fixed, or sticky). If there's no positioned ancestor, the initial containing block (usually the viewport) is used.
+ fixed: The containing block is established by the viewport.
+ sticky: The containing block depends on the scrolling box in which the sticky positioning is being applied.