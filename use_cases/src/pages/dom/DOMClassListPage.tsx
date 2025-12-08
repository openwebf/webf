import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMClassListPage: React.FC = () => {
  const boxRef = useRef<HTMLDivElement>(null);
  const [classes, setClasses] = useState('');
  const [isRed, setIsRed] = useState(false);
  const [isRounded, setIsRounded] = useState(false);
  const [isActive, setIsActive] = useState(false);

  const sync = () => setClasses(boxRef.current?.className || '');
  const toggleRed = () => { setIsRed(v => !v); setTimeout(sync, 0); };
  const toggleRounded = () => { setIsRounded(v => !v); setTimeout(sync, 0); };
  const toggleActive = () => { setIsActive(v => !v); setTimeout(sync, 0); };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">DOMTokenList (classList)</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div
              ref={boxRef}
              className={`w-40 h-20 border border-line rounded flex items-center justify-center ${isRed ? 'bg-red-200' : ''} ${isRounded ? 'rounded-2xl' : ''} ${isActive ? 'ring-2 ring-sky-400' : ''}`}
            >
              target
            </div>
            <div className="flex gap-2 flex-wrap items-center mt-2">
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={toggleRed}>toggle red</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={toggleRounded}>toggle rounded</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={toggleActive}>toggle active</button>
            </div>
            <div className="font-mono text-sm mt-2">className: {classes}</div>
          </div>
      </WebFListView>
    </div>
  );
};
