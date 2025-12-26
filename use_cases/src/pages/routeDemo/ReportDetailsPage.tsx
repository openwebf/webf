import React from 'react';
import { useParams, useLocation, WebFRouter } from '../../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const ReportDetailsPage: React.FC = () => {
  const params = useParams();
  const location = useLocation();
  const reportId = params.id ?? (params as any).reportId ?? location.state?.reportId;

  return (
    <WebFListView className="p-5 bg-surface-secondary rounded-xl mb-5 border border-line">
      <h1 className="text-2xl font-semibold mb-4 text-fg-primary">Report Details</h1>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Report Parameters:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <p className="mb-2 font-mono text-fg">
            <strong>Year:</strong> {params.year || 'Not provided'}
          </p>
          <p className="mb-2 font-mono text-fg">
            <strong>Month:</strong> {params.month || 'Not provided'}
          </p>
          <p className="mb-0 font-mono text-fg">
            <strong>Report ID:</strong> {reportId || 'Not provided'}
          </p>
        </div>
      </div>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Report Information:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <h3 className="text-sm mb-2 text-fg-secondary">Period</h3>
              <p className="text-base m-0 text-fg">
                {params.month || '--'}/{params.year || '--'}
              </p>
            </div>
            <div>
              <h3 className="text-sm mb-2 text-fg-secondary">Department</h3>
              <p className="text-base m-0 capitalize text-fg">{location.state?.department || 'Not specified'}</p>
            </div>
            <div>
              <h3 className="text-sm mb-2 text-fg-secondary">Format</h3>
              <p className="text-base m-0 uppercase text-fg">{location.state?.format || 'Not specified'}</p>
            </div>
            <div>
              <h3 className="text-sm mb-2 text-fg-secondary">Report ID</h3>
              <p className="text-base m-0 font-mono text-fg">{reportId || '--'}</p>
            </div>
          </div>
        </div>
      </div>

      <div className="mb-5">
        <h2 className="text-lg font-semibold mb-3 text-fg-primary">Navigation State:</h2>
        <div className="bg-surface-tertiary p-4 rounded-lg border border-line">
          <pre className="m-0 text-xs font-mono whitespace-pre-wrap text-fg">
            {JSON.stringify(location.state, null, 2)}
          </pre>
        </div>
      </div>

      <div className="flex">
        <button
          onClick={() => WebFRouter.pop()}
          className="bg-[#007aff] hover:bg-[#006fe6] text-white border-0 rounded-lg py-3 px-6 text-base cursor-pointer transition-colors active:scale-[.98]"
        >
          Back
        </button>
      </div>
    </WebFListView>
  );
};
