---
sidebar_position: 9
title: Flex Layout
---

The Flexbox (or flexible box) layout model in CSS is a way to design complex layout structures with a more predictable
way than traditional models, especially when it comes to distributing space and aligning items in complex layouts and
when the sizes of your items are unknown or dynamic.

Learn how to use flex layout in CSS: https://css-tricks.com/snippets/css/a-guide-to-flexbox/

## Basics of Flexbox

To use Flexbox, you need a container set to display: flex or display: inline-flex (if you want the container to behave
like an inline element).

```css
.container {
    display: flex;
}
```

### Main Components

+ Flex Container: The parent element in which you apply display: flex or display: inline-flex.
+ Flex Items: The children of the flex container.

### Main Axis and Cross Axis

+ Main Axis: The primary axis along which flex items are laid out. It can be horizontal or vertical, depending on the
  flex-direction property.
+ Cross Axis: The axis perpendicular to the main axis.

### Properties for the Flex Container

+ flex-direction: Defines the direction of the main axis.
  + row (default): left to right
  + row-reverse: right to left
  + column: top to bottom
  + column-reverse: bottom to top
+ flex-wrap: By default, flex items will try to fit onto one line. You can change that with this property.
  + nowrap (default): all flex items on one line
  + wrap: flex items wrap onto multiple lines
  + wrap-reverse: flex items wrap onto multiple lines in reverse order
+ flex-flow: A shorthand for flex-direction and flex-wrap.
+ justify-content: Aligns flex items along the main axis.
  + flex-start (default): items at the start of the container
  + flex-end: items at the end of the container
  + center: items at the center
  + space-between: equal space between items
  + space-around: equal space around each item
  + space-evenly: equal space between and around each item
+ align-items: Aligns flex items along the cross axis.
  + flex-start: items at the start of the container
  + flex-end: items at the end of the container
  + center: items at the center
  + baseline: items aligned such as their baselines align
  + stretch (default): stretch to fill the container (still respects min-width/max-width)
+ align-content: Aligns flex lines when there's extra space in the cross-axis.
  + flex-start
  + flex-end
  + center
  + space-between
  + space-around
  + stretch (default)

### Properties for the Flex Items

+ flex-grow: Defines the ability for a flex item to grow. Takes a unitless value that serves as a proportion.
+ flex-shrink: Defines the ability for a flex item to shrink. Takes a unitless value that serves as a proportion.
+ flex-basis: Defines the default size of an element before the remaining space is distributed.
+ flex: A shorthand for flex-grow, flex-shrink, and flex-basis.
+ align-self: Allows the default alignment (or the one specified by align-items) to be overridden for individual flex
  items.

### Example

```css
.container {
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: center;
}

.item {
    flex: 1; /* shorthand for flex-grow: 1, flex-shrink: 1, flex-basis: 0% */
}
```