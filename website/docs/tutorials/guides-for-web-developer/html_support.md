---
sidebar_position: 4
title: HTML and SVG support
---

WebF use [gumbo-parser](https://github.com/google/gumbo-parser) as the HTML/SVG parser to support HTML/SVG rendering.

It is fully conformant with the HTML5 spec, so feel free to use any HTML tags or attributes just like in browsers.

### Loading stylesheets with `<link />` and JavaScript libraries with `<script />` elements.

In WebF, you can directly use `<script />` element to load external JavaScript libraries, including Vue.js from the CDN,
and use `<link />` element to load external stylesheets just like in web browsers.

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="https://openwebf.com/css/example.css">
</head>
<body>
<div id="app">{{ message }}</div>
<script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
<script>
  const {createApp} = Vue

  createApp({
    data() {
      return {
        message: 'Hello Vue!'
      }
    }
  }).mount('#app')
</script>
</body>
</html>
```

### I need to play video in WebF apps

To support play video playback in WebF, you need to use
the [embedder Flutter Widgets](/docs/tutorials/guides-for-flutter-developer/loading-web-contents-from-disk) feature of
WebF. This converts any Flutter widgets into an HTML tags that can be used in your WebF apps.

This capability allows any Flutter widgets to be incorporated into your WebF app, leveraging the tools and libraries
from Flutter ecosystem to
enhance your WebF app.

For example:

You can use the [video_player](https://pub.dev/packages/video_player) flutter plugins to play videos in WebF.

Read the source codes in this [example](https://github.com/openwebf/samples/tree/main/demos/video_player) for more
details.

## Supported HTML tags

WebF support a subset of HTML tags in WhatWG standards.

These HTML tags have the same behavior the same as in browsers.

+ `<br />`
+ `<b />`
+ `<abbr />`
+ `<em />`
+ `<cite />`
+ `<i />`
+ `<samp />`
+ `<strong />`
+ `<small />`
+ `<s />`
+ `<span />`
+ `<a />`
+ `<pre />`
+ `<p />`
+ `<div />`
+ `<code />`
+ `<ul />`
+ `<li />`
+ `<ol />`
+ `<template />`
+ `<aside />`
+ `<header />`
+ `<main />`
+ `<nav />`
+ `<section />`
+ `<h1 />`
+ `<h2 />`
+ `<h3 />`
+ `<h4 />`
+ `<h5 />`
+ `<h6 />`
+ `<input />`
+ `<textarea />`
+ `<button />`
+ `<head />`
+ `<title />`
+ `<meta />`
+ `<link />`
+ `<style />`
+ `<noscript />`
+ `<script />`
+ `<html />`
+ `<body />`
+ `<img />`
+ `<canvas />`

## Basic SVG support

SVG support in WebF is still in the early stage. From now, we only provide limited SVG support:

1. We only support rendering SVG with `<svg />` tags. Loading `SVG` in CSS or via the `<img />` element is currently not
   supported.
2. Only these tags are supported:
    1. `<svg />`
    4. `<rect />`
    5. `<path />`
    6. `<text />`
    7. `<g />`

**Example**

The follow SVG will display a `GitHub` logo in WebF:

```svg

<svg class="icon" viewBox="0 0 1024 1024">
    <path d="M64 512c0 195.2 124.8 361.6 300.8 422.4 22.4 6.4 19.2-9.6 19.2-22.4v-76.8c-134.4 16-140.8-73.6-150.4-89.6-19.2-32-60.8-38.4-48-54.4 32-16 64 3.2 99.2 57.6 25.6 38.4 76.8 32 105.6 25.6 6.4-22.4 19.2-44.8 35.2-60.8-144-22.4-201.6-108.8-201.6-211.2 0-48 16-96 48-131.2-22.4-60.8 0-115.2 3.2-121.6 57.6-6.4 118.4 41.6 124.8 44.8 32-9.6 70.4-12.8 112-12.8 41.6 0 80 6.4 112 12.8 12.8-9.6 67.2-48 121.6-44.8 3.2 6.4 25.6 57.6 6.4 118.4 32 38.4 48 83.2 48 131.2 0 102.4-57.6 188.8-201.6 214.4 22.4 22.4 38.4 54.4 38.4 92.8v112c0 9.6 0 19.2 16 19.2C832 876.8 960 710.4 960 512c0-246.4-201.6-448-448-448S64 265.6 64 512z"
          fill="#040000" p-id="3824"></path>
</svg>
```

![img](/img/github.png)

## I want more HTML/SVG elements support

If you require more HTML elements for your web app to work in WebF, please raise
an [issue](https://github.com/openwebf/webf/issues/new?assignees=&labels=enhancement%2Cimplement&projects=&template=feature_needs_to_implement.yaml)
in our GitHub repo. Once there are more people expressing a desire for this feature, we will plan to support it.
