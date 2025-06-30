import React, { useRef } from 'react';
import FlutterCupertinoButton from '../CustomElements/FlutterCupertinoButton';
import FlutterCupertinoModalPopup, { FlutterCupertinoModalPopupElement } from '../CustomElements/FlutterCupertinoModalPopup';
import WebFListView from '../CustomElements/WebFListView';

interface ShareItem {
  icon: string;
  label: string;
}

export default function ModalPopupDemo() {
  // Create refs for each popup
  const basicPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const customPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const heightPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const noMaskClosePopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const customStylePopupRef = useRef<FlutterCupertinoModalPopupElement>(null);

  // Share items for the custom popup
  const shareItems: ShareItem[] = [
    { icon: 'pencil', label: 'Message' },
    { icon: 'mail_fill', label: 'Email' },
    { icon: 'link', label: 'Copy Link' },
    { icon: 'share', label: 'More' },
  ];

  // Methods for showing popups
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
    <div id="main">
      <WebFListView id="list">
        <div className="component-section">
          <div className="section-title">Modal Popup</div>
          <div className="component-block">
            {/* Basic Usage */}
            <div className="component-item">
              <div className="item-label">Basic Usage</div>
              <FlutterCupertinoButton variant="filled" onClick={showBasicPopup}>
                Show Basic Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Content */}
            <div className="component-item">
              <div className="item-label">Custom Content</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomPopup}>
                Show Custom Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Height */}
            <div className="component-item">
              <div className="item-label">Custom Height</div>
              <FlutterCupertinoButton variant="filled" onClick={showHeightPopup}>
                Show 400px Height Popup
              </FlutterCupertinoButton>
            </div>

            {/* Disable Mask Close */}
            <div className="component-item">
              <div className="item-label">Disable Mask Close</div>
              <FlutterCupertinoButton variant="filled" onClick={showNoMaskClosePopup}>
                Show Non-maskClosable Popup
              </FlutterCupertinoButton>
            </div>

            {/* Custom Style */}
            <div className="component-item">
              <div className="item-label">Custom Style</div>
              <FlutterCupertinoButton variant="filled" onClick={showCustomStylePopup}>
                Show Custom Style Popup
              </FlutterCupertinoButton>
            </div>
          </div>
        </div>

        {/* Basic Popup */}
        <FlutterCupertinoModalPopup
          ref={basicPopupRef}
          height={200}
          onClose={onPopupClose}
        >
          <div className="popup-content" onClick={() => console.log('clicked')}>
            <div className="popup-title">Basic Popup</div>
            <div className="popup-text">This is a basic popup example</div>
          </div>
        </FlutterCupertinoModalPopup>

        {/* Custom Popup */}
        <FlutterCupertinoModalPopup
          ref={customPopupRef}
          height={300}
          onClose={onPopupClose}
        >
          <div className="popup-content">
            <div className="popup-title">Share to</div>
            <div className="share-grid">
              {shareItems.map((item, index) => (
                <div className="share-item" key={index}>
                  <div className="share-label">{item.label}</div>
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
          <div className="popup-content">
            <div className="popup-title">Custom Height</div>
            <div className="popup-text">This popup has a height of 400px</div>
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
          <div className="popup-content">
            <div className="popup-title">Disable Mask Close</div>
            <div className="popup-text">
              This popup has disabled mask close functionality, can only be closed by other means
            </div>
            <div className="popup-footer">
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
          <div className="popup-content custom-style">
            <div className="popup-title">Custom Style</div>
            <div className="popup-text">
              This is a custom styled popup example with disabled background and semi-transparent mask
            </div>
          </div>
        </FlutterCupertinoModalPopup>
      </WebFListView>
    </div>
  );
}
