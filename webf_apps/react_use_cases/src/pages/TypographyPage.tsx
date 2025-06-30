import React from 'react';
import { createComponent } from '../utils/CreateComponent';
import styles from './TypographyPage.module.css';

const WebFListView = createComponent({
  tagName: 'webf-listview',
  displayName: 'WebFListView'
});

export const TypographyPage: React.FC = () => {
  return (
    <div id="main">
      <WebFListView className={styles.list}>
        <div className={styles.componentSection}>
          <div className={styles.sectionTitle}>Typography Layout Showcase</div>
          <div className={styles.componentBlock}>
            
            {/* Basic Text Styles */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Basic Text Styles</div>
              <div className={styles.itemDesc}>Different font weights, sizes, and styles</div>
              <div className={styles.textContainer}>
                <h1 className={styles.heading1}>Heading 1 - Large Title</h1>
                <h2 className={styles.heading2}>Heading 2 - Section Title</h2>
                <h3 className={styles.heading3}>Heading 3 - Subsection</h3>
                <p className={styles.bodyText}>Body text with normal weight and size. This is the standard paragraph text used for most content.</p>
                <p className={styles.smallText}>Small text for captions, footnotes, or supplementary information.</p>
                <p className={styles.boldText}>Bold text for emphasis and important information.</p>
                <p className={styles.italicText}>Italic text for quotes, titles, or stylistic emphasis.</p>
              </div>
            </div>

            {/* Multilingual Text */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Multilingual Text Support</div>
              <div className={styles.itemDesc}>English, Chinese, and Japanese text with proper line breaking</div>
              <div className={styles.textContainer}>
                <div className={styles.multilingualSection}>
                  <h4>English Text</h4>
                  <p className={styles.englishText}>
                    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
                  </p>
                </div>
                
                <div className={styles.multilingualSection}>
                  <h4>Chinese Text (中文)</h4>
                  <p className={styles.chineseText}>
                    这是中文文本示例。中文排版需要考虑字符间距、行高以及自动换行等因素。WebF框架能够很好地处理中文字符的显示和布局，确保文本在不同设备上都能正确显示。中文文本通常不需要单词间的空格，字符可以紧密排列。
                  </p>
                </div>
                
                <div className={styles.multilingualSection}>
                  <h4>Japanese Text (日本語)</h4>
                  <p className={styles.japaneseText}>
                    これは日本語のテキストサンプルです。日本語のタイポグラフィでは、ひらがな、カタカナ、漢字の混在を考慮する必要があります。WebFフレームワークは日本語文字の表示とレイアウトを適切に処理し、異なるデバイスで正しく表示されることを保証します。
                  </p>
                </div>

                <div className={styles.multilingualSection}>
                  <h4>Mixed Languages</h4>
                  <p className={styles.mixedText}>
                    This is English text mixed with 中文字符 and 日本語文字. The WebF framework handles mixed-language content seamlessly, ensuring proper spacing and line breaks across different character sets. 这种混合语言的内容在现代网页中很常见。
                  </p>
                </div>
              </div>
            </div>

            {/* Text and Image Layout */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Text and Image Layout</div>
              <div className={styles.itemDesc}>Various text and image layout patterns using basic CSS</div>
              <div className={styles.textContainer}>
                {/* Flexbox side-by-side layout */}
                <div className={styles.flexLayout}>
                  <h4>Side-by-Side Layout with Flexbox</h4>
                  <div className={styles.flexContainer}>
                    <img 
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                      alt="Flex image" 
                      className={styles.flexImage}
                    />
                    <p className={styles.flexText}>
                      This layout uses flexbox to position image and text side by side. Flexbox provides excellent control over alignment and spacing. The image maintains its aspect ratio while the text flexes to fill the remaining space. This approach is responsive and works well across different screen sizes. The gap between elements can be easily adjusted, and the layout naturally adapts when content changes.
                    </p>
                  </div>
                </div>

                {/* Reverse flexbox layout */}
                <div className={styles.flexLayout}>
                  <h4>Reversed Layout</h4>
                  <div className={styles.flexContainerReverse}>
                    <img 
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                      alt="Flex reverse" 
                      className={styles.flexImage}
                    />
                    <p className={styles.flexText}>
                      Using flex-direction: row-reverse, we can easily place the image on the right. This creates visual variety in the layout. Flexbox makes it simple to alternate between left and right image placements, creating a dynamic reading experience. The consistent spacing and alignment ensure a professional appearance throughout.
                    </p>
                  </div>
                </div>

                {/* Inline-block layout */}
                <div className={styles.inlineLayout}>
                  <h4>Inline-Block Mixed Content</h4>
                  <div className={styles.inlineContainer}>
                    <div className={styles.inlineItem}>
                      <img 
                        src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                        alt="Inline 1" 
                        className={styles.inlineImage}
                      />
                      <p className={styles.inlineText}>Inline-block elements flow naturally like text but can have dimensions.</p>
                    </div>
                    <div className={styles.inlineItem}>
                      <p className={styles.inlineText}>This layout technique allows multiple items to sit side by side while maintaining block-level properties.</p>
                    </div>
                    <div className={styles.inlineItem}>
                      <img 
                        src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                        alt="Inline 2" 
                        className={styles.inlineImage}
                      />
                      <p className={styles.inlineText}>Perfect for card-like layouts and galleries.</p>
                    </div>
                  </div>
                </div>

                {/* Magazine style with large first letter */}
                <div className={styles.magazineLayout}>
                  <h4>Magazine Style Typography</h4>
                  <p className={styles.dropCapText}>
                    <span className={styles.dropCap}>W</span>ebF provides excellent support for sophisticated typography layouts. This magazine-style design features a decorative drop cap that adds visual interest to the beginning of the paragraph. The large first letter is achieved using inline-block display and specific sizing. This creates a professional editorial appearance perfect for long-form content, articles, and digital publications.
                  </p>
                  <div className={styles.magazineImageContainer}>
                    <img 
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                      alt="Magazine" 
                      className={styles.magazineImage}
                    />
                    <p className={styles.magazineCaption}>Image with caption using flexbox</p>
                  </div>
                </div>

                {/* Position-based overlapping layout */}
                <div className={styles.overlapLayout}>
                  <h4>Overlapping Content with Position</h4>
                  <div className={styles.overlapContainer}>
                    <img 
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                      alt="Background" 
                      className={styles.overlapImage}
                    />
                    <div className={styles.overlapTextBox}>
                      <p className={styles.overlapText}>
                        Using position relative and absolute, we can create sophisticated overlapping layouts. This text box overlaps the image, creating depth and visual interest. This technique is useful for hero sections, feature highlights, and creating engaging visual hierarchies.
                      </p>
                    </div>
                  </div>
                </div>

                {/* Vertical centered layout */}
                <div className={styles.centeredLayout}>
                  <h4>Centered Image and Text</h4>
                  <div className={styles.centeredContainer}>
                    <img 
                      src="https://uxwing.com/wp-content/themes/uxwing/download/brands-and-social-media/w3c-icon.png" 
                      alt="Centered" 
                      className={styles.centeredImage}
                    />
                    <p className={styles.centeredText}>
                      This vertical layout centers both image and text using flexbox with column direction. Perfect for feature highlights, testimonials, or any content that benefits from centered presentation. The layout maintains its center alignment across different screen sizes.
                    </p>
                  </div>
                </div>
              </div>
            </div>

            {/* Text Alignment and Formatting */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Text Alignment and Formatting</div>
              <div className={styles.itemDesc}>Different text alignments and formatting options</div>
              <div className={styles.textContainer}>
                <div className={styles.alignmentSection}>
                  <p className={styles.textLeft}>Left-aligned text (default)</p>
                  <p className={styles.textCenter}>Center-aligned text</p>
                  <p className={styles.textRight}>Right-aligned text</p>
                  <p className={styles.textJustify}>
                    Justified text stretches across the full width of the container by adjusting the spacing between words. This creates clean, aligned edges on both sides of the text block, which can be useful for formal documents or newspaper-style layouts.
                  </p>
                </div>
              </div>
            </div>

            {/* Line Height and Spacing */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Line Height and Spacing</div>
              <div className={styles.itemDesc}>Demonstrating different line heights and text spacing</div>
              <div className={styles.textContainer}>
                <div className={styles.spacingSection}>
                  <p className={styles.tightSpacing}>
                    Tight line spacing example. This text has reduced line height, making the lines closer together. This can be useful for compact layouts or when space is limited.
                  </p>
                  
                  <p className={styles.normalSpacing}>
                    Normal line spacing example. This represents the default line height that provides good readability for most content types.
                  </p>
                  
                  <p className={styles.looseSpacing}>
                    Loose line spacing example. This text has increased line height, making it more airy and easier to read, especially for longer paragraphs or when enhanced readability is important.
                  </p>
                </div>
              </div>
            </div>

            {/* Word Break and Overflow */}
            <div className={styles.componentItem}>
              <div className={styles.itemLabel}>Word Break and Text Overflow</div>
              <div className={styles.itemDesc}>Handling long words and text overflow scenarios</div>
              <div className={styles.textContainer}>
                <div className={styles.overflowSection}>
                  <div className={styles.overflowBox}>
                    <p className={styles.normalBreak}>
                      Normal text with regular word breaking behavior. This text will wrap at word boundaries.
                    </p>
                  </div>
                  
                  <div className={styles.overflowBox}>
                    <p className={styles.breakAll}>
                      Thisislongwordbreakallexamplewhereeverythingbreaksatanycharactertopreventoverflow.
                    </p>
                  </div>
                  
                  <div className={styles.overflowBox}>
                    <p className={styles.ellipsisText}>
                      This is a very long text that demonstrates text overflow with ellipsis. The text will be truncated and show dots when it exceeds the container width.
                    </p>
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