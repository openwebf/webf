import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

const SectionTitle: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <h2 className="text-lg font-bold text-gray-800 mt-4 mb-2 px-1">{children}</h2>
);

const Card: React.FC<{ children: React.ReactNode; className?: string }> = ({ children, className = '' }) => (
  <div className={`bg-white rounded-xl border border-gray-200 shadow-sm p-4 flex flex-col gap-4 ${className}`}>
    {children}
  </div>
);

const Label: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <span className="text-xs font-mono bg-gray-100 text-gray-600 px-2 py-1 rounded border border-gray-200 inline-block">
    {children}
  </span>
);

const Cell: React.FC<{ children: React.ReactNode; className?: string; style?: React.CSSProperties }> = ({ children, className = '', style }) => (
  <div className={`flex items-center justify-center rounded-lg text-sm font-semibold p-3 ${className}`} style={style}>
    {children}
  </div>
);

export const GridLayoutPage: React.FC = () => {
  return (
    <div className="w-full h-full bg-gray-50">
      <WebFListView className="p-5 flex flex-col gap-6 w-full box-border pb-20">

        {/* Hero */}
        <div className="grid grid-cols-3 grid-rows-3 gap-3 p-5 rounded-2xl" style={{ background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}>
          <div className="col-span-3 bg-white/90 rounded-xl p-4 text-center text-xl font-extrabold text-indigo-700">
            CSS Grid Layout
          </div>
          <div className="bg-white/85 rounded-xl p-3 text-center font-semibold text-purple-700">Sidebar</div>
          <div className="bg-white/95 rounded-xl p-4 text-sm text-gray-700">
            CSS Grid is a two-dimensional layout system that handles both columns and rows. It is ideal for building complex page layouts with precise control.
          </div>
          <div className="bg-white/85 rounded-xl p-3 text-center font-semibold text-purple-700">Aside</div>
          <div className="col-span-3 bg-white/85 rounded-xl p-3 text-center font-semibold text-purple-700">Footer</div>
        </div>

        {/* 1. Basic Grid */}
        <div className="flex flex-col gap-2">
          <SectionTitle>1. Basic Grid (grid-cols)</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Equal-width columns using <code>grid-cols-3</code>.</p>
            <div className="grid grid-cols-3 gap-3">
              <Cell className="bg-blue-100 border border-blue-300 text-blue-800">1</Cell>
              <Cell className="bg-blue-100 border border-blue-300 text-blue-800">2</Cell>
              <Cell className="bg-blue-100 border border-blue-300 text-blue-800">3</Cell>
              <Cell className="bg-amber-100 border border-amber-300 text-amber-800">4</Cell>
              <Cell className="bg-amber-100 border border-amber-300 text-amber-800">5</Cell>
              <Cell className="bg-amber-100 border border-amber-300 text-amber-800">6</Cell>
            </div>
            <Label>grid grid-cols-3 gap-3</Label>
          </Card>
        </div>

        {/* 2. Column Spanning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>2. Column Spanning</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Items spanning multiple columns with <code>col-span-*</code>.</p>
            <div className="grid grid-cols-4 gap-3">
              <Cell className="col-span-4 bg-indigo-500 text-white">col-span-4 (full width)</Cell>
              <Cell className="col-span-2 bg-indigo-400 text-white">col-span-2</Cell>
              <Cell className="col-span-2 bg-purple-400 text-white">col-span-2</Cell>
              <Cell className="col-span-1 bg-blue-200 text-blue-800">1</Cell>
              <Cell className="col-span-2 bg-pink-400 text-white">col-span-2</Cell>
              <Cell className="col-span-1 bg-blue-200 text-blue-800">1</Cell>
              <Cell className="col-span-3 bg-emerald-400 text-white">col-span-3</Cell>
              <Cell className="col-span-1 bg-blue-200 text-blue-800">1</Cell>
            </div>
            <Label>grid grid-cols-4 + col-span-*</Label>
          </Card>
        </div>

        {/* 3. Row Spanning */}
        <div className="flex flex-col gap-2">
          <SectionTitle>3. Row Spanning</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Items spanning multiple rows with <code>row-span-*</code>.</p>
            <div className="grid grid-cols-3 grid-rows-3 gap-3" style={{ height: 220 }}>
              <Cell className="row-span-3 bg-violet-500 text-white">row-span-3</Cell>
              <Cell className="col-span-2 bg-sky-200 text-sky-800">A</Cell>
              <Cell className="row-span-2 bg-rose-400 text-white">row-span-2</Cell>
              <Cell className="bg-amber-200 text-amber-800">B</Cell>
              <Cell className="col-span-2 bg-emerald-200 text-emerald-800">C</Cell>
            </div>
            <Label>grid grid-cols-3 grid-rows-3 + row-span-*</Label>
          </Card>
        </div>

        {/* 4. Gap Variants */}
        <div className="flex flex-col gap-2">
          <SectionTitle>4. Gap Variants</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-1">Uniform gap with <code>gap-4</code>:</p>
            <div className="grid grid-cols-4 gap-4">
              {[1,2,3,4].map(i => (
                <Cell key={i} className="bg-teal-100 border border-teal-300 text-teal-800">{i}</Cell>
              ))}
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1">Different row/column gaps with <code>gap-x-2 gap-y-6</code>:</p>
            <div className="grid grid-cols-4 gap-x-2 gap-y-6">
              {[1,2,3,4,5,6,7,8].map(i => (
                <Cell key={i} className="bg-orange-100 border border-orange-300 text-orange-800">{i}</Cell>
              ))}
            </div>
            <Label>gap-4 / gap-x-2 gap-y-6</Label>
          </Card>
        </div>

        {/* 5. Explicit Start/End */}
        <div className="flex flex-col gap-2">
          <SectionTitle>5. Explicit Start / End</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Place items at exact grid positions using <code>col-start-*</code> and <code>col-end-*</code>.</p>
            <div className="grid grid-cols-6 gap-2">
              <Cell className="col-start-1 col-end-3 bg-blue-400 text-white">col 1–2</Cell>
              <Cell className="col-start-3 col-end-7 bg-pink-400 text-white">col 3–6</Cell>
              <Cell className="col-start-1 col-end-4 bg-emerald-400 text-white">col 1–3</Cell>
              <Cell className="col-start-4 col-end-5 bg-amber-300 text-amber-800">4</Cell>
              <Cell className="col-start-5 col-end-7 bg-violet-400 text-white">col 5–6</Cell>
              <Cell className="col-start-2 col-end-6 bg-cyan-400 text-white">col 2–5</Cell>
            </div>
            <Label>col-start-* col-end-*</Label>
          </Card>
        </div>

        {/* 6. Named Grid Areas */}
        <div className="flex flex-col gap-2">
          <SectionTitle>6. Named Grid Areas</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Classic page layout using <code>grid-template-areas</code>.</p>
            <div
              className="grid gap-2"
              style={{
                gridTemplateAreas: `"header header header" "nav content sidebar" "footer footer footer"`,
                gridTemplateColumns: '140px 1fr 110px',
                gridTemplateRows: '50px 1fr 40px',
                height: 260,
              }}
            >
              <Cell className="bg-blue-500 text-white font-bold" style={{ gridArea: 'header' }}>Header</Cell>
              <Cell className="bg-purple-500 text-white" style={{ gridArea: 'nav' }}>Nav</Cell>
              <Cell className="bg-sky-50 border border-sky-200 text-sky-700" style={{ gridArea: 'content' }}>Content</Cell>
              <Cell className="bg-pink-500 text-white" style={{ gridArea: 'sidebar' }}>Sidebar</Cell>
              <Cell className="bg-emerald-500 text-white font-bold" style={{ gridArea: 'footer' }}>Footer</Cell>
            </div>
            <Label>grid-template-areas</Label>
          </Card>
        </div>

        {/* 7. Auto Flow */}
        <div className="flex flex-col gap-2">
          <SectionTitle>7. Grid Auto Flow</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-1"><code>grid-flow-row</code> (default):</p>
            <div className="grid grid-cols-3 grid-flow-row gap-2">
              {['A','B','C','D','E'].map(c => (
                <Cell key={c} className="bg-blue-100 border border-blue-300 text-blue-800">{c}</Cell>
              ))}
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1"><code>grid-flow-col</code> with 2 rows:</p>
            <div className="grid grid-rows-2 grid-flow-col gap-2">
              {['A','B','C','D','E'].map(c => (
                <Cell key={c} className="bg-rose-100 border border-rose-300 text-rose-800">{c}</Cell>
              ))}
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1"><code>grid-flow-row-dense</code> (fills gaps):</p>
            <div className="grid grid-cols-3 grid-flow-row-dense gap-2">
              <Cell className="col-span-2 bg-indigo-400 text-white">col-span-2</Cell>
              <Cell className="bg-amber-200 text-amber-800">B</Cell>
              <Cell className="col-span-2 bg-indigo-400 text-white">col-span-2</Cell>
              <Cell className="bg-emerald-200 text-emerald-800">D</Cell>
              <Cell className="bg-cyan-200 text-cyan-800">E</Cell>
            </div>
            <Label>grid-flow-row / grid-flow-col / grid-flow-row-dense</Label>
          </Card>
        </div>

        {/* 8. Auto Columns / Auto Rows */}
        <div className="flex flex-col gap-2">
          <SectionTitle>8. Auto Columns & Auto Rows</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-1"><code>auto-rows-min</code> — rows shrink to content:</p>
            <div className="grid grid-cols-3 auto-rows-min gap-2">
              <Cell className="bg-teal-100 border border-teal-300 text-teal-800">Short</Cell>
              <Cell className="bg-teal-100 border border-teal-300 text-teal-800 p-6">Taller content with more padding</Cell>
              <Cell className="bg-teal-100 border border-teal-300 text-teal-800">Short</Cell>
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1"><code>auto-rows-fr</code> — rows expand equally:</p>
            <div className="grid grid-cols-3 auto-rows-fr gap-2" style={{ height: 160 }}>
              <Cell className="bg-violet-100 border border-violet-300 text-violet-800">1</Cell>
              <Cell className="bg-violet-100 border border-violet-300 text-violet-800">2</Cell>
              <Cell className="bg-violet-100 border border-violet-300 text-violet-800">3</Cell>
              <Cell className="bg-violet-100 border border-violet-300 text-violet-800">4</Cell>
              <Cell className="bg-violet-100 border border-violet-300 text-violet-800">5</Cell>
            </div>
            <Label>auto-rows-min / auto-rows-fr</Label>
          </Card>
        </div>

        {/* 9. Alignment — place-items */}
        <div className="flex flex-col gap-2">
          <SectionTitle>9. Place Items (Align + Justify)</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-1"><code>place-items-center</code>:</p>
            <div className="grid grid-cols-3 place-items-center gap-3 bg-gray-100 rounded-lg p-3" style={{ height: 120 }}>
              <Cell className="bg-blue-400 text-white w-16 h-10">A</Cell>
              <Cell className="bg-pink-400 text-white w-16 h-10">B</Cell>
              <Cell className="bg-emerald-400 text-white w-16 h-10">C</Cell>
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1"><code>place-items-start</code>:</p>
            <div className="grid grid-cols-3 place-items-start gap-3 bg-gray-100 rounded-lg p-3" style={{ height: 120 }}>
              <Cell className="bg-blue-400 text-white w-16 h-10">A</Cell>
              <Cell className="bg-pink-400 text-white w-16 h-10">B</Cell>
              <Cell className="bg-emerald-400 text-white w-16 h-10">C</Cell>
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1"><code>place-items-end</code>:</p>
            <div className="grid grid-cols-3 place-items-end gap-3 bg-gray-100 rounded-lg p-3" style={{ height: 120 }}>
              <Cell className="bg-blue-400 text-white w-16 h-10">A</Cell>
              <Cell className="bg-pink-400 text-white w-16 h-10">B</Cell>
              <Cell className="bg-emerald-400 text-white w-16 h-10">C</Cell>
            </div>
            <Label>place-items-center / start / end</Label>
          </Card>
        </div>

        {/* 10. Place Content */}
        <div className="flex flex-col gap-2">
          <SectionTitle>10. Place Content</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600 mb-1"><code>place-content-center</code> — centers the whole grid:</p>
            <div className="grid grid-cols-2 place-content-center gap-3 bg-gray-100 rounded-lg" style={{ height: 180 }}>
              <Cell className="bg-indigo-400 text-white w-20 h-12">1</Cell>
              <Cell className="bg-indigo-400 text-white w-20 h-12">2</Cell>
              <Cell className="bg-indigo-400 text-white w-20 h-12">3</Cell>
              <Cell className="bg-indigo-400 text-white w-20 h-12">4</Cell>
            </div>
            <p className="text-sm text-gray-600 mt-3 mb-1"><code>place-content-between</code>:</p>
            <div className="grid grid-cols-2 place-content-between gap-3 bg-gray-100 rounded-lg" style={{ height: 180 }}>
              <Cell className="bg-rose-400 text-white w-20 h-12">1</Cell>
              <Cell className="bg-rose-400 text-white w-20 h-12">2</Cell>
              <Cell className="bg-rose-400 text-white w-20 h-12">3</Cell>
              <Cell className="bg-rose-400 text-white w-20 h-12">4</Cell>
            </div>
            <Label>place-content-center / between</Label>
          </Card>
        </div>

        {/* 11. Place Self */}
        <div className="flex flex-col gap-2">
          <SectionTitle>11. Place Self (Per-Item Alignment)</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Override alignment on individual items with <code>place-self-*</code>.</p>
            <div className="grid grid-cols-3 gap-3 bg-gray-100 rounded-lg p-3" style={{ height: 160 }}>
              <Cell className="place-self-start bg-blue-400 text-white w-16 h-10">start</Cell>
              <Cell className="place-self-center bg-pink-400 text-white w-16 h-10">center</Cell>
              <Cell className="place-self-end bg-emerald-400 text-white w-16 h-10">end</Cell>
              <Cell className="place-self-stretch bg-amber-300 text-amber-800">stretch</Cell>
              <Cell className="justify-self-end self-start bg-violet-400 text-white w-16 h-10">j-end s-start</Cell>
              <Cell className="justify-self-start self-end bg-cyan-400 text-white w-16 h-10">j-start s-end</Cell>
            </div>
            <Label>place-self-start / center / end / stretch</Label>
          </Card>
        </div>

        {/* 12. Responsive Grid */}
        <div className="flex flex-col gap-2">
          <SectionTitle>12. Responsive Grid</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Columns change at breakpoints: <code>grid-cols-2 md:grid-cols-4</code>.</p>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
              {[1,2,3,4,5,6,7,8].map(i => (
                <Cell key={i} className="bg-gradient-to-br from-blue-100 to-indigo-100 border border-indigo-200 text-indigo-700">
                  Item {i}
                </Cell>
              ))}
            </div>
            <Label>grid-cols-2 md:grid-cols-4</Label>
          </Card>
        </div>

        {/* 13. Auto-fill with minmax */}
        <div className="flex flex-col gap-2">
          <SectionTitle>13. Auto-Fill with minmax</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">
              Auto-fill creates as many columns as will fit. Uses <code>repeat(auto-fill, minmax(80px, 1fr))</code>.
            </p>
            <div className="grid gap-3" style={{ gridTemplateColumns: 'repeat(auto-fill, minmax(80px, 1fr))' }}>
              {Array.from({ length: 10 }).map((_, i) => (
                <Cell key={i} className="bg-emerald-100 border border-emerald-300 text-emerald-800">{i + 1}</Cell>
              ))}
            </div>
            <Label>repeat(auto-fill, minmax(80px, 1fr))</Label>
          </Card>
        </div>

        {/* 14. Nested Grid */}
        <div className="flex flex-col gap-2">
          <SectionTitle>14. Nested Grids</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Grids inside grid cells for complex layouts.</p>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid grid-cols-2 gap-2 bg-blue-50 rounded-lg p-3 border border-blue-200">
                <Cell className="bg-blue-400 text-white">A1</Cell>
                <Cell className="bg-blue-300 text-white">A2</Cell>
                <Cell className="col-span-2 bg-blue-500 text-white">A3 (span 2)</Cell>
              </div>
              <div className="grid grid-rows-3 gap-2 bg-pink-50 rounded-lg p-3 border border-pink-200">
                <Cell className="bg-pink-400 text-white">B1</Cell>
                <Cell className="bg-pink-300 text-white">B2</Cell>
                <Cell className="bg-pink-500 text-white">B3</Cell>
              </div>
            </div>
            <Label>Nested grid grid-cols-2 inside grid cells</Label>
          </Card>
        </div>

        {/* 15. Dashboard Layout */}
        <div className="flex flex-col gap-2">
          <SectionTitle>15. Dashboard Layout</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Real-world grid layout resembling a dashboard.</p>
            <div className="grid grid-cols-4 grid-rows-3 gap-3" style={{ height: 300 }}>
              <Cell className="col-span-4 bg-slate-800 text-white font-bold text-base">Dashboard Header</Cell>
              <Cell className="col-span-1 row-span-2 bg-slate-700 text-white flex-col gap-2">
                <div className="text-xs opacity-70">Menu</div>
                <div>Nav</div>
              </Cell>
              <Cell className="col-span-2 bg-blue-500 text-white flex-col">
                <div className="text-xs opacity-80">Revenue</div>
                <div className="text-lg font-bold">$12,450</div>
              </Cell>
              <Cell className="bg-emerald-500 text-white flex-col">
                <div className="text-xs opacity-80">Users</div>
                <div className="text-lg font-bold">1,234</div>
              </Cell>
              <Cell className="col-span-2 bg-amber-100 border border-amber-300 text-amber-800">Chart Area</Cell>
              <Cell className="bg-purple-100 border border-purple-300 text-purple-800">Activity</Cell>
            </div>
            <Label>grid-cols-4 grid-rows-3 + col-span + row-span</Label>
          </Card>
        </div>

        {/* 16. Photo Gallery */}
        <div className="flex flex-col gap-2">
          <SectionTitle>16. Photo Gallery Grid</SectionTitle>
          <Card>
            <p className="text-sm text-gray-600">Masonry-like gallery with span variations.</p>
            <div className="grid grid-cols-3 gap-2">
              <div className="col-span-2 row-span-2 bg-gradient-to-br from-sky-400 to-blue-500 rounded-lg flex items-center justify-center text-white font-bold text-lg" style={{ minHeight: 140 }}>Featured</div>
              <div className="bg-gradient-to-br from-pink-400 to-rose-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" style={{ minHeight: 65 }}>Photo 2</div>
              <div className="bg-gradient-to-br from-amber-400 to-orange-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" style={{ minHeight: 65 }}>Photo 3</div>
              <div className="bg-gradient-to-br from-emerald-400 to-green-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" style={{ minHeight: 65 }}>Photo 4</div>
              <div className="bg-gradient-to-br from-violet-400 to-purple-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" style={{ minHeight: 65 }}>Photo 5</div>
              <div className="col-span-1 row-span-1 bg-gradient-to-br from-cyan-400 to-teal-500 rounded-lg flex items-center justify-center text-white font-semibold p-3" style={{ minHeight: 65 }}>Photo 6</div>
            </div>
            <Label>col-span-2 row-span-2 for featured item</Label>
          </Card>
        </div>

      </WebFListView>
    </div>
  );
};