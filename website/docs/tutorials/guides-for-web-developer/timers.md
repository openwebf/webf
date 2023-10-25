---
sidebar_position: 7
title: Timers
---

Timers in web development provide a way to schedule code to run either once after a specified duration or repeatedly at fixed time intervals. 

They're primarily managed through the window object.

## setTimeout(function, delay)

- **Purpose**: Executes a function once after waiting for the specified delay in milliseconds.
- **Parameters**:
  - `function`: The function to execute.
  - `delay`: The number of milliseconds to wait before executing the function.
- **Returns**: A unique numeric ID which can be used to cancel the timeout using `clearTimeout()`.
- **Example**:
  ```javascript
  setTimeout(() => {
    console.log("Hello after 2 seconds");
  }, 2000);
  ```

## clearTimeout(timeoutID)

- **Purpose**: Cancels a previously set timeout.
- **Parameter**:
  - `timeoutID`: The ID of the timeout you want to cancel, as returned by `setTimeout`.
- **Example**:
  ```javascript
  const timerID = setTimeout(() => {
    console.log("This will not run");
  }, 2000);

  clearTimeout(timerID);
  ```

## setInterval(function, delay, ...args)

- **Purpose**: Executes a function repeatedly, with a fixed time delay between successive calls.
- **Parameters**:
  - `function`: The function to execute.
  - `delay`: The interval time in milliseconds.
- **Returns**: A unique numeric ID which can be used to cancel the interval using `clearInterval()`.
- **Example**:
  ```javascript
  let count = 0;
  const intervalID = setInterval(() => {
    count++;
    console.log(`This has run ${count} times`);
    if (count >= 5) {
      clearInterval(intervalID);
    }
  }, 1000);
  ```

## clearInterval(intervalID)

- **Purpose**: Cancels a previously set interval.
- **Parameter**:
  - `intervalID`: The ID of the interval you want to cancel, as returned by `setInterval`.
- **Example**: Refer to the above `setInterval` example.

## Points to Note:

1. **Not Always Precise**: The `delay` parameter doesn't guarantee execution after the exact number of milliseconds you specify. For instance, if the event loop or the browser's task queue is busy, the execution could be delayed.

2. **Zero Delay Doesn't Mean Immediate Execution**: Specifying a delay of `0` milliseconds does not necessarily mean the callback will fire right away. It just means it will fire on the next cycle of the event loop.

3. **Nested Timers**: If a timer (like `setTimeout`) is called from a function that itself is being called as a result of a timer, the additional time for the previous call might be added, causing slight delays.