---
sidebar_position: 6
title: Canvas Support
---

# Canvas Support

The Canvas 2D API is a feature in webf/browser that enables drawing and manipulating graphics directly in an HTML canvas
element using JavaScript.

This provides a way to render graphics, animations, and even games without relying on plugins or external tools.

## Canvas Element

The starting point is the `<canvas>` HTML element, which creates a blank canvas that you can draw upon:

```html

<canvas id="myCanvas" width="400" height="200"></canvas>
```

This creates a canvas of 400 pixels in width and 200 pixels in height. 

However, displaying the canvas element by itself will not show anything besides a blank rectangle (or sometimes nothing at all, unless given a border or background).

## Drawing on the Canvas

To draw on the canvas, you use JavaScript and the Canvas API. The key object here is the 2D rendering context, which you can obtain from any canvas element.

```javascript
let canvas = document.getElementById('myCanvas');
let ctx = canvas.getContext('2d');
```

### Drawing Commands

### Paths:

- **beginPath()**: Resets the current path.
- **closePath()**: Connects the last point in the path to the starting point.
- **moveTo(x, y)**: Moves the pen to the specified coordinates without drawing.
- **lineTo(x, y)**: Draws a line from the current position to the specified coordinates.
- **arc(x, y, radius, startAngle, endAngle, antiClockwise)**: Draws an arc or a section of a circle. If the `antiClockwise` argument is `true`, the arc is drawn counterclockwise; otherwise, it's drawn clockwise.
- **arcTo(x1, y1, x2, y2, radius)**: Draws an arc using control points and a radius.
- **quadraticCurveTo(cp1x, cp1y, x, y)**: Draws a quadratic Bézier curve.
- **bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)**: Draws a cubic Bézier curve.

### Drawing Styles:

- **fillStyle**: Property to set the color, gradient, or pattern to fill shapes.
- **strokeStyle**: Property to set the color, gradient, or pattern for shape outlines.
- **createLinearGradient(x1, y1, x2, y2)**: Creates a linear gradient object.
- **createRadialGradient(x1, y1, r1, x2, y2, r2)**: Creates a radial (or circular) gradient object.
- **createPattern(image, type)**: Creates a pattern using a specified image (or another canvas) and repetition type (`"repeat"`, `"repeat-x"`, `"repeat-y"`, or `"no-repeat"`).
  - CanvasPattern.setTransform currently not supported.

### Drawing Shapes:

- **fill()**: Fills the current path.
- **stroke()**: Outlines the current path.
- **clearRect(x, y, width, height)**: Clears the specified rectangular area, making it transparent.
- **fillRect(x, y, width, height)**: Draws a filled rectangle.
- **strokeRect(x, y, width, height)**: Draws a rectangular outline.

### Text:

- **font**: Property to set the current font properties.
- **textAlign**: Property to set the text alignment (`"start"`, `"end"`, `"left"`, `"right"`, or `"center"`).
- **textBaseline**: Property to set the baseline alignment (`"top"`, `"hanging"`, `"middle"`, `"alphabetic"`, `"ideographic"`, or `"bottom"`).
- **fillText(text, x, y, [maxWidth])**: Fills a text string at the specified coordinates.
- **strokeText(text, x, y, [maxWidth])**: Outlines a text string at the specified coordinates.
- ~~**measureText(text)**: Returns a `TextMetrics` object containing information about the width of the text.~~ 

### Image Drawing:

- **drawImage(image, dx, dy, [dWidth, dHeight])**: Draws an image, video frame, or another canvas onto the canvas. This method has multiple overloads to support cropping and scaling.

### Global Composite Operations:

- ~~**globalAlpha**: Property to set the global transparency level.~~
- ~~**globalCompositeOperation**: Property to set how shapes and images are drawn onto the existing content. Common values include `"source-over"`, `"destination-over"`, `"multiply"`, `"screen"`, etc.~~

### Line Styles:

- **lineCap**: Property to set the end style of lines (`"butt"`, `"round"`, or `"square"`).
- **lineJoin**: Property to set the corner style of paths (`"bevel"`, `"round"`, or `"miter"`).
- **lineWidth**: Property to set the width of lines.
~~- **setLineDash(segments)**: Sets the current line dash pattern.~~
~~- **getLineDash()**: Returns the current line dash pattern.~~
- **lineDashOffset**: Property to set the offset for the line dash pattern.

### Transformations:

- **scale(x, y)**: Scales the canvas units.
- **rotate(angle)**: Rotates the canvas around the current origin.
- **translate(x, y)**: Moves the canvas origin to a different point.
- **transform(a, b, c, d, e, f)**: Multiplies the current transformation matrix with the given matrix.
- **setTransform(a, b, c, d, e, f)**: Resets the current transform to the identity and then invokes `transform()`.
- **resetTransform()**: Resets the current transform to the identity matrix.

### Other Commands:

- **clip()**: Clips the region using the current path.
- **save()**: Saves the current drawing state to a stack.
- **restore()**: Restores the drawing state from the stack.
- ~~**isPointInPath(x, y)**: Checks if the given point is inside the current path.~~
- ~~**isPointInStroke(x, y)**: Checks if the given point is on the path's stroke.~~