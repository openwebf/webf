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

const Badge: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <span className="px-2 py-1 bg-gray-100 border border-gray-200 rounded text-xs font-mono text-gray-600 w-fit">
    {children}
  </span>
);

export const SelectorsPage: React.FC = () => {
  return (
    <div className="w-full h-full bg-gray-50">
      <WebFListView className="p-5 flex flex-col gap-6 w-full box-border pb-20">
        
        {/* 1. User Action Pseudo-classes */}
        <div className="flex flex-col gap-2">
          <SectionTitle>1. User Actions</SectionTitle>
          <Card>
            <p className="text-sm text-gray-500">
              Interactive pseudo-classes in WebF are best demonstrated with direct target matches.
              Hover reacts on desktop mouse input, while focus-based states work across platforms.
            </p>
            <div className="grid grid-cols-2 gap-4">
              <button className="p-3 rounded bg-blue-500 text-white hover:bg-blue-700 hover:shadow-lg transition-all text-center">
                Hover Me
              </button>
              <button className="p-3 rounded bg-emerald-500 text-white active:bg-emerald-800 active:scale-95 transition-all text-center">
                Click (Active)
              </button>
              <input 
                type="text" 
                placeholder="Focus Me" 
                className="p-2 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent w-full"
              />
              <button className="p-3 rounded border border-amber-300 bg-amber-50 text-amber-900 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-amber-500 focus-visible:ring-offset-2 transition-all text-center">
                Keyboard Focus Ring
              </button>
            </div>
            <div className="rounded-xl border border-slate-200 bg-slate-50 p-4 focus-within:border-cyan-500 focus-within:bg-cyan-50 transition-colors">
              <div className="flex items-center justify-between gap-3 mb-3">
                <div>
                  <div className="font-semibold text-slate-800">Focus Within Container</div>
                  <div className="text-sm text-slate-500">Tab into the input to light up the parent card.</div>
                </div>
                <span className="text-xs rounded-full border border-cyan-200 bg-white px-2 py-1 text-cyan-700">
                  :focus-within
                </span>
              </div>
              <input
                type="text"
                placeholder="Focus inside this container"
                className="w-full rounded border border-slate-300 bg-white px-3 py-2 focus:outline-none focus:ring-2 focus:ring-cyan-500"
              />
            </div>
            <div className="rounded-lg border border-dashed border-gray-300 bg-white/80 p-3 text-xs text-gray-500">
              <strong>Note:</strong> <code>:hover</code> is shown only for direct target matches and desktop mouse input.
              Parent-chain hover demos were intentionally removed to keep the runtime impact small.
            </div>
            <div className="flex flex-wrap gap-2 mt-2">
              <Badge>:hover</Badge>
              <Badge>:active</Badge>
              <Badge>:focus</Badge>
              <Badge>:focus-visible</Badge>
              <Badge>:focus-within</Badge>
            </div>
          </Card>
        </div>

        {/* 2. Structural Pseudo-classes */}
        <div className="flex flex-col gap-2">
          <SectionTitle>2. Structural (First/Last/Nth)</SectionTitle>
          <Card>
            <p className="text-sm text-gray-500 mb-2">
              Items styled based on their position in the list.
            </p>
            <div className="flex flex-col gap-2">
              {[1, 2, 3, 4, 5].map((i) => (
                <div 
                  key={i} 
                  className="p-2 rounded border border-gray-200 
                    first:bg-indigo-100 first:text-indigo-700 first:border-indigo-200
                    last:bg-rose-100 last:text-rose-700 last:border-rose-200
                    even:bg-gray-50 
                    odd:bg-white"
                >
                  Item {i}
                  {i === 1 && <span className="float-right text-xs opacity-60">first-child</span>}
                  {i === 5 && <span className="float-right text-xs opacity-60">last-child</span>}
                  {i % 2 === 0 && i !== 5 && <span className="float-right text-xs opacity-60">even</span>}
                  {i % 2 !== 0 && i !== 1 && i !== 5 && <span className="float-right text-xs opacity-60">odd</span>}
                </div>
              ))}
            </div>
            <div className="flex flex-wrap gap-2 mt-2">
              <Badge>:first-child</Badge>
              <Badge>:last-child</Badge>
              <Badge>:nth-child(odd/even)</Badge>
            </div>
          </Card>
        </div>

        {/* 3. Attribute Selectors */}
        <div className="flex flex-col gap-2">
          <SectionTitle>3. Attribute Selectors</SectionTitle>
          <Card>
            <p className="text-sm text-gray-500 mb-2">
              Styling based on data attributes (often used for state).
            </p>
            <div className="flex gap-3">
              <div 
                className="flex-1 p-4 rounded text-center border transition-colors data-[status=success]:bg-green-100 data-[status=success]:text-green-800 data-[status=success]:border-green-200" 
                data-status="success"
              >
                Success
              </div>
              <div 
                className="flex-1 p-4 rounded text-center border transition-colors data-[status=error]:bg-red-100 data-[status=error]:text-red-800 data-[status=error]:border-red-200" 
                data-status="error"
              >
                Error
              </div>
              <div 
                className="flex-1 p-4 rounded text-center border transition-colors data-[active=true]:bg-blue-100 data-[active=true]:border-blue-300 data-[active=true]:font-bold" 
                data-active="true"
              >
                Active
              </div>
            </div>
            <div className="flex flex-wrap gap-2 mt-2">
              <Badge>[data-status="..."]</Badge>
              <Badge>[data-active="true"]</Badge>
            </div>
          </Card>
        </div>

        {/* 4. Sibling Combinators (Peer) */}
        <div className="flex flex-col gap-2">
          <SectionTitle>4. Sibling Combinators (Peer)</SectionTitle>
          <Card>
            <p className="text-sm text-gray-500 mb-2">
              Style an element based on the state of a previous sibling.
            </p>
            <div className="p-4 border border-gray-100 rounded-lg bg-gray-50">
              <label className="flex items-center gap-3 cursor-pointer">
                <input type="checkbox" className="peer sr-only" />
                <div className="w-6 h-6 border-2 border-gray-300 rounded bg-white peer-checked:bg-blue-500 peer-checked:border-blue-500 peer-focus:ring-2 peer-focus:ring-blue-200 transition-all flex items-center justify-center">
                  <span className="text-white opacity-0 peer-checked:opacity-100 text-sm">✓</span>
                </div>
                <span className="text-gray-500 peer-checked:text-blue-700 peer-checked:font-bold peer-checked:line-through decoration-blue-500/50 transition-all">
                  Check me to style siblings
                </span>
              </label>
              <div className="mt-3 p-2 text-sm text-gray-400 bg-gray-100 rounded hidden peer-checked:block peer-checked:bg-blue-50 peer-checked:text-blue-600">
                I am a general sibling that appears when checked!
              </div>
            </div>
            <div className="flex flex-wrap gap-2 mt-2">
              <Badge>input + label (Adjacent)</Badge>
              <Badge>input ~ div (General)</Badge>
            </div>
          </Card>
        </div>

        {/* 5. Direct Target Hover */}
        <div className="flex flex-col gap-2">
          <SectionTitle>5. Direct Target Hover</SectionTitle>
          <Card>
            <p className="text-sm text-gray-500 mb-2">
              This demo keeps the hovered element as the actual event target, so it works with WebF&apos;s target-only
              <code className="mx-1 rounded bg-gray-100 px-1 py-0.5">:hover</code>
              behavior.
            </p>
            <div className="rounded-lg border border-gray-200 bg-white p-5 text-gray-700 shadow-sm transition-all hover:-translate-y-0.5 hover:border-indigo-300 hover:bg-indigo-50 hover:text-indigo-800 hover:shadow-md">
              Hover this card on desktop. The styles are attached to this exact element, not a parent chain.
            </div>
            <div className="rounded-lg border border-dashed border-gray-300 bg-white/80 p-3 text-xs text-gray-500">
              <strong>Important:</strong> patterns like
              <code className="mx-1 rounded bg-gray-100 px-1 py-0.5">.group:hover .child</code>
              are intentionally not showcased here, because WebF no longer promotes hover state from a hovered child to its parent chain.
            </div>
            <div className="flex flex-wrap gap-2 mt-2">
              <Badge>div:hover</Badge>
              <Badge>target-only</Badge>
              <Badge>desktop-only</Badge>
            </div>
          </Card>
        </div>

        {/* 6. Pseudo-elements */}
        <div className="flex flex-col gap-2">
          <SectionTitle>6. Pseudo-elements</SectionTitle>
          <Card>
            <div className="flex flex-col gap-4">
              <div className="p-3 bg-slate-50 border border-slate-200 rounded relative">
                <p className="text-slate-600 first-letter:text-3xl first-letter:font-bold first-letter:text-slate-900 first-letter:mr-1 first-letter:float-left leading-relaxed">
                  This paragraph demonstrates the first-letter pseudo-element. It makes the first letter larger and bolder, like in a book or magazine.
                </p>
              </div>
              
              <ul className="list-none space-y-2">
                <li className="text-gray-600 before:content-['•'] before:text-blue-500 before:mr-2 before:font-bold">
                  List item using <code className="text-xs bg-gray-100 p-1 rounded">before:content-['•']</code>
                </li>
                <li className="text-gray-600 after:content-['→'] after:text-red-500 after:ml-2">
                  List item using <code className="text-xs bg-gray-100 p-1 rounded">after:content-['→']</code>
                </li>
              </ul>

              <input 
                type="text" 
                placeholder="Custom placeholder color" 
                className="p-2 border border-gray-300 rounded placeholder:text-pink-400 placeholder:italic w-full"
              />
            </div>
            <div className="flex flex-wrap gap-2 mt-2">
              <Badge>::first-letter</Badge>
              <Badge>::before</Badge>
              <Badge>::after</Badge>
              <Badge>::placeholder</Badge>
            </div>
          </Card>
        </div>

      </WebFListView>
    </div>
  );
};
