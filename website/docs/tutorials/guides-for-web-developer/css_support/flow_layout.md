---
sidebar_position: 8
title: Flow Layout
---

The flow layout, often referred to as "normal flow" in CSS, is the default layout mechanism by which webf/browser render
web page content.

When elements are laid out according to the normal flow, they behave predictably based on their display value (block,
inline, etc.) and their source order in the HTML document.

## Display Values:

In the context of the flow layout, the two primary `display` values to consider are `block` and `inline`.

- **Block-Level Elements**:
  - These elements create a new "block" or "box" in the layout.
  - They typically stretch the full width of their parent container and stack vertically.
  - Examples: `div`, `h1`-`h6`, `p`, `ul`, `li`, etc.

- **Inline-Level Elements**:
  - These elements flow horizontally within their containing element, wrapping to the next line when they run out of space.
  - They only take up as much width as necessary.
  - Examples: `span`, `a`, `strong`, `em`, etc.

## Flow Layout Behavior:

- **Block-Level Elements**:
  - Start on a new line and extend the full width of their parent container by default.
  - Respect top and bottom margins, but adjacent vertical margins will collapse into a single margin of the size of the largest margin (known as "margin collapsing").
  - Respect padding and borders.

- **Inline-Level Elements**:
  - Flow within the content, from left to right in languages that are read this way.
  - Do not start on a new line.
  - Horizontal margins, padding, and borders are respected, but vertical ones might not affect layout significantly.
  - Width and height properties do not apply. Instead, the content determines their size.
  - They can't have block-level elements inside them.

## Out of Flow:

Elements can be taken out of the normal flow using properties like `position` (with values other than `static`). Once an element is out of the flow, it no longer affects the positioning of other elements in the normal flow.

- **Positioned Elements**: Elements with `position` values of `relative`, `absolute`, `fixed`, or `sticky` are considered "positioned" and can be taken out of the normal flow, depending on the value.

## Containing Blocks:

In the flow layout, the containing block of an element is determined by the nearest block-level ancestor. This containing block defines the area in which the element is laid out.