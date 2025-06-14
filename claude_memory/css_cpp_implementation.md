# CSS C++ Implementation in WebF

## Overview
WebF's C++ CSS implementation in the `bridge/` directory follows Chromium/Blink's architecture, providing a robust foundation for CSS parsing, storage, and computation.

## Architecture

### Core Class Hierarchy
The CSS value system is built on a type-safe class hierarchy:

```
CSSValue (base class)
├── CSSPrimitiveValue
│   ├── CSSNumericLiteralValue (numbers with units)
│   ├── CSSIdentifierValue (keywords)
│   └── CSSStringValue (strings)
├── CSSValueList (space/comma separated values)
├── CSSColorValue (color representations)
├── CSSImageValue (image references)
├── CSSGradientValue (gradient definitions)
├── CSSFunctionValue (CSS functions)
├── CSSCustomIdentValue (custom identifiers)
└── CSSValuePair (value pairs)
```

### Key Components

#### 1. CSS Properties (`bridge/core/css/properties/`)
- **css_properties.json5**: Property definitions with metadata
- **css_property_names.h**: Generated enum of 400+ CSS properties
- **CSSProperty**: Base class for property handling
- **Longhand/Shorthand properties**: Separate handling for different property types

#### 2. CSS Values (`bridge/core/css/`)
- **css_value.h/cc**: Base CSSValue class with ClassType enum
- **css_value_keywords.json5**: 500+ CSS keyword definitions
- **CSSValueID**: Generated enum for all CSS keywords
- **Primitive values**: Numbers, lengths, percentages, colors, etc.

#### 3. CSS Parser (`bridge/core/css/parser/`)
- **CSSParser**: Main parser interface
- **CSSPropertyParser**: Parses individual properties
- **CSSParserToken**: Token representation
- **CSSParserContext**: Parsing context and state
- **CSSParsingUtils**: Utility functions for consuming specific value types

#### 4. CSS Syntax Parser (Recent Addition)
- **CSSSyntaxStringParser**: Parses CSS syntax definitions
- **CSSSyntaxDefinition**: Represents parsed syntax patterns
- **CSSSyntaxComponent**: Individual syntax components
- **CSSVariableData**: Custom property storage

### Parsing Flow

1. **Tokenization**: Input CSS text → CSSParserTokens
2. **Property Parsing**: Tokens → CSSPropertyParser → CSSValue objects
3. **Value Construction**: Type-specific parsing creates appropriate CSSValue subclasses
4. **Storage**: Parsed values stored in ComputedStyle or inline styles

### Value Types and Units

#### Length Units
- Absolute: px, cm, mm, in, pt, pc, q
- Font-relative: em, rem, ex, ch
- Viewport-relative: vw, vh, vmin, vmax
- Percentage: %

#### Other Units
- Time: s, ms
- Angle: deg, rad, grad, turn
- Resolution: dpi, dpcm, dppx

### Special Features

#### 1. Calc Support
- CSSMathExpressionNode: AST for math expressions
- CSSMathFunctionValue: Represents calc() and other math functions
- Supports nested calculations and unit conversions

#### 2. Custom Properties (CSS Variables)
- CSSVariableData: Stores unparsed custom property values
- CSSVariableReferenceValue: References to var() usage
- Late resolution during style computation

#### 3. Color Handling
- Named colors from css_value_keywords.json5
- RGB/RGBA/HSL/HSLA parsing
- System colors support
- Color interpolation for animations

#### 4. Grid Support
- CSSGridTemplateAreasValue
- CSSGridLineNamesValue
- Grid-specific parsing utilities

### Integration Points

#### 1. JavaScript Bindings
- IDL files define JavaScript APIs
- C++ implementations expose CSS values to JavaScript
- CSSOM (CSS Object Model) support

#### 2. Style Resolution
- ComputedStyle: Final computed values
- StyleResolver: Applies CSS rules to elements
- Cascade: Handles specificity and inheritance

#### 3. Layout Integration
- Values passed to layout engine (in webf/ Dart code)
- Unit conversions and calculations
- Font metrics and viewport units resolved

### File Organization

```
bridge/core/css/
├── properties/          # Property definitions and handlers
│   ├── css_properties.json5
│   ├── longhands/      # Individual property implementations
│   └── shorthands/     # Shorthand property expansions
├── parser/             # Parsing infrastructure
│   ├── css_parser.cc
│   ├── css_property_parser.cc
│   └── css_parsing_utils.cc
├── css_value.h         # Base value class
├── css_primitive_value.h
├── css_value_list.h
└── [other value types]
```

### Recent Enhancements

The Blink CSS syntax parser integration (commit 04d5e37aa) adds:
- Enhanced custom property validation
- Type-safe parsing for modern CSS features
- Better error handling and recovery
- Support for CSS Typed OM preparation

### Usage Example

```cpp
// Parsing a CSS value
const CSSValue* value = CSSParser::ParseValue(
    CSSPropertyID::kWidth, 
    "100px", 
    context
);

// Type checking
if (value->IsNumericLiteralValue()) {
    const CSSNumericLiteralValue* numeric = 
        To<CSSNumericLiteralValue>(value);
    double pixels = numeric->ComputePixels(context);
}
```

This C++ implementation provides WebF with a production-grade CSS engine that matches web standards and enables high-performance styling and layout calculations.