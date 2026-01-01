<script setup lang="ts">
import styles from './FontFacePage.module.css';
</script>

<template>
  <div id="main">
    <webf-list-view :class="styles.list">
      <div :class="styles.componentSection">
        <div :class="styles.sectionTitle">Custom Font Face Showcase</div>
        <div :class="styles.componentBlock">
          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Google Fonts Integration</div>
            <div :class="styles.itemDesc">Examples of popular Google Fonts loaded via CSS @font-face</div>
            <div :class="styles.fontContainer">
              <div :class="styles.fontExample">
                <div :class="styles.fontName">Roboto</div>
                <div :class="[styles.fontSample, styles.roboto]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Sans-serif • Modern • Readable • Google Font</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">Open Sans</div>
                <div :class="[styles.fontSample, styles.openSans]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Sans-serif • Humanist • Friendly • Google Font</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">Lato</div>
                <div :class="[styles.fontSample, styles.lato]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Sans-serif • Contemporary • Warm • Google Font</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">Montserrat</div>
                <div :class="[styles.fontSample, styles.montserrat]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Sans-serif • Geometric • Urban • Google Font</div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Serif Font Families</div>
            <div :class="styles.itemDesc">Traditional serif fonts for formal and readable text</div>
            <div :class="styles.fontContainer">
              <div :class="styles.fontExample">
                <div :class="styles.fontName">Playfair Display</div>
                <div :class="[styles.fontSample, styles.playfairDisplay]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Serif • Elegant • High-contrast • Display font</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">Merriweather</div>
                <div :class="[styles.fontSample, styles.merriweather]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Serif • Readable • Screen-optimized • Text font</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">Crimson Text</div>
                <div :class="[styles.fontSample, styles.crimsonText]">The quick brown fox jumps over the lazy dog. 1234567890</div>
                <div :class="styles.fontDetails">Serif • Academic • Book-style • Reading font</div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Monospace Fonts</div>
            <div :class="styles.itemDesc">Fixed-width fonts perfect for code and technical content</div>
            <div :class="styles.fontContainer">
              <div :class="styles.fontExample">
                <div :class="styles.fontName">Fira Code</div>
                <div :class="[styles.fontSample, styles.firaCode]">const example = () =&gt; &#123; return 'Hello World'; &#125;</div>
                <div :class="styles.fontDetails">Monospace • Programming ligatures • Code font</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">Source Code Pro</div>
                <div :class="[styles.fontSample, styles.sourceCodePro]">function calculate(a, b) &#123; return a + b; &#125;</div>
                <div :class="styles.fontDetails">Monospace • Adobe • Clean • Developer-friendly</div>
              </div>

              <div :class="styles.fontExample">
                <div :class="styles.fontName">JetBrains Mono</div>
                <div :class="[styles.fontSample, styles.jetbrainsMono]">class Example &#123; constructor() &#123; this.value = 42; &#125; &#125;</div>
                <div :class="styles.fontDetails">Monospace • IDE-optimized • Modern • Developer font</div>
              </div>
            </div>
          </div>

          <div :class="styles.componentItem">
            <div :class="styles.itemLabel">Font Weight Variations</div>
            <div :class="styles.itemDesc">Different weights of the same font family</div>
            <div :class="styles.fontContainer">
              <div :class="styles.weightExample">
                <div :class="styles.fontName">Roboto Font Weights</div>
                <div :class="[styles.weightSample, styles.roboto, styles.weight100]">Thin (100): The quick brown fox jumps over the lazy dog</div>
                <div :class="[styles.weightSample, styles.roboto, styles.weight300]">Light (300): The quick brown fox jumps over the lazy dog</div>
                <div :class="[styles.weightSample, styles.roboto, styles.weight400]">Regular (400): The quick brown fox jumps over the lazy dog</div>
                <div :class="[styles.weightSample, styles.roboto, styles.weight500]">Medium (500): The quick brown fox jumps over the lazy dog</div>
                <div :class="[styles.weightSample, styles.roboto, styles.weight700]">Bold (700): The quick brown fox jumps over the lazy dog</div>
                <div :class="[styles.weightSample, styles.roboto, styles.weight900]">Black (900): The quick brown fox jumps over the lazy dog</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </webf-list-view>
  </div>
</template>
