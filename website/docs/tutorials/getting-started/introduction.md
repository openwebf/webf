---
sidebar_position: 1
title: Introduction
---

# What is WebF?

WebF is a Flutter package that enables developers to build their Flutter apps using HTML/CSS and JavaScript in one code
base and deploy to mobile and desktop platforms.

It offers a subset of browser capabilities, including HTML, CSS, and a JavaScript runtime environment with built-in DOM,
Window, Document, and other APIs defined in W3C/WhatWG standards.

This allows developers to utilize popular web frameworks, libraries, and other utilities to build apps compatible with
both WebF and web browsers.

By embedding an [optimized QuickJS engine](https://github.com/openwebf/quickjs), WebF can reduce loading time by 50%
compared to WebView.

All Flutter capabilities and its ecosystem are fully accessible to web developers.
This makes it possible for them to embed a native performance video player or a 3D game engine into the web without
experiencing the performance loss associated with WebAssembly or WebGL in WebView.

## Getting Started

We recommend you to start with the [tutorial](/docs/tutorials/getting-started/quick-start), which guides you through the
process of developing an WebF app and distributing it to users.

The [examples](https://github.com/openwebf) and [API documentation](./) are also good places to browse around and
discover new things.

## What is in the docs?

There are two major kinds of developers who are expected to read this documentation -- Web developers and Flutter/client
developers.

These docs are consists of the following different parts:

1. Guide for Web Developers: An end-to-end guide on how to create your first WebF app using HTML/CSS and JavaScript.
2. Guide for Flutter/Client Developers: An end-to-end guide on how to customize behavior and extend WebF's capabilities
   using Flutter.
3. Performance & Optimizations: Crucial methods for measuring and improving the performance of WebF.
4. Best Practices: Essential checklists to keep in mind when developing a WebF app.
5. Resources: Design documents and an overview of the architecture.
6. Contributing Guide: Instructions for developers who want to contribute to WebF.

## Getting help

Are you getting stuck anywhere? Here are a few links to places to look:

1. If you need help developing your app, [our community Discord server](https://discord.gg/jkUsNGndFP) is a great
   place to receive advice from other WebF app developers.
2. If you suspect you're encountering a bug with the WebF, please check the GitHub issue tracker to see if any existing
   issues that match your problem. If not, feel free to fill out our bug report template and submit a new issue.
3. If you want to become a contributor of WebF, please contact [andycall](https://discordapp.com/users/375903419610824707) via discord directly.