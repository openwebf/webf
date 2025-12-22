import React from 'react';
import { useLocation, WebFRouter } from '../../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const ProfileEditPage: React.FC = () => {
  const location = useLocation();

  return (
    <WebFListView className="p-5 bg-surface-secondary rounded-xl mb-5 border border-line">
      <h1 className="text-2xl font-semibold mb-4 text-fg-primary">Edit Profile</h1>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Deep Link Navigation Demo</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <p className="mb-2 text-fg-secondary">This page demonstrates direct deep-link navigation.</p>
          <p className="mb-0 text-fg-secondary">
            When you click "Back", it will pop back to the previous route (if any).
          </p>
        </div>
      </div>
        
      {location.state?.formData && (
        <div className="mb-5">
          <h2 className="text-lg font-semibold mb-3 text-fg-primary">Form Data:</h2>
          <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
            <p className="mb-2 font-mono text-fg">
              <strong>Name:</strong> {location.state.formData.name || 'Not provided'}
            </p>
            <p className="mb-2 font-mono text-fg">
              <strong>Email:</strong> {location.state.formData.email || 'Not provided'}
            </p>
            {location.state.formData.preferences && (
              <div className="mt-3">
                <p className="mb-2 font-semibold text-fg">Preferences:</p>
                <div className="pl-4">
                  <p className="mb-1 font-mono text-fg">
                    <strong>Theme:</strong> {location.state.formData.preferences.theme}
                  </p>
                  <p className="mb-0 font-mono text-fg">
                    <strong>Language:</strong> {location.state.formData.preferences.language}
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>
      )}

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Session Information:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          {location.state?.editMode !== undefined && (
            <p className="mb-2 font-mono text-fg">
              <strong>Edit Mode:</strong> {location.state.editMode ? 'Enabled' : 'Disabled'}
            </p>
          )}
          {location.state?.scrollPosition !== undefined && (
            <p className="mb-2 font-mono text-fg">
              <strong>Scroll Position:</strong> {location.state.scrollPosition}px
            </p>
          )}
          {location.state?.lastModified && (
            <p className="mb-0 font-mono text-fg">
              <strong>Last Modified:</strong> {new Date(location.state.lastModified).toLocaleString()}
            </p>
          )}
        </div>
      </div>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Complete State:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <pre className="m-0 text-xs font-mono whitespace-pre-wrap text-fg">
            {JSON.stringify(location.state, null, 2)}
          </pre>
        </div>
      </div>

      <button
        onClick={() => WebFRouter.pop()}
        className="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
      >
        Back
      </button>
    </WebFListView>
  );
};
