---
sidebar_position: 10
title: Transition and Animations
---

Transitions and animations are tools that allow you to create smooth and controlled animations directly in the webf
without the need for JavaScript.

They can be used to enhance user experience by providing visual feedback, guiding attention, or adding flair to web page
interactions.

## CSS Transitions

Transitions allow property changes in CSS values to occur smoothly over a specified duration.

**Properties**:

+ transition-property: Specifies the name of the CSS property to which the transition is applied.
+ transition-duration: Defines the duration over which transitions should occur.
+ transition-timing-function: Describes how the intermediate values used during a transition will be calculated. It
  allows for acceleration and deceleration within the transition.
+ transition-delay: Defines when the transition will start.

**Example:**

```css
.box {
    width: 100px;
    height: 100px;
    background-color: blue;
    transition: background-color 0.3s ease-in-out;
}
```

```javascript
const box = document.querySelector('.box');
box.onclick = () => box.style.backgroundColor = 'red';
```

In this example, when you click the .box, its background color will change from blue to red over a duration of 0.3
seconds with an ease-in-out timing function.

## CSS Animations

Animations allow for more complex sequences of property changes, defined with keyframes.

**Properties:**

+ animation-name: Specifies the name of the @keyframes animation.
+ animation-duration: How long the animation should take to complete one cycle.
+ animation-timing-function: How the animation progresses over its duration.
+ animation-delay: When the animation will start.
+ animation-iteration-count: How many times the animation will play.
+ animation-direction: The direction in which the animation should play.
+ animation-fill-mode: Specifies how a CSS animation should apply styles to its target before and after its execution.
+ animation-play-state: Whether the animation is running or paused.

Keyframes: Defined using the @keyframes rule, it specifies the animation sequence, using percentages to denote specific
points during the animation timeline.

```css
@keyframes fadeInOut {
  0% { opacity: 0; }
  50% { opacity: 1; }
  100% { opacity: 0; }
}

.box {
  width: 100px;
  height: 100px;
  background-color: blue;
  animation: fadeInOut 3s infinite;
}
```

In this example, the .box will fade in and out over a 3-second duration, repeating indefinitely.