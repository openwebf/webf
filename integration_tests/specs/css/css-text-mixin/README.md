# CSS Text Mixin Integration Tests

This directory contains comprehensive integration tests for the CSSTextMixin improvements implemented in WebF. These tests verify the correct functionality of the following enhancements:

## Test Files Overview

### 1. `text_baseline_test.ts`
Tests locale-based text baseline selection improvements.

**Features tested:**
- Alphabetic baseline for Latin scripts (English, French, German, etc.)
- Ideographic baseline for CJK scripts (Chinese, Japanese, Korean)
- Locale inheritance from ancestor elements
- Fallback to document root `lang` attribute
- Complex locale format parsing (e.g., `zh-Hans-CN`, `ja-JP`)
- Mixed content with different baselines

**Key improvements:**
- Fixed `getTextBaseLine()` to use language/script for baseline selection instead of `vertical-align`
- Ensures consistent text rendering within the same line regardless of vertical-align values
- Better internationalization support for CJK languages

### 2. `locale_support_test.ts`
Tests the locale extraction and hierarchy system.

**Features tested:**
- Locale extraction from element `lang` attributes
- Locale inheritance from parent elements
- Override behavior (closer lang attributes take precedence)
- Fallback to document root lang attribute
- Graceful handling of empty/invalid lang attributes
- Complex locale hierarchies with multiple nested languages
- Locale-specific text rendering differences
- Dynamic locale updates

**Key improvements:**
- Implemented `getLocale()` method that parses DOM lang attributes
- Proper fallback hierarchy: element → ancestors → document root → null
- Support for complex locale formats like `zh-Hans-CN` and `sr-Cyrl-RS`

### 3. `color_relative_properties_test.ts`
Tests the optimized color-relative property updates.

**Features tested:**
- `currentColor` in border properties
- Multiple `currentColor` properties updating simultaneously
- Mixed color values and `currentColor` efficiency
- Performance optimization without full CSS re-parsing
- `currentColor` in background-color properties
- Nested `currentColor` inheritance
- Complex color hierarchies performance

**Key improvements:**
- Implemented `updateColorRelativeProperty()` for efficient color updates
- Uses CSS color abstraction to avoid re-parsing property strings
- Direct property updates for common `currentColor` cases
- Fallback to full parsing only when necessary

### 4. `text_effects_test.ts`
Tests background and foreground Paint support for text effects.

**Features tested:**
- `background-clip: text` effects
- Background Paint for text rendering
- Foreground Paint for text rendering
- Combined background-clip with various text properties
- Dynamic background changes for text effects
- Multiple gradient text elements efficiency
- Text effects with different writing modes
- Text effects during animations
- Fallback when background-clip is not supported

**Key improvements:**
- Implemented `getBackground()` method for background Paint support
- Implemented `getForeground()` method for foreground Paint support
- Proper handling of `background-clip: text` for gradient text effects
- Support for both solid colors and gradients as text fills

### 5. `text_comprehensive_test.ts`
Integration tests combining all features.

**Features tested:**
- Locale-based baselines with text effects
- `currentColor` with locale-specific text and gradients
- Performance with complex multilingual layouts
- Complex text inheritance hierarchies
- Dynamic layout changes maintaining text quality

**Integration scenarios:**
- Multilingual gradient text with appropriate baselines
- `currentColor` optimization in multilingual contexts
- Performance testing with multiple languages and effects
- Complex inheritance with nested locale changes
- Dynamic updates across all text features

## Test Group Configuration

These tests are included in the "TextAndColorAndFilterEffect" group in `spec_group.json5`:

```json5
{
  "name": "TextAndColorAndFilterEffect",
  "specs": [
    "specs/css/css-text/**/*.{js,jsx,ts,tsx,html}",
    "specs/css/css-text-decor/**/*.{js,jsx,ts,tsx,html}",
    "specs/css/css-color/**/*.{js,jsx,ts,tsx,html}",
    "specs/css/css-text-color/**/*.{js,jsx,ts,tsx,html}",
    "specs/css/filter-effects/**/*.{js,jsx,ts,tsx,html}"
  ]
}
```

## Running the Tests

### Run all CSS text tests:
```bash
cd integration_tests
npm run integration -- --spec-group=TextAndColorAndFilterEffect
```

### Run specific test files:
```bash
# Single test file
npm run integration -- specs/css/css-text-mixin/text_baseline_test.ts

# Multiple test files
npm run integration -- specs/css/css-text-mixin/text_baseline_test.ts specs/css/css-text-mixin/locale_support_test.ts

# Individual test categories:
npm run integration -- specs/css/css-text-mixin/text_baseline_test.ts         # Baseline tests
npm run integration -- specs/css/css-text-mixin/locale_support_test.ts         # Locale support tests  
npm run integration -- specs/css/css-text-mixin/color_relative_properties_test.ts  # Color optimization tests
npm run integration -- specs/css/css-text-mixin/text_effects_test.ts           # Text effects tests
npm run integration -- specs/css/css-text-mixin/text_comprehensive_test.ts     # Comprehensive integration tests
```

### Get help:
```bash
npm run integration -- --help
```

## Expected Behavior

### Before the improvements:
- `vertical-align: top` incorrectly used ideographic baseline for all text
- No locale-based baseline selection
- Full CSS re-parsing for every `currentColor` update
- Limited support for text effects with background/foreground Paint

### After the improvements:
- Proper baseline selection based on text language/script
- Efficient `currentColor` updates without re-parsing
- Full support for gradient text effects via `background-clip: text`
- Comprehensive locale support with proper inheritance hierarchy

## Performance Expectations

These tests include performance assertions to ensure the optimizations are working:

- Color updates should complete in < 50ms for moderate complexity
- Complex multilingual layouts should update in < 100ms
- No visual regressions during rapid property changes
- Consistent rendering quality across different locales and effects

## Browser Compatibility Notes

While these tests run in WebF's rendering engine, they test CSS features that should be compatible with:

- `lang` attribute support (universal)
- `currentColor` (CSS2.1+, widely supported)
- `background-clip: text` (modern browsers with vendor prefixes)
- Complex locale formats (BCP 47 language tags)

The tests include appropriate fallbacks and graceful degradation for features that may not be supported in all environments.