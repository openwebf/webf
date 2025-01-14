---
sidebar_position: 11
title: Asynchronous Web API
---

# Asynchrony Support

Asynchrony is a new feature in WebF that allows properties and methods of Element and WidgetElement to be accessed both synchronously and asynchronously. This capability is particularly beneficial as it leverages the advantages of dedicated threading, reduces blocking on the Flutter UI thread, and improves the overall performance of WebF applications.

## How to Use

To access a property or call a method asynchronously, simply add the "_async" suffix to the end of the original property or method. The arguments and return values remain unchanged.

Here’s an example:

```js
// Synchronously
// Call the scroll method and access scrollX/scrollY properties
window.scroll(0, 40);
let scrollX = window.scrollX;
let scrollY = window.scrollY;

// Asynchronously
// Call the scroll method asynchronously with scroll_async
// Access scrollX and scrollY properties asynchronously with scrollX_async and scrollY_async
await window.scroll_async(0, 40);
let scrollX = await window.scrollX_async;
let scrollY = await window.scrollY_async;
```

## Supported API

The following list outlines the properties and methods that support asynchrony in WebF.

### Docuemnt

### CSSStyleDeclaration

#### Property
* cssText
* length

#### Method
getPropertyValue
* setProperty
* removeProperty


### Docuemnt
#### Property
* cookie
* compatMode
* domain
* readyState
* visibilityState
* hidden
* title

#### Method
* querySelectorAll
* querySelector
* getElementById
* getElementsByClassName
* getElementsByTagName
* getElementsByName
* elementFromPoint

### Element
#### Property
* offsetTop
* offsetLeft
* offsetWidth
* offsetHeight
* scrollTop
* scrollLeft
* scrollWidth
* scrollHeight
* clientTop
* clientLeft
* clientWidth
* clientHeight
* dir

#### Method
* getBoundingClientRect
* getClientRects
* scroll
* scrollBy
* scrollTo
* getElementsByClassName
* getElementsByTagName
* querySelectorAll
* querySelector
* matches
* closest

### Window
#### Property
* innerWidth
* innerHeight
* scrollX
* scrollY
* pageXOffset
* pageYOffset
* screen
* colorScheme
* devicePixelRatio

#### Method
* scroll
* scrollTo
* scrollBy
* open
* getComputedStyle

### DOMMatrix/DOMMatrixReadonly
#### Property
* is2D
* isIdentity
* a
* b
* c
* d
* e
* f
* m11
* m12
* m13
* m14
* m21
* m22
* m23
* m24
* m31
* m32
* m33
* m34
* m41
* m42
* m43
* m44

#### Method
* flipX
* flipY
* inverse
* multiply
* rotateAxisAngle
* rotate
* scale
* scale3d
* scaleNonUniform
* skewX
* skewY
* toString
* transformPoint
* translate

### DOMPoint/DOMPointReadonly
#### Property
* x
* y
* z
* w

#### Method
* matrixTransform

### HTMLAnchorElement
#### Property
* href
* target
* rel
* type
* protocol
* host
* hostname
* port
* pathname
* search
* hash

### HTMLHeadElement
#### Property
* disabled
* rel
* href
* type

### HTMLInputElement
#### Property
* value
* type
* disabled
* placeholder
* readonly
* autofocus
* defaultValue

#### Method
blur
focus


### HTMLImageElement
#### Property
* src
* loading
* width
* height
* naturalWidth
* naturalHeight
* complete

### HTMLScriptElement
#### Property
* src
* async
* type
* text
* readyState

### Canvas
#### Property
* width
* height

### CanvasRenderingContext2D
#### Property
* fillStyle
* direction
* font
* strokeStyle
* lineCap
* lineDashOffset
* lineJoin
* lineWidth
* miterLimit
* textAlign
* textBaseline

#### Method
* arc
* arcTo
* fillRect
* clearRect
* strokeRect
* fillText
* ellipse
* strokeText
* save
* restore
* beginPath
* bezierCurveTo
* clip
* closePath
* drawImage
* fill
* lineTo
* moveTo
* quadraticCurveTo
* rect
* rotate
* roundRect
* resetTransform
* scale
* stroke
* setTransform
* transform
* translate
* reset
* createLinearGradient
* createRadialGradient
* createPattern

### Path2D
#### Method
* moveTo
* closePath
* lineTo
* bezierCurveTo
* arc
* arcTo
* ellipse
* rect
* roundRect
* addPath
