import React, { useState, useEffect, useRef } from 'react';
import { FlutterCupertinoModalPopup } from '@openwebf/react-cupertino-ui';
import { registerGlobalModalListener, hideGlobalModal } from '../hooks/useGlobalModal';

export const GlobalModal: React.FC = () => {
  const popupRef = useRef<any>(null);
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');

  useEffect(() => {
    const unregister = registerGlobalModalListener((payload) => {
      if (payload) {
        setTitle(payload.title);
        setBody(payload.body);
        popupRef.current?.show();
      } else {
        popupRef.current?.hide();
      }
    });
    return unregister;
  }, []);

  return (
    <FlutterCupertinoModalPopup
      ref={popupRef}
      height={350}
      onClose={() => hideGlobalModal()}
    >
      <div style={{ padding: 24 }}>
        <div style={{ fontSize: 20, fontWeight: 600, marginBottom: 12 }}>{title}</div>
        <div style={{ fontSize: 14, color: '#666', whiteSpace: 'pre-line' }}>{body}</div>
      </div>
    </FlutterCupertinoModalPopup>
  );
};
