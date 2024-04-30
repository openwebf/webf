---
sidebar_position: 10
title: WebF vs Browsers
---

WebF behaves like a web browser but is not designed to be one.

## The Design Principle of WebF vs. Web Browsers

Web browsers are primarily designed to allow users to access any untrusted origins securely, protecting them from
attackers. The architecture of web browsers prioritizes security and cross-page stability, even at the expense of
performance. As a result, developers using web browser engines are limited in their ability to optimize app performance,
as the most effective performance optimization techniques are often unsafe and prohibited in a browser environment.

Over the past 20 years, web browser engines have become increasingly powerful. Engineers proficient in HTML/CSS and
JavaScript are readily available, prompting many companies to build desktop and mobile apps based on web browser engines
to reduce development costs.

However, for desktop and mobile apps built on top of web browser engines, security and cross-page stability are less
critical than performance. The architecture that maximizes security can hinder performance, creating a bottleneck for
apps built on these engines.

This limitation is why we initiated the WebF project. We aim to redesign the HTML/CSS and JavaScript/Rust runtime system
to create desktop and mobile apps that use browser technology but run more efficiently.

## Perspective Differences Between WebF and Web Browsers

Web browsers are designed to treat each page as standalone and isolated, with resources like images not shared across
pages. Strict memory boundaries between pages prevent data theft from untrusted origins.

In contrast, native app development with languages like Dart, Kotlin, or Swift allows all app components to share a
single environment and context. Native apps can switch routes and pages within a single rendering context and runtime
environment, requiring far less memory and resources than initializing a WebView instance and loading content from a
URL.

For compatibility, our initial routing-related functionality mimics browser design. Users of React-Router or Vue-Router
will find that these work similarly in WebF. However, we recommend using our Hybrid Route feature, where multiple route
pages share the same JavaScript runtime and rendering context, just as they would on a native platform.

## Security Policy Differences

Web browsers incorporate numerous security features, such as CORS, based on the assumption that any executed code could
be malicious. WebF, however, is designed for building apps with web technologies where all JavaScript code has
permissions akin to those of Dart or other native languages. In WebF, all codes are trusted by default, with no sandbox
policy enforced.

## The Main Goals of WebF

The performance of web pages in browsers, although optimized continually, still lags behind native platforms like
iOS/Android or cross-platform frameworks like Flutter.

WebF is engineered to allow developers to build mobile and desktop apps using web technologies such as HTML/CSS and
JavaScript. The primary goal is to maximize performance using web technologies on various clients, maintaining
compatibility with most existing JavaScript libraries and frameworks while pursuing more profound optimization
opportunities.

Recent projects like React Native and mini-apps in China have shown significant performance improvements when not
strictly tied to a single web browser. These successes have demonstrated that there are opportunities to surpass the
capabilities of current web browsers, a realization that motivated the creation of WebF. Our goal is to enhance the
efficiency of HTML/CSS and JavaScript-based applications beyond what is possible with WebView in mobile, desktop, and
other client environments.

WebF not only brings these optimization techniques out of the box but also ensures maximal compatibility with the
broader web ecosystem for developers.

