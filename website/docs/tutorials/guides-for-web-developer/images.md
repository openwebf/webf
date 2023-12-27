---
sidebar_position: 9
title: Images
---

Images play a crucial role in web application development, affecting user experience, design aesthetics, page load times, and more.

## Basics of Using Images in WebF

HTML Image Tag: The primary method to embed images in web pages.

```html
<img src="path/to/image.jpg">
```

+ src: Specifies the image's URL

## Image Formats

There are various image formats, each with its strengths:

+ JPEG (or JPG): Suitable for photographs or images with gradients. It uses lossy compression, meaning some image data is lost for smaller file sizes.
+ PNG: Best for images requiring transparency or those with sharp edges and lines, like logos or UI elements. Supports lossless compression.
+ GIF: Used for simple animations.
+ ~~SVG (Scalable Vector Graphics): An XML-based format for two-dimensional graphics. It's vector-based, so it scales without losing clarity. Ideal for logos, icons, and simple illustrations.~~
+ WebP: A modern format developed by Google, offering both lossless and lossy compression. Generally provides better compression ratios than JPEG or PNG.

## CSS Background Images

Instead of the `<img>` tag, images can be set as CSS backgrounds:

```css
div {
    background-image: url('path/to/image.jpg');
}
```

## The Image API

The Image() constructor creates a new HTMLImageElement instance. It is functionally equivalent to document.createElement('img').

```javascript
const myImage = new Image(100, 200);
myImage.src = "picture.jpg";
document.body.appendChild(myImage);
```

This would be the equivalent of defining the following HTML tag inside the `<body>`:

```html
<img width="100" height="200" src="picture.jpg" />
```

## Image Lazy Loading

Image lazy loading is a performance optimization technique used in web development to defer the loading of off-screen images until the user scrolls near or to them. 

Instead of loading all images on a page immediately when the page loads, lazy loading only loads the images that are currently in the viewport, improving initial page load times and reducing the initial amount of data consumed.

### Benefits of Image Lazy Loading

+ Improved Page Load Time: Initial page load is faster because fewer requests are made, and fewer data is transferred.
+ Reduced Data Usage: Especially beneficial for users on metered or slow internet connections.
+ Resource Conservation: Reduces server requests and conserves bandwidth, leading to potential cost savings and decreased resource usage.

### How Lazy Loading Works

+ Placeholder Setup: Images not in the viewport initially get a placeholder, often a small, low-quality image or a colored placeholder.
+ Scroll Detection: As the user scrolls through the page, a script checks which images have entered the viewport.
+ Image Loading: Once an image is near or in the viewport, the actual image is fetched and replaces the placeholder.

### Implementing Lazy Loading

Using the loading Attribute:

```html
<img src="image.jpg" alt="Description" loading="lazy">
```

When set to "lazy", webf will handle the lazy loading of the image. It's a simple and straightforward method.