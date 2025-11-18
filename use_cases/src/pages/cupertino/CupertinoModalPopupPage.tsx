import React, {useRef, useState} from 'react';
import {WebFListView} from '@openwebf/react-core-ui';
import {
  FlutterCupertinoButton,
  FlutterCupertinoModalPopup,
  FlutterCupertinoModalPopupElement,
} from '@openwebf/react-cupertino-ui';

export const CupertinoModalPopupPage: React.FC = () => {
  const basicPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const propsPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const noMaskPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);
  const styledPopupRef = useRef<FlutterCupertinoModalPopupElement>(null);

  const [lastClosed, setLastClosed] = useState<string | null>(null);

  const openBasic = () => {
    basicPopupRef.current?.show();
  };

  const openPropsDemo = () => {
    propsPopupRef.current?.show();
  };

  const openNoMask = () => {
    noMaskPopupRef.current?.show();
  };

  const openStyled = () => {
    styledPopupRef.current?.show();
  };

  const closeNoMask = () => {
    noMaskPopupRef.current?.hide();
  };

  const handleClose = (source: string) => {
    setLastClosed(source);
    console.log('popup closed', source);
  };

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <h1 className="text-2xl md:text-3xl font-semibold text-fg-primary mb-4">
          Cupertino Modal Popup
        </h1>
        <p className="text-fg-secondary mb-6">
          Use <code>FlutterCupertinoModalPopup</code> to present an iOS-style modal bottom sheet from WebF and Flutter.
          The popup is controlled imperatively via a <code>ref</code> with <code>show()</code> / <code>hide()</code>.
        </p>

        <div className={"flex"}>
          {/* Basic Popup instance */}
          <FlutterCupertinoModalPopup
            ref={basicPopupRef}
            height={250}
            onClose={() => handleClose('basic popup')}
          >
            <div className="bg-[skyblue] border">content</div>
          </FlutterCupertinoModalPopup>
        </div>

        {/* Quick Start */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Quick Start</h2>
          <p className="text-fg-secondary mb-4">
            Attach a ref to <code>FlutterCupertinoModalPopup</code> and
            call <code>show()</code> or <code>hide()</code>{' '}
            to control its visibility.
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
            <FlutterCupertinoButton variant="filled" onClick={openBasic}>
              Show Modal Popup
            </FlutterCupertinoButton>
            <p className="text-sm text-fg-secondary">
              Tap the button to show a simple modal popup. Dismiss it by tapping the mask or the close button inside.
            </p>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200">
              <pre className="text-sm overflow-x-auto">
                <code>{`import { useRef } from 'react';
import { FlutterCupertinoModalPopup } from '@openwebf/react-cupertino-ui';

export function ModalPopupExample() {
  const popupRef = useRef<FlutterCupertinoModalPopupElement | null>(null);

  const openPopup = () => {
    popupRef.current?.show();
  };

  const closePopup = () => {
    popupRef.current?.hide();
  };

  return (
    <>
      <button onClick={openPopup}>Show Popup</button>

      <FlutterCupertinoModalPopup
        ref={popupRef}
        height={250}
        onClose={() => console.log('popup closed')}
      >
        <div className="popup-content">
          <div className="popup-title">Modal Popup</div>
          <div className="popup-text">
            This content is rendered inside a Cupertino-style bottom sheet.
          </div>
          <button onClick={closePopup}>Close</button>
        </div>
      </FlutterCupertinoModalPopup>
    </>
  );
}`}</code>
              </pre>
          </div>
        </section>

        {/* Props Overview */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Props Overview</h2>
          <p className="text-fg-secondary mb-4">
            Configure the popup&apos;s height, background behavior, and surface styling with these props.
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
            <FlutterCupertinoButton variant="filled" onClick={openPropsDemo}>
              Show Props Demo
            </FlutterCupertinoButton>
            <p className="text-sm text-fg-secondary">
              This popup uses a fixed height, disables mask-close, and customizes the background opacity.
            </p>
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200 mb-4">
              <pre className="text-sm overflow-x-auto">
                <code>{`<FlutterCupertinoModalPopup
  ref={popupRef}
  height={300}
  maskClosable={false}
  surfacePainted
  backgroundOpacity={0.6}
/>`}</code>
              </pre>
          </div>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-2 text-sm text-fg-secondary">
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">visible?: boolean</code> – controls whether the
              popup is visible. In most cases you call <code>show()</code> / <code>hide()</code> on the ref instead of
              binding this directly.
            </div>
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">height?: number</code> – fixed height of the popup
              content in logical pixels. If omitted, the height is driven by its children.
            </div>
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">surfacePainted?: boolean</code> – whether the popup
              surface uses Cupertino background styling. Default: <code>true</code>.
            </div>
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">maskClosable?: boolean</code> – when{' '}
              <code>true</code>, tapping the background mask dismisses the popup. Default: <code>true</code>.
            </div>
            <div>
              <code className="bg-gray-100 px-2 py-0.5 rounded">backgroundOpacity?: number</code> – opacity of the
              background mask (0.0–1.0). Default: <code>0.4</code>.
            </div>
          </div>
        </section>

        {/* Imperative API & Events */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Imperative API & Events</h2>
          <p className="text-fg-secondary mb-4">
            The popup mirrors Flutter&apos;s <code>showCupertinoModalPopup</code> pattern and exposes imperative{' '}
            <code>show()</code> and <code>hide()</code> methods on the underlying WebF custom element.
          </p>

          <div className="bg-surface-secondary rounded-xl p-6 border border-line mb-4 space-y-4">
            <div className="flex flex-wrap gap-3">
              <FlutterCupertinoButton variant="tinted" onClick={openBasic}>
                Show via ref.show()
              </FlutterCupertinoButton>
            </div>
            <div className="text-sm text-fg-secondary">
              The <code>onClose</code> callback fires whenever the popup is dismissed, whether by mask tap, calling{' '}
              <code>hide()</code>, or system back gesture.
            </div>
            {lastClosed && (
              <div className="mt-2 text-xs px-3 py-2 rounded bg-blue-50 text-blue-800">
                Last closed: {lastClosed}
              </div>
            )}
          </div>

          <div className="bg-gray-50 rounded-lg p-4 border border-gray-200 mb-4">
              <pre className="text-sm overflow-x-auto">
                <code>{`// Show the popup
popupRef.current?.show();

// Hide the popup
popupRef.current?.hide();

// Listen for close events
<FlutterCupertinoModalPopup
  ref={popupRef}
  onClose={(event) => {
    // event is CustomEvent<void>
    console.log('popup closed', event);
  }}
>
  {/* content */}
</FlutterCupertinoModalPopup>`}</code>
              </pre>
          </div>
        </section>

        {/* Variants & Styling */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Variants & Styling</h2>
          <p className="text-fg-secondary mb-4">
            The popup content is rendered from its children. Use inner <code>div</code> elements with{' '}
            <code>className</code> / <code>style</code> to control layout and appearance.
          </p>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
              <h3 className="font-semibold text-fg-primary text-sm">Non-maskClosable Popup</h3>
              <p className="text-xs text-fg-secondary">
                Mask taps are ignored; the popup can only be closed from inside (e.g. via a button).
              </p>
              <FlutterCupertinoButton variant="filled" onClick={openNoMask}>
                Show non-maskClosable
              </FlutterCupertinoButton>
            </div>

            <div className="bg-surface-secondary rounded-xl p-6 border border-line space-y-3">
              <h3 className="font-semibold text-fg-primary text-sm">Custom Surface & Background</h3>
              <p className="text-xs text-fg-secondary">
                Disable Cupertino surface painting and use a lighter background mask to blend with the page.
              </p>
              <FlutterCupertinoButton variant="filled" onClick={openStyled}>
                Show custom styled popup
              </FlutterCupertinoButton>
            </div>
          </div>
        </section>

        {/* Notes */}
        <section className="mb-8">
          <h2 className="text-xl font-semibold text-fg-primary mb-3">Notes & Best Practices</h2>
          <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded text-sm text-gray-700 space-y-2">
            <p>
              This component is the WebF counterpart to Flutter&apos;s <code>showCupertinoModalPopup</code>, exposing a
              declarative container plus imperative <code>show()</code> / <code>hide()</code> API.
            </p>
            <p>
              Prefer method-based control via the ref instead of binding <code>visible</code> directly, unless you need
              a fully controlled React state pattern.
            </p>
            <p>
              For picker-style flows (date picker or custom pickers), nest the picker components as children of{' '}
              <code>FlutterCupertinoModalPopup</code> so they appear in a modal sheet.
            </p>
          </div>
          </section>
      </WebFListView>

      {/* Basic Popup instance */}
      <FlutterCupertinoModalPopup
        ref={basicPopupRef}
        height={250}
        onClose={() => handleClose('basic popup')}
      >
        <div className="p-4">
          <div className="text-lg font-semibold text-fg-primary mb-1">Modal Popup</div>
          <div className="text-sm text-fg-secondary mb-3">
            This content is rendered inside a Cupertino-style bottom sheet.
          </div>
          <FlutterCupertinoButton
            variant="tinted"
            onClick={() => basicPopupRef.current?.hide()}
          >
            Close
          </FlutterCupertinoButton>
        </div>
      </FlutterCupertinoModalPopup>

      {/* Props Demo Popup */}
      <FlutterCupertinoModalPopup
        ref={propsPopupRef}
        height={300}
        maskClosable={false}
        surfacePainted
        backgroundOpacity={0.6}
        onClose={() => handleClose('props demo')}
      >
        <div className="p-4">
          <div className="text-lg font-semibold text-fg-primary mb-1">Props Demo</div>
          <div className="text-sm text-fg-secondary mb-3">
            Fixed height, mask disabled, and dimmed background. Close via the primary action below.
          </div>
          <FlutterCupertinoButton
            variant="filled"
            onClick={() => propsPopupRef.current?.hide()}
          >
            Close
          </FlutterCupertinoButton>
        </div>
      </FlutterCupertinoModalPopup>

      {/* Non-maskClosable Popup */}
      <FlutterCupertinoModalPopup
        ref={noMaskPopupRef}
        height={260}
        maskClosable={false}
        backgroundOpacity={0.6}
        onClose={() => handleClose('non-maskClosable')}
      >
        <div className="p-4">
          <div className="text-lg font-semibold text-fg-primary mb-1">Non-maskClosable</div>
          <div className="text-sm text-fg-secondary mb-3">
            Tapping the backdrop will not dismiss this popup. Use the button below instead.
          </div>
          <FlutterCupertinoButton variant="filled" onClick={closeNoMask}>
            Close popup
          </FlutterCupertinoButton>
        </div>
      </FlutterCupertinoModalPopup>

      {/* Custom Styled Popup */}
      <FlutterCupertinoModalPopup
        ref={styledPopupRef}
        height={250}
        surfacePainted={false}
        backgroundOpacity={0.2}
        onClose={() => handleClose('custom styled')}
      >
        <div className="p-4 bg-white/90 backdrop-blur rounded-t-2xl">
          <div className="text-lg font-semibold text-fg-primary mb-1">Custom Styled Popup</div>
          <div className="text-sm text-fg-secondary">
            This popup disables the default Cupertino surface and uses a lighter, more transparent background mask.
          </div>
        </div>
      </FlutterCupertinoModalPopup>
    </div>
  );
};
