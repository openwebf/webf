---
sidebar_position: 2
title: Overview
---

This guide was designed for developers who have experiences of Web development. If you don't know what is Web
development,
please read the [Web developer guide in MDN](https://developer.mozilla.org/en-US/docs/Learn).

## Key concepts of Web development

HTML/CSS and JavaScript, the three crucial components of Web development, form the foundation of the entire web
development process.

Web developers write code to generate these three components, which browser engines then render into web pages for
deployment to their customers.

In addition to browser engine companies, there are several non-profile groups that maintaining a set of open standards
to describe the technical details of HTML/CSS and JavaScript. These standards define the behavior of HTML/CSS and
JavaScript and ensure
their consistent functioning across different browsers, such as Chrome, Safari and Firefox.

These groups are:

1. [W3C](https://www.w3.org/): This group defines the CSS and other Web APIs in addition to of HTML and DOM
   specifications.
2. [WhatWG](https://spec.whatwg.org/): This group defines the HTML and DOM and other Web API specifications.
3. [TC39](https://tc39.es/): This group defines the features of the JavaScript language and its built-in APIs.

All the features provided by WebF strictly follow the above standards. These standards make it possible to deploy your
web apps for both WebF and WebView, yielding the same results as expected.

## Utilize Flutter to enhance your Web

WebF is built on top of the Flutter framework.

Not only does it provide a 100% consistent environment for both mobile and desktop platforms, but it also allows you to
leverage the capabilities of Flutter to enhance your web apps.

Examples include embedding a natively-implemented video player to play videos with customized encoding, or gaining
access to I/O
with file or network and spawning new processes with the Dart SDK.

WebF facilitates communication with Dart in JS and support embedding any Flutter widgets as a custom HTML element, which
can then be added to your web apps.

## Design Goals of WebF

WebF provides a comprehensive solution for web developers, allowing them to leverage their existing skills in HTML, CSS,
and JavaScript to build cross-platform applications for both mobile and desktop devices.

This distinguishes it from other cross-platform solutions such as [React-Native](https://reactnative.dev/)
or [Weex](https://weexapp.com/). These platforms indeed offer
JavaScript support, but they also require developers to use platform-specific APIs and development tools, which can add
complexity and learning overhead, particularly when you need to support both mobile/desktop and web browsers.

The HTML/CSS and JavaScript support from WebF strictly adhere to the specifications defined by the W3C, WhatWG, and TC39
groups. This ensures that web apps running on WebF are fully compatible with web browsers without requiring any
modifications or conditional ("if-else") statements.

The ultimate goal of WebF is to build a bridge between web development and Flutter/client-side development. Each side
has its own advantages and disadvantages, and WebF aims to combine the strengths of both.

## The limits of WebF

Although WebF supports standard HTML/CSS and JavaScript for development, it doesn't mean you can use any feature from
Web standards to develop WebF apps. Achieving full compliance is the ultimate goal of the WebF project, but there's
still much more work to do.

In its current stages, WebF can offer a subset of Web standards support, which is sufficient for developing attractive
web apps. Please keep in mind whether a certain CSS or DOM API is supported in WebF when developing WebF apps.