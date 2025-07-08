# DOM Migration Guide

## Overview
This guide documents the migration of DOM implementations from Dart to C++ in WebF.

## Elements with Shared Implementations

Some HTML elements share the same C++ class implementation:

### HTMLHeadingElement
- Used by: h1, h2, h3, h4, h5, h6
- Constructor: `HTMLHeadingElement(const AtomicString& local_name, Document& document)`
- The tag name must be passed to distinguish between different heading levels

### HTMLQuoteElement  
- Used by: blockquote, q
- Constructor: `HTMLQuoteElement(const AtomicString& local_name, Document& document)`
- The tag name must be passed to distinguish between block and inline quotes

## Code Generation Considerations

The standard code generation system (using html_tag_names.json5) doesn't support elements that:
1. Share the same interface class
2. Need the tag name passed to the constructor

For these special elements, use the `CustomHTMLElementFactory::CreateCustomElement` method.

## Integration Steps

1. The generated `HTMLElementFactory::Create` should first check the custom factory
2. If custom factory returns nullptr, proceed with standard element creation
3. This allows gradual migration while maintaining compatibility

## Adding New Special Elements

1. Add the element to `html_special_elements.json5`
2. Update `CustomHTMLElementFactory::CreateCustomElement` with the new logic
3. Ensure the C++ class constructor accepts the tag name parameter