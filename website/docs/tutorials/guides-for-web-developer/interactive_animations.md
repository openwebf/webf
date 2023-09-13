---
sidebar_position: 5
title: Interactive Animations
---

Dart and JavaScript communication has been extensively optimized, allowing direct use of the DOM API and events for
interactive animations.

In WebF, you can seamlessly control animation status with JavaScript as in a browser, free from
lag due to communication delays.

## Drag and Drop example

**HTML**:

```html

<div class="circle"></div>
```

**CSS**:

```css
.circle {
    width: 50px;
    height: 50px;
    background-color: blue;
    border-radius: 50%;
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
}
```

**JavaScript**:

```javascript
const circle = document.querySelector('.circle');

// Function to update circle position
function updatePosition(event) {
    let x, y;

    // Check if event is touch or mouse
    if (event.touches) {
        x = event.touches[0].clientX;
        y = event.touches[0].clientY;
    } else {
        x = event.clientX;
        y = event.clientY;
    }

    circle.style.left = x + 'px';
    circle.style.top = y + 'px';
}

document.addEventListener('touchmove', (e) => {
    updatePosition(e);
});
```

This example showcases WebF's real-time animation performance. On triggering a gesture, the animation runs seamlessly
without frame drops.

<video src="/videos/interactive_motion_1.mov" controls style={{width: "300px", margin: '0 auto', display: 'block'}} />

### requestAnimationFrame

A more modern and recommended approach for creating JavaScript-based animations. It optimizes the animation for the best performance.

```javascript
function animate(time) {
  // Update properties for animation
  requestAnimationFrame(animate);
}
requestAnimationFrame(animate);
```

## More Complex Examples

Check out this demo showcasing the performance of an interactive drag list. For a deeper dive, view the source code here:

https://github.com/openwebf/samples/tree/main/demos/interactive_drag_list

<video src="/videos/interactive_motion_2.mov" controls style={{width: "300px", margin: '0 auto', display: 'block'}} />

