import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const TypographyPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className="flex-1 p-0 m-0">
        <div className="p-5 bg-gray-100 dark:bg-gray-900 min-h-screen max-w-7xl mx-auto">
          <div className="text-2xl font-bold text-gray-800 dark:text-white mb-6 text-center">Typography Layout Showcase</div>
          <div className="flex flex-col">

            {/* Basic Text Styles */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Basic Text Styles</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Different font weights, sizes, and styles</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <h1 className="text-3xl font-bold text-gray-800 dark:text-white mb-4 leading-tight">Heading 1 - Large Title</h1>
                <h2 className="text-2xl font-semibold text-gray-800 dark:text-white mb-3 leading-snug">Heading 2 - Section Title</h2>
                <h3 className="text-xl font-medium text-gray-800 dark:text-white mb-2.5 leading-normal">Heading 3 - Subsection</h3>
                <p className="text-base font-normal text-gray-800 dark:text-white leading-relaxed mb-3">Body text with normal weight and size. This is the standard paragraph text used for most content.</p>
                <p className="text-sm font-normal text-gray-600 dark:text-gray-300 leading-normal mb-3">Small text for captions, footnotes, or supplementary information.</p>
                <p className="text-base font-bold text-gray-800 dark:text-white leading-relaxed mb-3">Bold text for emphasis and important information.</p>
                <p className="text-base font-normal italic text-gray-800 dark:text-white leading-relaxed mb-3">Italic text for quotes, titles, or stylistic emphasis.</p>
              </div>
            </div>

            {/* Multilingual Text */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Multilingual Text Support</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">English, Chinese, and Japanese text with proper line breaking</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="mb-6">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">English Text</h4>
                  <p className="text-base leading-relaxed text-gray-800 dark:text-white mb-4">
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                  </p>
                </div>

                <div className="mb-6">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">Chinese Text (中文)</h4>
                  <p className="text-base leading-loose text-gray-800 dark:text-white mb-4" style={{fontFamily: '-apple-system, BlinkMacSystemFont, "PingFang SC", "Hiragino Sans GB", "Microsoft YaHei", sans-serif'}}>
                    这是中文文本示例。中文排版需要考虑字符间距、行高以及自动换行等因素。WebF框架能够很好地处理中文字符的显示和布局，确保文本在不同设备上都能正确显示。中文文本通常不需要单词间的空格，字符可以紧密排列。
                  </p>
                </div>

                <div className="mb-6">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">Japanese Text (日本語)</h4>
                  <p className="text-base leading-loose text-gray-800 dark:text-white mb-4" style={{fontFamily: '-apple-system, BlinkMacSystemFont, "Hiragino Kaku Gothic ProN", "Hiragino Sans", Meiryo, sans-serif'}}>
                    これは日本語のテキストサンプルです。日本語のタイポグラフィでは、ひらがな、カタカナ、漢字の混在を考慮する必要があります。WebFフレームワークは日本語文字の表示とレイアウトを適切に処理し、異なるデバイスで正しく表示されることを保証します。
                  </p>
                </div>

                <div className="mb-6">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-2">Mixed Languages</h4>
                  <p className="text-base leading-normal text-gray-800 dark:text-white mb-4">
                    This is English text mixed with 中文字符 and 日本語文字. The WebF framework handles mixed-language content seamlessly, ensuring proper spacing and line breaks across different character sets. 这种混合语言的内容在现代网页中很常见。
                  </p>
                </div>
              </div>
            </div>

            {/* Text and Image Layout */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text and Image Layout</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text and image layout patterns using basic CSS</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                {/* Flexbox side-by-side layout */}
                <div className="mb-8">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Side-by-Side Layout with Flexbox</h4>
                  <div className="flex flex-row items-start mb-6 max-md:flex-col">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Flex"
                      className="flex-shrink-0 w-[120px] h-[120px] rounded-lg shadow-md object-cover mr-5 max-md:w-full max-md:max-w-[200px] max-md:self-center max-md:mr-0 max-md:mb-4"
                    />
                    <p className="flex-1 text-base leading-relaxed text-gray-800 dark:text-white text-justify m-0">
                      This layout uses flexbox to position image and text side by side. Flexbox provides excellent control over alignment and spacing. The image maintains its aspect ratio while the text flexes to fill the remaining space. This approach is responsive and works well across different screen sizes. The gap between elements can be easily adjusted, and the layout naturally adapts when content changes.
                    </p>
                  </div>
                </div>

                {/* Reverse flexbox layout */}
                <div className="mb-8">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Reversed Layout</h4>
                  <div className="flex flex-row-reverse items-start mb-6 max-md:flex-col">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Flex reverse"
                      className="flex-shrink-0 w-[120px] h-[120px] rounded-lg shadow-md object-cover ml-5 max-md:w-full max-md:max-w-[200px] max-md:self-center max-md:ml-0 max-md:mb-4"
                    />
                    <p className="flex-1 text-base leading-relaxed text-gray-800 dark:text-white text-justify m-0">
                      Using flex-direction: row-reverse, we can easily place the image on the right. This creates visual variety in the layout. Flexbox makes it simple to alternate between left and right image placements, creating a dynamic reading experience. The consistent spacing and alignment ensure a professional appearance throughout.
                    </p>
                  </div>
                </div>

                {/* Inline-block layout */}
                <div className="mb-8">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Inline-Block Mixed Content</h4>
                  <div className="flex flex-wrap gap-2 mb-6">
                    <div className="flex-1 min-w-[250px] bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-md:w-full max-md:mb-4">
                      <img
                        src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                        alt="Inline 1"
                        className="w-full h-[100px] object-cover rounded-md mb-3"
                      />
                      <p className="text-sm leading-relaxed text-gray-800 dark:text-white m-0">Inline-block elements flow naturally like text but can have dimensions.</p>
                    </div>
                    <div className="flex-1 min-w-[250px] bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-md:w-full max-md:mb-4">
                      <p className="text-sm leading-relaxed text-gray-800 dark:text-white m-0">This layout technique allows multiple items to sit side by side while maintaining block-level properties.</p>
                    </div>
                    <div className="flex-1 min-w-[250px] bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-md:w-full max-md:mb-4">
                      <img
                        src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                        alt="Inline 2"
                        className="w-full h-[100px] object-cover rounded-md mb-3"
                      />
                      <p className="text-sm leading-relaxed text-gray-800 dark:text-white m-0">Perfect for card-like layouts and galleries.</p>
                    </div>
                  </div>
                </div>

                {/* Magazine style with large first letter */}
                <div className="mb-8">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Magazine Style Typography</h4>
                  <p className="text-base leading-relaxed text-gray-800 dark:text-white text-justify mb-4">
                    <span className="inline-block text-7xl leading-[60px] font-bold mr-2 -mb-2 text-blue-600 dark:text-blue-400 align-top" style={{fontFamily: 'Georgia, serif'}}>W</span>ebF provides excellent support for sophisticated typography layouts. This magazine-style design features a decorative drop cap that adds visual interest to the beginning of the paragraph. The large first letter is achieved using inline-block display and specific sizing. This creates a professional editorial appearance perfect for long-form content, articles, and digital publications.
                  </p>
                  <div className="flex flex-col items-center my-5">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Magazine"
                      className="rounded-lg shadow-md w-[200px] h-auto"
                    />
                    <p className="text-sm text-gray-600 dark:text-gray-300 mt-2 italic">Image with caption using flexbox</p>
                  </div>
                </div>

                {/* Position-based overlapping layout */}
                <div className="mb-8">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Overlapping Content with Position</h4>
                  <div className="relative mb-6 overflow-hidden rounded-lg">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Background"
                      className="block w-full h-[200px] object-cover rounded-lg"
                    />
                    <div className="absolute bottom-2.5 left-5 right-5 bg-white/95 dark:bg-gray-800/95 rounded-lg p-4 shadow-xl max-md:left-2.5 max-md:right-2.5 max-md:p-3">
                      <p className="text-sm leading-relaxed text-gray-800 dark:text-white m-0">
                        Using position relative and absolute, we can create sophisticated overlapping layouts. This text box overlaps the image, creating depth and visual interest. This technique is useful for hero sections, feature highlights, and creating engaging visual hierarchies.
                      </p>
                    </div>
                  </div>
                </div>

                {/* Vertical centered layout */}
                <div className="mb-8">
                  <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Centered Image and Text</h4>
                  <div className="flex flex-col items-center text-center">
                    <img
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png"
                      alt="Centered"
                      className="w-[150px] h-[150px] rounded-full object-cover shadow-xl mb-4"
                    />
                    <p className="text-base leading-relaxed text-gray-800 dark:text-white m-0 max-w-full px-4">
                      This vertical layout centers both image and text using flexbox with column direction. Perfect for feature highlights, testimonials, or any content that benefits from centered presentation. The layout maintains its center alignment across different screen sizes.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Text Alignment and Formatting */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Alignment and Formatting</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Different text alignments and formatting options</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-left">Left-aligned text (default)</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-center">Center-aligned text</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-right">Right-aligned text</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-justify">
                  Justified text stretches across the full width of the container by adjusting the spacing between words. This creates clean, aligned edges on both sides of the text block, which can be useful for formal documents or newspaper-style layouts.
                </p>
              </div>
            </div>

            {/* Line Height and Spacing */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Line Height and Spacing</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Demonstrating different line heights and text spacing</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <p className="mb-5 p-4 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 leading-tight">
                  Tight line spacing example. This text has reduced line height, making the lines closer together. This can be useful for compact layouts or when space is limited.
                </p>

                <p className="mb-5 p-4 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 leading-relaxed">
                  Normal line spacing example. This represents the default line height that provides good readability for most content types.
                </p>

                <p className="mb-5 p-4 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 leading-loose">
                  Loose line spacing example. This text has increased line height, making it more airy and easier to read, especially for longer paragraphs or when enhanced readability is important.
                </p>
              </div>
            </div>

            {/* Word Break and Overflow */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Word Break and Text Overflow</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Handling long words and text overflow scenarios</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-wrap -m-2">
                  <div className="flex-1 min-w-[250px] m-2 bg-white dark:bg-gray-800 rounded-md p-4 border border-gray-200 dark:border-gray-600 min-h-[80px] max-md:flex-[1_1_100%]">
                    <p className="break-words m-0">
                      Normal text with regular word breaking behavior. This text will wrap at word boundaries.
                    </p>
                  </div>

                  <div className="flex-1 min-w-[250px] m-2 bg-white dark:bg-gray-800 rounded-md p-4 border border-gray-200 dark:border-gray-600 min-h-[80px] max-md:flex-[1_1_100%]">
                    <p className="break-all m-0">
                      Thisislongwordbreakallexamplewhereeverythingbreaksatanycharactertopreventoverflow.
                    </p>
                  </div>

                  <div className="flex-1 min-w-[250px] m-2 bg-white dark:bg-gray-800 rounded-md p-4 border border-gray-200 dark:border-gray-600 min-h-[80px] max-md:flex-[1_1_100%]">
                    <p className="whitespace-nowrap overflow-hidden text-ellipsis m-0">
                      This is a very long text that demonstrates text overflow with ellipsis. The text will be truncated and show dots when it exceeds the container width.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Text Decoration */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Decoration</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text decoration styles including underline, overline, and line-through</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <p className="mb-4 p-3 text-base underline">Underlined text for emphasis or links</p>
                <p className="mb-4 p-3 text-base overline">Overline text decoration above the text</p>
                <p className="mb-4 p-3 text-base line-through">Line-through text for strikethrough effect</p>
                <p className="mb-4 p-3 text-base" style={{textDecoration: 'underline', textDecorationStyle: 'double'}}>Double underline for strong emphasis</p>
                <p className="mb-4 p-3 text-base" style={{textDecoration: 'underline', textDecorationStyle: 'wavy', textDecorationColor: '#ff4444'}}>Wavy underline for spelling errors or special cases</p>
                <p className="mb-4 p-3 text-base" style={{textDecoration: 'underline', textDecorationStyle: 'dotted', textDecorationColor: '#007aff'}}>Dotted underline decoration style</p>
                <p className="mb-4 p-3 text-base" style={{textDecoration: 'underline overline', textDecorationColor: '#007aff'}}>Combined decorations: underline and overline</p>
              </div>
            </div>

            {/* Text Transform */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Transform</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Transforming text case: uppercase, lowercase, capitalize</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base uppercase">This text is transformed to uppercase</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base lowercase">THIS TEXT IS TRANSFORMED TO LOWERCASE</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base capitalize">this text has each word capitalized</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border-l-4 border-blue-600 text-base normal-case">This text retains its original case</p>
              </div>
            </div>

            {/* Letter and Word Spacing */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Letter and Word Spacing</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Adjusting spacing between letters and words</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-normal">Normal letter spacing - default spacing between characters.</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-tight">Tight letter spacing - characters closer together.</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-wide">Wide letter spacing - expanded space between characters.</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 tracking-widest">Extra wide letter spacing for dramatic effect.</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600" style={{wordSpacing: 'normal'}}>Normal word spacing between words in this sentence.</p>
                <p className="mb-4 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600" style={{wordSpacing: '10px'}}>Wide word spacing between words in this sentence.</p>
              </div>
            </div>

            {/* Text Shadow */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Shadow Effects</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text shadow effects for depth and emphasis</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="bg-white dark:bg-gray-800 rounded-lg p-5 flex flex-col gap-6">
                  <p className="text-2xl font-semibold m-0 p-4 text-center" style={{textShadow: '2px 2px 4px rgba(0, 0, 0, 0.3)'}}>Simple text shadow effect</p>
                  <p className="text-2xl font-semibold m-0 p-4 text-center" style={{textShadow: '0 4px 8px rgba(0, 0, 0, 0.2)'}}>Blurred shadow for soft effect</p>
                  <p className="text-2xl font-semibold m-0 p-4 text-center" style={{textShadow: '1px 1px 2px rgba(0, 0, 0, 0.3), 2px 2px 4px rgba(0, 0, 0, 0.2), 3px 3px 6px rgba(0, 0, 0, 0.1)'}}>Multiple shadows for depth</p>
                  <p className="text-2xl font-semibold m-0 p-4 text-center text-white rounded-lg" style={{background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)', textShadow: '2px 2px 8px rgba(0, 0, 0, 0.5)'}}>Colored shadow effect</p>
                  <p className="text-2xl font-semibold m-0 p-4 text-center text-white bg-gray-900 rounded-lg" style={{textShadow: '0 0 10px #00ff00, 0 0 20px #00ff00, 0 0 30px #00ff00, 0 0 40px #00ff00'}}>Neon glow effect</p>
                  <p className="text-2xl font-semibold m-0 p-4 text-center text-gray-300 bg-gray-200 rounded-lg" style={{textShadow: '1px 1px 1px rgba(255, 255, 255, 0.8), -1px -1px 1px rgba(0, 0, 0, 0.2)'}}>Embossed 3D text effect</p>
                </div>
              </div>
            </div>

            {/* Lists and Structured Content */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Lists and Structured Content</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Ordered lists, unordered lists, and nested structures</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-6">
                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Unordered List (Bullets)</h4>
                    <ul className="m-0 pl-6 leading-loose text-gray-800 dark:text-white">
                      <li className="mb-2">First item in the list</li>
                      <li className="mb-2">Second item with more content</li>
                      <li className="mb-2">Third item
                        <ul className="mt-2 mb-2">
                          <li className="mb-2">Nested item 1</li>
                          <li className="mb-2">Nested item 2</li>
                        </ul>
                      </li>
                      <li className="mb-2">Fourth item</li>
                    </ul>
                  </div>

                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Ordered List (Numbers)</h4>
                    <ol className="m-0 pl-6 leading-loose text-gray-800 dark:text-white">
                      <li className="mb-2">First step in the process</li>
                      <li className="mb-2">Second step follows</li>
                      <li className="mb-2">Third step with substeps
                        <ol className="mt-2 mb-2">
                          <li className="mb-2">Substep A</li>
                          <li className="mb-2">Substep B</li>
                        </ol>
                      </li>
                      <li className="mb-2">Final step</li>
                    </ol>
                  </div>

                  <div className="bg-white dark:bg-gray-800 rounded-lg p-4 border border-gray-200 dark:border-gray-600">
                    <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Custom List Styles</h4>
                    <ul className="m-0 pl-6 leading-loose text-gray-800 dark:text-white list-[circle]">
                      <li className="mb-2">Circle markers</li>
                      <li className="mb-2">Square markers</li>
                      <li className="mb-2">Disc markers</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>

            {/* Blockquotes and Citations */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Blockquotes and Citations</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Formatted quotes and citations for emphasis</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <blockquote className="m-0 mb-6 p-6 border-l-4 border-blue-600 bg-white dark:bg-gray-800 rounded-lg italic">
                  <p className="text-lg leading-relaxed text-gray-800 dark:text-white mb-3">
                    "The only way to do great work is to love what you do. If you haven't found it yet, keep looking. Don't settle."
                  </p>
                  <cite className="block text-sm text-gray-600 dark:text-gray-300 not-italic font-semibold text-right">— Steve Jobs</cite>
                </blockquote>

                <blockquote className="m-0 mb-6 p-6 border-t-4 border-blue-600 bg-white dark:bg-gray-800 rounded-lg italic text-center">
                  <p className="text-lg leading-relaxed text-gray-800 dark:text-white mb-3">
                    "Design is not just what it looks like and feels like. Design is how it works."
                  </p>
                  <cite className="block text-sm text-gray-600 dark:text-gray-300 not-italic font-semibold">— Steve Jobs</cite>
                </blockquote>

                <div className="my-6 p-6 bg-gradient-to-br from-purple-600 to-purple-900 rounded-xl text-center">
                  <p className="text-2xl font-semibold text-white m-0 leading-snug italic">"Typography is the craft of endowing human language with a durable visual form."</p>
                </div>
              </div>
            </div>

            {/* Code and Monospace Text */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Code and Monospace Text</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Displaying code snippets and monospace text</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-5">
                  <p className="text-base leading-relaxed m-0 bg-white dark:bg-gray-800 p-3 rounded-md">
                    Inline code example: <code className="bg-gray-200 dark:bg-gray-700 text-pink-600 dark:text-pink-400 px-1.5 py-0.5 rounded font-mono text-sm">const greeting = "Hello World";</code>
                  </p>

                  <pre className="m-0 p-4 bg-gray-900 rounded-lg overflow-x-auto shadow-md">
                    <code className="text-gray-300 font-mono text-sm leading-relaxed">{`function calculateSum(a, b) {
  return a + b;
}

const result = calculateSum(5, 10);
console.log(result); // Output: 15`}</code>
                  </pre>

                  <div className="bg-gray-900 rounded-lg overflow-hidden shadow-md">
                    <div className="bg-gray-800 text-gray-300 px-4 py-2 text-sm font-semibold border-b border-gray-700">Terminal</div>
                    <pre className="m-0 p-4 bg-gray-900">
                      <code className="text-green-400 font-mono text-sm leading-relaxed">{`$ npm install webf
$ npm run dev
Server running on http://localhost:3000`}</code>
                    </pre>
                  </div>
                </div>
              </div>
            </div>

            {/* Text Colors and Gradients */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Text Colors and Gradients</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Various text color schemes and gradient effects</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-4">
                  <p className="m-0 p-3 rounded-md text-base font-semibold text-blue-600 bg-blue-50">Primary color text</p>
                  <p className="m-0 p-3 rounded-md text-base font-semibold text-purple-600 bg-purple-50">Secondary color text</p>
                  <p className="m-0 p-3 rounded-md text-base font-semibold text-green-600 bg-green-50">Success message text</p>
                  <p className="m-0 p-3 rounded-md text-base font-semibold text-orange-600 bg-orange-50">Warning message text</p>
                  <p className="m-0 p-3 rounded-md text-base font-semibold text-red-600 bg-red-50">Error message text</p>
                  <p className="m-0 p-3 rounded-md text-base font-semibold text-cyan-600 bg-cyan-50">Information text</p>
                  <h2 className="text-4xl font-bold p-4 bg-gradient-to-r from-purple-600 to-purple-900 bg-clip-text text-transparent">Gradient Text Effect</h2>
                  <h2 className="text-4xl font-bold p-4 bg-gradient-to-r from-red-500 via-yellow-500 via-green-500 via-blue-500 to-purple-500 bg-clip-text text-transparent">Rainbow Gradient Text</h2>
                </div>
              </div>
            </div>

            {/* Font Families */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Font Family Variations</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Different font families for various purposes</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-4">
                  <p className="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg font-sans">Sans-serif font - Clean and modern appearance</p>
                  <p className="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg font-serif">Serif font - Traditional and elegant style</p>
                  <p className="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg font-mono">Monospace font - Fixed-width characters for code</p>
                  <p className="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-lg" style={{fontFamily: '"Brush Script MT", cursive'}}>Cursive font - Handwriting style appearance</p>
                  <p className="m-0 p-3 bg-white dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-600 text-xl" style={{fontFamily: 'Papyrus, fantasy'}}>Fantasy font - Decorative display font</p>
                </div>
              </div>
            </div>

            {/* Bidirectional Text */}
            <div className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-lg border border-gray-200 dark:border-gray-700 mb-8 w-full">
              <div className="text-lg font-semibold text-gray-800 dark:text-white mb-2">Bidirectional Text (RTL/LTR)</div>
              <div className="text-sm text-gray-600 dark:text-gray-300 mb-5 leading-relaxed">Right-to-left and mixed direction text support</div>
              <div className="bg-gray-50 dark:bg-gray-700 rounded-lg p-5 border border-gray-200 dark:border-gray-600 w-full">
                <div className="flex flex-col gap-5">
                  <div className="p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 ltr text-left">
                    <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Left-to-Right (LTR)</h4>
                    <p className="m-0 text-base leading-loose">This is English text that reads from left to right. This is the default direction for most Western languages.</p>
                  </div>

                  <div className="p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 rtl text-right">
                    <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Right-to-Left (RTL)</h4>
                    <p className="m-0 text-base leading-loose">هذا نص عربي يُقرأ من اليمين إلى اليسار. اللغة العربية والعبرية تستخدمان هذا الاتجاه.</p>
                  </div>

                  <div className="p-4 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-600 ltr text-left">
                    <h4 className="text-base font-semibold text-blue-600 dark:text-blue-400 mb-3">Mixed Bidirectional Text</h4>
                    <p className="m-0 text-base leading-loose">This is English text with عربي (Arabic) words mixed in the same paragraph, demonstrating bidirectional text handling.</p>
                  </div>
                </div>
              </div>
            </div>

          </div>
        </div>
      </WebFListView>
    </div>
  );
};
