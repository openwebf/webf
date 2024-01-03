---
sidebar_position: 9
title: Fetch and XHR
---

WebF has built-in support for both the Fetch API and XHR (XMLHttpRequest) API, allowing you to use the same methods for
networking as in browsers.

## Fetch API

The Fetch API provides a modern way to fetch resources over the network in web development.

It's an improvement over the older XMLHttpRequest, offering a more powerful and flexible feature set.

### Overview

+ Promises: Fetch is promise-based, which allows for a more elegant asynchronous code. It's a significant improvement
  over the callback-heavy approach of XMLHttpRequest.
+ Modular Design: With Fetch, the request and response functionalities are broken down into separate concepts, leading
  to more modular and maintainable code.

### Main Components

+ Global fetch() function: This is the entry point for making network requests. You pass in the resource URL you want to
  fetch and, optionally, a configuration object to specify details about the request.
+ Request Object: Represents a resource request. While you can often just use a URL string with fetch(), the Request
  object gives you more detailed control over the request configuration.
+ Response Object: Represents a response to a request. It contains methods to extract the body of the response in
  various formats (e.g., text, blob, JSON, etc.), headers, and other metadata.
+ Headers Object: Used to configure and inspect the headers on a request or response.

### Using Fetch API

Here's a basic example:

```javascript
fetch('https://api.example.com/data')
    .then(response => response.json())
    .then(data => console.log(data))
    .catch(error => console.error('Error fetching data:', error));
```

In this example, a GET request is made to a specified URL. If successful, the response is parsed as JSON and then logged
to the console.

### Advanced Features

**Method and Headers:** You can specify HTTP methods (like POST, PUT, DELETE) and set request headers.

```javascript
fetch('https://api.example.com/data', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({key: 'value'})
});
```

**Error Handling:** Unlike XMLHttpRequest, Fetch API treats HTTP error statuses (like 404 or 500) as successful
responses. You need to manually check for these:

```javascript
fetch('https://api.example.com/data')
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => console.log(data))
    .catch(error => console.error('Error:', error));
```

## XMLHttpRequest (XHR) API

The XMLHttpRequest (XHR) is a browser-based API that developers use to make asynchronous requests in web applications.

Before the advent of the Fetch API, XHR was the primary way to make asynchronous requests from web pages.

### Overview

XHR allows for asynchronous operations, meaning it can fetch data from a server in the background without requiring a
full page refresh.

### Making an XHR Request

**Create an XHR Object:**

```javascript
var xhr = new XMLHttpRequest();
```

**Setup the Request:**

```javascript
xhr.open('GET', 'https://api.example.com/data', true);
```

The open method initializes the request. The first parameter is the HTTP method (e.g., 'GET', 'POST'). The second is the
URL, and the third indicates whether the request should be asynchronous (only support true for asynchronous).

**Handling the Response:**

Attach an event listener to the onreadystatechange property. This event will fire multiple times, covering various stages of the request.

```javascript
xhr.onreadystatechange = function() {
    if (xhr.readyState === 4 && xhr.status === 200) {
        var response = JSON.parse(xhr.responseText);
        console.log(response);
    }
};
```

+ readyState: Holds the status of the XMLHttpRequest.
  + 0: UNSENT
  + 1: OPENED
  + 2: HEADERS_RECEIVED
  + 3: LOADING
  + 4: DONE
+ status: Contains the status code of the response (e.g., 200 for OK, 404 for Not Found).

**Send the Request:**

```javascript
xhr.send();
```

If this were a POST request, you could pass data to the send method.

### Advanced Features

**Setting Request Headers:**

After opening but before sending the request, you can set headers using the setRequestHeader method.

```javascript
xhr.setRequestHeader('Content-Type', 'application/json');
```

**Handling Errors:**

You can handle network errors using the onerror event handler.

```javascript
xhr.onerror = function() {
    console.error("Request failed.");
};
```

**Timeouts:**

XHRs can be set to timeout if a response isn't received within a specified time.

```javascript
xhr.timeout = 3000; // time in milliseconds
xhr.ontimeout = function(e) {
    console.error("Request timed out.");
};
```

**Abort Request:**

You can abort an XHR if needed using the abort method.

xhr.abort();

## Is the networking in WebF under CORS control ?

No, since the execution codes are trusted by default, there is no CORS (Cross-Origin Resource Sharing) policy to forbid
your application from sending or receiving data from any origin.

For more details, please read [WebF vs Browsers](/)