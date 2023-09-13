---
sidebar_position: 3
title: DOM and Selectors Support
---

Unlike React-native, which only allows you to operate the virtual DOM, WebF give you full access to DOM and virtual DOM,
behavior the same way as it would when running in web browsers.

Just like the concepts you learn in web development, all supported DOM api strictly follow the WhatWG DOM standards. You can easily find documentations and demos
in [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/API/Document_Object_Model).

## EventTarget API supports

The EventTarget object is the base class for DOM elements. It provides Elements and Nodes with the ability to add
listeners
to handle user interactions.

Refer to the [EventTarget](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget) docs in MDN; all three methods
are available in WebF.

+ [EventTarget.addEventListener(type, listener, useCapture)](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener): Registers a specific listener for a specified event type on an EventTarget.
+ [EventTarget.removeEventListener(type, listener, useCapture)](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/removeEventListener): Removes a previously registered event listener from the EventTarget.
+ [EventTarget.dispatchEvent(event)](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/dispatchEvent): Dispatches a specified event to the EventTarget, invoking the affected EventListeners in the appropriate order.

**Demos**

```javascript
document.body.addEventListener('click', () => {
   console.log('Clicked!');
});
const clickEvent = new MouseEvent('click');
document.body.dispatchEvent(clickEvent);
```

:::info
Refer to the [W3C DOM Events Standard](https://www.w3.org/TR/DOM-Level-3-Events/#event-flow), the event dispatch
mechanism includes three event phases:

1. The capture phase: The event object propagates through the target's ancestors from the Window to the target's parent.
   This phase is also known as the capturing phase.
2. The target phase: The event object arrives at the event object's event target. This phase is also known as the
   at-target phase. If the event type indicates that the event doesn't bubble, then the event object will halt after
   completion of this phase.
3. The bubble phase: The event object propagates through the target's ancestors in reverse order, starting with the
   target’s parent and ending with the Window. This phase is also known as the bubbling phase.

:::

WebF also supports event attributes in Elements; you can add an event listener by setting event attributes to an
Element.

```javascript
document.body.onclick = () => {
   console.log('clicked');
}
```

## Node API supports

The DOM Node interface is an abstract base class upon which many other DOM API objects are based, thus letting those
object types to be used similarly and often interchangeably. As an abstract class, there is no such thing as a plain
Node object. All objects that implement Node functionality are based on one of its subclasses. Most notable are
Document, Element, and DocumentFragment.

<svg viewBox="-1 -1 650 42" preserveAspectRatio="xMinYMin meet">
  <rect x="0" y="0" width="88" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="44" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      EventTarget
    </text>
  <line x1="88" y1="14" x2="118" y2="14" stroke="#D4DDE4"></line>
  <polyline points="88,14 98,9 98,19 88,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="118" y="0" width="75" height="25" fill="#F4F7F8" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="155.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Node
    </text>
</svg>

WebF give you the DOM Node API to operating the DOM tree in WebF. All these Node APIs are strictly follow the WhatWG DOM
standards.

Refer to the [Node](https://developer.mozilla.org/en-US/docs/Web/API/Node) docs in MDN; We provide part of Node API
supports:

+ [Node.nodeType](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeType): Returns an unsigned short representing the type of the node (e.g., ELEMENT_NODE, TEXT_NODE).
+ [Node.nodeName](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeName): Returns the name of the node depending on its type (e.g., the tag name for elements).
+ [Node.nodeValue](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeValue): Returns or sets the value of a node depending on its type.
+ [Node.hasChildNodes()](https://developer.mozilla.org/en-US/docs/Web/API/Node/hasChildNodes): Checks if a node has any child nodes; returns true or false.
+ [Node.childNodes](https://developer.mozilla.org/en-US/docs/Web/API/Node/childNodes): Returns a live NodeList containing all the child nodes of the node.
+ [Node.firstChild](https://developer.mozilla.org/en-US/docs/Web/API/Node/firstChild): Returns the first child node of the node, or null if there is no child.
+ [Node.isConnected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected): Returns a boolean indicating if the node is connected to the DOM.
+ [Node.lastChild](https://developer.mozilla.org/en-US/docs/Web/API/Node/lastChild): Returns the last child node of the node, or null if there are no children.
+ [Node.nextSibling](https://developer.mozilla.org/en-US/docs/Web/API/Node/nextSibling): Returns the next sibling node, or null if there's no subsequent node.
+ [Node.ownerDocument](https://developer.mozilla.org/en-US/docs/Web/API/Node/ownerDocument): Returns the Document object associated with the node.
+ [Node.parentElement](https://developer.mozilla.org/en-US/docs/Web/API/Node/parentElement): Returns the parent Element of the specified node in the DOM, or null if no parent exists.
+ [Node.parentNode](https://developer.mozilla.org/en-US/docs/Web/API/Node/parentNode): Returns the parent node of the specified node in the DOM tree.
+ [Node.previousSibling](https://developer.mozilla.org/en-US/docs/Web/API/Node/previousSibling): Returns the previous sibling node, or null if there's no preceding node.
+ [Node.textContent](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent): Returns or sets the textual content of an element and its descendants.
+ [Node.appendChild(childNode)](https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild): Adds a node to the end of the list of children of a specified parent node. Parameter: childNode - The node to add.
+ [Node.cloneNode(\[deep\])](https://developer.mozilla.org/en-US/docs/Web/API/Node/cloneNode): Creates a duplicate of the node. Parameter: deep (optional) - If true, it clones all descendants.
+ [Node.contains(otherNode)](https://developer.mozilla.org/en-US/docs/Web/API/Node/contains): Checks whether the node is an ancestor (or the same node) as another node. Parameter: otherNode - The node to check. 
+ [Node.insertBefore(newNode, referenceNode)](https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore): Inserts a new child node before a reference node. Parameters: newNode - The node to insert, referenceNode - The node before which the new node will be inserted.
+ [Node.isEqualNode(otherNode)](https://developer.mozilla.org/en-US/docs/Web/API/Node/isEqualNode): Checks if two nodes are equal in terms of attributes, child nodes, etc. Parameter: otherNode - The node to compare.
+ [Node.isSameNode(otherNode)](https://developer.mozilla.org/en-US/docs/Web/API/Node/isSameNode): Checks if two nodes are the exact same node. Parameter: otherNode - The node to compare.
+ [Node.removeChild(child)](https://developer.mozilla.org/en-US/docs/Web/API/Node/removeChild): Removes a child node from the DOM. Parameter: child - The child node to remove.
+ [Node.replaceChild(newChild, oldChild)](https://developer.mozilla.org/en-US/docs/Web/API/Node/replaceChild): Replaces one child node with another. Parameters: newChild - The new node, oldChild - The node to replace.

**Samples**

```javascript
const div = document.createElement('div');
document.body.appendChild(div);
```

## Document API supports

The Document interface represents any web page loaded in the WebF and serves as an entry point into the web page's
content, which is the DOM tree.

<svg viewBox="-1 -1 650 42" preserveAspectRatio="xMinYMin meet">
  <rect x="0" y="0" width="88" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="44" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      EventTarget
    </text>
  <line x1="88" y1="14" x2="118" y2="14" stroke="#D4DDE4"></line>
  <polyline points="88,14 98,9 98,19 88,14" stroke="#D4DDE4" fill="#fff"></polyline>
 <rect x="118" y="0" width="75" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="155.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Node
    </text>
  <line x1="193" y1="14" x2="223" y2="14" stroke="#D4DDE4"></line>
  <polyline points="193,14 203,9 203,19 193,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="223" y="0" width="75" height="25" fill="#F4F7F8" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="260.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Document
    </text>
</svg>

WebF give you the Document API to operating the DOM tree in WebF. All these Document APIs are strictly follow the WhatWG
DOM standards.

+ [Document.all](https://developer.mozilla.org/en-US/docs/Web/API/Document/all): An historical way to access all DOM elements; not recommended due to non-standard behavior. 
+ [Document.head](https://developer.mozilla.org/en-US/docs/Web/API/Document/head): Returns the `<head>` element of the current document.
+ [Document.body](https://developer.mozilla.org/en-US/docs/Web/API/Document/body): Returns the `<body>` element of the current document.
+ [Document.cookie](https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie): Gets or sets the cookies associated with the current document.
+ [Document.domain](https://developer.mozilla.org/en-US/docs/Web/API/Document/domain): Gets or sets the domain portion of the origin of the current document.
+ [Document.documentElement](https://developer.mozilla.org/en-US/docs/Web/API/Document/documentElement): Returns the root element of the document, typically the `<html>` element.
+ [Document.location](https://developer.mozilla.org/en-US/docs/Web/API/Document/location):  Gets or sets the current location of the document.
+ [Document.compatMode](https://developer.mozilla.org/en-US/docs/Web/API/Document/compatMode): Indicates whether the document is rendered in "Quirks" or "Standards" mode.
+ [Document.readyState](https://developer.mozilla.org/en-US/docs/Web/API/Document/readyState):  Returns the loading state of the document (e.g., "loading", "interactive", "complete").
+ [Document.visibilityState](https://developer.mozilla.org/en-US/docs/Web/API/Document/visibilityState): Returns the visibility state of the document (e.g., "visible", "hidden").
+ [Document.hidden](https://developer.mozilla.org/en-US/docs/Web/API/Document/hidden): Returns true if the document is hidden; otherwise, returns false.
+ [Document.defaultView](https://developer.mozilla.org/en-US/docs/Web/API/Document/defaultView): Returns the window object associated with the current document.
+ [Document.createElement(tagName)](https://developer.mozilla.org/en-US/docs/Web/API/Document/createElement): Creates an element with the given tag name. Parameter: tagName.
+ [Document.createElementNS(namespaceURI, qualifiedName)](https://developer.mozilla.org/en-US/docs/Web/API/Document/createElementNS): Creates an element with the given namespace and qualified name. Parameters: namespaceURI, qualifiedName.
+ [Document.createTextNode(data)](https://developer.mozilla.org/en-US/docs/Web/API/Document/createTextNode): Creates a new text node. Parameter: data.
+ [Document.createDocumentFragment()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createDocumentFragment): Creates a new document fragment.
+ [Document.createComment(data)](https://developer.mozilla.org/en-US/docs/Web/API/Document/createComment): Creates a new comment node. Parameter: data.
+ [Document.createEvent(eventInterface)](https://developer.mozilla.org/en-US/docs/Web/API/Document/createEvent): Creates a new event object. Deprecated in favor of using specific event constructors. Parameter: eventInterface.
+ [Document.getElementById(id)](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementById): Returns the element with the specified ID. Parameter: id.
+ [Document.getElementsByClassName(className)](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByClassName): Returns a live HTMLCollection of elements with the given class name. Parameter: className.
+ [Document.getElementsByTagName(tagName)](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByTagName): Returns a live HTMLCollection of elements with the given tag name. Parameter: tagName.
+ [Document.getElementsByName(name)](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByName): Returns a NodeList of elements with the given name attribute. Parameter: name.
+ [Document.querySelector(selectors)](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector): Returns the first element that matches the specified group of selectors. Parameter: selectors.
+ [Document.querySelectorAll(selectors)](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelectorAll): Returns a NodeList of all elements that match the specified group of selectors. Parameter: selectors.

## CharacterData API supports

The CharacterData abstract interface represents a Node object that contains characters. This is an abstract interface,
meaning there aren't any objects of type CharacterData: it is implemented by other interfaces like Text, Comment.

<svg viewBox="-1 -1 650 42" preserveAspectRatio="xMinYMin meet">
  <rect x="0" y="0" width="88" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="44" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      EventTarget
    </text>
  <line x1="88" y1="14" x2="118" y2="14" stroke="#D4DDE4"></line>
  <polyline points="88,14 98,9 98,19 88,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="118" y="0" width="75" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="155.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Node
    </text>
  <line x1="193" y1="14" x2="223" y2="14" stroke="#D4DDE4"></line>
  <polyline points="193,14 203,9 203,19 193,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="223" y="0" width="104" height="25" fill="#F4F7F8" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="275" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      CharacterData
    </text>
</svg>

Refer to the [CharacterData](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData) docs in MDN; We provide part of CharacterData
API supports:

+ [CharacterData.data](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/data): A string representing the character data of the node, or the content of the node. Can be both read and written to
+ [CharacterData.length](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/length): Returns the length of the string contained in the CharacterData node
+ [CharacterData.before(...nodesOrDOMStrings)](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/before): Inserts content (specified as a set of nodes or strings) immediately before the CharacterData node.
+ [CharacterData.after(...nodesOrDOMStrings)](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/after): Inserts content (specified as a set of nodes or strings) immediately after the CharacterData node.

## Element API supports

Element is the most general base class from which all element objects (i.e. objects that represent elements) in a
Document inherit. It only has methods and properties common to all kinds of elements. More specific classes inherit from
Element.

<svg viewBox="-1 -1 650 42" preserveAspectRatio="xMinYMin meet">
  <rect x="0" y="0" width="88" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="44" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      EventTarget
    </text>
  <line x1="88" y1="14" x2="118" y2="14" stroke="#D4DDE4"></line>
  <polyline points="88,14 98,9 98,19 88,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="118" y="0" width="75" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="155.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Node
    </text>
  <line x1="193" y1="14" x2="223" y2="14" stroke="#D4DDE4"></line>
  <polyline points="193,14 203,9 203,19 193,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="223" y="0" width="75" height="25" fill="#F4F7F8" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="260.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Element
    </text>
</svg>


WebF give you the Element API to operating the DOM tree in WebF. All these Element APIs are strictly follow the WhatWG
DOM
standards.

Refer to the [Element](https://developer.mozilla.org/en-US/docs/Web/API/Element) docs in MDN; We provide part of Element
API supports:

+ [Element.id](https://developer.mozilla.org/en-US/docs/Web/API/Element/id): Gets or sets the identifier of the element.
+ [Element.className](https://developer.mozilla.org/en-US/docs/Web/API/Element/className):  Gets or sets the class attribute of the element as a string.
+ [Element.classList](https://developer.mozilla.org/en-US/docs/Web/API/Element/classList): Returns a live DOMTokenList object representing the class attributes of the element.
+ [Element.remove](https://developer.mozilla.org/en-US/docs/Web/API/Element/remove):  Removes the element from the DOM.
+ [Element.attributes](https://developer.mozilla.org/en-US/docs/Web/API/Element/attributes): Returns a live NamedNodeMap of all the element's attributes.
+ [Element.clientHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientHeight): Returns the viewable height of the element in pixels, including padding.
+ [Element.clientLeft](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientLeft): Returns the width of the left border of the element in pixels.
+ [Element.clientTop](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientTop): Returns the width of the top border of the element in pixels.
+ [Element.clientWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientWidth): Returns the viewable width of the element in pixels, including padding.
+ [Element.outerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML): Gets or sets the serialized HTML fragment describing the element including its descendants.
+ [Element.innerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML): Gets or sets the HTML content inside the element.
+ [Element.scrollLeft](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollLeft): Gets or sets the number of pixels by which the content of the element is scrolled to the left.
+ [Element.scrollTop](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollTop): Gets or sets the number of pixels by which the content of the element is scrolled upwards.
+ [Element.scrollWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth): Returns the width in pixels of the entire content of the element, including content not viewable.
+ [Element.scrollHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight): Returns the height in pixels of the entire content of the element, including content not viewable.
+ [Element.prefix](https://developer.mozilla.org/en-US/docs/Web/API/Element/prefix): Returns the namespace prefix of the element, or null if no prefix is specified.
+ [Element.localName](https://developer.mozilla.org/en-US/docs/Web/API/Element/localName): Returns the local part of the qualified name of the element.
+ [Element.namespaceURI](https://developer.mozilla.org/en-US/docs/Web/API/Element/namespaceURI): Returns the namespace URI of the element, or null if no namespace is specified.
+ [Element.tagName](https://developer.mozilla.org/en-US/docs/Web/API/Element/tagName): Returns the name of the element (uppercased in HTML documents).
+ [Element.getAttribute(attrName)](https://developer.mozilla.org/en-US/docs/Web/API/Element/getAttribute): Returns the value of a specified attribute on the element. Parameter: attrName.
+ [Element.setAttribute(attrName, value)](https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute): Sets the value of an attribute on the element. Parameters: attrName, value.
+ [Element.removeAttribute(attrName)](https://developer.mozilla.org/en-US/docs/Web/API/Element/removeAttribute): Removes an attribute from the element. Parameter: attrName.
+ [Element.hasAttribute(attrName)](https://developer.mozilla.org/en-US/docs/Web/API/Element/hasAttribute): Returns true if the element has the specified attribute, otherwise false. Parameter: attrName.
+ [Element.getBoundingClientRect()](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect): Returns a DOMRect object providing information about the size of the element and its position relative to the viewport.
+ [Element.getElementsByClassName(className)](https://developer.mozilla.org/en-US/docs/Web/API/Element/getElementsByClassName): Returns a live HTMLCollection of descendants of the element with the specified class name. Parameter: className.
+ [Element.getElementsByTagName(tagName)](https://developer.mozilla.org/en-US/docs/Web/API/Element/getElementsByTagName): Returns a live HTMLCollection of descendants of the element with the specified tag name. Parameter: tagName.
+ [Element.querySelector(selectors)](https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelector): Returns the first element that is a descendant of the element on which it is invoked that matches the specified group of selectors. Parameter: selectors.
+ [Element.querySelectorAll(selectors)](https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelectorAll): Returns a static NodeList of all elements that are descendants of the element on which it is invoked that match the specified group of selectors. Parameter: selectors.
+ [Element.matches(selectors)](https://developer.mozilla.org/en-US/docs/Web/API/Element/matches): Checks if the element would be selected by the provided selector string. Returns true or false. Parameter: selectors.
+ [Element.closest(selectors)](https://developer.mozilla.org/en-US/docs/Web/API/Element/closest): Returns the closest ancestor of the current element (or the current element itself) which matches the selectors. Returns null if no such element exists. Parameter: selectors.
+ [Element.scroll(options)](https://developer.mozilla.org/en-US/docs/Web/API/Element/scroll): Scrolls the element to a particular set of coordinates. Parameter: options.
+ [Element.scrollBy(options)](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollBy): Scrolls the element to a particular set of coordinates. Parameter: options.
+ [Element.scrollTo(options)](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollTo): Scrolls the element by a particular set of coordinates relative to its current position. Parameter: options.
+ [Element.firstElementChild](https://developer.mozilla.org/en-US/docs/Web/API/Element/firstElementChild): Returns the first child element of the element, or null if there is none.
+ [Element.lastElementChild](https://developer.mozilla.org/en-US/docs/Web/API/Element/lastElementChild): Returns the last child element of the element, or null if there is none.
+ [Element.children](https://developer.mozilla.org/en-US/docs/Web/API/Element/children): Returns a live HTMLCollection of the child elements of the element.
+ [Element.childElementCount](https://developer.mozilla.org/en-US/docs/Web/API/Element/childElementCount): Returns the number of child elements of the element.
+ [Element.prepend(...nodesOrDOMStrings)](https://developer.mozilla.org/en-US/docs/Web/API/Element/prepend): Inserts nodes or strings at the beginning of the element. Parameters: nodesOrDOMStrings.
+ [Element.append(...nodesOrDOMStrings)](https://developer.mozilla.org/en-US/docs/Web/API/Element/append): Inserts nodes or strings at the end of the element. Parameters: nodesOrDOMStrings.
+ [Element.before(...nodesOrDOMStrings)](https://developer.mozilla.org/en-US/docs/Web/API/Element/before): Inserts nodes or strings immediately before the element. Parameters: nodesOrDOMStrings
+ [Element.after(...nodesOrDOMStrings)](https://developer.mozilla.org/en-US/docs/Web/API/Element/after): Inserts nodes or strings immediately after the element. Parameters: nodesOrDOMStrings

**Samples**

```javascript
document.body.innerHTML = `<div>helloworld</div>`;
```

## HTMLElement API supports

The HTMLElement interface represents any HTML element. Some elements directly implement this interface, while others
implement it via an interface that inherits it.

<svg viewBox="-1 -1 650 42" preserveAspectRatio="xMinYMin meet">
  <rect x="0" y="0" width="88" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="44" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      EventTarget
    </text>
  <line x1="88" y1="14" x2="118" y2="14" stroke="#D4DDE4"></line>
  <polyline points="88,14 98,9 98,19 88,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="118" y="0" width="75" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="155.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Node
    </text>
  <line x1="193" y1="14" x2="223" y2="14" stroke="#D4DDE4"></line>
  <polyline points="193,14 203,9 203,19 193,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="223" y="0" width="75" height="25" fill="#fff" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="260.5" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      Element
    </text>
  <line x1="298" y1="14" x2="328" y2="14" stroke="#D4DDE4"></line>
  <polyline points="298,14 308,9 308,19 298,14" stroke="#D4DDE4" fill="#fff"></polyline>
  <rect x="328" y="0" width="88" height="25" fill="#F4F7F8" stroke="#D4DDE4" stroke-width="2px"></rect>
    <text x="372" y="16" font-size="10px" fill="#4D4E53" text-anchor="middle">
      HTMLElement
    </text>
</svg>

WebF give you the HTMLElement API to operating the DOM tree in WebF. All these HTMLElement APIs are strictly follow the
WhatWG DOM standards.

Refer to the HTMLElement docs in MDN; We provide part of HTMLElement API supports:

+ [HTMLElement.offsetTop](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement): Returns the distance of the current element relative to the top of the offsetParent node.
+ [HTMLElement.offsetLeft](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetLeft): Returns the distance of the current element relative to the left of the offsetParent node.
+ [HTMLElement.offsetWidth](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetWidth): Returns the layout width of the element, typically including padding, border, and possibly scrollbar, but not the margin.
+ [HTMLElement.offsetHeight](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetHeight): Returns the layout height of the element, typically including padding, border, and possibly scrollbar, but not the margin.
+ [HTMLElement.dataset](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset): Provides read/write access to custom data-* attributes on the element.
+ [HTMLElement.style](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/style): Returns a CSSStyleDeclaration object that represents the style attribute of the element, used to get or set inline styles.
+ [HTMLElement.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click): Simulates a mouse click on the element, triggering the associated event and any event listeners.

## DOMTokenList API supports

The DOMTokenList interface represents a set of space-separated tokens. Such a set is returned by Element.classList and many others.

A DOMTokenList is indexed beginning with 0 as with JavaScript Array objects. DOMTokenList is always case-sensitive.

Refer to the [DOMTokenList](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList) docs in MDN; We provide part of DOMTokenList API supports:

+ [DOMTokenList.length](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/length): Returns the number of tokens in the list.
+ [DOMTokenList.item(index)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/item): Returns the token at the given index, or `null` if the index is out of bounds.
+ [DOMTokenList.contains(token)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/contains): Checks if the list contains the specified token.
+ [DOMTokenList.add(...tokens)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/add): Adds the specified tokens to the list.
+ [DOMTokenList.remove(...tokens)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/remove): Removes the specified tokens from the list.
+ [DOMTokenList.toggle(token, force)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/toggle): Toggles the presence of a token in the list; can be forced with the `force` parameter.
+ [DOMTokenList.replace(oldToken, newToken)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/replace): Replaces an existing token with a new one.
+ [DOMTokenList.supports(token)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/supports): Checks if the associated element supports the given token.
+ [DOMTokenList.value](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/value): Represents the underlying string of the token list; can be set or retrieved.
+ [DOMTokenList.entries()](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/entries): Returns an iterator allowing to go through all key/value pairs in the list.
+ [DOMTokenList.forEach(callback, thisArg)](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/forEach): Executes a function for each token in the list.
+ [DOMTokenList.keys()](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/keys): Returns an iterator allowing to go through all keys of the key/value pairs in the list.
+ [DOMTokenList.values()](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/values): Returns an iterator allowing to go through all values of the key/value pairs in the list.

## I want more DOM API support

If you require more DOM APIs for your libraries to work in WebF, please raise an [issue](https://github.com/openwebf/webf/issues/new?assignees=&labels=enhancement%2Cimplement&projects=&template=feature_needs_to_implement.yaml) in our GitHub repo. Once there are more people expressing a desire for this feature, we will plan to support it.