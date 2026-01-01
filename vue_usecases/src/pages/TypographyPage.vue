<script setup lang="ts"></script>

<template>
  <div id="main">
    <webf-list-view class="flex-1 p-0 m-0">
      <div class="p-5 bg-gray-100 dark:bg-gray-900 min-h-screen max-w-7xl mx-auto">
        <div class="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">Typography Layout Showcase</div>
        <div class="flex flex-col">
          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Basic Text Styles</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Different font weights, sizes, and styles</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <h1 class="text-3xl font-bold text-gray-800 dark:text-white mb-4 leading-tight">Heading 1 - Large Title</h1>
              <h2 class="text-2xl font-semibold text-gray-800 dark:text-white mb-3 leading-snug">Heading 2 - Section Title</h2>
              <h3 class="text-xl font-medium text-gray-800 dark:text-white mb-2.5 leading-normal">Heading 3 - Subsection</h3>
              <p class="text-base font-normal text-gray-800 dark:text-white leading-relaxed mb-3">
                Body text with normal weight and size. This is the standard paragraph text used for most content.
              </p>
              <p class="text-sm font-normal text-gray-600 dark:text-gray-300 leading-normal mb-3">Small text for captions, footnotes, or supplementary information.</p>
              <p class="text-base font-bold text-gray-800 dark:text-white leading-relaxed mb-3">Bold text for emphasis and important information.</p>
              <p class="text-base font-normal italic text-gray-800 dark:text-white leading-relaxed mb-3">Italic text for quotes, titles, or stylistic emphasis.</p>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Multilingual Text Support</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">English, Chinese, and Japanese text with proper line breaking</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="mb-6">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">English Text</h4>
                <p class="text-base leading-relaxed text-gray-800 dark:text-white mb-4">
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis
                  nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                </p>
              </div>

              <div class="mb-6">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">Chinese Text (中文)</h4>
                <p
                  class="text-base leading-loose text-gray-800 dark:text-white mb-4"
                  style='font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif'
                >
                  这是中文文本示例。中文排版需要考虑字符间距、行高以及自动换行等因素。WebF框架能够很好地处理中文字符的显示和布局，确保文本在不同设备上都能正确显示。中文文本通常不需要单词间的空格，字符可以紧密排列。
                </p>
              </div>

              <div class="mb-6">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">Japanese Text (日本語)</h4>
                <p
                  class="text-base leading-loose text-gray-800 dark:text-white mb-4"
                  style='font-family: -apple-system, BlinkMacSystemFont, "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif'
                >
                  これは日本語のテキストサンプルです。日本語のタイポグラフィでは、ひらがな、カタカナ、漢字の混在を考慮する必要があります。WebFフレームワークは日本語文字の表示とレイアウトを適切に処理し、異なるデバイスで正しく表示されることを保証します。
                </p>
              </div>

              <div class="mb-6">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">Mixed Languages</h4>
                <p class="text-base leading-normal text-gray-800 dark:text-white mb-4">
                  This is English text mixed with 中文字符 and 日本語文字. The WebF framework handles mixed-language content seamlessly, ensuring proper spacing and line breaks
                  across different character sets. 这种混合语言的内容在现代网页中很常见。
                </p>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text and Image Layout</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text and image layout patterns using basic CSS</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="mb-8">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Side-by-Side Layout with Flexbox</h4>
                <div class="flex flex-row items-start mb-6 max-md:flex-col">
                  <img
                    src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                    alt="Flex"
                    class="flex-shrink-0 w-[120px] h-[120px] rounded-lg shadow-md object-cover mr-5 max-md:w-full max-md:max-w-[200px] max-md:self-center max-md:mr-0 max-md:mb-4"
                  />
                  <p class="flex-1 text-base leading-relaxed text-gray-800 dark:text-white text-justify m-0">
                    This layout uses flexbox to position image and text side by side. Flexbox provides excellent control over alignment and spacing. The image maintains its
                    aspect ratio while the text flexes to fill the remaining space. This approach is responsive and works well across different screen sizes. The gap between
                    elements can be easily adjusted, and the layout naturally adapts when content changes.
                  </p>
                </div>
              </div>

              <div class="mb-8">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Reversed Layout</h4>
                <div class="flex flex-row-reverse items-start mb-6 max-md:flex-col">
                  <img
                    src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                    alt="Flex reverse"
                    class="flex-shrink-0 w-[120px] h-[120px] rounded-lg shadow-md object-cover ml-5 max-md:w-full max-md:max-w-[200px] max-md:self-center max-md:ml-0 max-md:mb-4"
                  />
                  <p class="flex-1 text-base leading-relaxed text-gray-800 dark:text-white text-justify m-0">
                    Using flex-direction: row-reverse, we can easily place the image on the right. This creates visual variety in the layout. Flexbox makes it simple to
                    alternate between left and right image placements, creating a dynamic reading experience. The consistent spacing and alignment ensure a professional
                    appearance throughout.
                  </p>
                </div>
              </div>

              <div class="mb-8">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Inline-Block Mixed Content</h4>
                <div class="flex flex-wrap gap-2 mb-6">
                  <div class="flex-1 min-w-[250px] bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-md:w-full max-md:mb-4">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Inline 1"
                      class="w-full h-[100px] object-cover rounded-md mb-3"
                    />
                    <p class="text-sm leading-relaxed text-gray-800 dark:text-white m-0">Inline-block elements flow naturally like text but can have dimensions.</p>
                  </div>
                  <div class="flex-1 min-w-[250px] bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-md:w-full max-md:mb-4">
                    <p class="text-sm leading-relaxed text-gray-800 dark:text-white m-0">
                      This layout technique allows multiple items to sit side by side while maintaining block-level properties.
                    </p>
                  </div>
                  <div class="flex-1 min-w-[250px] bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-md:w-full max-md:mb-4">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Inline 2"
                      class="w-full h-[100px] object-cover rounded-md mb-3"
                    />
                    <p class="text-sm leading-relaxed text-gray-800 dark:text-white m-0">Perfect for card-like layouts and galleries.</p>
                  </div>
                </div>
              </div>

              <div class="mb-8">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Magazine Style Typography</h4>
                <p class="text-base leading-relaxed text-gray-800 dark:text-white text-justify mb-4">
                  <span
                    class="inline-block text-7xl leading-[60px] font-bold mr-2 -mb-2 text-blue-600 dark:text-blue-400 align-top"
                    style="font-family: Georgia, serif"
                    >W</span
                  >ebF provides excellent support for sophisticated typography layouts. This magazine-style design features a decorative drop cap that adds visual interest to
                  the beginning of the paragraph. The large first letter is achieved using inline-block display and specific sizing. This creates a professional editorial
                  appearance perfect for long-form content, articles, and digital publications.
                </p>
                <div class="flex flex-col items-center my-5">
                  <img src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" alt="Magazine" class="rounded-lg shadow-md w-[200px] h-auto" />
                  <p class="text-sm text-gray-600 dark:text-gray-300 mt-2 italic">Image with caption using flexbox</p>
                </div>
              </div>

              <div class="mb-8">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Overlapping Content with Position</h4>
                <div class="relative mb-6 overflow-hidden rounded-lg">
                  <img
                    src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                    alt="Background"
                    class="block w-full h-[200px] object-cover rounded-lg"
                  />
                  <div class="absolute bottom-2.5 left-5 right-5 bg-white/95 dark:bg-gray-800/95 rounded-lg p-4 shadow-xl max-md:left-2.5 max-md:right-2.5 max-md:p-3">
                    <p class="text-sm leading-relaxed text-gray-800 dark:text-white m-0">
                      Using position relative and absolute, we can create sophisticated overlapping layouts. This text box overlaps the image, creating depth and visual
                      interest. This technique is useful for hero sections, feature highlights, and creating engaging visual hierarchies.
                    </p>
                  </div>
                </div>
              </div>

              <div class="mb-8">
                <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Centered Image and Text</h4>
                <div class="flex flex-col items-center text-center">
                  <img
                    src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                    alt="Centered"
                    class="w-[150px] h-[150px] rounded-full object-cover shadow-xl mb-4"
                  />
                  <p class="text-base leading-relaxed text-gray-800 dark:text-white m-0 max-w-full px-4">
                    This vertical layout centers both image and text using flexbox with column direction. Perfect for feature highlights, testimonials, or any content that
                    benefits from centered presentation. The layout maintains its center alignment across different screen sizes.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Alignment and Formatting</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Different text alignments and formatting options</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-left">Left-aligned text (default)</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-center">Center-aligned text</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-right">Right-aligned text</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-justify">
                Justified text stretches across the full width of the container by adjusting the spacing between words. This creates clean, aligned edges on both sides of
                the text block, which can be useful for formal documents or newspaper-style layouts.
              </p>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Line Height and Spacing</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Demonstrating different line heights and text spacing</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <p class="mb-5 p-4 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 leading-tight">
                Tight line spacing example. This text has reduced line height, making the lines closer together. This can be useful for compact layouts or when space is
                limited.
              </p>

              <p class="mb-5 p-4 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 leading-relaxed">
                Normal line spacing example. This represents the default line height that provides good readability for most content types.
              </p>

              <p class="mb-5 p-4 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 leading-loose">
                Loose line spacing example. This text has increased line height, making it more airy and easier to read, especially for longer paragraphs or when enhanced
                readability is important.
              </p>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Word Break and Text Overflow</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Handling long words and text overflow scenarios</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="flex flex-wrap -m-2">
                <div class="flex-1 min-w-[250px] m-2 bg-white dark:bg-gray-800 rounded-md p-4 border border-gray-200 dark:border-gray-600 min-h-[80px] max-md:flex-[1_1_100%]">
                  <p class="break-words m-0">Normal text with regular word breaking behavior. This text will wrap at word boundaries.</p>
                </div>

                <div class="flex-1 min-w-[250px] m-2 bg-white dark:bg-gray-800 rounded-md p-4 border border-gray-200 dark:border-gray-600 min-h-[80px] max-md:flex-[1_1_100%]">
                  <p class="break-all m-0">Thisislongwordbreakallexamplewhereeverythingbreaksatanycharactertopreventoverflow.</p>
                </div>

                <div class="flex-1 min-w-[250px] m-2 bg-white dark:bg-gray-800 rounded-md p-4 border border-gray-200 dark:border-gray-600 min-h-[80px] max-md:flex-[1_1_100%]">
                  <p class="whitespace-nowrap overflow-hidden text-ellipsis m-0">
                    This is a very long text that demonstrates text overflow with ellipsis. The text will be truncated and show dots when it exceeds the container width.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Decoration</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">
              Various text decoration styles including underline, overline, and line-through
            </div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <p class="mb-4 p-3 text-base underline">Underlined text for emphasis or links</p>
              <p class="mb-4 p-3 text-base overline">Overline text decoration above the text</p>
              <p class="mb-4 p-3 text-base line-through">Line-through text for strikethrough effect</p>
              <p class="mb-4 p-3 text-base" style="text-decoration: underline; text-decoration-style: double">Double underline for strong emphasis</p>
              <p class="mb-4 p-3 text-base" style="text-decoration: underline; text-decoration-style: wavy; text-decoration-color: #ff4444">
                Wavy underline for spelling errors or special cases
              </p>
              <p class="mb-4 p-3 text-base" style="text-decoration: underline; text-decoration-style: dotted; text-decoration-color: #007aff">
                Dotted underline decoration style
              </p>
              <p class="mb-4 p-3 text-base" style="text-decoration: underline overline; text-decoration-color: #007aff">
                Combined decorations: underline and overline
              </p>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Transform</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Transforming text case: uppercase, lowercase, capitalize</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base uppercase">This text is transformed to uppercase</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base lowercase">THIS TEXT IS TRANSFORMED TO LOWERCASE</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base capitalize">this text has each word capitalized</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base normal-case">This text retains its original case</p>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Letter and Word Spacing</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Adjusting spacing between letters and words</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-normal">
                Normal letter spacing - default spacing between characters.
              </p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-tight">Tight letter spacing - characters closer together.</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-wide">Wide letter spacing - expanded space between characters.</p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-widest">
                Extra wide letter spacing for dramatic effect.
              </p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600" style="word-spacing: normal">
                Normal word spacing between words in this sentence.
              </p>
              <p class="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600" style="word-spacing: 10px">
                Wide word spacing between words in this sentence.
              </p>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Shadow Effects</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text shadow effects for depth and emphasis</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="bg-white dark:bg-gray-800 rounded-lg p-5 flex flex-col gap-6">
                <p class="text-2xl font-semibold m-0 p-4 text-center" style="text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3)">Simple text shadow effect</p>
                <p class="text-2xl font-semibold m-0 p-4 text-center" style="text-shadow: 0 4px 8px rgba(0, 0, 0, 0.2)">Blurred shadow for soft effect</p>
                <p
                  class="text-2xl font-semibold m-0 p-4 text-center"
                  style="text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3), 2px 2px 4px rgba(0, 0, 0, 0.2), 3px 3px 6px rgba(0, 0, 0, 0.1)"
                >
                  Multiple shadows for depth
                </p>
                <p
                  class="text-2xl font-semibold m-0 p-4 text-center text-white rounded-lg"
                  style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.5)"
                >
                  Colored shadow effect
                </p>
                <p
                  class="text-2xl font-semibold m-0 p-4 text-center text-white bg-gray-900 rounded-lg"
                  style="text-shadow: 0 0 10px #00ff00, 0 0 20px #00ff00, 0 0 30px #00ff00, 0 0 40px #00ff00"
                >
                  Neon glow effect
                </p>
                <p
                  class="text-2xl font-semibold m-0 p-4 text-center text-gray-300 bg-gray-200 rounded-lg"
                  style="text-shadow: 1px 1px 1px rgba(255, 255, 255, 0.8), -1px -1px 1px rgba(0, 0, 0, 0.2)"
                >
                  Embossed 3D text effect
                </p>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Lists and Structured Content</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Ordered lists, unordered lists, and nested structures</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="flex flex-col gap-6">
                <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                  <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Unordered List (Bullets)</h4>
                  <ul class="m-0 pl-6 leading-loose text-gray-800 dark:text-white">
                    <li class="mb-2">First item in the list</li>
                    <li class="mb-2">Second item with more content</li>
                    <li class="mb-2">
                      Third item
                      <ul class="mt-2 mb-2">
                        <li class="mb-2">Nested item 1</li>
                        <li class="mb-2">Nested item 2</li>
                      </ul>
                    </li>
                    <li class="mb-2">Fourth item</li>
                  </ul>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                  <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Ordered List (Numbers)</h4>
                  <ol class="m-0 pl-6 leading-loose text-gray-800 dark:text-white">
                    <li class="mb-2">First step in the process</li>
                    <li class="mb-2">Second step follows</li>
                    <li class="mb-2">
                      Third step with substeps
                      <ol class="mt-2 mb-2">
                        <li class="mb-2">Substep A</li>
                        <li class="mb-2">Substep B</li>
                      </ol>
                    </li>
                    <li class="mb-2">Final step</li>
                  </ol>
                </div>

                <div class="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                  <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Custom List Styles</h4>
                  <ul class="m-0 pl-6 leading-loose text-gray-800 dark:text-white list-[circle]">
                    <li class="mb-2">Circle markers</li>
                    <li class="mb-2">Square markers</li>
                    <li class="mb-2">Disc markers</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Blockquotes and Citations</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Formatted quotes and citations for emphasis</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <blockquote class="m-0 mb-6 p-6 border-l-4 border-blue-600 bg-white dark:bg-gray-800 rounded-lg italic">
                <p class="text-lg leading-relaxed text-gray-800 dark:text-white mb-3">
                  "The only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle."
                </p>
                <cite class="block text-sm text-gray-600 dark:text-gray-300 not-italic font-semibold text-right">— Steve Jobs</cite>
              </blockquote>

              <blockquote class="m-0 mb-6 p-6 border-t-4 border-blue-600 bg-white dark:bg-gray-800 rounded-lg italic text-center">
                <p class="text-lg leading-relaxed text-gray-800 dark:text-white mb-3">"Design is not just what it looks like and feels like. Design is how it works."</p>
                <cite class="block text-sm text-gray-600 dark:text-gray-300 not-italic font-semibold">— Steve Jobs</cite>
              </blockquote>

              <div class="my-6 p-6 bg-gradient-to-br from-purple-600 to-purple-900 rounded-xl text-center">
                <p class="text-2xl font-semibold text-white m-0 leading-snug italic">
                  "Typography is the craft of endowing human language with a durable visual form."
                </p>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Code and Monospace Text</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Displaying code snippets and monospace text</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="flex flex-col gap-5">
                <p class="text-base leading-relaxed m-0 bg-white dark:bg-gray-800 p-3 rounded-md">
                  Inline code example:
                  <code class="bg-gray-200 dark:bg-gray-700 text-pink-600 dark:text-pink-400 px-1.5 py-0.5 rounded font-mono text-sm">
                    const greeting = "Hello World";
                  </code>
                </p>

                <pre class="m-0 p-4 bg-gray-900 rounded-lg overflow-x-auto shadow-md">
                  <code class="text-gray-300 font-mono text-sm leading-relaxed" v-pre>function calculateSum(a, b) {
  return a + b;
}

const result = calculateSum(5, 10);
console.log(result); // Output: 15</code>
                </pre>

                <div class="bg-gray-900 rounded-lg overflow-hidden shadow-md">
                  <div class="bg-gray-800 text-gray-300 px-4 py-2 text-sm font-semibold border-b border-gray-700">Terminal</div>
                  <pre class="m-0 p-4 bg-gray-900">
                    <code class="text-green-400 font-mono text-sm leading-relaxed" v-pre>$ npm install webf
$ npm run dev
Server running on http://localhost:3000</code>
                  </pre>
                </div>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Colors and Gradients</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text color schemes and gradient effects</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="flex flex-col gap-4">
                <p class="m-0 p-3 rounded-md text-base font-semibold text-blue-600 bg-blue-50">Primary color text</p>
                <p class="m-0 p-3 rounded-md text-base font-semibold text-purple-600 bg-purple-50">Secondary color text</p>
                <p class="m-0 p-3 rounded-md text-base font-semibold text-green-600 bg-green-50">Success message text</p>
                <p class="m-0 p-3 rounded-md text-base font-semibold text-orange-600 bg-orange-50">Warning message text</p>
                <p class="m-0 p-3 rounded-md text-base font-semibold text-red-600 bg-red-50">Error message text</p>
                <p class="m-0 p-3 rounded-md text-base font-semibold text-cyan-600 bg-cyan-50">Information text</p>
                <h2 class="text-4xl font-bold p-4 bg-gradient-to-r from-purple-600 to-purple-900 bg-clip-text text-transparent">Gradient Text Effect</h2>
                <h2 class="text-4xl font-bold p-4 bg-gradient-to-r from-red-500 via-yellow-500 via-green-500 via-blue-500 to-purple-500 bg-clip-text text-transparent">
                  Rainbow Gradient Text
                </h2>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Font Family Variations</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Different font families for various purposes</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="flex flex-col gap-4">
                <p class="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg font-sans">Sans-serif font - Clean and modern appearance</p>
                <p class="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg font-serif">Serif font - Traditional and elegant style</p>
                <p class="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg font-mono">Monospace font - Fixed-width characters for code</p>
                <p class="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg" style='font-family: "Brush Script MT", cursive'>
                  Cursive font - Handwriting style appearance
                </p>
                <p class="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-xl" style="font-family: Papyrus, fantasy">
                  Fantasy font - Decorative display font
                </p>
              </div>
            </div>
          </div>

          <div class="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
            <div class="text-lg font-semibold text-gray-800 dark:text-white mb-2">Bidirectional Text (RTL/LTR)</div>
            <div class="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Right-to-left and mixed direction text support</div>
            <div class="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
              <div class="flex flex-col gap-5">
                <div dir="ltr" class="p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 text-left">
                  <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Left-to-Right (LTR)</h4>
                  <p class="m-0 text-base leading-loose">This is English text that reads from left to right. This is the default direction for most Western languages.</p>
                </div>

                <div dir="rtl" class="p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 text-right">
                  <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Right-to-Left (RTL)</h4>
                  <p class="m-0 text-base leading-loose">هذا نص عربي يُقرأ من اليمين إلى اليسار. اللغة العربية والعبرية تستخدمان هذا الاتجاه.</p>
                </div>

                <div dir="ltr" class="p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 text-left">
                  <h4 class="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Mixed Bidirectional Text</h4>
                  <p class="m-0 text-base leading-loose">
                    This is English text with عربي (Arabic) words mixed in the same paragraph, demonstrating bidirectional text handling.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
