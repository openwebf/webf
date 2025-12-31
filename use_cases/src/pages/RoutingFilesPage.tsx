import React from 'react';
import { RoutingDemoShell } from './RoutingDemoShell';
import { RouterDemoFiles } from './RouterDemoFiles';

export const RoutingFilesPage: React.FC = () => {
  return (
    <RoutingDemoShell title="Routing Demo: Files">
      <RouterDemoFiles />
    </RoutingDemoShell>
  );
};

