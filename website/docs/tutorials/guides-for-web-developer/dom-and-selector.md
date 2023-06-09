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

+ [EventTarget.addEventListener()](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener)
+ [EventTarget.removeEventListener()](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/removeEventListener)
+ [EventTarget.dispatchEvent()](https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/dispatchEvent)

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

WebF implement these three phases internally but only provides APIs for Web developers to handle phase 2 and 3.

Therefore, the following codes won't be functional until we add support for APIs to trigger callback at phase 1.

```javascript
document.body.addEventListener('click', () => {
   console.log('Clicked!');
}, true /* the third parameter indicates that this callback should be triggered at the capture phase, but we don't support this in the current versions  */);
```

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

+ [Node.nodeType](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeType)
+ [Node.nodeName](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeName)
+ [Node.nodeValue](https://developer.mozilla.org/en-US/docs/Web/API/Node/nodeValue)
+ [Node.hasChildNodes()](https://developer.mozilla.org/en-US/docs/Web/API/Node/hasChildNodes)
+ [Node.childNodes](https://developer.mozilla.org/en-US/docs/Web/API/Node/childNodes)
+ [Node.firstChild](https://developer.mozilla.org/en-US/docs/Web/API/Node/firstChild)
+ [Node.isConnected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected)
+ [Node.lastChild](https://developer.mozilla.org/en-US/docs/Web/API/Node/lastChild)
+ [Node.nextSibling](https://developer.mozilla.org/en-US/docs/Web/API/Node/nextSibling)
+ [Node.ownerDocument](https://developer.mozilla.org/en-US/docs/Web/API/Node/ownerDocument)
+ [Node.parentElement](https://developer.mozilla.org/en-US/docs/Web/API/Node/parentElement)
+ [Node.parentNode](https://developer.mozilla.org/en-US/docs/Web/API/Node/parentNode)
+ [Node.previousSibling](https://developer.mozilla.org/en-US/docs/Web/API/Node/previousSibling)
+ [Node.textContent](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent)
+ [Node.appendChild()](https://developer.mozilla.org/en-US/docs/Web/API/Node/appendChild)
+ [Node.cloneNode()](https://developer.mozilla.org/en-US/docs/Web/API/Node/cloneNode)
+ [Node.contains()](https://developer.mozilla.org/en-US/docs/Web/API/Node/contains)
+ [Node.insertBefore()](https://developer.mozilla.org/en-US/docs/Web/API/Node/insertBefore)
+ [Node.isEqualNode()](https://developer.mozilla.org/en-US/docs/Web/API/Node/isEqualNode)
+ [Node.isSameNode()](https://developer.mozilla.org/en-US/docs/Web/API/Node/isSameNode)
+ [Node.removeChild()](https://developer.mozilla.org/en-US/docs/Web/API/Node/removeChild)
+ [Node.replaceChild()](https://developer.mozilla.org/en-US/docs/Web/API/Node/replaceChild)

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

+ [Document.all](https://developer.mozilla.org/en-US/docs/Web/API/Document/all)
+ [Document.head](https://developer.mozilla.org/en-US/docs/Web/API/Document/head)
+ [Document.body](https://developer.mozilla.org/en-US/docs/Web/API/Document/body)
+ [Document.cookie](https://developer.mozilla.org/en-US/docs/Web/API/Document/cookie)
+ [Document.domain](https://developer.mozilla.org/en-US/docs/Web/API/Document/domain)
+ [Document.documentElement](https://developer.mozilla.org/en-US/docs/Web/API/Document/documentElement)
+ [Document.location](https://developer.mozilla.org/en-US/docs/Web/API/Document/location)
+ [Document.compatMode](https://developer.mozilla.org/en-US/docs/Web/API/Document/compatMode)
+ [Document.readyState](https://developer.mozilla.org/en-US/docs/Web/API/Document/readyState)
+ [Document.visibilityState](https://developer.mozilla.org/en-US/docs/Web/API/Document/visibilityState)
+ [Document.hidden](https://developer.mozilla.org/en-US/docs/Web/API/Document/hidden)
+ [Document.defaultView](https://developer.mozilla.org/en-US/docs/Web/API/Document/defaultView)
+ [Document.createElement()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createElement)
+ [Document.createElementNS()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createElementNS)
+ [Document.createTextNode()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createTextNode)
+ [Document.createDocumentFragment()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createDocumentFragment)
+ [Document.createComment()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createComment)
+ [Document.createEvent()](https://developer.mozilla.org/en-US/docs/Web/API/Document/createEvent)
+ [Document.getElementById()](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementById)
+ [Document.getElementsByClassName()](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByClassName)
+ [Document.getElementsByTagName()](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByTagName)
+ [Document.getElementsByName()](https://developer.mozilla.org/en-US/docs/Web/API/Document/getElementsByName)
+ [Document.querySelector()](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector)
+ [Document.querySelectorAll()](https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelectorAll)

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

+ [CharacterData.data](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/data)
+ [CharacterData.length](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/length)
+ [CharacterData.before](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/before)
+ [CharacterData.after](https://developer.mozilla.org/en-US/docs/Web/API/CharacterData/after)

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

+ [Element.id](https://developer.mozilla.org/en-US/docs/Web/API/Element/id)
+ [Element.className](https://developer.mozilla.org/en-US/docs/Web/API/Element/className)
+ [Element.classList](https://developer.mozilla.org/en-US/docs/Web/API/Element/classList)
+ [Element.remove](https://developer.mozilla.org/en-US/docs/Web/API/Element/remove)
+ [Element.attributes](https://developer.mozilla.org/en-US/docs/Web/API/Element/attributes)
+ [Element.clientHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientHeight)
+ [Element.clientLeft](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientLeft)
+ [Element.clientTop](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientTop)
+ [Element.clientWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/clientWidth)
+ [Element.outerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/outerHTML)
+ [Element.innerHTML](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML)
+ [Element.scrollLeft](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollLeft)
+ [Element.scrollTop](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollTop)
+ [Element.scrollWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth)
+ [Element.scrollHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight)
+ [Element.prefix](https://developer.mozilla.org/en-US/docs/Web/API/Element/prefix)
+ [Element.localName](https://developer.mozilla.org/en-US/docs/Web/API/Element/localName)
+ [Element.namespaceURI](https://developer.mozilla.org/en-US/docs/Web/API/Element/namespaceURI)
+ [Element.tagName](https://developer.mozilla.org/en-US/docs/Web/API/Element/tagName)
+ [Element.getAttribute()](https://developer.mozilla.org/en-US/docs/Web/API/Element/getAttribute)
+ [Element.setAttribute()](https://developer.mozilla.org/en-US/docs/Web/API/Element/setAttribute)
+ [Element.removeAttribute()](https://developer.mozilla.org/en-US/docs/Web/API/Element/removeAttribute)
+ [Element.hasAttribute()](https://developer.mozilla.org/en-US/docs/Web/API/Element/hasAttribute)
+ [Element.getBoundingClientRect()](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect)
+ [Element.getElementsByClassName()](https://developer.mozilla.org/en-US/docs/Web/API/Element/getElementsByClassName)
+ [Element.getElementsByTagName()](https://developer.mozilla.org/en-US/docs/Web/API/Element/getElementsByTagName)
+ [Element.querySelector()](https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelector)
+ [Element.querySelectorAll()](https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelectorAll)
+ [Element.matches()](https://developer.mozilla.org/en-US/docs/Web/API/Element/matches)
+ [Element.closest()](https://developer.mozilla.org/en-US/docs/Web/API/Element/closest)
+ [Element.scroll()](https://developer.mozilla.org/en-US/docs/Web/API/Element/scroll)
+ [Element.scrollBy()](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollBy)
+ [Element.scrollTo()](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollTo)
+ [Element.firstElementChild](https://developer.mozilla.org/en-US/docs/Web/API/Element/firstElementChild)
+ [Element.lastElementChild](https://developer.mozilla.org/en-US/docs/Web/API/Element/lastElementChild)
+ [Element.children](https://developer.mozilla.org/en-US/docs/Web/API/Element/children)
+ [Element.childElementCount](https://developer.mozilla.org/en-US/docs/Web/API/Element/childElementCount)
+ [Element.prepend()](https://developer.mozilla.org/en-US/docs/Web/API/Element/prepend)
+ [Element.append()](https://developer.mozilla.org/en-US/docs/Web/API/Element/append)
+ [Element.before()](https://developer.mozilla.org/en-US/docs/Web/API/Element/before)
+ [Element.after()](https://developer.mozilla.org/en-US/docs/Web/API/Element/after)

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

+ [HTMLElement.offsetTop](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement)
+ [HTMLElement.offsetLeft](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetLeft)
+ [HTMLElement.offsetWidth](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetWidth)
+ [HTMLElement.offsetHeight](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/offsetHeight)
+ [HTMLElement.dataset](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset)
+ [HTMLElement.style](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/style)
+ [HTMLElement.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click)

## DOMTokenList API supports

The DOMTokenList interface represents a set of space-separated tokens. Such a set is returned by Element.classList and many others.

A DOMTokenList is indexed beginning with 0 as with JavaScript Array objects. DOMTokenList is always case-sensitive.

Refer to the [DOMTokenList](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList) docs in MDN; We provide part of DOMTokenList API supports:

+ [DOMTokenList.length](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/length)
+ [DOMTokenList.item](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/item)
+ [DOMTokenList.contains](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/contains)
+ [DOMTokenList.add](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/add)
+ [DOMTokenList.remove](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/remove)
+ [DOMTokenList.toggle](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/toggle)
+ [DOMTokenList.replace](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/replace)
+ [DOMTokenList.supports](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/supports)
+ [DOMTokenList.value](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/value)
+ [DOMTokenList.entries](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/entries)
+ [DOMTokenList.forEach](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/forEach)
+ [DOMTokenList.keys](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/keys)
+ [DOMTokenList.values](https://developer.mozilla.org/en-US/docs/Web/API/DOMTokenList/values)

## I want more DOM API support

If you require more DOM APIs for your libraries to work in WebF, please raise an [issue](https://github.com/openwebf/webf/issues/new?assignees=&labels=enhancement%2Cimplement&projects=&template=feature_needs_to_implement.yaml) in our GitHub repo. Once there are more people expressing a desire for this feature, we will plan to support it.