import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DisplayFlowPage: React.FC = () => {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Display: block / inline / inline-block</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="flex gap-3 flex-wrap items-start">
              <div className="block w-40 p-2 bg-gray-200 border border-line rounded">block element</div>
              <span className="inline px-2 py-1 bg-emerald-100 border border-line rounded">inline element A</span>
              <span className="inline px-2 py-1 bg-emerald-100 border border-line rounded">inline element B</span>
              <div className="inline-block w-[120px] p-2 bg-amber-200 border border-line rounded">inline-block 120px</div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Other display values</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Common value beyond the basics: none (hidden).</div>
            {/* none */}
            <div className="border border-dashed border-line rounded p-3">
              <div className="flex items-center gap-2">
                <div className="px-2 py-1 rounded border border-line bg-rose-100">visible</div>
                <div className="hidden px-2 py-1 rounded border border-line bg-rose-100">hidden (display: none)</div>
                <div className="text-sm text-fg-secondary">The hidden box does not affect layout.</div>
              </div>
            </div>
          </div>

          {/*<h2 className="text-lg font-medium text-fg-primary mb-2">More display values</h2>*/}
          {/*<div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">*/}
          {/*  <div className="text-sm text-fg-secondary mb-3">Modern display values for layout and formatting contexts.</div>*/}
          {/*  <div className="space-y-3">*/}
          {/*    <div className="border border-dashed border-line rounded p-3">*/}
          {/*      <div className="text-xs text-fg-secondary mb-2">display: table / table-row / table-cell</div>*/}
          {/*      <div className="table w-full border-collapse">*/}
          {/*        <div className="table-row">*/}
          {/*          <div className="table-cell bg-green-200 border border-line p-2">Cell A</div>*/}
          {/*          <div className="table-cell bg-green-200 border border-line p-2">Cell B</div>*/}
          {/*          <div className="table-cell bg-green-200 border border-line p-2">Cell C</div>*/}
          {/*        </div>*/}
          {/*      </div>*/}
          {/*    </div>*/}

          {/*    <div className="border border-dashed border-line rounded p-3">*/}
          {/*      <div className="text-xs text-fg-secondary mb-2">display: contents (box removed, children remain)</div>*/}
          {/*      <div className="flex gap-2 border-2 border-pink-400 rounded p-2">*/}
          {/*        <div className="contents">*/}
          {/*          <div className="bg-pink-200 border border-line rounded p-2">Child 1</div>*/}
          {/*          <div className="bg-pink-200 border border-line rounded p-2">Child 2</div>*/}
          {/*        </div>*/}
          {/*        <div className="bg-pink-300 border border-line rounded p-2">Sibling</div>*/}
          {/*      </div>*/}
          {/*      <div className="text-xs text-fg-secondary mt-1">The contents wrapper has no box; children become siblings</div>*/}
          {/*    </div>*/}
          {/*  </div>*/}
          {/*</div>*/}

          <h2 className="text-lg font-medium text-fg-primary mb-2">Margin collapsing</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Adjacent vertical margins collapse into a single margin. Adding padding/border or creating a BFC prevents collapse.</div>
            <div className="grid md:grid-cols-2 gap-4">
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-sm text-fg-secondary">Siblings with collapsing margins</div>
                <div className="bg-amber-100 border border-line rounded mt-4 mb-6 p-2">A (mt-4, mb-6)</div>
                <div className="bg-amber-100 border border-line rounded mt-6 p-2">B (mt-6)</div>
                <div className="text-xs text-fg-secondary mt-2">mt-6 and mb-6 between A/B collapse to 6</div>
              </div>
              <div className="border border-dashed border-line rounded p-2">
                <div className="text-sm text-fg-secondary">Prevented by padding on parent</div>
                <div className="p-1 border border-line rounded">
                  <div className="bg-emerald-100 border border-line rounded mt-4 mb-6 p-2">A (mt-4, mb-6)</div>
                  <div className="bg-emerald-100 border border-line rounded mt-6 p-2">B (mt-6)</div>
                </div>
                <div className="text-xs text-fg-secondary mt-2">Padding creates separation; margins no longer collapse</div>
              </div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Normal flow stacking</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">In normal flow, block elements stack vertically and inline elements flow horizontally.</div>
            <div className="border border-dashed border-line rounded p-3">
              <div className="block bg-blue-200 border border-blue-400 rounded p-2 mb-2">Block 1</div>
              <div className="block bg-blue-200 border border-blue-400 rounded p-2 mb-2">Block 2</div>
              <div className="bg-green-100 border border-green-400 rounded p-2">
                <span className="inline-block bg-green-300 border border-green-500 rounded px-2 py-1 mr-1">Inline 1</span>
                <span className="inline-block bg-green-300 border border-green-500 rounded px-2 py-1 mr-1">Inline 2</span>
                <span className="inline-block bg-green-300 border border-green-500 rounded px-2 py-1">Inline 3</span>
              </div>
            </div>
          </div>

          <h2 className="text-lg font-medium text-fg-primary mb-2">Width and height behavior</h2>
          <div className="bg-surface-secondary border border-line rounded-xl p-4 mb-6">
            <div className="text-sm text-fg-secondary mb-3">Block elements take full width by default; inline elements size to content.</div>
            <div className="space-y-3">
              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">Block: auto width (fills container)</div>
                <div className="block bg-purple-200 border border-purple-400 rounded p-2">Block element</div>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">Inline: width/height ignored</div>
                <span className="inline bg-pink-200 border border-pink-400 rounded p-2" style={{ width: '200px', height: '100px' }}>
                  Inline (width/height don't apply)
                </span>
              </div>

              <div className="border border-dashed border-line rounded p-3">
                <div className="text-xs text-fg-secondary mb-2">Inline-block: width/height respected</div>
                <span className="inline-block bg-orange-200 border border-orange-400 rounded p-2" style={{ width: '200px', height: '60px' }}>
                  Inline-block 200×60
                </span>
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
