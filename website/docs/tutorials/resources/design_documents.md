---
sidebar_position: 1
title: Design Documents
---

## Introduction

When developing a mobile application, considerations around development efficiency, performance & user experience, and
maintenance iteration costs are unavoidable.

Apps based on WebView can offer excellent development efficiency. However, their performance and user experience are
typically mediocre. They also suffer from compatibility issues due to browser fragmentation and have inconvenient
debugging, leading to increased maintenance and iteration costs.

Pure client-side development technologies based on Native/Flutter can provide the best performance and user experience.
However, their development efficiency lags behind Web, and they're limited by release constraints, meaning that their
iteration cycles are strictly controlled, failing to respond to business demands in real-time.

WebF is a rendering engine compatible with web browsers. It builds upon Flutter's existing rendering pipeline and
implements the capabilities that web applications depend on, such as CSS/HTML/JavaScript/Web API. This allows
applications written by front-end developers to run on Flutter.

WebF offers developers a development efficiency comparable to WebView. Simultaneously, its performance and experience
lie between WebView and Native apps. It provides developers with a consistent runtime environment across all platforms,
eliminating concerns about compatibility. It also supports debugging using Chrome's DevTools and even has the capability
to perform real-time debugging of all functionalities in a production environment, significantly reducing the cost of
application maintenance and iteration.

In terms of performance and experience, WebF also offers developers two different solutions to cater to various business
scenarios. Developers can freely choose to use CSS directly or employ Flutter Widget for UI implementation. The former
has a lower development maintenance cost, while the latter delivers a better interaction and experience.

## Architecture Overview

![1](./imgs/architecture_overview.png)

WebF, built upon Flutter Foundation, has additionally constructed a Rendering layer to implement layout capabilities as
defined in the CSS standard, including Flexbox, Flow layouts, positioning, etc., to cater to developers' needs to design
various page layouts using CSS.

Furthermore, it integrates the parsing of HTML and CSS, the construction of the DOM tree, the building of the CSSOM, and
the processing of cascading styles, catering to developers utilizing HTML to establish page structure and CSS cascade
style sheets to set the page's appearance. The HTML/CSS capabilities provided by WebF are all implemented as defined by
the W3C standard and compatible to web browsers. The final result is entirely consistent with the outcome rendered by
browsers like Chrome and Safari. This allows developers to run HTML/CSS codes written for the web directly on WebF
without any modifications, eliminating the need to learn new functionalities. By mastering web development technologies,
developers can effortlessly develop applications on WebF.

Beyond the core HTML/CSS capabilities, WebF also offers auxiliary features such as Web Modules and Inspector to provide
developers with extensibility and debugging support.

The capabilities described above detail the core rendering support that WebF achieves based on Flutter using the Dart
language. To enable developers to construct pages using JavaScript, WebF incorporates QuickJS as its JavaScript Engine
and integrates commonly used Web APIs and DOM APIs in web pages, fulfilling the operational requirements for frontend
frameworks like React and Vue. This ensures that these frontend frameworks and their related ecosystem components run in
the JavaScript environment provided by WebF without altering a single line of code, achieving a seamless migration from
web pages to WebF pages.

## The Rendering Process of WebF

![image-20231016083451148](./imgs/rendering_process.png)

The HTML/CSS/JavaScript written by developers undergoes six stages to render the codes into pixels and display them on
the user's mobile device:

1. **Parsing**: HTML Parser and CSS Parser are used to generate the respective DOM Tree and CSSOM Tree.
2. **JavaScript Execution**: The JavaScript Engine parses and runs the code. During this phase, the frontend framework's
   code will be executed. Additionally, the structure of the DOM Tree might be modified and updated through JavaScript
   APIs.
3. **Tree Combination**: The DOM Tree and CSSOM Tree are combined to form the RenderObject Tree.
4. **Layout**: The hardware notifies the software layer through the VSYNC signal. As the next frame for rendering
   begins, the Layout method of the RenderObject Tree is sequentially invoked. This confirms the entire page's structure
   and coordinate information. The internal layout algorithm will convert the style information passed by the user
   through the CSS stylesheet into corresponding dimensions and coordinates, establishing the position of every
   RenderObject on the page.
5. **Painting**: Once the layout for the RenderObject is finalized, it transitions into the Paint phase. In this phase,
   the RenderObject interprets the styling information set through the CSS stylesheet into corresponding graphic API
   drawing commands. Leveraging dimensions and coordinates acquired from the preceding stage, it then converts these
   drawing commands into the Layer Tree, which is subsequently relayed to the Flutter engine.
6. **Rendering & Display**: Upon receiving the Layer Tree, the Flutter engine employs Skia/Impeller to transmute the
   graphic commands into corresponding operations for OpenGL/Metal/Vulkan. These operations are then processed by the
   GPU, culminating in the content being displayed on the user's screen.

## The Binding System of WebF

WebF utilizes the QuickJS JavaScript Engine, developed by Fabrice Bellard. QuickJS supports the ES2020 specification,
encompassing features such as modules, asynchronous generators, proxies, and BigInt.

However, standard JavaScript engines, including QuickJS, don't natively support Web API interfaces like Window,
Document, and DOM APIs. These interfaces are defined in W3C/WhatWG standards and are typically exclusive to JavaScript
runtimes in web browsers.

To bridge this gap, WebF's binding system was conceived. Its primary function is to seamlessly integrate APIs from
C++/Dart DOM implementations into the JavaScript environment.

A significant portion, nearly half, of WebF's codebase is written in Dart. Additionally, WebF leverages the Flutter
widget system. This setup allows Flutter developers to craft custom elements using Flutter widgets and Dart. Given that
the custom elements are wholly defined in Dart, the binding system also facilitates a mechanism that defines properties
and methods in Dart, ensuring they are accessible in JavaScript.

They are hundreds of Web API was included in WebF; These APIs meet the execution requirements of front-end frameworks
and application codes.

These built-in APIs are implemented using C++. They are then exposed as JavaScript APIs through the C API provided by
the QuickJS Engine for JavaScript to call.

However, to fully expose a comprehensive set of C++ implemented DOM API and Web API for JavaScript to call, we need a
complete registration management mechanism to assist core developers in maintaining these APIs.

### How JavaScript Web APIs Registered in WebF

The Web APIs defined by W3C web standards are not just standalone sets of APIs. They are organized into an extensive
prototype chain where each member can inherit the properties and methods of its parent. JavaScript uses prototype
objects to implement class inheritance.

QuickJS provides only the fundamental atomic operation C APIs for developers, such as creating an object, setting an
attribute, and defining an object's prototype, among others. However, according to the WhatWG DOM standard, a
comprehensive DOM API encompasses EventTarget, Node, Element, HTMLElement, and the various HTML tags corresponding to
HTMLElement. They have an inheritance hierarchy: Node inherits from EventTarget, Element inherits from Node, and
HTMLElement inherits from Element. With each level of inheritance, the derived class inherits all the properties and
methods of its parent class.

Given that we have a collection of EventTarget, Node, and Element implemented in C++, how can we make them available in
JavaScript? The challenge is to ensure that performance isn't compromised while maintaining the inheritance
relationships from C++.

If JavaScript retrieves a DOM object, these inheritance relationships must be pre-established. This allows users to
utilize JavaScript to access properties and methods defined by the Element from this object, as well as those defined by
EventTarget.

When aiming to implement a comprehensive set of DOM APIs in C++, the primary challenge is establishing the inheritance
of properties and methods. This ensures that an Element instantiated in C++ can access methods delineated on the
EventTarget, which is also crafted in C++

![image3](./imgs/api_organized.png)

JavaScript employs the prototype mechanism to achieve property inheritance, a mechanism that can be extended to objects
instantiated in C++. By utilizing the QuickJS API to adjust the prototype chain of objects created in C++, we can
establish their inheritance relationships. Consequently, JavaScript code can navigate and locate the relevant properties
and methods via the prototype chain

#### How to Implement Type Mapping between C++ and JavaScript

JavaScript is a dynamically typed language, so converting its types to C++ requires runtime checks to ascertain the
exact type of a parameter. When C++ receives a call from JavaScript, there has to be a preliminary logic check before
the type conversion can occur.

Thanks to TypeScript typing, we can know the expected parameter types for an API. This can enable us to generate logic
checks for automatic type conversion and verification. However, due to the countless combinations of JavaScript types,
simple "if" checks cannot cover every scenario. We need a mechanism that can handle combinations of different types and
also validate these types.

WebF uses the C++ Template Type Traits feature to implement this type conversion module.

![image6 (1)](./imgs/gen_bindings.png)

The code generator uses TypeScript Typings' type definitions to produce the relevant type conversion code. The Converter
is a C++ template class designed to accept template parameters. The code generator transposes the TypeScript type into
template parameters that the Converter can process, enabling the Converter to manage type validation and associated
operations.

Specific type mapping is as follows:

| TS                                              | C++                      |
|-------------------------------------------------|--------------------------|
| double                                          | IDLDouble                |
| Int64                                           | IDLInt64                 |
| double?                                         | `IDLOptional<IDLDouble>` |
| double \| null                                  | `IDLNullable<IDLDouble>` |
| double[]                                        | `IDLSequence<IDLDouble>` |
| type BlobParty = { name: string, value: double} | DictionaryType           |
| Function                                        | const std::shared_ptr< > |
| any                                             | IDLAny                   |

The C++ Template's Type Traits will automatically match the corresponding class based on the template parameter and then
call the processing function corresponding to the type:

![img](./imgs/binding_code.png)

#### How to Quickly Generate the Type Mapping and API codes

The DOM API and Web API standards encompass a vast array of APIs and attributes, collectively numbering in the hundreds.
Each attribute has its specific parameters and type constraints. In WebF, these APIs have C++ implementations. To make
them accessible to JavaScript, they need to be wrapped using the QuickJS API, complete with parameter validation.
Manually coding this would be not only tedious but also prone to human error. Hence, the logical approach is to employ a
specialized code generator to expedite the creation of the Binding API code.

<img alt="img" src="/img/binding_gen.png" width="400"/>

The DOM API and Web API standards define a large number of APIs and attributes, which combined, total in the hundreds.
Each attribute has its corresponding parameters and type requirements. In WebF, these APIs are implemented using C++.
However, invoking the QuickJS API is essential to encapsulate these C++ functions into a JavaScript function for
JavaScript calls, along with the necessary parameter validation. Manually writing this vast amount of code would not
only be time-consuming but might also lead to errors due to individual oversight. Thus, hand-writing this code would
result in a significant waste of time and resources. As a result, there's a pressing need to develop a specialized code
generator that can rapidly generate Binding API code.

<img alt="code_gen" src="/img/code_gen.png" width="450"/>

Using the Compiler API provided by TypeScript, the Code Generator parses the TypeScript Types into a TypeScript AST.
Then, through a series of transformations, it generates the IDLBlobs data structure. IDLBlobs represents the structured
information of TypeScript Types and can be read by the EJS Template to generate C++ files. During the generation
process, code for parameter validation is also produced. This validation ensures that JavaScript types are correctly
converted to C++ types for use in C++ code.

### How to achieve high-performance data communication between C++ and Dart

WebF's built-in JavaScript Engine, DOM API, and Web API are all implemented in C/C++. However, the specific
implementations of DOM and CSS, as well as layout-related capabilities, are written in the Dart language. Therefore,
establishing a high-performance data channel is a necessary step.

#### Relationship between JavaScript and Dart threads

In the design of some rendering engines, they tend to place JavaScript and UI rendering in separate, independent
threads. This design offers the benefit of ensuring that the execution of JavaScript and the rendering of the UI don't
interfere with each other. However, since JavaScript and UI run on two separate threads, their data communication must
be managed through thread scheduling and synchronization. Therefore, whenever data communication occurs, it
simultaneously affects the performance of both threads, causing the entire page to lag

![dart_js_thread](./imgs/dart_js_thread.png)

When developers need to implement UI animations in a page using JavaScript, they face a noticeable frame drop issue. The
root cause of this problem is that since JavaScript controls the UI for animations, there needs to be communication from
JavaScript to UI and vice versa during the rendering process of every frame. To achieve a rendering frame rate of at
least 60 FPS, the time consumed per frame must be less than 16 ms. However, for rendering engines that treat JavaScript
and UI threads as two separate entities, this time is far from sufficient, leading to stuttering issues.

![single_thread](./imgs/single_thread.png)

In WebF, JavaScript and Dart run in the same thread, eliminating the need for multi-thread synchronization. Furthermore,
benefiting from the single-threaded model, Dart and C++ can share data. This allows for more efficient information
communication than conventional data structures like JSON.

#### Design of DOM Node Operation Command Buffer

During the initial page load phase, the rendering engine needs to parse HTML and generate a large number of DOM nodes.
The creation information of these nodes needs to be sent from C++ to Dart, and then handed over to the Dart side to
complete the remaining steps.

Typically, this information is very dense at initial load. Even simpler web applications can produce thousands of DOM
operation instructions. Due to the communication efficiency of Dart FFI, a single Dart FFI to C++ communication takes
about 0.01 to 0.02 ms. Therefore, for such dense communication instruction operations, it is necessary to buffer the
operations and then process them in batches.

![command_buffer](./imgs/command_buffer.png)

At the start of each frame, when there is JavaScript code to execute, and the DOM API is manipulated through JavaScript,
a UICommand operation instruction is generated. The generated operation instructions are not sent to Dart immediately
but are stored in a separate space.

As the frame is about to end, all cached UICommands are retrieved at once, and operations are executed in bulk. Finally,
ClearUICommand is called to clear the instructions, awaiting the next frame's processing.

#### Data communication format of DOM node operation Command

To maximize performance, WebF has specifically designed a special command format for DOM node operations:

<img alt="ui_command" src="/img/ui_commands.png" width="300"/>

The single UICommand is 40 bytes, with both Type and ID taking up 4 bytes each, Arg0_len and Arg1_len are also 4 bytes
each, and the remaining members are 8 bytes each.

This data structure, simply by reading memory in 40-byte lengths, allows the retrieval of multiple operation commands.
There's no need for additional parsing; they can be used directly.

This design is very efficient because it minimizes the overhead of command processing, allowing for a streamlined,
low-latency communication between C++ and Dart. The fixed size of commands simplifies the reading process, eliminating
the need for complex parsing logic or handling of variable-length messages.

#### Data communication format specifically designed for APIs

Besides using UICommand, WebF also provides a way for JavaScript to communicate data directly with Dart through C++.

In WebF, JS needs to send various types of data to the Dart side, and Dart also needs to return different types of data
to JS. These data types include not only serializable strings, numbers, objects, and arrays, but also non-serializable
data types. These data are unique, cannot be duplicated, and must ensure that the value obtained after cross-language
transmission is still the original object, such as when the type of data being passed is an Element object.

In addition to non-duplicable objects, the types of data can also be functions, used to directly expose Dart's functions
in JavaScript for developers to call using JavaScript. And these aren't just limited to synchronous calls; they also
need to support JavaScript functions returning a Promise, or passing an async-await function.

This setup is particularly important in managing complex interactions in web applications where the frontend (
JavaScript) and backend (Dart, in this case) need to maintain consistent states and perform various real-time
operations. This interplay must be seamless, especially when dealing with non-serializable data types, to ensure the
integrity and consistency of data throughout the application. The system could handle these unique objects appropriately
to maintain their identity and state across these interactions. Moreover, supporting various types of function calls,
including those that are asynchronous, enhances the responsiveness and user experience of the application by efficiently
handling tasks that may take some time to complete.

Therefore, using JSON as the only medium for data transfer is insufficient to meet all these needs, so a new data
communication format is required. This format should not only transmit regular value types but also reference types and
even functions.

Firstly, we need a more efficient data structure compared to JSON. This structure should not require additional parsing
for processing; it can be used directly.

<img alt="ui_command" src="/img/native_value.png" width="500"/>

WebF utilizes the NativeValue C struct as its communication protocol, determining the data type with a uint32_t and
using the remaining 12 bytes to store data. This structure, compared to using JSON, saves time that would otherwise be
spent parsing strings, significantly enhancing communication efficiency.

Communication between JavaScript and Dart occurs through C/C++ acting as a bridge. Data communication between JavaScript
and C/C++ can be achieved through the C API provided by QuickJS. However, direct object transfer between Dart and C++
isn't possible because Dart's object transfer is reference-based, while C/C++ involves pointer passing. Therefore,
standard Dart objects cannot be directly transmitted through FFI, nor is it easy to compare values.

<img alt="ui_command" src="/img/binding_object.png" width="500"/>

To resolve the aforementioned issues, we require a shared data structure that can be accessed by both Dart and C++.
Then, both C++ objects and Dart objects should hold the pointer address of this data structure simultaneously.

<img alt="ui_command" src="/img/binding_object_flow.png" width="500"/>

This method means that when there's a need to pass an object from C++ to the Dart environment, it's only necessary to
pass the pointer of the shared data structure into Dart. Then, the actual Dart object can be identified based on this
pointer address using an existing mapping table. Similarly, when a Dart object needs to be passed to C++, only the
address of the shared data structure needs to be transmitted.

Subsequently, in C++, the pointer to the corresponding JavaScript object can be retrieved based on the pointer stored
within the shared data structure.

This technique facilitates a smooth and efficient object transfer between the different environments, ensuring data
consistency and integrity while avoiding the performance overhead of serialization and deserialization. It leverages
direct memory access and pointer sharing, which is significantly faster and more resource-efficient, especially when
dealing with complex or high-volume data transitions.

#### Managing the lifecycle of Element objects through JavaScript GC

Managing the lifecycle of Element objects through JavaScript GC involves JavaScript calling Dart Element objects through
APIs implemented with C++ Binding. This process spans three languages, creating significant challenges in determining
the right time for memory recycling.

When a JavaScript Element object is no longer in use and gets released by JavaScript GC, the Dart-side Element doesn't
recognize its unavailability, leading to persistent memory storage and a memory leak issue.

Therefore, a notification mechanism is necessary. When an Element is released by JavaScript GC, Dart needs to be
informed to carry out the memory release on its side.

QuickJS API offers a function that listens for the timing of objects being reclaimed by GC, allowing for a callback
function to be executed right before this object is released.

With this callback function, WebF can seamlessly integrate the lifecycles of JavaScript and Dart objects. When a
JavaScript Element is released by GC, this callback can be used to unlink the reference to the Dart-side Element,
allowing Dart's GC to take over the destruction of this Element.

