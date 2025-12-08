import React, { useRef } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterCupertinoButton, FlutterCupertinoModalPopup } from '@openwebf/react-cupertino-ui';
// Tailwind migration

export const ModalPopupPage: React.FC = () => {
  const basicPopupRef = useRef<any>(null);
  const customPopupRef = useRef<any>(null);
  const heightPopupRef = useRef<any>(null);
  const noMaskClosePopupRef = useRef<any>(null);
  const customStylePopupRef = useRef<any>(null);

  const shareItems = [
    { icon: 'pencil', label: 'Message' },
    { icon: 'mail_fill', label: 'Email' },
    { icon: 'link', label: 'Copy Link' },
    { icon: 'share', label: 'More' },
  ];

  const showBasicPopup = () => {
    basicPopupRef.current?.show();
  };

  const showCustomPopup = () => {
    customPopupRef.current?.show();
  };

  const showHeightPopup = () => {
    heightPopupRef.current?.show();
  };

  const showNoMaskClosePopup = () => {
    noMaskClosePopupRef.current?.show();
  };

  const hideNoMaskClosePopup = () => {
    noMaskClosePopupRef.current?.hide();
  };

  const showCustomStylePopup = () => {
    customStylePopupRef.current?.show();
  };

  const onPopupClose = () => {
    console.log('Popup closed');
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-3xl mx-auto py-6">
          <h1 className="text-2xl font-semibold text-fg-primary mb-4">Modal Popup</h1>
          <div className="flex flex-col gap-4">
            
            {/* Basic Usage */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicPopup}>
                Show Basic Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Content */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Custom Content</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomPopup}>
                Show Custom Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Height */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Custom Height</div>
              <FlutterCupertinoButton variant="filled" onClick={showHeightPopup}>
                Show 400px Height Popup
              </FlutterCupertinoButton>
            </div>

            {/* Disable Mask Close */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Disable Mask Close</div>
              <FlutterCupertinoButton variant="filled" onClick={showNoMaskClosePopup}>
                Show Non-maskClosable Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Style */}
            <div className="bg-surface-secondary border border-line rounded-xl p-4">
              <div className="text-lg font-medium text-fg-primary mb-2">Custom Style</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomStylePopup}>
                Show Custom Style Popup
              </FlutterCupertinoButton>
            </div>
          </div>

        {/* Basic Popup */}
        <FlutterCupertinoModalPopup
          ref={basicPopupRef}
          height={200}
          onClose={onPopupClose}
        >
          <div className="p-4">
            <div className="text-lg font-semibold text-fg-primary mb-1">Basic Popup</div>
            <div className="text-sm text-fg-secondary">This is a basic popup example</div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Custom Popup */}
        <FlutterCupertinoModalPopup
          ref={customPopupRef}
          height={300}
          onClose={onPopupClose}
        >
          <div className="p-4">
            <div className="text-lg font-semibold text-fg-primary mb-2">Share to</div>
            <div className="grid grid-cols-4 gap-3">
              {shareItems.map((item) => (
                <div key={item.icon} className="text-center">
                  <div className="text-sm text-fg-secondary">{item.label}</div>
                </div>
              ))}
            </div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Height Popup */}
        <FlutterCupertinoModalPopup
          ref={heightPopupRef}
          height={400}
          onClose={onPopupClose}
        >
          <div className="p-4">
            <div className="text-lg font-semibold text-fg-primary mb-1">Custom Height</div>
            <div className="text-sm text-fg-secondary">This popup has a height of 400px</div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* No Mask Close Popup */}
        <FlutterCupertinoModalPopup
          ref={noMaskClosePopupRef}
          height={250}
          maskClosable={false}
          backgroundOpacity={0.6}
          onClose={onPopupClose}
        >
          <div className="p-4">
            <div className="text-lg font-semibold text-fg-primary mb-1">Disable Mask Close</div>
            <div className="text-sm text-fg-secondary">
              This popup has disabled mask close functionality, can only be closed by other means
            </div>
            <div className="pt-3">
              <FlutterCupertinoButton variant="filled" onClick={hideNoMaskClosePopup}>
                Close
              </FlutterCupertinoButton>
            </div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Custom Style Popup */}
        <FlutterCupertinoModalPopup
          ref={customStylePopupRef}
          height={250}
          surfacePainted={false}
          backgroundOpacity={0.2}
          onClose={onPopupClose}
        >
          <div className="p-4">
            <div className="text-lg font-semibold text-fg-primary mb-1">Custom Style</div>
            <div className="text-sm text-fg-secondary">
              This is a custom styled popup example with disabled background and semi-transparent mask
            </div>
          </div>
        </FlutterCupertinoModalPopup>
      </WebFListView>
    </div>
  );
};
