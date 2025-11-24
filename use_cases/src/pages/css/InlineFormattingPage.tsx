import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const InlineFormattingPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Baseline alignment</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Inline boxes of different font sizes align on their text baselines.</div>
            <div className="flex items-baseline gap-3 border-b border-dashed border-line pb-3">
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 12 }}>12px</span>
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 16 }}>16px</span>
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 24 }}>24px</span>
              <span className="inline-block px-2 py-1 bg-purple-200 border border-line rounded" style={{ fontSize: 32 }}>32px</span>
              <span className="text-[20px] leading-none text-fg-secondary">Aa</span>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Line-height and inline formatting context</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Compare <code>line-height</code> values: unitless scales with font-size; fixed units create fixed line boxes.</div>
            <div className="grid md:grid-cols-3 gap-3">
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-xs text-fg-secondary mb-2">line-height: normal</div>
                <p className="bg-amber-100 p-2 rounded">
                  The quick brown fox<br/>jumps over the lazy dog.
                </p>
              </div>
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-xs text-fg-secondary mb-2">line-height: 1.2 (unitless)</div>
                <p className="leading-[1.2] bg-amber-100 p-2 rounded">
                  The quick brown fox<br/>jumps over the lazy dog.
                </p>
              </div>
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-xs text-fg-secondary mb-2">line-height: 32px</div>
                <p className="leading-[32px] bg-amber-100 p-2 rounded">
                  The quick brown fox<br/>jumps over the lazy dog.
                </p>
              </div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">vertical-align</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Displayed in a true inline formatting context. The green squares are inline-blocks aligned relative to the text.</div>
            <div className="space-y-1">
              <p className="text-[18px] leading-8">
                Aa
                <span className="inline-block align-baseline w-8 h-8 bg-emerald-300 mx-2" />
                <span className="text-sm text-fg-secondary">baseline</span>
              </p>
              <p className="text-[18px] leading-8">
                Aa
                <span className="inline-block align-top w-8 h-8 bg-emerald-300 mx-2" />
                <span className="text-sm text-fg-secondary">top</span>
              </p>
              <p className="text-[18px] leading-8">
                Aa
                <span className="inline-block align-middle w-8 h-8 bg-emerald-300 mx-2" />
                <span className="text-sm text-fg-secondary">middle</span>
              </p>
              <p className="text-[18px] leading-8">
                Aa
                <span className="inline-block align-bottom w-8 h-8 bg-emerald-300 mx-2" />
                <span className="text-sm text-fg-secondary">bottom</span>
              </p>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Superscripts and subscripts</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">HTML <code>&lt;sup&gt;</code>/<code>&lt;sub&gt;</code> adjust baseline; CSS <code>vertical-align: super/sub</code> mimics it.</div>
            <p className="text-[16px]">
              Water is H<sup>2</sup>O, and angles are 90<sup>°</sup>.
            </p>
            <p className="text-[16px] mt-2">
              E = mc<span className="align-[super] text-[12px]">2</span> using CSS super;
              X<span className="align-[sub] text-[12px]">i</span> for subscript.
            </p>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Inline-block baseline vs top</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">By default, inline-blocks align their baseline with text. Use <code>vertical-align: top</code> to align their top edges.</div>
            <div className="border border-dashed border-line rounded p-3">
              <div className="text-xs text-fg-secondary mb-2">baseline (default)</div>
              <div className="text-[18px] text-fg-secondary">Aa
                <div className="inline-block align-baseline w-10 h-6 bg-sky-200 mx-2" />
                <div className="inline-block align-baseline w-10 h-10 bg-sky-300 mx-2" />
                <div className="inline-block align-baseline w-10 h-14 bg-sky-400 mx-2" />
              </div>
              <div className="text-xs text-fg-secondary mt-3 mb-2">top</div>
              <div className="text-[18px] text-fg-secondary">Aa
                <div className="inline-block align-top w-10 h-6 bg-emerald-200 mx-2" />
                <div className="inline-block align-top w-10 h-10 bg-emerald-300 mx-2" />
                <div className="inline-block align-top w-10 h-14 bg-emerald-400 mx-2" />
              </div>
            </div>
          </div>

          {/*<h2 className="text-lg font-medium text-fg-primary mb-2">Images as inline (replaced) elements</h2>*/}
          {/*<div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">*/}
          {/*  <div className="text-sm text-fg-secondary mb-3">Images sit on the baseline and leave a small descender gap. Align bottom or make them block to remove the gap.</div>*/}
          {/*  <div className="space-y-2">*/}
          {/*    <div className="border border-dashed border-line rounded p-2">*/}
          {/*      <div className="text-xs text-fg-secondary mb-1">default (baseline)</div>*/}
          {/*      <span className="text-[18px]">Text*/}
          {/*        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCI+PHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiBmaWxsPSIjNjRCNUY2Ii8+PC9zdmc+" alt="img" className="inline h-6 w-6 mx-2"/>*/}
          {/*        after*/}
          {/*      </span>*/}
          {/*    </div>*/}
          {/*    <div className="border border-dashed border-line rounded p-2">*/}
          {/*      <div className="text-xs text-fg-secondary mb-1">align-bottom</div>*/}
          {/*      <span className="text-[18px]">Text*/}
          {/*        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCI+PHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiBmaWxsPSIjRTU3MzczIi8+PC9zdmc+" alt="img" className="inline h-6 w-6 mx-2 align-bottom"/>*/}
          {/*        after*/}
          {/*      </span>*/}
          {/*    </div>*/}
          {/*    <div className="border border-dashed border-line rounded p-2">*/}
          {/*      <div className="text-xs text-fg-secondary mb-1">block image</div>*/}
          {/*      <div className="flex items-center gap-2">*/}
          {/*        <span className="text-[18px]">Above</span>*/}
          {/*        <img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCI+PHJlY3Qgd2lkdGg9IjI0IiBoZWlnaHQ9IjI0IiBmaWxsPSIjODFDNzg0Ii8+PC9zdmc+" alt="img" className="block h-6 w-6"/>*/}
          {/*        <span className="text-[18px]">Below</span>*/}
          {/*      </div>*/}
          {/*    </div>*/}
          {/*  </div>*/}
          {/*</div>*/}

          <h2 className="text-lg font-medium text-fg-primary mb-2">RTL (Right-to-Left) Text Direction</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Text direction affects inline flow, alignment, and ordering. Use <code>dir="rtl"</code> or <code>direction: rtl</code>.</div>

            <div className="space-y-4">
              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">LTR (Left-to-Right) - Default</div>
                <p className="text-[16px] bg-blue-50 p-2 rounded" dir="ltr">
                  This is English text flowing from left to right.
                </p>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">RTL (Right-to-Left) - Arabic/Hebrew</div>
                <p className="text-[16px] bg-blue-50 p-2 rounded" dir="rtl">
                  هذا نص عربي يتدفق من اليمين إلى اليسار
                </p>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">Mixed Bidirectional Text (Bidi)</div>
                <p className="text-[16px] bg-blue-50 p-2 rounded" dir="rtl">
                  This is English mixed with عربي (Arabic) and numbers 123.
                </p>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">RTL with Inline Elements</div>
                <p className="text-[16px] bg-blue-50 p-2 rounded" dir="rtl">
                  <span className="bg-yellow-200 px-1">مرحبا</span> بك في
                  <strong className="text-blue-600">WebF</strong> و
                  <span className="bg-green-200 px-1">اختبار RTL</span>
                </p>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">Text Alignment in RTL</div>
                <div className="space-y-2">
                  <p className="text-[14px] bg-purple-50 p-2 rounded text-right" dir="rtl">
                    النص العربي - text-align: right (explicit)
                  </p>
                  <p className="text-[14px] bg-purple-50 p-2 rounded text-left" dir="rtl">
                    النص العربي - text-align: left (overrides RTL default)
                  </p>
                  <p className="text-[14px] bg-purple-50 p-2 rounded text-center" dir="rtl">
                    النص العربي - text-align: center
                  </p>
                </div>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">Inline-block Elements in RTL</div>
                <div className="text-[16px] bg-blue-50 p-2 rounded" dir="rtl">
                  <span className="inline-block w-8 h-8 bg-red-300 mx-1" />
                  <span className="inline-block w-8 h-8 bg-green-300 mx-1" />
                  <span className="inline-block w-8 h-8 bg-blue-300 mx-1" />
                  مربعات ملونة
                </div>
              </div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Line boxes and background highlight</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Line boxes stack to form a paragraph box. Background fills the content area for each line.</div>
            <p className="text-[16px] leading-[2]">
              <span className="bg-yellow-200">Inline</span> content
              <span className="bg-yellow-200">wraps</span> across
              <span className="bg-yellow-200">lines</span> and aligns
              <span className="bg-yellow-200">on</span> the baseline.
            </p>
          </div>
      </WebFListView>
    </div>
  );
};
