import React, { useRef } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton, FlutterCupertinoLoading } from '@openwebf/react-cupertino-ui';

export const LoadingPage: React.FC = () => {
  const basicLoadingRef = useRef<any>(null);
  const textLoadingRef = useRef<any>(null);
  const autoHideLoadingRef = useRef<any>(null);
  const maskClosableLoadingRef = useRef<any>(null);

  const showBasicLoading = () => {
    basicLoadingRef.current?.show();
    setTimeout(() => {
      basicLoadingRef.current?.hide();
    }, 1000);
  };

  const showLoadingWithText = () => {
    textLoadingRef.current?.show({ text: 'Loading...' });
    setTimeout(() => textLoadingRef.current?.hide(), 1000);
  };

  const showAutoHideLoading = () => {
    autoHideLoadingRef.current?.show({ text: 'Processing...' });
    setTimeout(() => autoHideLoadingRef.current?.hide(), 2000);
  };

  const showMaskClosableLoading = () => {
    maskClosableLoadingRef.current?.show({ text: 'Click mask to close' });
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Loading</h1>
          <div className="flex flex-col gap-4">
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicLoading}>Show Loading</FlutterCupertinoButton>
            </div>

            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">With Text</div>
              <FlutterCupertinoButton variant="filled" onClick={showLoadingWithText}>Show Loading</FlutterCupertinoButton>
            </div>

            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Auto Hide</div>
              <FlutterCupertinoButton variant="filled" onClick={showAutoHideLoading}>Show Loading (Auto hide in 2s)</FlutterCupertinoButton>
            </div>

            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Mask Closable</div>
              <FlutterCupertinoButton variant="filled" onClick={showMaskClosableLoading}>Show Loading (Click mask to close)</FlutterCupertinoButton>
            </div>
          </div>

          <FlutterCupertinoLoading ref={basicLoadingRef} />
          <FlutterCupertinoLoading ref={textLoadingRef} />
          <FlutterCupertinoLoading ref={autoHideLoadingRef} />
          <FlutterCupertinoLoading ref={maskClosableLoadingRef} maskClosable />
      </WebFListView>
    </div>
  );
};
