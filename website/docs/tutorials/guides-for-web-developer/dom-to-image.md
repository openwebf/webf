---
sidebar_position: 6
title: DOM Element To Image
---

WebF allows direct exporting of any DOM element's rendering content to a PNG image, eliminating the need for third-party
libraries like html2canvas.

## Element.toBlob()

Element.toBlob is a proprietary extension API for WebF, which supports exporting PNG image content from elements that have
already been mounted on the DOM tree and fully rendered.

For example, for the following HTML structure, if we want to generate a separate PNG image of the rendered content of the div with class="box":

```css
.box {
    width: 200px;
    height: 200px;
    border: 1px solid #000;
}

```

```html
<div class="container">
    <div class="box">
        Helloworld
    </div>
</div>
```

By using a selector to get the DOM instance, and then calling the toBlob method, we can obtain a Blob object containing PNG information.

```javascript
const box = document.querySelector('.box');
const snapshotBlob = await box.toBlob(window.devicePixelRatio);
```

The Blob class provides a number of methods for consuming its contents in different formats.

**Convert a Blob to a Uint8Array**

These snippets read the contents to an ArrayBuffer, then creates a Uint8Array from the buffer.


```javascript
const arr = new Uint8Array(await snapshotBlob.arrayBuffer());
```

**Convert a Blob to a base64 string**

The Blob object has an additional base64 method extended by WebF, which can directly convert the Blob object into a base64 string.

```javascript
const base64String = await snapshotBlob.base64();
```
