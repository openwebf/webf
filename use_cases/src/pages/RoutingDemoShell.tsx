import React, { PropsWithChildren } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';

export function RoutingDemoShell(
  props: PropsWithChildren<{
    title: string;
    description?: string;
  }>,
) {
  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="min-h-screen w-full px-3 md:px-6 py-6 box-border">
        <div className="bg-surface-secondary rounded-2xl border border-line p-5 mb-5">
          <div className="text-2xl font-semibold text-fg-primary mb-2">{props.title}</div>
          {props.description ? (
            <div className="text-sm text-fg-secondary leading-relaxed">{props.description}</div>
          ) : null}
        </div>

        <div className="rounded-2xl border border-line bg-surface-secondary p-4 md:p-6 box-border">
          {props.children}
        </div>
      </WebFListView>
    </div>
  );
}

