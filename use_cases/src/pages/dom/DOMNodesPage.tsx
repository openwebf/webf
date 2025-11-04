import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMNodesPage: React.FC = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [counter, setCounter] = useState(1);
  const [queryCount, setQueryCount] = useState(0);

  const createNode = (label: string) => {
    const el = document.createElement('span');
    el.className = `node-item ${styles.nodeItem}`;
    el.textContent = label;
    return el;
  };

  const append = () => {
    containerRef.current?.appendChild(createNode(`Item ${counter}`));
    setCounter(c => c + 1);
  };
  const insertFirst = () => {
    const c = containerRef.current!;
    c.insertBefore(createNode('First'), c.firstChild);
  };
  const replaceFirst = () => {
    const c = containerRef.current!;
    if (c.firstChild) c.replaceChild(createNode('Replaced'), c.firstChild);
  };
  const removeLast = () => {
    const c = containerRef.current!;
    if (c.lastChild) c.removeChild(c.lastChild);
  };
  const cloneLast = () => {
    const c = containerRef.current!;
    if (c.lastElementChild) c.appendChild(c.lastElementChild.cloneNode(true));
  };
  const runQuery = () => {
    setQueryCount(containerRef.current?.querySelectorAll('.node-item').length || 0);
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Nodes: create/append/insert/replace/remove/clone</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div className="flex gap-2 flex-wrap mb-2">
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={append}>Append</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={insertFirst}>Insert First</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={replaceFirst}>Replace First</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={removeLast}>Remove Last</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={cloneLast}>Clone Last</button>
              <button className="px-3 py-2 rounded border border-line hover:bg-surface-hover" onClick={runQuery}>querySelectorAll('.node-item')</button>
            </div>
            <div ref={containerRef} className="min-h-20 p-2 border border-dashed border-line rounded bg-surface" />
            <div className="font-mono text-sm mt-2">query count: {queryCount}</div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
