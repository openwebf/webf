import React from 'react';
import { useParams, useLocation, WebFRouter } from '../../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const UserDetailsPage: React.FC = () => {
  const params = useParams();
  const location = useLocation();

  return (
    <WebFListView className="p-5 bg-surface-secondary rounded-xl mb-5 border border-line">
      <h1 className="text-2xl font-semibold mb-4 text-fg-primary">User Details</h1>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Route Parameters:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <p className="mb-2 font-mono text-fg">
            <strong>userId:</strong> {params.id || 'Not provided'}
          </p>
          {params.userType && (
            <p className="font-mono text-fg">
              <strong>userType:</strong> {params.userType}
            </p>
          )}
        </div>
      </div>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Location State:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <pre className="m-0 text-xs font-mono whitespace-pre-wrap text-fg">
            {JSON.stringify(location.state, null, 2)}
          </pre>
        </div>
      </div>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Current Path:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <p className="m-0 font-mono text-fg">{location.pathname}</p>
        </div>
      </div>

      <div className="flex flex-wrap gap-3">
        <button
          onClick={() => WebFRouter.pop()}
          className="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
        >
          Back
        </button>
        <button
          onClick={() => WebFRouter.pushState({}, '/user/888')}
          className="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
        >
          Go User Details 888
        </button>
      </div>
    </WebFListView>
  );
};
