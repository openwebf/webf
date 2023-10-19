---
sidebar_position: 6
title: Sizing Items
---

Sizing items refers to setting the width, height, and sometimes the depth of elements.

There are various properties and units you can use to size items, and the method you choose often depends on the context
and the design requirements.

## How to set the size for a element

### Width and Height

The primary properties to set the size of an element are width and height.

```css
div {
    width: 300px;
    height: 150px;
}
```

### Units

There are several units you can use to define sizes:

Absolute Units:

+ px (pixels): A dot on the screen.
+ cm, mm, in, pt, pc: Physical units. Not often used for screen designs because they don't always translate well to
  digital displays.
  Relative Units:

Relative Units:

+ %: Relative to the parent element's size.
+ em: Relative to the font size of the element.
+ rem: Relative to the font size of the root element.
+ vw: 1% of the viewport's width.
+ vh: 1% of the viewport's height.
+ vmin: 1% of the viewport's smaller dimension (either width or height).
+ vmax: 1% of the viewport's larger dimension (either width or height).

### Min and Max Sizing

You can also set minimum and maximum widths and heights for elements:

```css
div {
    min-width: 200px;
    max-width: 600px;
    min-height: 100px;
    max-height: 400px;
}
```

### Flexbox

In a flex container, you can control the size of flex items using the flex property or its longhand properties (
flex-grow, flex-shrink, and flex-basis):

```css
.flex-item {
  flex: 1; /* grow and shrink equally and take up equal space */
}
```

### Object Fit

For content like images inside an element, you can control how they should be resized:

```css
img {
  width: 300px;
  height: 200px;
  object-fit: cover; /* Resize the image to cover the element, cropping if necessary */
}
```


## How intrinsic size affect the box size

Intrinsic size refers to the natural or default size of an element, without any external styling applied.

For images, the intrinsic size is the actual width and height of the image in pixels as it was created.

### No Width or Height Specified

If you don't specify a width or height for an image in your CSS or HTML, the image will display at its intrinsic size. 

This means the box size will be exactly the same as the image's natural width and height.

```html
<img src="image.jpg" alt="Description">
```

If image.jpg is 500x300 pixels, the image will take up a 500x300 pixel space on the page.

### Specified Width, No Height

If you specify a width but no height for an image, the height will auto-adjust to maintain the image's aspect ratio.

```html
<img src="image.jpg" alt="Description" style="width: 250px;">
```

If the intrinsic size of image.jpg is 500x300 pixels, the rendered image will be 250x150 pixels to maintain the same aspect ratio.

### Specified Height, No Width

Similarly, if you specify a height but no width, the width will auto-adjust to maintain the image's aspect ratio.

### Specified Width and Height

If you specify both width and height, the image will be resized to those dimensions, potentially breaking the aspect ratio. This can lead to the image looking stretched or squished.

```html
<img src="image.jpg" alt="Description" style="width: 250px; height: 250px;">
```

This will force the image into a square shape, which can distort its appearance if its intrinsic aspect ratio isn't 1:1.

### CSS Properties like max-width: The max-width

The max-width property can also affect the box size of an image. 

If an image has an intrinsic width of 500 pixels but is inside a container that has max-width: 300px; the image will not exceed 300 pixels in width. 

If the height isn't specified, it will scale proportionally.