import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMInnerHTMLPage: React.FC = () => {
  const [input, setInput] = useState('<b>Hello</b> & <i>World</i>');
  const textRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (textRef.current) {
      textRef.current.textContent = input;
    }
  }, [input]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">innerHTML vs textContent</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <input className="w-full rounded border border-line px-3 py-2 bg-surface" value={input} onChange={(e) => setInput(e.target.value)} />
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 mt-2">
              <div className="border border-line rounded bg-surface p-2">
                <div className="font-semibold mb-1">innerHTML</div>
                <div dangerouslySetInnerHTML={{ __html: input }} />
              </div>
              <div className="border border-line rounded bg-surface p-2">
                <div className="font-semibold mb-1">textContent</div>
                <div ref={textRef} />
              </div>
            </div>
          </div>
      </WebFListView>
    </div>
  );
};
