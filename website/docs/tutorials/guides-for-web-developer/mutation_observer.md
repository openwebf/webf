---
sidebar_position: 6
title: MutationObserver
---

The MutationObserver interface provides the ability to watch for changes being made to the DOM tree. It is designed as a
replacement for the older Mutation Events feature, which was part of the DOM3 Events specification.

The implementation of the MutationObserver API in WebF and its support in Chrome are completely consistent.

The following doc contents are referring to [MDN](https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver).

## Example

```javascript
// Select the node that will be observed for mutations
const targetNode = document.getElementById("some-id");

// Options for the observer (which mutations to observe)
const config = {attributes: true, childList: true, subtree: true};

// Callback function to execute when mutations are observed
const callback = (mutationList, observer) => {
  for (const mutation of mutationList) {
    if (mutation.type === "childList") {
      console.log("A child node has been added or removed.");
    } else if (mutation.type === "attributes") {
      console.log(`The ${mutation.attributeName} attribute was modified.`);
    }
  }
};

// Create an observer instance linked to the callback function
const observer = new MutationObserver(callback);

// Start observing the target node for configured mutations
observer.observe(targetNode, config);

// Later, you can stop observing
observer.disconnect();
```

## MutationObserver.disconnect()

If the element being observed is removed from the DOM, and then subsequently released by the browser's garbage
collection mechanism, the MutationObserver will stop observing the removed element. However, the MutationObserver itself
can continue to exist to observe other existing elements.

### **Syntax**

```
disconnect()
```

#### **Parameters**

None.

#### **Return value**

undefined.

#### **Example**

This example creates an observer, then disconnects from it, leaving it available for possible reuse.

```javascript
const targetNode = document.querySelector("#someElement");
const observerOptions = {
  childList: true,
  attributes: true,
};

const observer = new MutationObserver(callback);
observer.observe(targetNode, observerOptions);

/* some time later… */

observer.disconnect()
```

## MutationObserver.observer()

The `MutationObserver` method observe() configures the MutationObserver callback to begin receiving notifications of
changes to the DOM that match the given options.

Depending on the configuration, the observer may watch a single Node in the DOM tree, or that node and some or all of
its descendant nodes.

To stop the MutationObserver (so that none of its callbacks will be triggered any longer), call
`MutationObserver.disconnect()`.

### **Syntax**

```
observe(target, options)
```

### **Parameters**

#### target

A DOM Node (which may be an Element) within the DOM tree to watch for changes, or to be the root of a subtree of nodes
to be watched.

#### options

An object providing options that describe which DOM mutations should be reported to `mutationObserver`'s `callback`. At
a
minimum, one of childList, attributes, and/or characterData must be true when you call observe(). Otherwise, a TypeError
exception will be thrown.

Options are as follows:

- `subtree`
  - : Set to `true` to extend monitoring to the entire subtree of nodes rooted at `target`.
    All the other properties are then extended to all the nodes in the subtree instead of applying solely to
    the `target` node. The default value is `false`.
- `childList`
  - : Set to `true` to monitor the target node (and, if `subtree` is `true`, its descendants) for the addition of new
    child nodes or removal of existing child nodes.
    The default value is `false`.
- `attributes`
  - : Set to `true` to watch for changes to the value of attributes on the node or nodes being monitored. The default
    value is `true` if either of `attributeFilter` or `attributeOldValue` is specified, otherwise the default value
    is `false`.
- `attributeFilter`
  - : An array of specific attribute names to be monitored.
    If this property isn't included, changes to all attributes cause mutation notifications.
- `attributeOldValue`
  - : Set to `true` to record the previous value of any attribute that changes when monitoring the node or nodes for
    attribute changes;
    See [Monitoring attribute values](#monitoring_attribute_values) for an example of watching for attribute changes
    and recording values.
    The default value is `false`.
- `characterData`
  - : Set to `true` to monitor the specified target node (and, if `subtree` is `true`, its descendants) for changes to
    the character data contained within the node or nodes.
    The default value is `true` if `characterDataOldValue` is specified, otherwise the default value is `false`.
- `characterDataOldValue`
  - : Set to `true` to record the previous value of a node's text whenever the text changes on nodes being monitored.
    The default value is `false`.

### **Return value**

None

### **Exceptions**

- `TypeError`
  - : Thrown in any of the following circumstances:
    - The `options` are configured such that nothing will actually be monitored.
      (For example, if `childList`, `attributes`, and `characterData` are all `false`.)
    - The value of `options.attributes` is `false` (indicating that attribute changes are not to be monitored),
      but `attributeOldValue` is `true` and/or
      `attributeFilter` is present.
    - The `characterDataOldValue` option is `true` but `characterData` is `false` (indicating that character changes
      are not to be monitored).

## Usage notes

### Reusing MutationObservers

You can call `observe()` multiple times on the same
`MutationObserver` to watch for changes to different parts of the DOM tree
and/or different types of changes. There are some caveats to note:

- If you call `observe()` on a node that's already being observed by the same `MutationObserver`, all existing observers
  are automatically removed from all targets being observed before the new observer is activated.
- If the same `MutationObserver` is not already in use on the target, then the existing observers are left alone and the
  new one is added.

### Observation follows nodes when disconnected

Mutation observers are intended to let you be able to watch the desired set of nodes
over time, even if the direct connections between those nodes are severed. If you begin
watching a subtree of nodes, and a portion of that subtree is detached and moved
elsewhere in the DOM, you continue to watch the detached segment of nodes, receiving the
same callbacks as before the nodes were detached from the original subtree.

In other words, until you've been notified that nodes are being split off from your monitored subtree, you'll get
notifications of changes to that split-off subtree and its nodes.
This prevents you from missing changes that occur after the connection is severed
and before you have a chance to specifically begin monitoring the moved node or subtree for changes.

Theoretically, this means that if you keep track of the `MutationRecord` objects describing the changes that occur, you
should be able to "undo" the changes,
rewinding the DOM back to its initial state.

## Example

### Basic usage

In this example, we demonstrate how to call the method **`observe()`** on an instance of `MutationObserver`, once it has
been set up, passing it a target element
and an `options` object.

```js
// create a new instance of `MutationObserver` named `observer`,
// passing it a callback function
const observer = new MutationObserver(() => {
  console.log("callback that runs when observer is triggered");
});

// call `observe()`, passing it the element to observe, and the options object
observer.observe(document.querySelector("#element-to-observe"), {
  subtree: true,
  childList: true,
});
```

### Using `attributeFilter`

In this example, a Mutation Observer is set up to watch for changes to the
`status` and `username` attributes in any elements contained
within a subtree that displays the names of users in a chat room. This lets the code,
for example, reflect changes to users' nicknames, or to mark them as away from keyboard
(AFK) or offline.

```js
function callback(mutationList) {
  mutationList.forEach((mutation) => {
    switch (mutation.type) {
      case "attributes":
        switch (mutation.attributeName) {
          case "status":
            userStatusChanged(mutation.target.username, mutation.target.status);
            break;
          case "username":
            usernameChanged(mutation.oldValue, mutation.target.username);
            break;
        }
        break;
    }
  });
}

const userListElement = document.querySelector("#userlist");

const observer = new MutationObserver(callback);
observer.observe(userListElement, {
  attributeFilter: ["status", "username"],
  attributeOldValue: true,
  subtree: true,
});
```

### Monitoring attribute values

In this example we observe an input element for attribute value changes, and add a button which toggles the element input's `disabled`
attribute between `"true"` and `"false"`. Inside the observer's callback, we log the old value of the attribute.

#### HTML

```html

<button id="toggle">Toggle direction</button><br/>
<div id="container">
    <input type="text" id="rhubarb" value="Tofu"/>
</div>
<pre id="output"></pre>
```

#### CSS

```css
body {
    background-color: pink;
}

button,
input,
pre {
    margin: 0.5rem;
}
```

#### JavaScript

```js
const toggle = document.querySelector("#toggle");
const rhubarb = document.querySelector("#rhubarb");
const observerTarget = document.querySelector("#container");
const output = document.querySelector("#output");

toggle.addEventListener("click", () => {
  rhubarb.type = rhubarb.type === "text" ? "checkbox" : "text";
});

const config = {
  subtree: true,
  attributeOldValue: true,
};

const callback = (mutationList) => {
  for (const mutation of mutationList) {
    if (mutation.type === "attributes") {
      output.textContent = `The ${mutation.attributeName} attribute was modified from "${mutation.oldValue}".`;
    }
  }
};

const observer = new MutationObserver(callback);
observer.observe(observerTarget, config);
```