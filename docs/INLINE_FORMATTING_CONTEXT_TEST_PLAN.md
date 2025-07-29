# Inline Formatting Context Testing Plan

**Date**: January 2025  
**Objective**: Achieve full W3C-compliant inline formatting context support in WebF (excluding float support)

## Overview

This document outlines a comprehensive testing plan for implementing full inline formatting context (IFC) support in WebF. Each phase includes detailed integration test specifications that will guide feature implementation and bug fixes. Float support is explicitly excluded from this plan.

## Testing Phases

### Phase 1: Bidirectional Text Support (High Priority)

Bidirectional text is critical for international support and is currently the most significant missing feature.

#### Test Specifications

##### 1.1 Basic RTL Text
```typescript
it('should render RTL text correctly', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 300px;">
      مرحبا بك في WebF
    </div>
  `;
  await snapshot();
});
```

##### 1.2 Mixed Direction Text
```typescript
it('should handle mixed LTR and RTL text', async () => {
  document.body.innerHTML = `
    <div style="width: 400px;">
      Hello مرحبا World عالم!
    </div>
  `;
  await snapshot();
});
```

##### 1.3 Unicode Bidi Property
```typescript
it('should respect unicode-bidi property', async () => {
  document.body.innerHTML = `
    <div style="width: 400px;">
      <span style="unicode-bidi: embed; direction: rtl;">RTL text</span>
      in LTR context
    </div>
  `;
  await snapshot();
});
```

##### 1.4 Nested Direction Changes
```typescript
it('should handle nested direction changes', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px;">
      RTL: مرحبا
      <span style="direction: ltr;">LTR: Hello</span>
      عالم
    </div>
  `;
  await snapshot();
});
```

##### 1.5 Bidi with Inline Elements
```typescript
it('should handle bidi text with inline formatting', async () => {
  document.body.innerHTML = `
    <div style="width: 400px;">
      English <strong>bold</strong> text مع <em>نص عربي</em> مائل
    </div>
  `;
  await snapshot();
});
```

##### 1.6 Bidi Isolation
```typescript
it('should support unicode-bidi: isolate', async () => {
  document.body.innerHTML = `
    <div style="width: 400px;">
      User <span style="unicode-bidi: isolate;">اسم:محمد</span> (ID: 123)
    </div>
  `;
  await snapshot();
});
```

#### RTL Box Model Tests

##### 1.7 RTL Margin Direction
```typescript
it('should apply margins correctly in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; border: 1px solid black;">
      <div style="margin-left: 20px; margin-right: 40px; background: lightblue;">
        RTL: margin-left should be on physical left (end)
      </div>
      <div style="margin-inline-start: 20px; margin-inline-end: 40px; background: lightgreen;">
        RTL: logical margins should adapt to direction
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.8 RTL Padding Direction
```typescript
it('should apply padding correctly in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px;">
      <div style="padding-left: 20px; padding-right: 40px; background: lightblue; border: 1px solid blue;">
        RTL: padding-left (20px) on physical left
      </div>
      <div style="padding-inline-start: 20px; padding-inline-end: 40px; background: lightgreen; border: 1px solid green;">
        RTL: logical padding adapts to direction
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.9 RTL Border Direction
```typescript
it('should apply borders correctly in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px;">
      <div style="border-left: 5px solid red; border-right: 10px solid blue; padding: 10px;">
        Physical borders: left=red(5px), right=blue(10px)
      </div>
      <div style="border-inline-start: 5px solid red; border-inline-end: 10px solid blue; padding: 10px; margin-top: 10px;">
        Logical borders: start=red, end=blue
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.10 RTL Text Alignment with Box Model
```typescript
it('should handle text-align with RTL box model', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; border: 1px solid black;">
      <div style="text-align: left; padding: 10px; background: #f0f0f0;">
        text-align: left (physical left)
      </div>
      <div style="text-align: right; padding: 10px; background: #e0e0e0;">
        text-align: right (physical right)
      </div>
      <div style="text-align: start; padding: 10px; background: #d0d0d0;">
        text-align: start (logical - should be right in RTL)
      </div>
      <div style="text-align: end; padding: 10px; background: #c0c0c0;">
        text-align: end (logical - should be left in RTL)
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.11 RTL Positioning
```typescript
it('should handle positioned elements in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; height: 200px; position: relative; border: 2px solid black;">
      <div style="position: absolute; left: 10px; top: 10px; background: red; width: 50px; height: 50px;">
        left: 10px
      </div>
      <div style="position: absolute; right: 10px; top: 10px; background: blue; width: 50px; height: 50px;">
        right: 10px
      </div>
      <div style="position: absolute; inset-inline-start: 10px; top: 70px; background: green; width: 50px; height: 50px;">
        inset-inline-start
      </div>
      <div style="position: absolute; inset-inline-end: 10px; top: 70px; background: orange; width: 50px; height: 50px;">
        inset-inline-end
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.12 RTL Float Behavior
```typescript
it('should handle float direction in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; border: 1px solid black;">
      <div style="float: left; width: 100px; height: 50px; background: red; margin: 5px;">
        float: left
      </div>
      <div style="float: right; width: 100px; height: 50px; background: blue; margin: 5px;">
        float: right
      </div>
      <p style="clear: both;">RTL text flows from right to left around floats</p>
      <div style="float: inline-start; width: 100px; height: 50px; background: green; margin: 5px;">
        float: inline-start
      </div>
      <div style="float: inline-end; width: 100px; height: 50px; background: orange; margin: 5px;">
        float: inline-end
      </div>
      <p style="clear: both;">Logical float values adapt to direction</p>
    </div>
  `;
  await snapshot();
});
```

##### 1.13 RTL Inline Box Model
```typescript
it('should handle inline element box model in RTL', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; font-size: 16px;">
      <p>
        RTL text with 
        <span style="margin-left: 10px; margin-right: 20px; padding: 5px; background: yellow;">
          physical margins
        </span>
        and
        <span style="margin-inline-start: 10px; margin-inline-end: 20px; padding: 5px; background: lightblue;">
          logical margins
        </span>
      </p>
    </div>
  `;
  await snapshot();
});
```

##### 1.14 RTL Nested Direction Changes with Box Model
```typescript
it('should handle nested direction changes with box model', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; padding: 20px; border: 2px solid black;">
      RTL container with padding
      <div style="direction: ltr; margin: 10px; padding: 10px; border: 1px solid blue;">
        LTR nested with margins
        <span style="direction: rtl; display: inline-block; margin: 5px; padding: 5px; background: yellow;">
          RTL inline-block
        </span>
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.15 RTL Overflow and Scrolling
```typescript
it('should handle overflow scrolling in RTL', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 300px; height: 100px; overflow: auto; border: 1px solid black;">
      <div style="width: 500px; padding: 10px;">
        محتوى عربي طويل جداً يتجاوز عرض الحاوية ويحتاج إلى التمرير الأفقي
        Long Arabic content that exceeds container width and needs horizontal scrolling
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.16 RTL Logical Properties Complex Example
```typescript
it('should handle all logical properties in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px;">
      <div style="
        margin-block-start: 10px;
        margin-block-end: 10px;
        margin-inline-start: 20px;
        margin-inline-end: 30px;
        padding-block-start: 5px;
        padding-block-end: 5px;
        padding-inline-start: 15px;
        padding-inline-end: 25px;
        border-block-start: 2px solid red;
        border-block-end: 2px solid blue;
        border-inline-start: 3px solid green;
        border-inline-end: 4px solid orange;
        background: #f0f0f0;
      ">
        Full logical box model in RTL
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.17 RTL Width and Height Calculations
```typescript
it('should calculate box dimensions correctly in RTL', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px;">
      <div style="width: 200px; padding-left: 20px; padding-right: 30px; border-left: 5px solid red; border-right: 10px solid blue; margin-left: 10px; margin-right: 15px; background: lightgray;">
        Total width = 200 + 20 + 30 + 5 + 10 = 265px
        With margins: 265 + 10 + 15 = 290px
      </div>
    </div>
  `;
  await snapshot();
});
```

##### 1.18 RTL Transform Origin
```typescript
it('should handle transform-origin in RTL context', async () => {
  document.body.innerHTML = `
    <div style="direction: rtl; width: 400px; height: 200px; position: relative;">
      <div style="position: absolute; left: 50px; top: 50px; width: 100px; height: 50px; background: red; transform: rotate(45deg); transform-origin: left center;">
        Physical left origin
      </div>
      <div style="position: absolute; right: 50px; top: 50px; width: 100px; height: 50px; background: blue; transform: rotate(45deg); transform-origin: right center;">
        Physical right origin
      </div>
    </div>
  `;
  await snapshot();
});
```

### Phase 2: Typography Features (Medium Priority)

Typography features are essential for proper text rendering and design flexibility.

#### Test Specifications

##### 2.1 Letter Spacing
```typescript
it('should apply letter-spacing to text', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="letter-spacing: 2px;">Normal letter spacing</p>
      <p style="letter-spacing: 5px;">Wide letter spacing</p>
      <p style="letter-spacing: -1px;">Tight letter spacing</p>
    </div>
  `;
  await snapshot();
});
```

##### 2.2 Letter Spacing with Units
```typescript
it('should support different letter-spacing units', async () => {
  document.body.innerHTML = `
    <div style="font-size: 16px; width: 300px;">
      <p style="letter-spacing: 0.1em;">0.1em spacing</p>
      <p style="letter-spacing: 2px;">2px spacing</p>
      <p style="letter-spacing: 0.5rem;">0.5rem spacing</p>
    </div>
  `;
  await snapshot();
});
```

##### 2.3 Word Spacing
```typescript
it('should apply word-spacing to text', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="word-spacing: normal;">Normal word spacing here</p>
      <p style="word-spacing: 10px;">Wide word spacing here</p>
      <p style="word-spacing: -2px;">Tight word spacing here</p>
    </div>
  `;
  await snapshot();
});
```

##### 2.4 Combined Letter and Word Spacing
```typescript
it('should combine letter-spacing and word-spacing', async () => {
  document.body.innerHTML = `
    <div style="width: 400px;">
      <p style="letter-spacing: 1px; word-spacing: 5px;">
        This text has both letter and word spacing applied
      </p>
    </div>
  `;
  await snapshot();
});
```

##### 2.5 Spacing with Inline Elements
```typescript
it('should apply spacing across inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 400px; letter-spacing: 2px;">
      Text with <span style="color: red;">inline span</span> element
    </div>
  `;
  await snapshot();
});
```

### Phase 3: Text Overflow (Medium Priority)

Text overflow handling is crucial for responsive design and content management.

#### Test Specifications

##### 3.1 Basic Text Overflow Ellipsis
```typescript
it('should show ellipsis for overflowing text', async () => {
  document.body.innerHTML = `
    <div style="width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
      This is a very long text that will overflow the container
    </div>
  `;
  await snapshot();
});
```

##### 3.2 Multi-line Ellipsis
```typescript
it('should support multi-line text overflow', async () => {
  document.body.innerHTML = `
    <div style="width: 200px; height: 3em; overflow: hidden; text-overflow: ellipsis; 
                display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;">
      This is a very long text that spans multiple lines and should show ellipsis at the end of the second line when it overflows
    </div>
  `;
  await snapshot();
});
```

##### 3.3 Ellipsis with Inline Elements
```typescript
it('should handle ellipsis with inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
      Text with <span style="font-weight: bold;">bold</span> and <em>italic</em> parts that overflow
    </div>
  `;
  await snapshot();
});
```

##### 3.4 Custom Overflow String
```typescript
it('should support custom overflow indicator', async () => {
  document.body.innerHTML = `
    <div style="width: 200px; white-space: nowrap; overflow: hidden; text-overflow: '...';">
      Long text that needs custom overflow indicator
    </div>
  `;
  await snapshot();
});
```

### Phase 4: Advanced Line Breaking and CJK Support (High Priority)

Proper line breaking is essential for text layout in different languages and contexts, especially for CJK text.

#### Test Specifications

##### 4.1 CJK Text Basic Layout
```typescript
it('should layout CJK text correctly in inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <span>中文文本</span>と<span>日本語テキスト</span>와<span>한국어 텍스트</span>
    </div>
  `;
  await snapshot();
});
```

##### 4.2 CJK Line Breaking Rules
```typescript
it('should follow CJK line breaking rules', async () => {
  document.body.innerHTML = `
    <div style="width: 200px;">
      中文不应该在句号。或逗号，前面断行。
      日本語は句読点（。、）の前で改行しない。
      한국어는 마침표. 또는 쉼표, 앞에서 줄바꿈하지 않습니다.
    </div>
  `;
  await snapshot();
});
```

##### 4.3 CJK with Inline Formatting
```typescript
it('should handle CJK text with inline formatting elements', async () => {
  document.body.innerHTML = `
    <div style="width: 250px;">
      这是<strong>粗体中文</strong>和<em>斜体文本</em>的混合。
      <span style="color: red;">红色日本語</span>と<span style="background: yellow;">黄色背景</span>。
    </div>
  `;
  await snapshot();
});
```

##### 4.4 Mixed CJK and Latin Script
```typescript
it('should handle mixed CJK and Latin text in inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      使用<span style="font-family: monospace;">WebF Framework</span>来构建应用。
      <span>React</span>と<span>Vue.js</span>を使った開発。
      <strong>Flutter</strong>와 <em>Dart</em>를 사용한 개발.
    </div>
  `;
  await snapshot();
});
```

##### 4.5 CJK Punctuation Compression
```typescript
it('should handle CJK punctuation compression', async () => {
  document.body.innerHTML = `
    <div style="width: 200px;">
      「こんにちは」、「さようなら」。
      "你好"、"再见"。
      『안녕하세요』、『안녕히 가세요』。
    </div>
  `;
  await snapshot();
});
```

##### 4.6 Word Break with CJK
```typescript
it('should handle word-break property with CJK text', async () => {
  document.body.innerHTML = `
    <div style="width: 100px;">
      <p style="word-break: normal;">正常的中文断行行为</p>
      <p style="word-break: break-all;">可以在任意位置断行的中文文本</p>
      <p style="word-break: keep-all;">不允许在单词内断行</p>
    </div>
  `;
  await snapshot();
});
```

##### 4.7 CJK Ruby Annotations
```typescript
it('should support ruby annotations for CJK text', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <ruby>漢字<rt>かんじ</rt></ruby>の<ruby>読<rt>よ</rt></ruby>み
      <ruby>中文<rt>zhōng wén</rt></ruby>
      <ruby>한글<rt>han-geul</rt></ruby>
    </div>
  `;
  await snapshot();
});
```

##### 4.8 Vertical Text Layout
```typescript
it('should support vertical text layout for CJK', async () => {
  document.body.innerHTML = `
    <div style="writing-mode: vertical-rl; height: 200px;">
      縦書きの日本語テキスト
      <span style="text-decoration: underline;">下線付き</span>
    </div>
  `;
  await snapshot();
});
```

##### 4.9 CJK Text Spacing
```typescript
it('should handle CJK text spacing correctly', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="letter-spacing: 0.1em;">字间距调整的中文</p>
      <p style="word-spacing: 10px;">Word spacing doesn't affect CJK 中文</p>
    </div>
  `;
  await snapshot();
});
```

##### 4.10 Overflow Wrap with CJK
```typescript
it('should handle overflow-wrap with mixed content', async () => {
  document.body.innerHTML = `
    <div style="width: 150px; overflow-wrap: break-word;">
      Normal text with verylongEnglishwordandlongChinese中文内容混合
    </div>
  `;
  await snapshot();
});
```

##### 4.11 Line Height with CJK
```typescript
it('should handle line-height properly with CJK text', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="line-height: 1.5;">标准行高的中文文本内容</p>
      <p style="line-height: 2;">
        混合English and 中文 with 
        <span style="font-size: 20px;">大きな日本語</span>
      </p>
    </div>
  `;
  await snapshot();
});
```

##### 4.12 Text Alignment with CJK
```typescript
it('should align CJK text properly', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-align: left;">左对齐的中文文本</p>
      <p style="text-align: center;">センタリングされた日本語</p>
      <p style="text-align: right;">오른쪽 정렬된 한국어</p>
      <p style="text-align: justify;">
        这是一段两端对齐的中文文本，应该在每行的两端都对齐。
      </p>
    </div>
  `;
  await snapshot();
});
```

##### 4.13 English Word Breaking
```typescript
it('should break English words properly', async () => {
  document.body.innerHTML = `
    <div style="width: 100px;">
      <p style="word-break: normal;">Verylongwordthatexceedswidth</p>
      <p style="word-break: break-all;">Verylongwordthatexceedswidth</p>
      <p style="overflow-wrap: break-word;">Verylongwordthatexceedswidth</p>
    </div>
  `;
  await snapshot();
});
```

##### 4.14 Hyphenation
```typescript
it('should hyphenate text when hyphens: auto is set', async () => {
  document.body.innerHTML = `
    <div style="width: 200px; hyphens: auto;" lang="en">
      This paragraph contains some extraordinarily long words that should be hyphenated appropriately
    </div>
  `;
  await snapshot();
});
```

##### 4.15 Line Break Opportunities
```typescript
it('should handle explicit line break opportunities', async () => {
  document.body.innerHTML = `
    <div style="width: 100px;">
      Break<wbr>able<wbr>Word
      中文<wbr>可断<wbr>词语
    </div>
  `;
  await snapshot();
});
```

### Phase 5: Text Alignment and Indentation (Low Priority)

Advanced text formatting features for professional typography.

#### Test Specifications

##### 5.1 Text Indent
```typescript
it('should apply text-indent to first line', async () => {
  document.body.innerHTML = `
    <div style="width: 300px; text-indent: 2em;">
      This paragraph has its first line indented by 2em. The subsequent lines
      should start at the normal position without indentation.
    </div>
  `;
  await snapshot();
});
```

##### 5.2 Negative Text Indent
```typescript
it('should support negative text-indent with padding', async () => {
  document.body.innerHTML = `
    <div style="width: 300px; text-indent: -20px; padding-left: 20px;">
      • This creates a hanging indent effect where the bullet
        extends into the margin while text is aligned
    </div>
  `;
  await snapshot();
});
```

##### 5.3 Text Justify
```typescript
it('should justify text with text-align: justify', async () => {
  document.body.innerHTML = `
    <div style="width: 300px; text-align: justify;">
      This text should be justified, meaning that spaces between words are
      adjusted so that both edges of each line align with the container edges.
    </div>
  `;
  await snapshot();
});
```

##### 5.4 Text Justify with Last Line
```typescript
it('should handle text-align-last property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px; text-align: justify; text-align-last: center;">
      This justified paragraph should have its last line centered instead
      of left-aligned, which is the default behavior.
    </div>
  `;
  await snapshot();
});
```

### Phase 6: Additional Text Features (Medium Priority)

Additional text features for complete web compatibility.

#### Test Specifications

##### 6.1 Text Transform
```typescript
it('should apply text-transform property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-transform: uppercase;">this should be uppercase</p>
      <p style="text-transform: lowercase;">THIS SHOULD BE LOWERCASE</p>
      <p style="text-transform: capitalize;">this should have each word capitalized</p>
      <span style="text-transform: uppercase;">inline <em>with nested</em> elements</span>
    </div>
  `;
  await snapshot();
});
```

##### 6.2 Text Transform with CJK
```typescript
it('should handle text-transform with mixed scripts', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-transform: uppercase;">Hello 世界 world</p>
      <p style="text-transform: capitalize;">hello 中文 text こんにちは</p>
    </div>
  `;
  await snapshot();
});
```

##### 6.3 Tab Size
```typescript
it('should respect tab-size property', async () => {
  document.body.innerHTML = `
    <pre style="tab-size: 4;">
	One tab indent
		Two tab indent
			Three tab indent
    </pre>
    <pre style="tab-size: 8;">
	Same with larger tabs
		Two tab indent
    </pre>
  `;
  await snapshot();
});
```

##### 6.4 White Space Preserve with Tabs
```typescript
it('should preserve tabs with white-space: pre', async () => {
  document.body.innerHTML = `
    <div style="white-space: pre; width: 400px;">
Column1	Column2	Column3
Data1	Data2	Data3
    </div>
  `;
  await snapshot();
});
```

##### 6.5 Text Shadow
```typescript
it('should apply text-shadow to inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 300px; padding: 20px;">
      <p style="text-shadow: 2px 2px 4px rgba(0,0,0,0.5);">Simple shadow</p>
      <p style="text-shadow: 1px 1px 2px red, -1px -1px 2px blue;">Multiple shadows</p>
      <span style="text-shadow: 0 0 5px #00ff00;">Glowing <em>inline</em> text</span>
    </div>
  `;
  await snapshot();
});
```

##### 6.6 Text Decoration Styles
```typescript
it('should support text-decoration-style property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-decoration: underline solid;">Solid underline</p>
      <p style="text-decoration: underline double;">Double underline</p>
      <p style="text-decoration: underline dotted;">Dotted underline</p>
      <p style="text-decoration: underline dashed;">Dashed underline</p>
      <p style="text-decoration: underline wavy;">Wavy underline</p>
    </div>
  `;
  await snapshot();
});
```

##### 6.7 Text Decoration Color
```typescript
it('should support text-decoration-color property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-decoration: underline; text-decoration-color: red;">Red underline</p>
      <p style="text-decoration: line-through; text-decoration-color: blue;">Blue strikethrough</p>
      <span style="text-decoration: underline; text-decoration-color: green;">
        Green underline with <em style="text-decoration-color: orange;">orange nested</em>
      </span>
    </div>
  `;
  await snapshot();
});
```

##### 6.8 Text Decoration Thickness
```typescript
it('should support text-decoration-thickness property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-decoration: underline; text-decoration-thickness: 1px;">Thin underline</p>
      <p style="text-decoration: underline; text-decoration-thickness: 3px;">Thick underline</p>
      <p style="text-decoration: underline; text-decoration-thickness: 0.1em;">Em-based thickness</p>
    </div>
  `;
  await snapshot();
});
```

##### 6.9 Text Underline Position
```typescript
it('should support text-underline-position property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-decoration: underline; text-underline-position: under;">Under position</p>
      <p style="text-decoration: underline; text-underline-position: left;">Left position (vertical)</p>
      <p style="text-decoration: underline; text-underline-position: right;">Right position (vertical)</p>
    </div>
  `;
  await snapshot();
});
```

##### 6.10 Line Break Property
```typescript
it('should support line-break property for CJK', async () => {
  document.body.innerHTML = `
    <div style="width: 200px;">
      <p style="line-break: auto;">自動的な改行規則を使用する日本語テキスト。</p>
      <p style="line-break: loose;">緩い改行規則を使用する日本語テキスト。</p>
      <p style="line-break: normal;">通常の改行規則を使用する日本語テキスト。</p>
      <p style="line-break: strict;">厳密な改行規則を使用する日本語テキスト。</p>
    </div>
  `;
  await snapshot();
});
```

##### 6.11 Word Wrap (Legacy)
```typescript
it('should support word-wrap property (legacy overflow-wrap)', async () => {
  document.body.innerHTML = `
    <div style="width: 150px;">
      <p style="word-wrap: normal;">Verylongwordthatwillnotbreakbydefault</p>
      <p style="word-wrap: break-word;">Verylongwordthatwillbreakwhennecessary</p>
    </div>
  `;
  await snapshot();
});
```

##### 6.12 Quotes Property
```typescript
it('should support CSS quotes property', async () => {
  document.body.innerHTML = `
    <style>
      .custom-quotes { quotes: "«" "»" "‹" "›"; }
      .cjk-quotes { quotes: "「" "」" "『" "』"; }
    </style>
    <div style="width: 300px;">
      <p class="custom-quotes">
        <q>Outer quote with <q>nested quote</q> inside</q>
      </p>
      <p class="cjk-quotes" lang="ja">
        <q>外側の引用と<q>内側の引用</q>です</q>
      </p>
    </div>
  `;
  await snapshot();
});
```

##### 6.13 Text Size Adjust
```typescript
it('should support text-size-adjust for mobile', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="-webkit-text-size-adjust: 100%;">No size adjustment</p>
      <p style="-webkit-text-size-adjust: none;">Prevent size adjustment</p>
      <p style="-webkit-text-size-adjust: 150%;">150% size adjustment</p>
    </div>
  `;
  await snapshot();
});
```

### Phase 7: Performance and Edge Cases (Medium Priority)

Ensure robust performance and handle edge cases properly.

#### Test Specifications

##### 7.1 Large Text Performance
```typescript
it('should handle large amounts of text efficiently', async () => {
  const largeText = 'Lorem ipsum '.repeat(1000);
  document.body.innerHTML = `
    <div style="width: 500px; height: 300px; overflow: auto;">
      ${largeText}
    </div>
  `;
  
  const startTime = performance.now();
  await snapshot();
  const renderTime = performance.now() - startTime;
  
  expect(renderTime).toBeLessThan(1000); // Should render in less than 1 second
});
```

##### 7.2 Dynamic Content Updates
```typescript
it('should efficiently update inline content', async () => {
  document.body.innerHTML = `
    <div id="container" style="width: 300px;">
      Initial text content
    </div>
  `;
  
  const container = document.getElementById('container');
  
  // Update text multiple times
  for (let i = 0; i < 10; i++) {
    container.textContent = `Updated text content ${i}`;
    await snapshot();
  }
});
```

##### 7.3 Mixed Content Types
```typescript
it('should handle mixed inline content types', async () => {
  document.body.innerHTML = `
    <div style="width: 400px;">
      Text with 
      <img src="data:image/png;base64,..." style="width: 20px; height: 20px;">
      inline image and
      <span style="display: inline-block; width: 50px; height: 30px; background: blue;"></span>
      inline-block element
    </div>
  `;
  await snapshot();
});
```

##### 7.4 Zero Width and Empty Elements
```typescript
it('should handle zero-width and empty inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      Text<span></span>with<span style="width: 0;"></span>empty<span> </span>spans
    </div>
  `;
  await snapshot();
});
```

##### 7.5 Deeply Nested Inline Elements
```typescript
it('should handle deeply nested inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <span>Level 1
        <span>Level 2
          <span>Level 3
            <span>Level 4
              <span>Level 5 deeply nested</span>
            </span>
          </span>
        </span>
      </span>
    </div>
  `;
  await snapshot();
});
```

## Implementation Guidelines

### For Each Test:
1. **Create the integration test** in `integration_tests/specs/css/css-inline/`
2. **Run the test** to verify it fails (expected behavior)
3. **Implement the feature** in the appropriate WebF source files
4. **Update unit tests** in `webf/test/src/rendering/`
5. **Verify the integration test passes**
6. **Check for regressions** by running the full test suite

### Key Implementation Files:
- `webf/lib/src/rendering/inline_formatting_context.dart` - Main IFC implementation
- `webf/lib/src/rendering/line_breaker.dart` - Line breaking logic
- `webf/lib/src/rendering/inline_item.dart` - Inline item representation
- `webf/lib/src/css/render_style.dart` - CSS property implementations

### Success Criteria:
- All integration tests pass
- No regression in existing tests
- Performance benchmarks meet acceptable thresholds
- Code follows WebF coding standards
- Implementation matches W3C specifications

### Phase 8: Advanced Inline Features (Low Priority)

Additional advanced features for complete browser parity.

#### Test Specifications

##### 8.1 Initial Letter (Drop Caps)
```typescript
it('should support initial-letter property', async () => {
  document.body.innerHTML = `
    <style>
      p::first-letter {
        initial-letter: 3;
        font-weight: bold;
        color: red;
      }
    </style>
    <div style="width: 300px;">
      <p>This paragraph has a drop cap that spans three lines of text.</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.2 Text Combine Upright
```typescript
it('should support text-combine-upright for vertical text', async () => {
  document.body.innerHTML = `
    <div style="writing-mode: vertical-rl; height: 200px;">
      <p>平成<span style="text-combine-upright: all;">31</span>年</p>
      <p>令和<span style="text-combine-upright: digits 2;">2024</span>年</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.3 Text Orientation
```typescript
it('should support text-orientation in vertical writing', async () => {
  document.body.innerHTML = `
    <div style="writing-mode: vertical-rl; height: 200px;">
      <p style="text-orientation: mixed;">Mixed orientation ABC 123</p>
      <p style="text-orientation: upright;">Upright orientation ABC 123</p>
      <p style="text-orientation: sideways;">Sideways orientation ABC 123</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.4 Inline Box Decoration Break
```typescript
it('should support box-decoration-break for inline elements', async () => {
  document.body.innerHTML = `
    <div style="width: 200px;">
      <span style="background: yellow; padding: 5px; border: 2px solid red; 
                   box-decoration-break: clone;">
        This is a long inline element that wraps to multiple lines
      </span>
    </div>
  `;
  await snapshot();
});
```

##### 8.5 Soft Hyphens
```typescript
it('should handle soft hyphens correctly', async () => {
  document.body.innerHTML = `
    <div style="width: 150px;">
      <p>Super&shy;cali&shy;fragi&shy;listic&shy;expi&shy;ali&shy;docious</p>
      <p>Un&shy;break&shy;able&shy;word&shy;with&shy;soft&shy;hyphens</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.6 Non-Breaking Spaces and Characters
```typescript
it('should handle non-breaking spaces and characters', async () => {
  document.body.innerHTML = `
    <div style="width: 200px;">
      <p>Price:&nbsp;$100.00</p>
      <p>100&nbsp;km/h</p>
      <p>Mr.&nbsp;Smith</p>
      <p>10&#8209;20</p> <!-- non-breaking hyphen -->
    </div>
  `;
  await snapshot();
});
```

##### 8.7 Zero Width Spaces
```typescript
it('should handle zero-width spaces for line breaking', async () => {
  document.body.innerHTML = `
    <div style="width: 150px;">
      <p>Very&#8203;Long&#8203;Compound&#8203;Word&#8203;With&#8203;Break&#8203;Opportunities</p>
      <p>http://example.&#8203;com/very/&#8203;long/&#8203;url/&#8203;path</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.8 Inline Layout Containers (Flex)
```typescript
it('should support inline-flex display with baseline alignment', async () => {
  document.body.innerHTML = `
    <div style="width: 400px; font-size: 16px;">
      Text before 
      <span style="display: inline-flex; align-items: baseline; gap: 5px; background: lightblue;">
        <span style="font-size: 24px;">Big</span>
        <span style="font-size: 12px;">Small</span>
      </span>
      text after
    </div>
  `;
  await snapshot();
});
```

##### 8.9 Inline Flex with Different Alignments
```typescript
it('should handle inline-flex with various align-items values', async () => {
  document.body.innerHTML = `
    <div style="width: 500px; line-height: 1.5;">
      <p>Baseline: <span style="display: inline-flex; align-items: baseline; height: 50px; background: #eee;">
        <span>A</span><span style="font-size: 24px;">B</span><span>C</span>
      </span></p>
      <p>Center: <span style="display: inline-flex; align-items: center; height: 50px; background: #eee;">
        <span>A</span><span style="font-size: 24px;">B</span><span>C</span>
      </span></p>
      <p>Start: <span style="display: inline-flex; align-items: flex-start; height: 50px; background: #eee;">
        <span>A</span><span style="font-size: 24px;">B</span><span>C</span>
      </span></p>
    </div>
  `;
  await snapshot();
});
```

##### 8.10 Inline Block with Internal Layout
```typescript
it('should handle inline-block containing different layout modes', async () => {
  document.body.innerHTML = `
    <div style="width: 500px;">
      Text with 
      <span style="display: inline-block; border: 1px solid red;">
        <div style="display: flex; flex-direction: column;">
          <span>Flex child 1</span>
          <span>Flex child 2</span>
        </div>
      </span>
      and 
      <span style="display: inline-block; border: 1px solid blue;">
        <div style="display: block;">
          <span>Block content 1</span><br>
          <span>Block content 2</span>
        </div>
      </span>
      mixed layouts.
    </div>
  `;
  await snapshot();
});
```

##### 8.11 First Line and First Letter with Layout Containers
```typescript
it('should handle ::first-line and ::first-letter with inline layouts', async () => {
  document.body.innerHTML = `
    <style>
      p::first-line { font-weight: bold; color: blue; }
      p::first-letter { font-size: 2em; float: left; color: red; }
      .inline-flex::first-letter { background: yellow; }
    </style>
    <p style="width: 300px;">
      This paragraph has styled first line and first letter.
      <span style="display: inline-flex;" class="inline-flex">
        Flex content should work with pseudo-elements
      </span>
    </p>
  `;
  await snapshot();
});
```

##### 8.12 Text in Flexbox Containers
```typescript
it('should handle anonymous flex items for text nodes', async () => {
  document.body.innerHTML = `
    <div style="display: flex; width: 400px; gap: 10px;">
      Direct text becomes anonymous flex item
      <span>Explicit flex item</span>
      More text in anonymous item
    </div>
  `;
  await snapshot();
});
```

##### 8.13 Inline Containers with Vertical Writing
```typescript
it('should handle inline layout containers in vertical writing mode', async () => {
  document.body.innerHTML = `
    <div style="writing-mode: vertical-rl; height: 300px;">
      縦書きテキストに
      <span style="display: inline-flex; border: 1px solid red;">
        <span>埋</span><span>込</span>
      </span>
      フレックス
    </div>
  `;
  await snapshot();
});
```

##### 8.14 Text Wrapping with Inline Containers
```typescript
it('should wrap text properly around inline containers', async () => {
  document.body.innerHTML = `
    <div style="width: 200px;">
      This is a long text that contains an
      <span style="display: inline-flex; border: 2px solid blue; padding: 5px;">
        <span>inline</span><span>flex</span><span>box</span>
      </span>
      that should wrap properly when the line is too long.
    </div>
  `;
  await snapshot();
});
```

##### 8.15 Baseline of Empty Inline Containers
```typescript
it('should handle baseline of empty inline layout containers', async () => {
  document.body.innerHTML = `
    <div style="font-size: 20px;">
      Text with empty
      <span style="display: inline-flex; width: 50px; height: 30px; background: yellow;"></span>
      inline-flex and
      <span style="display: inline-block; width: 50px; height: 30px; background: lightblue;"></span>
      inline-block
    </div>
  `;
  await snapshot();
});
```

##### 8.16 Text Rendering Property
```typescript
it('should support text-rendering property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="text-rendering: auto;">Auto rendering</p>
      <p style="text-rendering: optimizeSpeed;">Optimize for speed</p>
      <p style="text-rendering: optimizeLegibility;">Optimize for legibility</p>
      <p style="text-rendering: geometricPrecision;">Geometric precision</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.17 Font Stretch
```typescript
it('should support font-stretch property', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p style="font-stretch: ultra-condensed;">Ultra condensed text</p>
      <p style="font-stretch: condensed;">Condensed text</p>
      <p style="font-stretch: normal;">Normal text</p>
      <p style="font-stretch: expanded;">Expanded text</p>
      <p style="font-stretch: ultra-expanded;">Ultra expanded text</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.18 Unicode Range
```typescript
it('should handle various Unicode ranges correctly', async () => {
  document.body.innerHTML = `
    <div style="width: 300px;">
      <p>Emoji: 😀 🎉 ❤️ 🌍</p>
      <p>Math: ∑ ∏ √ ∞ ≠ ≤ ≥</p>
      <p>Arrows: ← → ↑ ↓ ↔ ↕</p>
      <p>Box drawing: ┌─┐│└┘</p>
    </div>
  `;
  await snapshot();
});
```

##### 8.19 Content Editable with Inline Formatting
```typescript
it('should handle contenteditable with inline formatting', async () => {
  document.body.innerHTML = `
    <div contenteditable="true" style="width: 300px; border: 1px solid black; padding: 10px;">
      Edit this <strong>bold</strong> and <em>italic</em> text
    </div>
  `;
  
  // Focus and modify content
  const editable = document.querySelector('[contenteditable]');
  editable.focus();
  
  await snapshot();
});
```

## CSS Properties Covered in This Test Plan

This comprehensive test plan includes the following CSS properties for inline text support:

### Already Implemented (from analysis):
- Basic text layout, alignment, and white-space handling
- line-height with various units
- vertical-align property
- Basic text-decoration (underline, line-through)

### High Priority Features to Implement:
1. **Bidirectional text**: direction, unicode-bidi properties
2. **RTL Box Model Support**: 
   - Physical properties behavior in RTL (margin-left/right, padding-left/right, border-left/right)
   - Logical properties (margin-inline-start/end, padding-inline-start/end, border-inline-start/end)
   - Positioning in RTL (left/right vs inset-inline-start/end)
   - Float behavior in RTL contexts
   - Text alignment (start/end vs left/right)
   - Overflow and scrolling direction
3. **CJK text support**: Proper line breaking and layout for Chinese, Japanese, Korean

### Medium Priority Features to Implement:
4. **letter-spacing**: Character spacing control
5. **word-spacing**: Word spacing control
6. **text-overflow**: ellipsis support
7. **word-break**: break-all, keep-all
8. **overflow-wrap**: break-word behavior
9. **text-shadow**: Shadow effects on text (included in Phase 6.5)
10. **text-decoration-style**: solid, double, dotted, dashed, wavy (Phase 6.6)
11. **text-decoration-color**: Color of text decorations (Phase 6.7)
12. **text-decoration-thickness**: Thickness of decorations (Phase 6.8)
13. **text-underline-position**: Position of underlines (Phase 6.9)

### Additional Features:
14. **text-transform**: uppercase, lowercase, capitalize
15. **tab-size**: Control tab character width
16. **line-break**: CJK-specific line breaking rules
17. **quotes**: Custom quotation marks
18. **text-size-adjust**: Mobile text size adjustment
19. **initial-letter**: Drop caps
20. **text-combine-upright**: Vertical text combinations
21. **text-orientation**: Text orientation in vertical writing
22. **box-decoration-break**: How decorations break across lines
23. **text-rendering**: Rendering optimization hints
24. **font-stretch**: Font width variations
25. **text-indent**: First line indentation
26. **text-align-last**: Last line alignment in justified text
27. **hyphens**: Hyphenation control
28. **ruby**: Ruby annotations for CJK

### RTL-Specific CSS Properties:
29. **margin-inline-start/end**: Logical margin properties
30. **padding-inline-start/end**: Logical padding properties
31. **border-inline-start/end**: Logical border properties
32. **margin-block-start/end**: Block-axis margin properties
33. **padding-block-start/end**: Block-axis padding properties
34. **border-block-start/end**: Block-axis border properties
35. **inset-inline-start/end**: Logical positioning properties
36. **inset-block-start/end**: Block-axis positioning properties
37. **text-align: start/end**: Logical text alignment
38. **float: inline-start/inline-end**: Logical float values
39. **clear: inline-start/inline-end**: Logical clear values
40. **resize: inline/block**: Logical resize directions

## Conclusion

This testing plan provides comprehensive coverage for implementing full inline formatting context support in WebF. By following this test-driven approach, we ensure that each feature is properly implemented, tested, and maintains compatibility with web standards.