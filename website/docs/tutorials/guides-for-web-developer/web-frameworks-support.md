---
sidebar_position: 2
title: Web Frameworks Support
---

Just like web browsers, many web frameworks are well tested in WebF and can be run without any configuration or
modifications.

:::tip HOW TO RUN DEMOS IN THIS GUIDE
For demos with single HTML, you can save this HTML into an `index.html` file, and start a local http server for hosting.
We assume that the HTML can be accessed via the `http://localhost:8080/index.html` address.

For React or Vue projects, the build scripts will start the development server for you.

If you don't have a Flutter developer environment, you can use the following command to preview the results in WebF:

```bash
webf http://localhost:8080/index.html
```

Alternatively, change the URL of `WebFBundle.fromUrl` function in Dart and hot-restart your Flutter apps.

```dart
WebF(bundle: WebFBundle.fromUrl('http://localhost:8080/index.html'), // The page entry point
```

:::

## Vanilla JS support

WebF provides you the DOM API support the same as web browsers and supports W3C/WhatWG defined DOM and Web API;
this makes it possible to develop web apps with vanilla JS.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport"
        content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title>Document</title>
  <style>
    .text-container {
      margin: 10px 0;
    }
  </style>
</head>
<body>
<h1>helloworld</h1>
<div id="button">Click me to add more texts</div>
<div class="text-container"></div>
</body>
<script>
  const button = document.querySelector('#button');
  button.addEventListener('click', () => {
    const container = document.querySelector('.text-container');
    container.appendChild(document.createTextNode('TEXT'));
  });
</script>
</html>
```

The above code will print 'helloworld' in WebF just as it does in browsers

<video src="/videos/vanilla.mov" controls style={{width: "90%", margin: '0 auto', display: 'block'}} />

## Vue.js support

Both Vue2 and Vue3 are fully supported in WebF. Just set up a standard Vue project and run it in WebF.

:::info
Please use [vue-cli](https://cli.vuejs.org/zh/) instead of [Vite](https://vitejs.dev/) to create and build your project
currently.
Due to the lack of support of ESM modules, WebF cannot run the projects built by Vite in development mode.
However, we plan to support this in future versions of WebF.
:::

Check the [samples](https://github.com/openwebf/samples/tree/main/demos/hello-vue)

**Create your Vue project in vue-cli**

```bash
vue init vueapp
```

**Starting your vue project**

```
npm run serve
```

Use the `webf` command or `WebF` widget to load the URL printed in your terminal and you should see the result as below:

![img](/img/helloworld.png)

## React.js support

React.js in all versions is fully supported in WebF. Just set up a standard React.js project and run it in WebF.

Check the [samples](https://github.com/openwebf/samples/tree/main/demos/hello-react)

**Create and Starting your React.js project**

```
npx create-react-app my-app
cd my-app
npm start
```

:::note
Loading SVG as an image is currently not supported in WebF; you can replace it with a PNG file.
We plan to support this in future versions of WebF
:::

Use the `webf` command or `WebF` widget to load the URL printed in your terminal and you should see the result as below:

![react](/img/react.png)