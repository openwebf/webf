import React, { useEffect, useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const DOMDatasetPage: React.FC = () => {
  const elRef = useRef<HTMLDivElement>(null);
  const [role, setRole] = useState('admin');
  const [tag, setTag] = useState('demo');
  const [datasetView, setDatasetView] = useState<Record<string, string>>({});

  useEffect(() => {
    const el = elRef.current!;
    el.dataset.role = role;
    el.dataset.tag = tag;
    setDatasetView({ ...el.dataset } as any);
  }, [role, tag]);

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">dataset (data-*)</h1>
          <div className="bg-surface-secondary border border-line rounded-xl p-4">
            <div ref={elRef} className="p-2 border border-dashed border-line rounded bg-surface" data-user-id="42">
              Target element with data attributes
            </div>
            <div className="flex gap-2 flex-wrap items-center mt-2">
              <input className="rounded border border-line px-3 py-2 bg-surface" value={role} onChange={(e) => setRole(e.target.value)} placeholder="role" />
              <input className="rounded border border-line px-3 py-2 bg-surface" value={tag} onChange={(e) => setTag(e.target.value)} placeholder="tag" />
            </div>
            <div className="font-mono text-sm mt-2">
              dataset: {JSON.stringify(datasetView)}
            </div>
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
