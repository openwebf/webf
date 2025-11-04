import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export const TransformsPage: React.FC = () => {
  const Box = (props: { style: React.CSSProperties; label: string }) => (
    <div>
      <div className="w-30 h-30 w-[120px] h-[120px] flex items-center justify-center bg-gray-200 rounded border border-line" style={props.style}>Box</div>
      <div className="mt-2 text-sm text-fg-secondary text-center">{props.label}</div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6">
        <div className="max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Transforms</h1>
          <div className="flex gap-3 flex-wrap">
            <Box style={{ transform: 'translateX(20px)' }} label="translateX(20px)" />
            <Box style={{ transform: 'translateY(20px)' }} label="translateY(20px)" />
            <Box style={{ transform: 'scale(1.2)' }} label="scale(1.2)" />
            <Box style={{ transform: 'rotate(15deg)' }} label="rotate(15deg)" />
            <Box style={{ transform: 'skewX(10deg)' }} label="skewX(10deg)" />
            <Box style={{ transform: 'skewY(10deg)' }} label="skewY(10deg)" />
            <Box style={{ transform: 'translate(10px, 10px) scale(0.9) rotate(10deg)' }} label="combined" />
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
